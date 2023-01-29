# Read lines of file
f <- "data01.txt"
fp <- file(f,open="r")
lines <- readLines(fp)
close(fp)

data <- list()  # Initialise a list of lists?
these_data <- c()  # Intialise a character list?
for (line in lines) {
    if (line == "") {
        ## data <- append(data, these_data)
        data[[length(data) + 1]] <- these_data  # Append the data?
        these_data <- c()  # Reset the character list
    } else {
        ## these_data <- append(these_data, strtoi(line, 10))
        these_data[[length(these_data) + 1]] <- strtoi(line, 10)
    }
}

# Get sums of each elf
## sums <- sapply(data, sum)
sums <- c()
## for (i in 1:length(data)) {
    ## contents <- data[i]
    ## print(typeof(contents))
    ## print(contents[1])
    ## sums[[length(sums) + 1]] <- sum(contents)
## }

print(sums)


