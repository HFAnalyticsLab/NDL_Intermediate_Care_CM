
# Overview of SQL and R Scripts for Analysing Intermediate Care (IC) Pathways and Patient Outcomes
This document provides an overview of a series of SQL and R scripts developed to analyse healthcare datasets related to Intermediate Care (IC) pathways. These scripts cover a range of tasks, including linking multiple data sources, creating patient cohorts, calculating descriptive statistics, conducting survival analysis, and evaluating patient pathways. The SQL script primarily handles data linking, while the R scripts conduct deeper analyses, such as descriptive statistics, categorisation of need levels, and survival outcomes, with an emphasis on the effectiveness of IC support.

## 01_IC_sql_scripts.sql: Linking Healthcare Data for Analysis

The 01_IC_sql_scripts.sql script is used to link and analyse healthcare datasets related to IC pathways. The key functions of the script include:

**Creating Temporary Tables**: Generates temporary tables to link data from multiple sources, such as hospital admissions (APC), Community Services Data Set (CSDS), Adult Social Care (ASC), and other healthcare services (e.g., GP visits, A&E, 111 calls).

**Linking Hospital Admissions with Social Care Events**:
Matches hospital admission data with social care events and calculates the number of days between discharge and social care initiation.

**Assigning Pathways**: Classifies patients into specific care pathways (e.g., short-term residential care, reablement).

**Creating and Updating Cohort Tables**: Consolidates data into a core cohort table that includes demographics, care pathways, and healthcare involvement.

**Joining Data Across Multiple Events**: Links additional healthcare events (e.g., GP, A&E, 111 calls) to understand post-discharge healthcare utilization.

**Final Output**: Generates a fully linked dataset ready for analysis and reporting.

## 02_Calc_Descriptives.R: Descriptive Analysis of IC Pathways
The 02_Calc_Descriptives.R script performs descriptive analyses on healthcare data involving IC pathways:

**Filtering the Cohort**: Filters the cohort based on specific pathways and healthcare interactions (e.g., GP visits, A&E, 111 calls).

**Counting Patient Interactions**: Counts patients by different care pathways and types of healthcare encounters.

**Generating Summary Tables**: Produces summary tables for patients with long-term conditions (e.g., hypertension, diabetes, cancer) and their relation to care pathways.

**Creating Long-Term Condition Flag**: Creates an "LTC_flag" to indicate the presence of any long-term condition.

## 03_Calc_Levels_of_Need.R: Levels of Need Categorization
The 03_Calc_Levels_of_Need.R script categorises patients into different Levels of Need (LoN):

**Levels of Need Calculation**: Defines levels of need based on the Length of Stay (LoS) and Frailty Group, calculated for different time frames (7, 14, and 21 days).

**Tabulation and Analysis**: Creates frequency tables and performs event analysis to understand healthcare interactions (e.g., GP visits, A&E, 111 calls) related to different LoN.

**Frailty Evaluation**: Examines frailty scores in relation to LoN, adjusting for missing or invalid values.

## 04_Calc_No_pathway.R: Analysis of Patients Without a Defined Pathway
The 04_Calc_No_pathway.R script identifies and analyses patients who did not follow a defined IC pathway:

**No Pathway Group Creation**: Creates a new variable (NoICFlag) to categorize patients without an IC pathway based on specific conditions.

**Subsetting the Cohort**: Filters the cohort to include only certain IC categories.

**Descriptive Analysis**: Generates tables to analyze demographics, long-term conditions, and the relationship between frailty and the "No Pathway" group.

## 05_Calc_Survival_analysis_plus_machit.R: Survival Analysis with IC Support
The 05_Calc_Survival_analysis_plus_machit.R script conducts survival analysis comparing outcomes between patients with and without IC support:

**Data Preparation**: Reads and cleans cohort data, creating variables for survival time (sv_time) and mortality (dod_time).

**Matching Patients**: Uses the MatchIt package to create matched cohorts and generates propensity weights for balanced comparison.

**Survival Analysis**: Performs weighted Cox proportional hazards regression to analyze 90-day mortality outcomes and creates survival curves using survfit.

**Readmission Analysis**: Evaluates the risk of hospital readmission within 90 days for patients with and without IC support.

**Visualization**: Generates survival curves with confidence intervals and risk tables, highlighting differences in outcomes between groups.

