# read in the data as a vector of strings
path <- "data01.txt"
con <- file(path, open="r")
lines <- readLines(con)
close(con)

# helper function to cut up the vector of lines
partition <- function(x, start, stop){
  x[start:stop]
}

# find where the new lines are, and also add the endpoints for easier iteration
blank_lines <- c(0, which(lines == ""), length(lines) + 1)

# create a list of string vectors
data <- lapply(2:length(blank_lines), function(i){
  partition(lines, blank_lines[i-1] + 1, blank_lines[i] - 1)
})

# convert each of the strings to integers
# everything in R is a vector operation, so as.integer(c("1", "2", "3")) just
# works. lapply will apply as.integer to each of the vectors, and return a list
data <- lapply(data, as.integer)
