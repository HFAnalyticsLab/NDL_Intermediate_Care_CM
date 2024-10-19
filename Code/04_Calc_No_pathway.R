library (data.table)

setwd(".../Projects/NDL4_intermediate_care")

# Read Cohort data
LCohort <- fread("data/KD_NDL_IC_LinkedCoreCohort_plus2.csv")

colnames(LCohort)

table(LCohort$NoICFlag)

# Create No pathway group
LCohort$NoICFlag <- ifelse(LCohort$ICFlag %in% c(4,5),3,0)
LCohort$NoICFlag <- ifelse(LCohort$IC_Pathways == 1,1,LCohort$NoICFlag)
LCohort$NoICFlag <- ifelse(LCohort$IC_Pathways == 2,2,LCohort$NoICFlag)
LCohort$NoICFlag <- ifelse(LCohort$IC_Pathways == 12,12,LCohort$NoICFlag)

LCohort <- LCohort[LCohort$ICFlag %in% c(1,4,5) ]

########### Totals
table(LCohort[, c('NoICFlag')],useNA = "ifany")

########### SEX
table(LCohort[ , c('Sex','NoICFlag')],useNA = "ifany")

########## Age Groups <60,..., 90+
LCohort$Age_Group <- ifelse(LCohort$Age<60,"under60","NA")
LCohort$Age_Group <- ifelse(LCohort$Age>59 & LCohort$Age<70,"60-69",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>69 & LCohort$Age<80,"70-79",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>79 & LCohort$Age<90,"80-89",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>89 ,"90+",LCohort$Age_Group)

table(LCohort[, c('Age_Group','NoICFlag')],useNA = "ifany")

########### LTC
table(LCohort[ , c('LTC_flag','NoICFlag')],useNA = "ifany")

########## Conditions
table(LCohort[ , c('Hypertension','NoICFlag')])
table(LCohort[ , c('Cancer','NoICFlag')])
table(LCohort[ , c('Diabetes','NoICFlag')])
table(LCohort[ , c('CVD','NoICFlag')])
table(LCohort[ , c('Heart_failure','NoICFlag')])
table(LCohort[ , c('CKD','NoICFlag')])
table(LCohort[ , c('Asthma','NoICFlag')])
table(LCohort[ , c('COPD','NoICFlag')])
table(LCohort[ , c('Depression','NoICFlag')])


########### Frailty Group
table(LCohort[ , c('FrailtyGroup','NoICFlag')],useNA = "ifany")

########### Frailty Group
table(LCohort[ , c('LoN','NoICFlag')],useNA = "ifany")

fwrite(LCohort, "data/KD_NDL_IC_LinkedCoreCohort_plus3.csv")

