# =============================================================================
# ============================================================================

# Keys and fast binary search based on subset.

# https://cran.r-project.org/web/packages/data.table/vignettes/datatable-keys-fast-subset.html
# https://cran.r-project.org/web/packages/data.table/vignettes/


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
# all data.frames have a row names attribute. But these need to be unique

# we can subset a particular row using its row name as shown below
DF["C", ]

# data.frame
DF["C", ] %>% class()

# convert DF to DT
DT <- as.data.table(DF)

# the row names have been reset. Data.tables do not use row names. But as 
# they inherit from data.frames, it still has the row names attribute.
DT %>% row.names()

# instead data.tables use keys. Keys are supercharged row names

# we can set keys on multiple columns and the columns can be different types
# integer, numeric, character, factor

#duplicates in  keys are allowed

# setting a key does two things: 

# 1) physically reorders the rows of the data.table providing by
# reference -- always in increasing order. 

# 2) marks those columns as key columns by setting an attribute
# called sorted to the data.table.

# since the rows are reordered, a data.table can have at most one
# key because it cannot be sorted in more than one way.




# ==============================================
# set, get and use keys
# ==============================================
# set the column origin as key in the data.table flights.
setkey(flights, origin)
head(flights)

# Alternatively you can pass a character vector of column names to the function setkeyv().
# You can also set keys directly when creating data.tables using the 
# setkeyv(flights, "origin") # useful to program with
# data.table() function using key argument. It takes a character vector of column names.

# In data.table, the := operator and all the set* (e.g., setkey, setorder, 
# setnames etc..) functions are the only ones which modify the input object by reference.


# := function we saw in the “Introduction to data.table”

# Once you key a data.table by certain columns, 
# you can subset by querying those key columns using the .() notation 
# in i.

# this uses the key column origin
flights[.("JFK")]

# On single column key of character type, you can drop the .() notation
# can do multiple columns

# The row indices corresponding to the value “JFK” in origin is obtained first. 
# And since there is no expression in j, 
# all columns corresponding to those row indices are returned.

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

# row is i
# column is j

# now subset where the first key matches "JFK"
lst_ss <- list("JFK")
flights[lst_ss] 

# now subset where all rows just match the second column
flights[.(unique(origin), "MIA")]
    
lst_second_parameter <- list(unique(flights$origin), "MIA")
flights[lst_second_parameter]

# =============================================
# Combining keys with i and j =================
# =============================================

# this shouldn't be a surprise
flights[.("LGA", "TPA"), .(arr_delay, distance)]

# now chaining to order the column in decreasing order
flights[.("LGA", "TPA"), .(arr_delay, distance)][order(-arr_delay)]

flights[.("LGA", "TPA"), max(arr_delay)]


# =============================================
# sub-assign by reference using := in j =======
# =============================================
flights[, sort(unique(hour))]

setkey(flights, hour)
key(flights)
# hour == 24
flights[.(24), ] %>% head()

# set all hour = 24 to 0 ==> no need to re-assign
flights[.(24), hour := 0L] 

# we have changed our key column ... now it will be NULL
key(flights)

# =============================================
# aggregation using by ========================
# =============================================
setkey(flights, origin, dest)

# the "keyby" to automatically key the result by month  - it orders as well
ans <- flights["JFK", max(dep_delay), keyby = month]
ans

# =============================================
# mult and nomatch ============================
# =============================================

# return first row -- can have 'last', 'all'
flights[.("JFK", "MIA"), mult = "first"]

# origin = LGA, JFK, EWR ...dest = XNA should last
# JFK & XNA does not match any rows and therefore returns NA
flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last"]

# subset only if there is a match
flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", nomatch = NULL]


# =============================================
# binary search vs vector scan ================
# =============================================

# to use the slow vector scan.. key needs to be removed
setkey(flights, NULL)
flights[origin == "JFK" & dest == "MIA"]

# set up a table with 20 million rows
set.seed(2L)
N = 2e7L
DT = data.table(x = sample(letters, N, TRUE),
                y = sample(1000L, N, TRUE),
                val = runif(N))
print(object.size(DT), units = "Mb")

# usual way of subsetting
t1 <- system.time(ans1 <- DT[x == "g" & y == 877L])
t1

# now set keys
setkeyv(DT, c("x", "y"))
key(DT)

t2 <- system.time(ans2 <- DT[.("g", 877L)])
t2

# we can use binary search which results in 0(log, n) as 
# opposed to 0(n).  We can so this as the data is pre-sorted.
