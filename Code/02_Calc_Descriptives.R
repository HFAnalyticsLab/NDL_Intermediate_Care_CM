library (data.table)

setwd(".../Projects/NDL4_intermediate_care")

# Read Cohort data
LCohort <- fread("data/KD_NDL_IC_LinkedCoreCohort.csv")

table(LCohort$Der_CSDS_Pathway)
table(LCohort$Der_ASC_Pathway)

############
IC_either <- LCohort[!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway),]
nrow(IC_either)

IC_both <- LCohort[!is.na(LCohort$Der_CSDS_Pathway) & !is.na(LCohort$Der_ASC_Pathway),]
nrow(IC_both)

############
Calls111_IC <- LCohort[(!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway))
                       &(!is.na(LCohort$R_111_Count)),]
nrow(Calls111_IC)

Calls111_noIC <- LCohort[(is.na(LCohort$Der_CSDS_Pathway) & is.na(LCohort$Der_ASC_Pathway))
                         &(!is.na(LCohort$R_111_Count)),]
nrow(Calls111_noIC)

############
GP_App_IC <- LCohort[(!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway))
                     &(!is.na(LCohort$GP_App_Count)),]
nrow(GP_App_IC)

GP_App_noIC <- LCohort[(is.na(LCohort$Der_CSDS_Pathway) & is.na(LCohort$Der_ASC_Pathway))
                       &(!is.na(LCohort$GP_App_Count)),]
nrow(GP_App_noIC)

############
GP_Enc_IC <- LCohort[(!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway))
                     &(!is.na(LCohort$GP_Enc_Count)),]
nrow(GP_Enc_IC)

GP_Enc_noIC <- LCohort[(is.na(LCohort$Der_CSDS_Pathway) & is.na(LCohort$Der_ASC_Pathway))
                       &(!is.na(LCohort$GP_Enc_Count)),]
nrow(GP_Enc_noIC)
############
GP_Events_IC <- LCohort[(!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway))
                        &(!is.na(LCohort$GP_Events_Count)),]
nrow(GP_Events_IC)

GP_Events_noIC <- LCohort[(is.na(LCohort$Der_CSDS_Pathway) & is.na(LCohort$Der_ASC_Pathway))
                          &(!is.na(LCohort$GP_Events_Count)),]
nrow(GP_Events_noIC)



############
AE_Att_IC <- LCohort[(!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway))
                     &(!is.na(LCohort$AE_Att_Count)),]
nrow(AE_Att_IC)

AE_Att_noIC <- LCohort[(is.na(LCohort$Der_CSDS_Pathway) & is.na(LCohort$Der_ASC_Pathway))
                       &(!is.na(LCohort$AE_Att_Count)),]
nrow(AE_Att_noIC)

############
APC_Adm_IC <- LCohort[(!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway))
                      &(!is.na(LCohort$APCS_Adm_Count)),]
nrow(APC_Adm_IC)

APC_Adm_noIC <- LCohort[(is.na(LCohort$Der_CSDS_Pathway) & is.na(LCohort$Der_ASC_Pathway))
                        &(!is.na(LCohort$APCS_Adm_Count)),]
nrow(APC_Adm_noIC)

############
LCohort$ICFlag <- ifelse((!is.na(LCohort$Der_CSDS_Pathway) | !is.na(LCohort$Der_ASC_Pathway)),1,0)
LCohort$ICFlag <- ifelse(LCohort$Pathway=="Pathway 3" & LCohort$ICFlag == 0,3,LCohort$ICFlag)
LCohort$ICFlag <- ifelse(LCohort$Pathway=="Other" & LCohort$ICFlag == 0,5,LCohort$ICFlag)
LCohort$ICFlag <- ifelse((LCohort$Pathway=="Pathway 2/3" & LCohort$ICFlag == 0),4,LCohort$ICFlag)
table(LCohort$ICFlag)

LCohort$IC_CSDS <- ifelse(LCohort$Der_CSDS_Pathway %in% c(1,2,12) & LCohort$ICFlag == 1,1,0)
LCohort$IC_ASC <- ifelse(LCohort$Der_ASC_Pathway%in% c(1,2,12) & LCohort$ICFlag == 1,1,0)


LCohort$Der_CSDS_Pathway <- ifelse(is.na(LCohort$Der_CSDS_Pathway) ,0,LCohort$Der_CSDS_Pathway)
LCohort$Der_ASC_Pathway <- ifelse(is.na(LCohort$Der_ASC_Pathway)  ,0,LCohort$Der_ASC_Pathway)

LCohort$IC_Pathways <- 0
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 1 ,1,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 2 ,2,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 12 ,12,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_ASC_Pathway == 1 ,1,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_ASC_Pathway == 2 ,2,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_ASC_Pathway == 12 ,12,LCohort$IC_Pathways)

LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 1 & LCohort$Der_ASC_Pathway == 1  ,1,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 1 & LCohort$Der_ASC_Pathway == 2  ,2,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 1 & LCohort$Der_ASC_Pathway == 12  ,1,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 2 & LCohort$Der_ASC_Pathway == 1  ,2,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 2 & LCohort$Der_ASC_Pathway == 2  ,2,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 2 & LCohort$Der_ASC_Pathway == 12  ,2,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 12 & LCohort$Der_ASC_Pathway == 1  ,1,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 12 & LCohort$Der_ASC_Pathway == 2  ,2,LCohort$IC_Pathways)
LCohort$IC_Pathways <- ifelse(LCohort$Der_CSDS_Pathway == 12 & LCohort$Der_ASC_Pathway == 12  ,12,LCohort$IC_Pathways)

table(LCohort$IC_Pathways)

unique(LCohort$Pathway)

############
LCohort$FrailtyGroup <- NA
LCohort$FrailtyGroup <- ifelse(LCohort$FrailtyScore >= 0 & LCohort$FrailtyScore <= 0.12,1,LCohort$FrailtyGroup)
LCohort$FrailtyGroup <- ifelse(LCohort$FrailtyScore > 0.12 & LCohort$FrailtyScore <= 0.24,2,LCohort$FrailtyGroup)
LCohort$FrailtyGroup <- ifelse(LCohort$FrailtyScore > 0.24 & LCohort$FrailtyScore <= 0.36,3,LCohort$FrailtyGroup)
LCohort$FrailtyGroup <- ifelse(LCohort$FrailtyScore > 0.36 ,4,LCohort$FrailtyGroup)

table(LCohort[ , c('FrailtyGroup','ICFlag')])
table(LCohort[ , c('FrailtyGroup','IC_CSDS')])
table(LCohort[ , c('FrailtyGroup','IC_ASC')])
table(LCohort[ , c('FrailtyGroup','IC_Pathways')])

########### IMD
LCohort$IMD_quin <- ifelse(LCohort$IMD_decile == 1 |LCohort$IMD_decile == 2 ,5,NA)
LCohort$IMD_quin <- ifelse(LCohort$IMD_decile == 3 |LCohort$IMD_decile == 4 ,4,LCohort$IMD_quin)
LCohort$IMD_quin <- ifelse(LCohort$IMD_decile == 4 |LCohort$IMD_decile == 6 ,3,LCohort$IMD_quin)
LCohort$IMD_quin <- ifelse(LCohort$IMD_decile == 7 |LCohort$IMD_decile == 8 ,2,LCohort$IMD_quin)
LCohort$IMD_quin <- ifelse(LCohort$IMD_decile == 9 |LCohort$IMD_decile == 10 ,1,LCohort$IMD_quin)

table(LCohort[ , c('IMD_quin','ICFlag')])
table(LCohort[ , c('IMD_decile','ICFlag')])

table(LCohort[ , c('IMD_quin','IC_CSDS')])
table(LCohort[ , c('IMD_quin','IC_ASC')])

table(LCohort[ , c('IMD_quin','IC_Pathways')])

########### ICD10
table(LCohort[ , c('ICD10_Cat','ICFlag')])

########### APCS Pathway
table(LCohort[ , c('Pathway','ICFlag')])

########### SEX
table(LCohort[ , c('Sex','ICFlag')])

table(LCohort[ , c('Sex','IC_CSDS')])
table(LCohort[ , c('Sex','IC_ASC')])

table(LCohort[ , c('Sex','IC_Pathways')])


########## Age Groups 18-34, 35-64, 65+
LCohort$Age_Group <- ifelse(LCohort$Age>17 & LCohort$Age<35,"18-34","NA")
LCohort$Age_Group <- ifelse(LCohort$Age>34 & LCohort$Age<65,"35-64",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>64 ,"65+",LCohort$Age_Group)

########## Age Groups 18-34, 35-64, 65+
LCohort$Age_Group <- ifelse(LCohort$Age>17 & LCohort$Age<30,"18-29","NA")
LCohort$Age_Group <- ifelse(LCohort$Age>29 & LCohort$Age<40,"30-39",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>39 & LCohort$Age<50,"40-49",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>49 & LCohort$Age<60,"50-59",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>59 & LCohort$Age<70,"60-69",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>69 & LCohort$Age<80,"70-79",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>79 ,"80+",LCohort$Age_Group)

########## Age Groups <50,..., 90+
LCohort$Age_Group <- ifelse(LCohort$Age<50,"under50","NA")
LCohort$Age_Group <- ifelse(LCohort$Age>49 & LCohort$Age<55,"50-54",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>54 & LCohort$Age<60,"55-59",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>59 & LCohort$Age<65,"60-64",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>64 & LCohort$Age<70,"65-69",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>69 & LCohort$Age<75,"70-74",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>74 & LCohort$Age<80,"75-79",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>79 & LCohort$Age<85,"80-84",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>84 & LCohort$Age<90,"85-89",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>89 ,"90+",LCohort$Age_Group)

########## Age Groups <60,..., 90+
LCohort$Age_Group <- ifelse(LCohort$Age<60,"under60","NA")
LCohort$Age_Group <- ifelse(LCohort$Age>59 & LCohort$Age<70,"60-69",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>69 & LCohort$Age<80,"70-79",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>79 & LCohort$Age<90,"80-89",LCohort$Age_Group)
LCohort$Age_Group <- ifelse(LCohort$Age>89 ,"90+",LCohort$Age_Group)


table(LCohort[ , c('Age_Group','ICFlag')])

table(LCohort[ , c('Age_Group','IC_CSDS')])
table(LCohort[ , c('Age_Group','IC_ASC')])

table(LCohort[ , c('Age_Group','IC_Pathways')])

########## Ethnic groups
LCohort$Ethnos <- ifelse(LCohort$Ethnic_Group %in% c("A","B","C"),"White","NA")
LCohort$Ethnos <- ifelse(LCohort$Ethnic_Group %in% c("D","E","F","G") ,"Mixed",LCohort$Ethnos)
LCohort$Ethnos <- ifelse(LCohort$Ethnic_Group %in% c("H","J","K","L") ,"Asian",LCohort$Ethnos)
LCohort$Ethnos <- ifelse(LCohort$Ethnic_Group %in% c("M","N","P") ,"Black",LCohort$Ethnos)
LCohort$Ethnos <- ifelse(LCohort$Ethnic_Group %in% c("R","S") ,"Other",LCohort$Ethnos)
LCohort$Ethnos <- ifelse(LCohort$Ethnic_Group %in% c("99","Z","X") ,"DK",LCohort$Ethnos)

table(LCohort[ , c('Ethnos','ICFlag')])

table(LCohort[ , c('Ethnos','IC_CSDS')])
table(LCohort[ , c('Ethnos','IC_ASC')])

table(LCohort[ , c('Ethnos','IC_Pathways')])

########## Living Alone
table(LCohort[ , c('LivingAlone','ICFlag')])

table(LCohort[ , c('LivingAlone','IC_CSDS')])
table(LCohort[ , c('LivingAlone','IC_ASC')])

table(LCohort[ , c('LivingAlone','IC_Pathways')])

########## Living with under 18
table(LCohort[ , c('LivingWithUnder18','ICFlag')])


########## Carer
table(LCohort[ , c('Carer','ICFlag')])


########## HH
nrow(LCohort[LCohort$ICFlag==1 & LCohort$TotalHousehold<5,])
nrow(LCohort[LCohort$ICFlag==1 & LCohort$TotalHousehold>4,])
mean(LCohort$TotalHousehold,na.rm = T)
median(LCohort$TotalHousehold,na.rm = T)

nrow(LCohort[LCohort$IC_CSDS==1 & LCohort$TotalHousehold<5,])
nrow(LCohort[LCohort$IC_CSDS==1 & LCohort$TotalHousehold>4,])
mean(LCohort[LCohort$IC_CSDS==1 & LCohort$TotalHousehold<4,]$TotalHousehold,na.rm = T)
median(LCohort[LCohort$IC_CSDS==1,]$TotalHousehold,na.rm = T)

nrow(LCohort[LCohort$IC_ASC==1 & LCohort$TotalHousehold<5,])
nrow(LCohort[LCohort$IC_ASC==1 & LCohort$TotalHousehold>4,])
mean(LCohort[LCohort$IC_ASC==1,]$TotalHousehold,na.rm = T)
median(LCohort[LCohort$IC_ASC==1,]$TotalHousehold,na.rm = T)

nrow(LCohort[LCohort$IC_Pathways==1 & LCohort$TotalHousehold<5,])
nrow(LCohort[LCohort$IC_Pathways==1 & LCohort$TotalHousehold>4,])

nrow(LCohort[LCohort$IC_Pathways==2 & LCohort$TotalHousehold<5,])
nrow(LCohort[LCohort$IC_Pathways==2 & LCohort$TotalHousehold>4,])

nrow(LCohort[LCohort$IC_Pathways==12 & LCohort$TotalHousehold<5,])
nrow(LCohort[LCohort$IC_Pathways==12 & LCohort$TotalHousehold>4,])

########## Segmentation
table(LCohort[ , c('Segment','ICFlag')])

table(LCohort[ , c('Segment','IC_CSDS')])
table(LCohort[ , c('Segment','IC_ASC')])

table(LCohort[ , c('Segment','IC_Pathways')])


table(LCohort[ , c('Age_Group','Sex','ICFlag')])

################# Length of Stay in IC

LC_IC <- LCohort[LCohort$ICFlag == 1,]
LC_IC$CSDS_LoS <- as.numeric(difftime(LC_IC$Contact_End_Date,LC_IC$Contact_Start_Date, units = "days"))
LC_IC$CSDS_LoS <- ifelse(LC_IC$CSDS_LoS==0,1,LC_IC$CSDS_LoS)
LC_IC$ASC_LoS <- as.numeric(difftime(LC_IC$Event_End_Date,LC_IC$Event_Start_Date, units = "days"))
LC_IC$ASC_LoS <- ifelse(LC_IC$ASC_LoS==0,1,LC_IC$ASC_LoS)
LC_IC$IC_LOS <- LC_IC$CSDS_LoS
LC_IC$IC_LOS <- ifelse(!is.na(LC_IC$ASC_LoS),LC_IC$ASC_LoS,LC_IC$IC_LOS)
LC_IC$IC_LOS <- ifelse(!is.na(LC_IC$ASC_LoS)&!is.na(LC_IC$CSDS_LoS),(LC_IC$ASC_LoS + LC_IC$CSDS_LoS),LC_IC$IC_LOS)

head(LC_IC[!is.na(LC_IC$ASC_LoS)&!is.na(LC_IC$CSDS_LoS),])

mean(LC_IC$IC_LOS,na.rm = T)
median(LC_IC$IC_LOS,na.rm = T)

mean(LC_IC$CSDS_LoS,na.rm = T)
median(LC_IC$CSDS_LoS,na.rm = T)

mean(LC_IC$ASC_LoS,na.rm = T)
median(LC_IC$ASC_LoS,na.rm = T)

mean(LC_IC[LC_IC$IC_Pathways==1,]$IC_LOS,na.rm = T)
median(LC_IC[LC_IC$IC_Pathways==1,]$IC_LOS,na.rm = T)

mean(LC_IC[LC_IC$IC_Pathways==2,]$IC_LOS,na.rm = T)
median(LC_IC[LC_IC$IC_Pathways==2,]$IC_LOS,na.rm = T)

mean(LC_IC[LC_IC$IC_Pathways==12,]$IC_LOS,na.rm = T)
median(LC_IC[LC_IC$IC_Pathways==12,]$IC_LOS,na.rm = T)

########## Conditions
table(LCohort[ , c('Hypertension','ICFlag')])
table(LCohort[ , c('Cancer','ICFlag')])
table(LCohort[ , c('Diabetes','ICFlag')])
table(LCohort[ , c('CVD','ICFlag')])
table(LCohort[ , c('Heart_failure','ICFlag')])
table(LCohort[ , c('CKD','ICFlag')])
table(LCohort[ , c('Asthma','ICFlag')])
table(LCohort[ , c('COPD','ICFlag')])
table(LCohort[ , c('Depression','ICFlag')])

table(LCohort[ , c('Hypertension','IC_CSDS')])
table(LCohort[ , c('Cancer','IC_CSDS')])
table(LCohort[ , c('Diabetes','IC_CSDS')])
table(LCohort[ , c('CVD','IC_CSDS')])
table(LCohort[ , c('Heart_failure','IC_CSDS')])
table(LCohort[ , c('CKD','IC_CSDS')])
table(LCohort[ , c('Asthma','IC_CSDS')])
table(LCohort[ , c('COPD','IC_CSDS')])
table(LCohort[ , c('Depression','IC_CSDS')])

table(LCohort[ , c('Hypertension','IC_ASC')])
table(LCohort[ , c('Cancer','IC_ASC')])
table(LCohort[ , c('Diabetes','IC_ASC')])
table(LCohort[ , c('CVD','IC_ASC')])
table(LCohort[ , c('Heart_failure','IC_ASC')])
table(LCohort[ , c('CKD','IC_ASC')])
table(LCohort[ , c('Asthma','IC_ASC')])
table(LCohort[ , c('COPD','IC_ASC')])
table(LCohort[ , c('Depression','IC_ASC')])

table(LCohort[ , c('Hypertension','IC_Pathways')])
table(LCohort[ , c('Cancer','IC_Pathways')])
table(LCohort[ , c('Diabetes','IC_Pathways')])
table(LCohort[ , c('CVD','IC_Pathways')])
table(LCohort[ , c('Heart_failure','IC_Pathways')])
table(LCohort[ , c('CKD','IC_Pathways')])
table(LCohort[ , c('Asthma','IC_Pathways')])
table(LCohort[ , c('COPD','IC_Pathways')])
table(LCohort[ , c('Depression','IC_Pathways')])

########## LTCs
colnames(LCohort)
LCohort$LTC_flag <- 0
LCohort$LTC_flag <- ifelse(LCohort$Hypertension == 1, 1,0)
LCohort$LTC_flag <- ifelse(LCohort$Cancer == 1, 1,LCohort$LTC_flag)
LCohort$LTC_flag <- ifelse(LCohort$Diabetes == 1, 1,LCohort$LTC_flag)
LCohort$LTC_flag <- ifelse(LCohort$CVD == 1, 1,LCohort$LTC_flag)
LCohort$LTC_flag <- ifelse(LCohort$Heart_failure == 1, 1,LCohort$LTC_flag)
LCohort$LTC_flag <- ifelse(LCohort$CKD == 1, 1,LCohort$LTC_flag)
LCohort$LTC_flag <- ifelse(LCohort$Asthma == 1, 1,LCohort$LTC_flag)
LCohort$LTC_flag <- ifelse(LCohort$COPD == 1, 1,LCohort$LTC_flag)
LCohort$LTC_flag <- ifelse(LCohort$Depression == 1, 1,LCohort$LTC_flag)

table(LCohort[ , c('LTC_flag','ICFlag')])

table(LCohort[ , c('LTC_flag','IC_CSDS')])
table(LCohort[ , c('LTC_flag','IC_ASC')])

table(LCohort[ , c('LTC_flag','IC_Pathways')])

##########

fwrite(LCohort, "data/KD_NDL_IC_LinkedCoreCohort_plus.csv")



