library (data.table)

setwd(".../Projects/NDL4_intermediate_care")

# Read Cohort data
LCohort <- fread("data/KD_NDL_IC_LinkedCoreCohort_plus.csv")

### Create Levels of Need
### 7days
LCohort$LoN <- ifelse(LCohort$Spell_LoS<8 & LCohort$FrailtyGroup %in% c(1,2),1,0)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>7 & LCohort$FrailtyGroup %in% c(1,2),2,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS<8 & LCohort$FrailtyGroup %in% c(3,4),3,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>7 & LCohort$FrailtyGroup %in% c(3),3,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>7 & LCohort$FrailtyGroup == 4,4,LCohort$LoN)
table(LCohort[ , c('LoN','ICFlag')],useNA = "ifany")
table(LCohort[ , c('LoN','IC_Pathways')],useNA = "ifany")

### 14days
LCohort$LoN <- ifelse(LCohort$Spell_LoS<15 & LCohort$FrailtyGroup %in% c(1,2),1,0)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>14 & LCohort$FrailtyGroup %in% c(1,2),2,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS<15 & LCohort$FrailtyGroup %in% c(3,4),3,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>14 & LCohort$FrailtyGroup %in% c(3),3,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>14 & LCohort$FrailtyGroup == 4,4,LCohort$LoN)
table(LCohort[ , c('LoN','ICFlag')],useNA = "ifany")
table(LCohort[ , c('LoN','IC_Pathways')],useNA = "ifany")

table(LCohort[ , c('LoN','IC_Pathways')],useNA = "ifany")

### 21days
LCohort$LoN <- ifelse(LCohort$Spell_LoS<22 & LCohort$FrailtyGroup %in% c(1,2),1,0)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>21 & LCohort$FrailtyGroup %in% c(1,2),2,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS<22 & LCohort$FrailtyGroup %in% c(3,4),3,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>21 & LCohort$FrailtyGroup %in% c(3),3,LCohort$LoN)
LCohort$LoN <- ifelse(LCohort$Spell_LoS>21 & LCohort$FrailtyGroup == 4,4,LCohort$LoN)
table(LCohort[ , c('LoN','ICFlag')],useNA = "ifany")
table(LCohort[ , c('LoN','IC_Pathways')],useNA = "ifany")

table(LCohort[ , c('LoN','IC_CSDS')],useNA = "ifany")
table(LCohort[ , c('LoN','IC_ASC')],useNA = "ifany")

########### Totals
table(LCohort[LCohort$ICFlag == 1 , c('LoN')],useNA = "ifany")

########### SEX
table(LCohort[LCohort$ICFlag == 1 , c('Sex','LoN')],useNA = "ifany")

########## Age Groups <60,..., 90+
LCohort$Age_Group <- ifelse(LCohort$Age<60,"under60","NA")
LCohort$Age_Group <- ifelse(LCohort$Age>59 & LCohort$Age<70,"60-69",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>69 & LCohort$Age<80,"70-79",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>79 & LCohort$Age<90,"80-89",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>89 ,"90+",LCohort$Age_Group)

table(LCohort[LCohort$ICFlag == 1 , c('Age_Group','LoN')],useNA = "ifany")

########### LTC
table(LCohort[LCohort$ICFlag == 1 , c('LTC_flag','LoN')],useNA = "ifany")

########### Frailty Group
table(LCohort[LCohort$ICFlag == 1 , c('FrailtyGroup','LoN')],useNA = "ifany")

########### IC LoS
LC_IC <- LCohort[LCohort$ICFlag == 1,]
LC_IC$CSDS_LoS <- as.numeric(difftime(LC_IC$Contact_End_Date,LC_IC$Contact_Start_Date, units = "days"))
LC_IC$CSDS_LoS <- ifelse(LC_IC$CSDS_LoS==0,1,LC_IC$CSDS_LoS)
LC_IC$ASC_LoS <- as.numeric(difftime(LC_IC$Event_End_Date,LC_IC$Event_Start_Date, units = "days"))
LC_IC$ASC_LoS <- ifelse(LC_IC$ASC_LoS==0,1,LC_IC$ASC_LoS)
LC_IC$IC_LOS <- LC_IC$CSDS_LoS
LC_IC$IC_LOS <- ifelse(!is.na(LC_IC$ASC_LoS),LC_IC$ASC_LoS,LC_IC$IC_LOS)
LC_IC$IC_LOS <- ifelse(!is.na(LC_IC$ASC_LoS)&!is.na(LC_IC$CSDS_LoS),(LC_IC$ASC_LoS + LC_IC$CSDS_LoS),LC_IC$IC_LOS)


mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_LOS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_LOS,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_LOS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_LOS,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_LOS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_LOS,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_LOS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_LOS,na.rm = T)

########### Contacts
LC_IC$IC_CE <-LC_IC$Contact_Counts
LC_IC$IC_CE <- ifelse(!is.na(LC_IC$Event_Counts),LC_IC$Event_Counts,LC_IC$IC_CE)
LC_IC$IC_CE <- ifelse(!is.na(LC_IC$Event_Counts)&!is.na(LC_IC$Contact_Counts),(LC_IC$Event_Counts + LC_IC$Contact_Counts),LC_IC$IC_CE)


mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_CE,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_CE,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_CE,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_CE,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_CE,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_CE,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_CE,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_CE,na.rm = T)


############ Intensity
LC_IC$IC_Intensity <-0
LC_IC$IC_Intensity <- LC_IC$IC_LOS/LC_IC$IC_CE

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_Intensity,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_Intensity,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_Intensity,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_Intensity,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_Intensity,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_Intensity,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_Intensity,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_Intensity,na.rm = T)

############# Hospital Admission
mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$Spell_LoS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$Spell_LoS,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$Spell_LoS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$Spell_LoS,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$Spell_LoS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$Spell_LoS,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$Spell_LoS,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$Spell_LoS,na.rm = T)

############# Re-admissions
# 30 days
LC_IC$IC_RAdm30_cnt <- ifelse(!is.na(LC_IC$R_Adm30_Count),1,0)
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_RAdm30_cnt','LoN')],useNA = "ifany")
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_RAdm30_cnt')],useNA = "ifany")

LC_IC$IC_RAdm30 <-  as.numeric(difftime(LC_IC$R_Adm30_Date,LC_IC$Discharge_Date, units = "days"))
mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_RAdm30,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_RAdm30,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_RAdm30,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_RAdm30,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_RAdm30,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_RAdm30,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_RAdm30,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_RAdm30,na.rm = T)

# 60 days
LC_IC$IC_RAdm60_cnt <- ifelse(!is.na(LC_IC$R_Adm60_Count),1,0)
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_RAdm60_cnt','LoN')],useNA = "ifany")
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_RAdm60_cnt')],useNA = "ifany")

LC_IC$IC_RAdm60 <-  as.numeric(difftime(LC_IC$R_Adm60_Date,LC_IC$Discharge_Date, units = "days"))
mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_RAdm60,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_RAdm60,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_RAdm60,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_RAdm60,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_RAdm60,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_RAdm60,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_RAdm60,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_RAdm60,na.rm = T)

# 90 days
LC_IC$IC_RAdm90_cnt <- ifelse(!is.na(LC_IC$R_Adm90_Count),1,0)
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_RAdm90_cnt','LoN')],useNA = "ifany")
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_RAdm90_cnt')],useNA = "ifany")

LC_IC$IC_RAdm90 <-  as.numeric(difftime(LC_IC$R_Adm90_Date,LC_IC$Discharge_Date, units = "days"))
mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_RAdm90,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$IC_RAdm90,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_RAdm90,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$IC_RAdm90,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_RAdm90,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$IC_RAdm90,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_RAdm90,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$IC_RAdm90,na.rm = T)

########### Extended IC support (>91 days)
table(LC_IC[LC_IC$ICFlag == 1 & LC_IC$IC_LOS>90 , c('LoN')],useNA = "ifany")

########## GP events
# 30 days
LC_IC$IC_GP_cnt <- ifelse(!is.na(LC_IC$GP_Events_Count),1,0)
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_GP_cnt','LoN')],useNA = "ifany")

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$GP_Events_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$GP_Events_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$GP_Events_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$GP_Events_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$GP_Events_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$GP_Events_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$GP_Events_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$GP_Events_Count,na.rm = T)

########## A&E Att
# 30 days
LC_IC$IC_AE_cnt <- ifelse(!is.na(LC_IC$R_Att_Count),1,0)
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_AE_cnt','LoN')],useNA = "ifany")

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$R_Att_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$R_Att_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$R_Att_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$R_Att_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$R_Att_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$R_Att_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$R_Att_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$R_Att_Count,na.rm = T)

########## 111 calls
# 30 days
LC_IC$IC_111_cnt <- ifelse(!is.na(LC_IC$R_111_Count),1,0)
table(LC_IC[LC_IC$ICFlag == 1 , c('IC_111_cnt','LoN')],useNA = "ifany")

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$R_111_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==1,]$R_111_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$R_111_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==2,]$R_111_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$R_111_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==3,]$R_111_Count,na.rm = T)

mean(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$R_111_Count,na.rm = T)
median(LC_IC[LC_IC$ICFlag==1 & LC_IC$LoN==4,]$R_111_Count,na.rm = T)

########### Frailty
table(LCohort[LCohort$ICFlag == 1 , c('FrailtyGroup','LoN')],useNA = "ifany")

LC_IC$FrailtyScore <- ifelse(LC_IC$FrailtyScore == -1, NA,LC_IC$FrailtyScore)

#################
fwrite(LCohort, "data/KD_NDL_IC_LinkedCoreCohort_plus2.csv")


