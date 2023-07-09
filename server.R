library(tm)
library(stringr)
library(shiny)

# load N-Grams saved previously
# not going to use unigram due to computational considerations

quadgram <- readRDS("quadgram.RData");
trigram <- readRDS("trigram.RData");
bigram <- readRDS("bigram.RData");
#unigram <- readRDS("unigram.RData");

nGramUsed <<- ""

predictNextWord <- function(input) {
  input <- removeNumbers(removePunctuation(tolower(input)))
  input <- strsplit(input, " ")[[1]]

  # Katz Back-Off Algorithm
  # 1. To predict the next word, 4-gram is first used 
  # 2. If no 4-gram is found, back off to 3-gram
  # 3. If no 3-gram is found, back off to 2-gram
  # 4. If no 2-gram is found, fall back to the most common word i.e. "the".
  
  
  if (length(input)>= 3) {
    input <- tail(input,3)
    if (identical(character(0),head(quadgram[quadgram$unigram == input[1] 
                          & quadgram$bigram == input[2] & quadgram$trigram == input[3], 4],1))){
        predictNextWord(paste(input[2],input[3],sep=" "))
    } else {
      nGramUsed <<- "4-Gram"
      head(quadgram[quadgram$unigram == input[1] & quadgram$bigram == input[2] 
                      & quadgram$trigram == input[3], 4],1)
    }
  }
  else if (length(input) == 2){
    input <- tail(input,2)
    if (identical(character(0),head(trigram[trigram$unigram == input[1] 
                                & trigram$bigram == input[2], 3],1))) {
        predictNextWord(input[2])
    } else {
      nGramUsed <<- "3-Gram"
      head(trigram[trigram$unigram == input[1] & trigram$bigram == input[2], 3],1)
    }
  } else if (length(input) == 1){
    input <- tail(input,1)
    if (identical(character(0),head(bigram[bigram$unigram == input[1], 2],1))) {
      nGramUsed <<-"No match found. Most common unigram 'the' is predicted."; 
      head("the",1)
    } else {
      nGramUsed <<- "2-Gram"
      head(bigram[bigram$unigram == input[1],2],1)
    }
  } else {
    nGramUsed <<- "No Input so far. So, the most common unigram 'the' is predicted."
    head("the", 1)
  }
}

shinyServer(function(input, output,session) {
  output$prediction <- renderPrint({
    result <- predictNextWord(input$inputString)
    output$text2 <- renderText({nGramUsed})
    result
  });
  
  output$text1 <- renderText({
    input$inputString});
}
)