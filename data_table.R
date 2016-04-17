rm(list = ls())
options(stringsAsFactors = FALSE)
library(data.table)
# set seed to an integer
set.seed(45L)

DT <- data.table(V1=c(1L,2L), V2=LETTERS[1:3], V3=round(rnorm(4),4), V4=1:12)

# GENERAL FORM: DT[i, j, by] subset rows using i, calculate j, group_by j

# =================================
# ROWS (i)
# =================================

# select third to fifth row
DT[3:5,]
# select 1st, 3rd, 5th rows
DT[c(1,3,5),]

# select rows that have column V2 == "A"
DT[V2 == "A", ]

# select rows that column V2 == A or V2 == C
DT[V2 %in% c("A", "C"),]

# =================================
# COLUMNS (J)
# =================================

# select a single column and return a vector
DT[,V2]
class(DT[,V2])

# same as above but do this as a data.table
# .() is an alias to a list.
DT[, .(V2)]

# return multiple columns
DT[, .(V2, V2)]

# return the sum of V1 as a vector
DT[, (sum(V1))]

# return the sum of the VA as a data.table
DT[, .(sum(V1))]

# aggregates for several columns
DT[, .(sum(V1), sd(V3))]

# same as the above but with new columns
DT[, .(aggregate = sum(V1), stan_dev = sd(V3))]

# columns get recycled if they are a different length
DT[, .(V1, sd(V3))]

# wrapping in curly braces allows multiple expressions
DT[,{print(V2) ;plot(V3); NULL}]

# same as above
DT[,{print(V2)
  plot(V3)
  NULL}]



























