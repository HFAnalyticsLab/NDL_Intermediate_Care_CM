
rm(list=ls())
library(data.table)
library(ggplot2)
library(tsibble)
library(MatchIt)
library(survival)
library(survminer)
library(survey)
library(cmprskcoxmsm)
library(WeightIt)
library(mlogit)
library(stats)
### 

#setwd("...s/Projects/NDL4_intermediate_care")

# Read Cohort data
LCohort <- fread("../data/KD_NDL_IC_LinkedCoreCohort_plus2.csv")

colnames(LCohort)
table (LCohort$ICFlag, useNA = "ifany")
table (LCohort$IC_Pathways, useNA = "ifany")
LCohort$sv_time <- as.numeric(difftime(LCohort$R_Adm90_Date,LCohort$Discharge_Date, units = "days"))
LCohort$dod_time <- as.numeric(difftime(LCohort$DoD90,LCohort$Discharge_Date, units = "days"))
LCohort$ICFlag012 <- ifelse(LCohort$ICFlag==0 & LCohort$IC_Pathways==0, 0,9)
LCohort$ICFlag012 <- ifelse(LCohort$IC_Pathways==1, 1,LCohort$ICFlag012)
LCohort$ICFlag012 <- ifelse(LCohort$IC_Pathways==2, 2,LCohort$ICFlag012)
LCohort <- LCohort[!duplicated(LCohort[ , c("Der_Pseudo_NHS_Number","Discharge_Date")]),]

pat_01 <- LCohort[LCohort$ICFlag %in% c(0,1), c("Der_Pseudo_NHS_Number","Discharge_Date", "ICFlag","Age", 
                                                "Sex","LSOA11","Adm12_Count", "LivingAlone",
                                                "ICD10_Cat","Spell_LoS","FrailtyGroup","Ethnos",
                                                "Age_Group",
                                                "Depression", "Diabetes","Cancer",
                                                "CVD","Asthma","COPD","CKD",
                                                "Heart_failure","Hypertension",
                                                "DoD90","dod_time","R_Adm90_Count","sv_time")]
pat_01 <- pat_01[!is.na(pat_01$Diabetes) & !pat_01$Sex %in% c(0,9),]
pat_01$Sex <- ifelse(pat_01$Sex == 1,0,1)
pat_01$Adm12_Count <- ifelse(is.na(pat_01$Adm12_Count),0,pat_01$Adm12_Count)

pat_01 <- pat_01[!pat_01$LivingAlone=="",]
pat_01$LivingAlone <- ifelse(pat_01$LivingAlone == "Y",1,pat_01$LivingAlone)
pat_01$LivingAlone <- ifelse(pat_01$LivingAlone == "N",0,pat_01$LivingAlone)
pat_01$LivingAlone <- as.numeric(pat_01$LivingAlone)

pat_01$R_Adm90_Count <- ifelse(is.na(pat_01$R_Adm90_Count),0,1)
pat_01$sv_time <- ifelse(is.na(pat_01$sv_time),90,pat_01$sv_time)
pat_01$dod_time <- ifelse(is.na(pat_01$dod_time),90,pat_01$dod_time)
pat_01$DoD <- ifelse(is.na(pat_01$DoD90),0,1)

pat_01$LTCs <- rowSums(pat_01[,c(14:22)],na.rm = TRUE)

# Load IMD2019 data
imd19 <- fread("../data/imd2019_eng_sim.csv")
colnames(imd19)
imd19 <- imd19[,c("lsoa11cd","IMD_Score")]
colnames(imd19) <- c("LSOA11","IMD_Score")
pat_01 <- merge(pat_01,imd19,by="LSOA11",all.x = TRUE)
pat_01 <- pat_01[!is.na(pat_01$IMD_Score),]

# Calculate local IMD quintiles
quintile_breakpoints <- quantile(pat_01$IMD_Score, probs = seq(0, 1, 1/5) )
pat_01$IMD_local <- cut(pat_01$IMD_Score, breaks = quintile_breakpoints, include.lowest = TRUE, labels = c(5, 4, 3, 2, 1))
pat_01$IMD_local <- as.numeric(as.character(pat_01$IMD_local))

# Ethnicity - 0:White, 1:Non-white
pat_01 <- pat_01[!pat_01$Ethnos %in% c("","DK"),]
pat_01$EthnosBin <- ifelse(pat_01$Ethnos=="White",0,1)

pat_01 <- pat_01[!is.na(pat_01$FrailtyGroup),]

# LoS as continues variable is not working in the model
# Calculate a binary variable of patients with more than 91 days LoS
pat_01$LoS_over91 <- ifelse(pat_01$Spell_LoS>90,1,0)

#############
# ICFlag
# define the propensity score  model - i.e things that predict receiving intermediate care
pat_01$ICFlag <- as.factor(pat_01$ICFlag)
pat_01$Age_Group <- as.factor(pat_01$Age_Group)
pat_01$FrailtyGroup <- as.factor(pat_01$FrailtyGroup)
pat_01$ICD10_Cat <- as.factor(pat_01$ICD10_Cat)
pat_01$IMD_local <- as.factor(pat_01$IMD_local)

# Drop Hypertension from model because of singularities
select_formula<-as.formula(ICFlag~relevel(Age_Group, ref = "under60")+Sex+
                             relevel(IMD_local, ref = "5")+Adm12_Count+
                             LoS_over91+FrailtyGroup+LTCs+
                             EthnosBin+LivingAlone+ICD10_Cat+Depression+
                             Diabetes+Cancer+CVD+Asthma+COPD+CKD+Heart_failure)

# 
m1<-glm(select_formula, data=pat_01, family = binomial(link='logit'))
summary(m1)
# 

pat_matching <- pat_01[,c("Der_Pseudo_NHS_Number","Discharge_Date","ICFlag","Age", "Sex", 
                          "FrailtyGroup","EthnosBin", "LivingAlone",                 
                          "IMD_local","LoS_over91","LTCs")]
sel_f<-as.formula(ICFlag~Age+Sex+
                             relevel(IMD_local, ref = "5")+
                             LoS_over91+FrailtyGroup+LTCs+
                             EthnosBin+LivingAlone)
table(pat_matching$ICFlag)

## matching
matchcohort <- matchit(sel_f, data = pat_matching, method="nearest",
                       distance = "glm", ratio=1,estimand = "ATT")
summary(matchcohort$model)

matchedrows<-as.data.table(matchcohort$match.matrix)

matchedrows$id<-row.names(matchedrows)
matchcohort2 <- as.data.table(match.data(matchcohort))
table(matchcohort2$ICFlag)

matchcohort2 <- matchcohort2[,c("Der_Pseudo_NHS_Number","Discharge_Date","subclass")]

pat_01 <- merge(pat_01,matchcohort2,by=c("Der_Pseudo_NHS_Number","Discharge_Date"),all.y = T)
pat_01 <- pat_01[!is.na(pat_01$subclass),]
#

W.out <- weightit(select_formula,pat_01, estimand = "ATT",  method = "glm")
pat_01$iptw<-W.out$weights

# Survival weighted analysis - Survival curves comparing patient outcome (mortality) with and 
#                     without Integrated Care (IC) support over a 90-day period.
res.cox <- svycoxph(Surv(dod_time, DoD) ~ ICFlag, design=svydesign(ids=~Der_Pseudo_NHS_Number, weights =~iptw, data=pat_01))
summary(res.cox)


fit <- survfit(Surv(dod_time, DoD) ~ ICFlag, data =pat_01,weights = iptw)

ggsurvplot(fit,
           pval = FALSE, conf.int = TRUE,
           risk.table = TRUE, # Add risk table
           risk.table.col = "strata", # Change risk table color by groups
           conf.int.style = "step",
           xlim = c(0,90),
           break.time.by = 10,
           ggtheme = theme_bw(), # Change ggplot2 theme
           palette = c( "#2E9FDF","red"), 
           legend.labs = c("No IC support", "IC support"),
           xlab = "Time in days",
           risk.table.y.text = FALSE,
           ylim=c(0.85,1))

# Survival weighted analysis - Survival curves comparing patient outcome (readmission) with and 
#                     without Integrated Care (IC) support over a 90-day period.
res.cox <- svycoxph(Surv(sv_time, R_Adm90_Count) ~ ICFlag, design=svydesign(ids=~Der_Pseudo_NHS_Number, weights =~iptw, data=pat_01))
summary(res.cox)


fit <- survfit(Surv(sv_time, R_Adm90_Count) ~ ICFlag, data =pat_01,weights = iptw)

ggsurvplot(fit,
           pval = FALSE, conf.int = TRUE,
           risk.table = TRUE, # Add risk table
           risk.table.col = "strata", # Change risk table color by groups
           conf.int.style = "step",
           xlim = c(0,90),
           break.time.by = 10,
           ggtheme = theme_bw(), # Change ggplot2 theme
           palette = c( "#2E9FDF","red"), 
           legend.labs = c("No IC support", "IC support"),
           xlab = "Time in days",
           risk.table.y.text = FALSE,
           ylim=c(0.5,1))


