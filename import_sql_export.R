# Purpose:     Sample code for reading in data, using SQL in R, and exporting
# Programmer:  Ben Porter
# Date:        2/3/2014
# github link: https://github.com/benporter/R-import-sql-export/tree/master

# Load Libraries
library(XLConnect) #needed if using the readWorksheetFromFile() or writeWorksheetToFile() function
library(xlsx)      #needed if using the read.xlsx() function
library(sqldf)     #needed if using the sqldf() function

############################
# Part 1: Reading in Data
############################

# prints the current working directory
getwd()

# sets the current working directory
setwd("C:/Users/nbkznwu/Documents/R/QMAP Training Course/sample files/SAT Data/")
getwd()

#lists out the files in the current working directory
list.files()

# Import 1: XLConnect method for reading in .XLSX files
df <- readWorksheetFromFile(file="SAT Scores 2012 by State.xlsx",
                            sheet = "rdata",
                            header = TRUE)

# Import 2: xlsx library method for reading in .XLSX files
df <- read.xlsx(file="SAT Scores 2012 by State.xlsx",
                sheetName="rdata")

# Import 3: CSV files (no additional packages needed)
df <- read.csv(file="SAT Scores 2012 by State.csv")

# Import 4: TXT files, tab delimited
df <- read.table(file="SAT Scores 2012 by State.txt",
                 header=TRUE,
                 sep="\t")

###########################################
# Part 2: Inspect and Clean Up the Data
###########################################

#inspect data
nrow(df) # number of rows
ncol(df) # number of columns
head(df) # first 6 rows
tail(df) # last 6 rows
df       # prints entire dataset

# counts the number of missing values for each column
sapply(df, function(x) sum(is.na(x)))

# counts the number of null values for each column
sapply(df, function(x) sum(is.null(x)))

# counts the number of empty string values for each column
sapply(df, function(x) sum(x==""))

# compute summary statistics on each column
summary(df)

# SQL doesn't like periods in column names, so use gsub() to replace . with _
colnames(df)
colnames(df) <- gsub(colnames(df),pattern=".",replacement="_",fixed = TRUE)
colnames(df)

###########################################
# Part 3: Use SQL Against the Data
###########################################

# Notes:
# sqldf uses sqlite syntax
# use double quotes around the entire sql statement and single quotes around strings

# Count the number of records
sqldf("select count(*) as record_count
      from df")

# get a string of the column names, comma separated
columnList <- paste(colnames(df),collapse=", ")
columnList

# count the unique number of records
# example of a sub-query and example of using variables in the query using the paste() function
sqldf(paste("select count(*)
            from ( select count(*) as record_count
            from df
            group by " , columnList,
            ")"
            )
)

# create a table, called df_nc where ST=NC
df_nc <- sqldf("select *,
               1 as beststate
               from df
               where State='North Carolina'")

# left join example, orginal dataset and NC datatset
df_joined <- sqldf("select df.*,
                   df_nc.beststate
                   from df
                   left join
                   df_nc on df.State=df_nc.State")

# case logic example, used to change NA's to 0's
df_joined <- sqldf("select *,
                      case when beststate = 1 then 1
                      else 0
                    end as beststate_cleaned
                    from df_joined")

###########################################
# Part 4: Export the data
###########################################

# XLConnect library method to write an .XLSX file
writeWorksheetToFile(file = "SAT_output_file.xlsx",
                     data = df_joined,
                     sheet = "CustomTabName",
                     startRow = 1)

# Built-in method to write a .CSV file
write.table(x=df_joined,
            file = "SAT_output_file.csv",
            sep = ",")

# Built-in method to write a tab delimited .txt file
write.table(x=df_joined,
            file = "SAT_output_file.txt",
            sep = "\t")