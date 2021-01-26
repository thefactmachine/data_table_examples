rm(list = ls())
options(stringsAsFactors = FALSE)
library(data.table)
library(dplyr)

flights <- fread("data//flights14.csv")
flights %>% head()

# The melt and dcast functions for data.tables are for reshaping wide-to-long 
# and long-to-wide, respectively; the implementations are specifically 
# designed with large in-memory data (e.g. 10Gb) in mind.


s1 <- "family_id age_mother dob_child1 dob_child2 dob_child3
1         30 1998-11-26 2000-01-29         NA
2         27 1996-06-22         NA         NA
3         26 2002-07-11 2004-04-05 2007-09-02
4         32 2004-10-10 2009-08-27 2012-07-21
5         29 2000-12-05 2005-02-28         NA"

DT <- fread(s1)
DT

# ============================================================================
# wide to long
# ============================================================================

# we want each dob as a separate observation
# we are at 5 rows 
# we have three fields:
# => record count: 3 x 5 ==> 15 (include NA)
# column count (orig = 2) plus conversion (key and value = 2) (4 cols)
# dim(exp_table) ==> 15 x 4

DT_m1 <- melt(DT, id.vars = c("family_id", "age_mother"),
             measure.vars = c("dob_child1", "dob_child2", "dob_child3"))

DT_m1 %>% dim()

# By default, variable column is of type factor. Set variable.factor argument to 
# FALSE if you’d like to return a character vector instead.

# By default, variable column is of type factor. Set variable.factor argument 
# FALSE if you’d like to return a character vector instead.

DT_m1 


# ============================================================================
# long to wide
# ============================================================================
dcast(DT_m1, family_id + age_mother ~ variable, value.var = "value")

# ============================================================================
# Children in each family .....
# ============================================================================
dcast(DT_m1, family_id ~ ., fun.agg = 
        function(x) sum(!is.na(x)), value.var = "value")

# ============================================================================
# Advanced.....
# ============================================================================

s2 <- "family_id age_mother dob_child1 dob_child2 dob_child3 gender_child1 gender_child2 gender_child3
1         30 1998-11-26 2000-01-29         NA             1             2            NA
2         27 1996-06-22         NA         NA             2            NA            NA
3         26 2002-07-11 2004-04-05 2007-09-02             2             2             1
4         32 2004-10-10 2009-08-27 2012-07-21             1             1             1
5         29 2000-12-05 2005-02-28         NA             2             1            NA"
DT <- fread(s2)

DT

# ============


 # 6 rows for each key ==>  6 x 5 
DT_m1 = melt(DT, id = c("family_id", "age_mother"))
# Cols 2 key + 1 pair key val + 1 pair key value ==> 2 + 2 + 2 ==? 6
DT_m1 %>% dim()

set.seed(123)
DT_m1 %>% sample_n(10)

# the purpose of tstrsplit
c("dob_child1", "dob_child2", "gender_child1") %>% tstrsplit("_", fixed = TRUE)


DT_m1[, c("variable", "child") := tstrsplit(variable, "_", fixed = TRUE)] %>% 
  sample_n(10)

# stats::reshape is capable of performing 
# this operation in a very straightforward manner. 



DT.c1 = dcast(DT.m1, family_id + age_mother + child ~ variable, value.var = "value")
DT.c1



# ============================================================================
# Improved
# ============================================================================

DT

# "dob_child1" "dob_child2" "dob_child3"
colA = paste("dob_child", 1:3, sep = "")
colB = paste("gender_child", 1:3, sep = "")
lst_meas <- list(colA, colB)

DT_m2 = melt(DT, measure = list(colA, colB), value.name = c("dob", "gender"))
DT_m2

# ============================================================================
# Improved with patterns
# ============================================================================
DT_m3 = melt(DT, measure = patterns("^dob", "^gender"), value.name = c("dob", "gender"))
DT_m3

# ============================================================================
# Put humpty dumpty together again
# ============================================================================

# wide original
DT

# long
DT_m3

# long to wide how easy
DT_c2 = DT_m3 %>% dcast(family_id + age_mother ~ variable, value.var = c("dob", "gender"))
DT_c2
# ============================================================================
# ============================================================================
# ============================================================================
































