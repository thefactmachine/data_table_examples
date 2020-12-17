

rm(list = ls())
options(stringsAsFactors = FALSE)
library(data.table)
library(dplyr)

flights <- fread("data//flights14.csv")
flights %>% head()

# filtering
flights[origin == "JFK" & month == 6L]
flights[1:2]


# this returns a vector
flights[, arr_delay] %>% class()


# this returns a data.table
flights[, list(arr_delay)] %>% class()

# this is a synonym to a list
flights[, .(arr_delay, dep_delay)] %>% head()

# rename the columns
flights[, .(arr_delay = arr_delay, deo_delay = dep_delay)] %>% head()


# how many trips had a total delay that was minus  (arrived before or departed before)
# prints one line
flights[, sum((arr_delay + dep_delay) < 0)]

# what is the average delay for JFK origin flights in June
# one row here
flights[origin == "JFK" & month == 6L,  .(delay = mean(dep_delay))]

### Data table can optimise
# Because the three i, j and by are inside [...] data.table can optimise
# the query before evaluation...rather than each separately...


### Counting things -- the .N operator
#  one row here
flights[origin == "JFK" & month == 6L, .N]


# the following with = FALSE allows us to use data.frame syntax

# I cant see the difference here...
flights[1:4, c("arr_delay", "dep_delay"), with = FALSE]

flights[1:4, c("arr_delay", "dep_delay"), with = FALSE]

flights[1:4, c("arr_delay", "dep_delay"), with = TRUE] 

flights[order(origin, -dest)] %>% head()

# =======================================================================

# beyond the basics...................................
#  https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html)

# beyond the basics....
flights$origin %>% unique()

# basic group by
flights[, .(.N), by = .(origin)]

# how to name the aggregation column
flights[, .(count = .N), by = .(origin)]

# how to name the grouping column
flights[, .(count = .N), by = .(leaving_place = origin)]

# grouping by two variables
flights[, .(.N), by = c("origin", "dest")]

# with list syntax
flights[, .(.N), by = .(origin, dest)]

# with named list syntax
flights[, .(count = .N), by = .(leave = origin, arrive = dest)]

flights[carrier == "AA", .(count = .N ), by = origin]


### Sorting groups using keyby
#  Data.table retains the original order of groups. This is intentional
#  and by design.  But at times we would automatically like to sort
# by the variables that we grouped by.  "keyby" lets us sort by
# groups **Use keyby to sort groups instead of key**

# see here ... order is origin / destination
flights[carrier == "AA", .(delay = mean(arr_delay)), keyby = .(origin, dest)] 

# cant see the difference here
flights[carrier == "AA", .(delay = mean(arr_delay)), key = .(origin, dest)] 

# chaining ... we can keep tacking on expressions....

# step 1
flights[carrier == "AA", .(count = .N), by = .(origin, dest)]

# step 2 sort by count (descending order)
flights[carrier == "AA", .(count = .N), by = .(origin, dest)][order(-count)][1:4]

# ======================
# Expressions in group by

# returns 4 rows
flights[, .N, .(dep_delay > 0, arr_delay > 0)]

# same result as above...
flights[, .N, by = .(dep_delay > 0, arr_delay > 0)]


## Special symbol .SD
# set up a data.frame for the following
vct_id <- c("b", "b", "b", "a", "a", "c")
vct_a <- c(1, 2, 3, 4, 5, 6)
vct_b <- c(7, 8, 9, 10, 11, 12)
vct_c <- c(13, 14, 15, 16, 17, 18)
DT <- data.table(ID = vct_id, a = vct_a, b = vct_b, c = vct_c)
DT

# .SD stands for subset of data.  
# It by itself is a data.frame that holds the data 
# for the current group defined using "by"

# this prints columns a,b,c for each group
DT[, print(.SD), by = ID]

# calculate the mean for 3 columns for each group
# this applies the mean to all columns....
DT[, lapply(.SD, mean), by = ID]


# 24 rows here
# the .SDcols specifies which columns to apply the aggregate function
# there are two here....
# if we do not specify the .SDcols...the function is applied to all
# columns....
flights[carrier == "AA",
        lapply(.SD, mean),
        by = .(origin, dest),
        .SDcols = c("arr_delay", "dep_delay")]


# show the first two entries for each month
flights[, head(.SD, 2), by = origin]


DT[, .(val = c(a,b)), by = ID] 

## We will see how to add/update/delete columns by reference and how to combine them with i and by in the next vignette.
#  https://cran.r-project.org/web/packages/data.table/vignettes/datatable-keys-fast-subset.html



rm(list = ls())
options(stringsAsFactors = FALSE)
library(data.table)
library(dplyr)

flights <- fread("data//flights14.csv")

set.seed(1L)
DF = data.frame(ID1 = sample(letters[1:2], 10, TRUE),
                ID2 = sample(1:3, 10, TRUE),
                val = sample(10),
                stringsAsFactors = FALSE,
                row.names = sample(LETTERS[1:10]))

rownames(DF)

# we can subset a particular row using its row name as shown below
DF["C", ]

# we can set keys on multiple columns and the columns can be different types
# integer, numeric, character, factor

#duplicate keys are allowed

# setting a key does two things: 
# 1) physically reorders the rows of the data.table providing by
# reference -- always in increasing order. 

# 2) marks those columns as key columns by setting an attribute
# called sorted to the data.table.

# since the rows are reordered a data.table can have at most one
# key because it cannot be sorted in more than one way.

ls()

# set the column origin as key in the data.table flights.
setkey(flights, origin)
head(flights)

## alternatively we can provide character vectors to the function 'setkeyv()'
# setkeyv(flights, "origin") # useful to program with

setkeyv(flights, "origin") 

# := function we saw in the “Introduction to data.table”

# You can also set keys directly when creating data.tables using the data.table()
# function using key argument. It takes a character vector of column names.

# Once you key a data.table by certain columns, 
# you can subset by querying those key columns using the .() notation 
# in i.

# this uses the key column origin
flights[.("JFK")]

# On single column key of character type, you can drop the .() notation

# can do multiple columns
flights[c("JFK", "LGA")] 
## same as flights[.(c("JFK", "LGA"))]

# finding out what columns the data.table is keyed by
key(flights)

# =============================================
# Keys and multiple columns ===================
# =============================================

setkey(flights, origin, dest)

# or alternately
# setkeyv(flights, c("origin", "dest")

key(flights)

# subset where first col = JFK and 2 col = MIA
flights[.("JFK", "MIA")]





































