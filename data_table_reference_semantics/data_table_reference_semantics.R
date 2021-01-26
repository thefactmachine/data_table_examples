

rm(list = ls())
options(stringsAsFactors = FALSE)
library(data.table)
library(dplyr)

flights <- fread("data//flights14.csv")
flights %>% head()


# Plan:
# 1) two forms of :=
# 2) update, add, delete columns
# 3) combine with i and by
# 4) side effects of :=

DF = data.frame(ID = c("b","b","b","a","a","c"), a = 1:6, b = 7:12, c = 13:18)
DF

# the code "DF$C <- 18:13" resulted in a deep copy. The entire data.frame 
# was copied. A deep copy copies the data to another location in memory.
# A shallow copy is copy of the vector of column pointers. The data.table
# := operator prevents a shallow and deep copy.

# ======================================================================
# Two forms of :=
# ======================================================================

# 1) the LHS / RHS takes a character vector of column names and a RHS list
# of values. 

# DT[, c("colA", "colB", ...) := list(valA, valB, ...)]


# 2) functional form (see below) [not going to do]

# DT[, `:=`(colA = valA, # valA is assigned to colA
#           colB = valB, # valB is assigned to colB
#           ...
# )]

# WE DONT NEED TO ASSIGN THE RESULTS BACK TO A VARIABLE ==============

flights[, c("speed", "delay") := 
          list(distance / (air_time / 60), arr_delay + dep_delay)]

flights %>% head()

# functional form (can add comments)
# flights[, `:=`(speed = distance / (air_time/60), # speed in mph (mi/h)
#                delay = arr_delay + dep_delay)]   # delay in minutes

# sub-assign by reference
flights[hour == 24L, hour := 0L]

# When we want to see the result -- add brackets
flights[hour == 0L, hour := 24L][]

# ======================================================================
flights[, c("delay") := NULL][]

# functional form
# flights[, `:=`(delay = NULL)]

# ======================================================================

# Using with By
flights[, max_speed := max(speed), by = .(origin, dest)]
flights %>% sample_n(20)

# ======================================================================
# How can we add two more columns, computing max() of dep_delay and 
# arr_delay for each month, using .SD
# ======================================================================
# GREAT PIECE OF CODE

in_cols <- c("dep_delay", "arr_delay")
out_cols <- c("max_dep_delay", "max_arr_delay")

flights[, c(out_cols) := lapply(.SD, max), by = month, .SDcols = in_cols]

flights %>% sample(10)

# get rid of previous columns
flights[, c("speed", "max_speed", "max_dep_delay", "max_arr_delay") := NULL]
# ======================================================================
# := and copy()
# ======================================================================

foo <- function(DT) {
  # add speed and and max_speed
  DT[, speed := distance / (air_time/60)]
  DT[, .(max_speed = max(speed)), by = month]
}

ans = foo(flights)

# only speed updated here.
head(flights)

# this has got both speed and max_speed
head(ans)

# dont know why there is a difference. ......................

# Sometimes, we would like to pass a data.table object to a function and might
# want to use the := operator, but don't want to update the original object.
# we can do this with the copy() operator.

# first delete the speed column
flights[, speed := NULL]

foo <- function(DT) {
  DT <- copy(DT)                              ## deep copy
  DT[, speed := distance / (air_time/60)]     ## doesn't affect 'flights'
  DT[, .(max_speed = max(speed)), by = month]
}
ans <- foo(flights)
head(flights)

head(ans)


























