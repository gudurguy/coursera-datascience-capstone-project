# java options for memory usage
options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx8192m"))

# Preload required R librabires
library(tm)
library(RWeka)
library(R.utils)
library(dplyr)
library(parallel)

set.seed(5432)

sampleDataFile <- "sampleData.txt"

# for memory concerns, if the sample file is already there no need to read the source files again
if(!file.exists(sampleDataFile)) {

con1 <- file("../inputData/en_US.twitter.txt", open = "rb")
twitter <- readLines(con1, skipNul = TRUE, encoding="UTF-8")
close(con1)

con2 <- file("../inputData/en_US.news.txt", open = "rb")
news <- readLines(con2, skipNul = TRUE, encoding="UTF-8")
close(con2)

con3 <- file("../inputData/en_US.blogs.txt", open = "rb")
blogs <- readLines(con3, skipNul = TRUE, encoding="UTF-8")
close(con3)

# sampling text files 

samplePercent <- .01

blogsSampl <- blogs[as.logical(rbinom(length(blogs),1,samplePercent))]
newsSampl <- news[as.logical(rbinom(length(news),1,samplePercent))]
twitterSampl <- twitter[as.logical(rbinom(length(twitter),1,samplePercent))]

# combine sampled texts into one 
sampleData <- c(blogsSampl, newsSampl, twitterSampl)

# write sampled texts into text files for further analysis
writeLines(sampleData, "sampleData.txt")

}

# Data Cleaning

# the corpus will be converted to lowercase, strip white space, and removed punctuation and numbers etc.
# along with removing profanities

buildCorpus <- function (sampleData) {
  # profanities file
  profFile <- "full-list-of-bad-words_text-file_2022_05_05.txt"

  # start creating a clean corpus
  sampleCorpus <- VCorpus(VectorSource(sampleData))
  
  # remove all the heavy objects as we can work with sample data going forward
  rm(blogs, news, twitter, blogsSampl, newsSampl, twitterSampl, sampleData)
  
  # to lower case
  sampleCorpus <- tm_map(sampleCorpus, content_transformer(tolower))
  
  # remove profane words
  con <- file(profFile, open = "r")
  profanities <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
  sampleCorpus <- tm_map(sampleCorpus, removeWords, profanities)
  close(con)

  # remove numbers
  sampleCorpus <- tm_map(sampleCorpus, removeNumbers)
  # remove punctuation
  sampleCorpus <- tm_map(sampleCorpus, removePunctuation)
  # removing stray letters 
  sampleCorpus <- tm_map(sampleCorpus, removeWords, letters)
  # strip extra white space
  sampleCorpus <- tm_map(sampleCorpus, stripWhitespace)
}

# if corpus was already created and saved already use that, if not create it.
# this is a memory intesive operation hence saving all this work.

if(!file.exists("corpus.RData")) {  

# get sample file
con4 <- file(sampleDataFile, open = "rb")
sampleData <- readLines(con4, skipNul = TRUE, encoding="UTF-8")
close(con4)

# clean it 
sampleCorpus <- buildCorpus(sampleData)
saveRDS(sampleCorpus, "corpus.RData")
} else {  
  sampleCorpus <- readRDS("corpus.RData")
}

# function to tokenize and generate N-grams
buildNgramTDM <- function (sampleCorpus, n) {
  ngramTokenizer <- function(x) {NGramTokenizer(x, Weka_control(min = n, max = n))}
  ngramTDM <- TermDocumentMatrix(sampleCorpus, control = list(tokenizer = ngramTokenizer))
  ngramTDM
}


# genearate N-Grams

tdm2gram <- buildNgramTDM(sampleCorpus, 2)

tdm3gram <- buildNgramTDM(sampleCorpus, 3)

tdm4gram <- buildNgramTDM(sampleCorpus, 4)

rm(sampleCorpus)

# function to extract and sort N-Grams
ngram_sorted_df <- function (ngramTDM) {
  ngramTDMM <- as.matrix(ngramTDM)
  ngramTDMDf <- as.data.frame(ngramTDMM)
  colnames(ngramTDMDf) <- "Count"
  ngramTDMDf <- ngramTDMDf[order(-ngramTDMDf$Count), , drop = FALSE]
  ngramTDMDf
}



# extract and sort N-Grams

tdm2gramDf <- ngram_sorted_df(tdm2gram)
rm(tdm2gram)

tdm3gramDf <- ngram_sorted_df(tdm3gram)
rm(tdm3gram)

tdm4gramDf <- ngram_sorted_df(tdm4gram)
rm(tdm4gram)

# save generate n-grams into files for further use

quadgram <- data.frame(rows=rownames(tdm4gramDf),count=tdm4gramDf$Count)
quadgram$rows <- as.character(quadgram$rows)
quadgram_split <- strsplit(as.character(quadgram$rows),split=" ")
quadgram <- transform(quadgram,first = sapply(quadgram_split,"[[",1),second = sapply(quadgram_split,"[[",2),third = sapply(quadgram_split,"[[",3), fourth = sapply(quadgram_split,"[[",4))
rm(quadgram_split)
quadgram <- data.frame(unigram = quadgram$first,bigram = quadgram$second, trigram = quadgram$third, quadgram = quadgram$fourth, freq = quadgram$count,stringsAsFactors=FALSE)
saveRDS(quadgram,"quadgram.RData")
rm(tdm4gramDf)
rm(quadgram)

trigram <- data.frame(rows=rownames(tdm3gramDf),count=tdm3gramDf$Count)
trigram$rows <- as.character(trigram$rows)
trigram_split <- strsplit(as.character(trigram$rows),split=" ")
trigram <- transform(trigram,first = sapply(trigram_split,"[[",1),second = sapply(trigram_split,"[[",2),third = sapply(trigram_split,"[[",3))
rm(trigram_split)
trigram <- data.frame(unigram = trigram$first,bigram = trigram$second, trigram = trigram$third, freq = trigram$count,stringsAsFactors=FALSE)
saveRDS(trigram,"trigram.RData")
rm(tdm3gramDf)
rm(trigram)


bigram <- data.frame(rows=rownames(tdm2gramDf),count=tdm2gramDf$Count)
bigram$rows <- as.character(bigram$rows)
bigram_split <- strsplit(as.character(bigram$rows),split=" ")
bigram <- transform(bigram,first = sapply(bigram_split,"[[",1),second = sapply(bigram_split,"[[",2))
rm(bigram_split)
bigram <- data.frame(unigram = bigram$first,bigram = bigram$second,freq = bigram$count,stringsAsFactors=FALSE)
saveRDS(bigram,"bigram.RData")
rm(tdm2gramDf)
rm(bigram)

