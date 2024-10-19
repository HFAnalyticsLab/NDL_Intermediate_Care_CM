/*
Script: IC_sql_scripts.sql
Description: Link APCS admissions to ASC and CSDS events.  
Depedencies: Read only and Read/Write access to [<ICB Schema>] and [<ICB Schema>_RW] schemas respectively.
             Tables 
			 - [<ICB Schema>].[vw_SUS_Faster_APCS]
			 - [<ICB Schema>].[Adult_Social_Care]
			 - [<ICB Schema>_RW].[KD_CSDS_Referral]
			 - [<ICB Schema>_RW].[KD_CSDS_ServiceTypeReferredTo]
			 - [<ICB Schema>].[CSDS_CYP201CareContact]
			 - [<ICB Schema>].[GP_Events]
			 - [<ICB Schema>].[Patient]
			 - [<ICB Schema>].[vw_SUS_Faster_ECDS]
			 - [<ICB Schema>].[vw_NWAS_111_Data] 
			 - [<ICB Schema>_RW].[RP003_MPI]
			 - [<ICB Schema>_RW].[JWRefIMD]
			 - [<ICB Schema>_RW].[RP103_Segmentation]

Author: Konstantinos Daras (Konstantinos.Daras@liverpool.ac.uk)
Date: November 2023

LATEST OUTPUTS: 09 Nov 2023
*/

---------------------------------------
-- Link APCS admissions to CSDS events
---------------------------------------


--- Select APCS admissions between April 2021 and Dec2022 (CSDS data not available for Q1 2023) 
DROP TABLE IF EXISTS #_tmp_pathways
SELECT DISTINCT  
	[Der_Pseudo_NHS_Number],
	Admission_Method,
	[Ethnic_Group],
	[Sex],
	[Der_Age_at_CDS_Activity_Date] AS Age,
	[Der_Spell_LoS] AS Spell_LoS,
	[Der_Postcode_LSOA_2011_Code] AS LSOA11,
	SUBSTRING([Der_Diagnosis_All],3,3) AS P_Diagnosis,
	CASE 
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('A','B') then 'I'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('C') then 'II'
		When SUBSTRING([Der_Diagnosis_All],3,2) IN ('D0','D1','D2','D3','D4') then 'II'
		When SUBSTRING([Der_Diagnosis_All],3,2) IN ('D5','D6','D7','D8') then 'III'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('E') then 'IV'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('F') then 'V' 
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('G') then 'VI'
		When SUBSTRING([Der_Diagnosis_All],3,2) IN ('H0','H1','H2','H3','H4','H5') then 'VII'
		When SUBSTRING([Der_Diagnosis_All],3,2) IN ('H6','H7','H8','H9') then 'VIII'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('I') then 'IX'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('J') then 'X'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('K') then 'XI'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('L') then 'XII'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('M') then 'XIII'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('N') then 'XIV'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('O') then 'XV'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('P') then 'XVI'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('Q') then 'XVII'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('R') then 'XVIII'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('S','T') then 'XIX'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('V','W','X','Y') then 'XX'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('Z') then 'XXI'
		When SUBSTRING([Der_Diagnosis_All],3,1) IN ('U') then 'XXII'
		ELSE 'NK'
	END AS ICD10_Cat,
	[Admission_Date],
    [Discharge_Date],
	[Discharge_Destination],
	CASE   -- Based on HF guidance (see document "Discharge code exclusions.docx" - 15/11/2023)
			When [Discharge_Destination] = '19' then 'Pathway 0/1'
			When [Discharge_Destination] = '29' then 'Other'
			When [Discharge_Destination] = '30' then 'Other'
			When [Discharge_Destination] = '48' then 'Other'
			When [Discharge_Destination] = '49' then 'Pathway 0'
			When [Discharge_Destination] = '50' then 'Pathway 0' 
			When [Discharge_Destination] = '51' then 'Pathway 0'
			When [Discharge_Destination] = '52' then 'Pathway 0'
			When [Discharge_Destination] = '53' then 'Pathway 0'
			When [Discharge_Destination] = '54' then 'Pathway 2/3'
			When [Discharge_Destination] = '55' then 'Pathway 2/3'
			When [Discharge_Destination] = '56' then 'Pathway 2/3'
			When [Discharge_Destination] = '65' then 'Pathway 3'
			When [Discharge_Destination] = '66' then 'Pathway 0'
			When [Discharge_Destination] = '84' then 'Other'
			When [Discharge_Destination] = '85' then 'Pathway 2/3' 
			When [Discharge_Destination] = '87' then 'Pathway 2'
			When [Discharge_Destination] = '88' then 'Pathway 3' 
			When [Discharge_Destination] = '89' then 'Other' -- ORGANISATION responsible for forced repatriation
			When [Discharge_Destination] = '98' then 'Other'
			When [Discharge_Destination] = '99' then 'Other'
			When [Discharge_Destination] IS NULL then 'Other' 
			When [Discharge_Destination] = 'DK' then 'Other' 
			ELSE 'Other'
		End as Pathway
INTO #_tmp_pathways
FROM       [<ICB Schema>].[vw_SUS_Faster_APCS]
WHERE       LEFT(Der_Provider_Code,3) in ('REM') --('RBS','REM','RQ6','RBQ','RVY','RBL','RBN','REP','RJN','RBT','RWW','RWW','RJR','REN','RET') --C&M providers
			AND Der_Management_Type in ('EL','EM','NE') --Only EL:Elective, EM:Emergency and NE:Non-elective other. 
			AND Administrative_Category in ('01','03')
			-- 01: NHS PATIENT, including Overseas Visitors charged under the  NHS
			-- 03: Amenity PATIENT, one who pays for the use of a single room or small ward in accordance with the NHS Act 2006  
			AND Discharge_Date BETWEEN CONVERT(DATETIME, '2021-04-01', 102) AND CONVERT(DATETIME, '2022-12-31', 102) -- Discharge Year
			AND Der_Spell_LoS <> 0
			AND Discharge_Method <> '4' 
			-- 4: PATIENT died
			AND Admission_Method NOT IN ('31','32')
			-- 31,32: Maternity Admission: Admitted ante/post partum
			AND Age_At_Start_of_Spell_SUS >17    -- Age 18+
			AND Age_At_Start_of_Spell_SUS <7000  -- Age 18+
			AND [Discharge_Destination] <> '79'
			AND [Der_Pseudo_NHS_Number] IS NOT NULL

-- Identify duplicates
DROP TABLE IF EXISTS #_tmp_pathways0
SELECT Der_Pseudo_NHS_Number, Admission_Date, COUNT(*) AS CNT 
INTO #_tmp_pathways0
FROM #_tmp_pathways
GROUP BY Der_Pseudo_NHS_Number, Admission_Date
ORDER BY CNT DESC

-- Flag duplicates
DROP TABLE IF EXISTS #_core_cohort
SELECT 
    A.*,
	B.CNT
INTO #_core_cohort
FROM #_tmp_pathways A
LEFT JOIN
    #_tmp_pathways0 B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number
	AND A.Admission_Date = B.Admission_Date

-- Delete duplicates where Discharge_Destination is NK(codes 98 and 99) - 346 rows
DELETE FROM #_core_cohort 
WHERE Discharge_Destination IN ('98','99') 
AND CNT = 2   

-- Delete duplicate for a parient with same admission date and two different discharge dates.
-- We keep record with largest Spell_LoS value
DELETE FROM #_core_cohort
WHERE [Der_Pseudo_NHS_Number] = '<HARD CODED PATIENT ID>'
AND [Spell_LoS] = 4 AND CNT = 2

-- Check for duplicates
SELECT Der_Pseudo_NHS_Number, Admission_Date, COUNT(*) AS CNT 
FROM #_core_cohort
GROUP BY Der_Pseudo_NHS_Number, Admission_Date
ORDER BY CNT DESC
			
SELECT [Pathway], COUNT(*) AS CNT
FROM #_core_cohort
GROUP BY [Pathway]

SELECT  COUNT(*) AS CNT
FROM  (SELECT DISTINCT Der_Pseudo_NHS_Number, Admission_Date,Discharge_Date, Sex, Age
	 FROM #_core_cohort) A

-- Create Core Cohort APCS table in [<ICB Schema>_RW]
DROP TABLE IF EXISTS [<ICB Schema>_RW].[KD_NDL_IC_CoreCohort]
SELECT * INTO [<ICB Schema>_RW].[KD_NDL_IC_CoreCohort] FROM #_core_cohort 
SELECT COUNT(*) AS CNT FROM [<ICB Schema>_RW].[KD_NDL_IC_CoreCohort]

-- Flag Referrals with attended Contacts
DROP TABLE IF EXISTS #_flg_CSDS_Contacts
SELECT DISTINCT 
	Unique_ServiceRequestID,
	CASE 
		WHEN AttendOrNot IN ('5','6') THEN 1
		ELSE 0
	END AS Att_flg
INTO #_flg_CSDS_Contacts
FROM [<ICB Schema>].[CSDS_CYP201CareContact]
WHERE AttendOrNot IN ('5','6') 
GROUP BY Unique_ServiceRequestID, AttendOrNot


DROP TABLE IF EXISTS #_flg_CSDS_Referrals
SELECT 
    A.*,
	B.Att_flg
INTO #_flg_CSDS_Referrals
FROM [<ICB Schema>_RW].[KD_CSDS_Referral] A
LEFT JOIN
    #_flg_CSDS_Contacts B ON A.Unique_ServiceRequestID = B.Unique_ServiceRequestID
WHERE Att_flg = 1;

-- LINK TO CSDS data (Linkage window of 1 week)
DROP TABLE IF EXISTS #_lnk_APC_CSDS
SELECT 
    A.*,
    B.Unique_ServiceRequestID,
	B.ReferralRequest_ReceivedDate
INTO #_lnk_APC_CSDS
FROM #_core_cohort A
LEFT JOIN
    #_flg_CSDS_Referrals B ON A.Der_Pseudo_NHS_Number = B.CMv2_Pseudo_Number AND 
	B.ReferralRequest_ReceivedDate BETWEEN Discharge_Date AND DATEADD(WEEK, 1, A.Discharge_Date);

-- Calculate days between Discharge date and Referral Request date
DROP TABLE IF EXISTS #_lnk_APC_CSDS1
SELECT * , DATEDIFF(DAY, Discharge_Date, ReferralRequest_ReceivedDate) AS DaysBetweenR
INTO #_lnk_APC_CSDS1
FROM #_lnk_APC_CSDS
WHERE Der_Pseudo_NHS_Number IS NOT NULL

-- Identify Referral Request date
DROP TABLE IF EXISTS #_lnk_APC_CSDS2
SELECT * 
INTO #_lnk_APC_CSDS2
FROM (SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY Der_Pseudo_NHS_Number,ReferralRequest_ReceivedDate ORDER BY DaysBetweenR) AS RowNum
    FROM #_lnk_APC_CSDS1
	) AS A
WHERE Unique_ServiceRequestID IS NOT NULL;

-- TEST
SELECT [Pathway],COUNT(*) AS CNT
FROM #_lnk_APC_CSDS2
GROUP BY [Pathway]

SELECT Pathway, COUNT(*) AS CNT
FROM  (SELECT DISTINCT Der_Pseudo_NHS_Number, Admission_Date, Pathway FROM #_lnk_APC_CSDS2) A
GROUP BY Pathway 

SELECT * FROM #_lnk_APC_CSDS2
ORDER BY Der_Pseudo_NHS_Number, Admission_Date;

-- LINK TO Service Type
DROP TABLE IF EXISTS #_lnk_APC_CSDS3
SELECT 
    A.*,
 	B.[TeamType]
INTO #_lnk_APC_CSDS3
FROM #_lnk_APC_CSDS2 A
LEFT JOIN [<ICB Schema>_RW].[KD_CSDS_ServiceTypeReferredTo] B 
ON A.Der_Pseudo_NHS_Number = B.CMv2_Pseudo_Number AND 
   A.Unique_ServiceRequestID = B.Unique_ServiceRequestID
WHERE  B.[TeamType] IN ('18','51','52','53','54')

-- LINK TO Team Local Identifier
DROP TABLE IF EXISTS #_lnk_APC_CSDS4
SELECT DISTINCT
    A.*,
 	B.[TeamID_Local],
	B.[Contact_Date]
INTO #_lnk_APC_CSDS4
FROM #_lnk_APC_CSDS2 A
LEFT JOIN [<ICB Schema>].[CSDS_CYP201CareContact] B 
ON A.Unique_ServiceRequestID = B.Unique_ServiceRequestID
WHERE 
B.AttendOrNot IN ('5','6') 

---------------------
DROP TABLE IF EXISTS #_lnk_APC_CSDS5
SELECT DISTINCT
    A.*,
	DATEDIFF(DAY, A.[Discharge_Date], A.[Contact_Date]) AS DaysBetweenC,
    B.TeamType
INTO #_lnk_APC_CSDS5
FROM #_lnk_APC_CSDS4 A
LEFT JOIN
    #_lnk_APC_CSDS3 B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number AND 
	B.Unique_ServiceRequestID = A.Unique_ServiceRequestID
WHERE B.[TeamType] IN ('18','51','52','53','54')

-----------------------------------------------------------
DROP TABLE IF EXISTS #_lnk_APC_CSDS6
SELECT  A.*,
	    CASE   -- Assign pathway
			When [TeamType] = '52' then 1
			When [TeamType] = '53' then 1
			When [TeamType] = '54' then 2
			When [Pathway]= 'Other' AND [TeamType] = '18' then 12
			When [Pathway]= 'Other' AND [TeamType] = '51' then 12
			When [Pathway]= 'Pathway 0' AND [TeamType] = '18' then 12
			When [Pathway]= 'Pathway 0' AND [TeamType] = '51' then 12
			When [Pathway]= 'Pathway 0/1' AND [TeamType] = '18' then 1
			When [Pathway]= 'Pathway 0/1' AND [TeamType] = '51' then 1
			When [Pathway]= 'Pathway 2' AND [TeamType] = '18' then 2
			When [Pathway]= 'Pathway 2' AND [TeamType] = '51' then 2
			When [Pathway]= 'Pathway 2/3' AND [TeamType] = '18' then 2
			When [Pathway]= 'Pathway 2/3' AND [TeamType] = '51' then 2
			When [Pathway]= 'Pathway 3' AND [TeamType] = '18' then 2
			When [Pathway]= 'Pathway 3' AND [TeamType] = '51' then 2
		END AS Der_CSDS_Pathway
INTO #_lnk_APC_CSDS6
FROM #_lnk_APC_CSDS5 A

-- Create table in [<ICB Schema>_RW]
DROP TABLE IF EXISTS [<ICB Schema>_RW].[KD_NDL_IC_APCStoCSDS]
SELECT * INTO [<ICB Schema>_RW].[KD_NDL_IC_APCStoCSDS] FROM #_lnk_APC_CSDS6 
SELECT COUNT(*) AS CNT FROM [<ICB Schema>_RW].[KD_NDL_IC_APCStoCSDS]

----------------------------------------------------------------
--##############################################################
----------------------------------------------------------------

-- Link APCS admissions to ASC events (Linkage window of 1 week)
DROP TABLE IF EXISTS #_lnk_APC_ASC
SELECT 
    A.*,
	B.[Event_Start_Date],
	B.[Event_End_Date],
    B.[Request:_Route_of_Access],
	B.[Assessment_Type],
	B.[Service_Type],
    B.[Service_Component],
	B.[Unit_Cost],
    B.[Cost_Frequency_(Unit_Type)],
    B.[Planned_units_per_week]
INTO #_lnk_APC_ASC
FROM #_core_cohort A
LEFT JOIN
    [<ICB Schema>].[Adult_Social_Care] B ON A.Der_Pseudo_NHS_Number = B.Der_pseudo_nhsnumber AND 
	B.Event_Start_Date BETWEEN Discharge_Date AND DATEADD(WEEK, 1, A.Discharge_Date);

-- Calculate days between Discharge date and Referral Request date
DROP TABLE IF EXISTS #_lnk_APC_ASC1
SELECT * , DATEDIFF(DAY, Discharge_Date, Event_Start_Date) AS DaysBetween
INTO #_lnk_APC_ASC1
FROM #_lnk_APC_ASC
WHERE Der_Pseudo_NHS_Number IS NOT NULL AND Event_Start_Date IS NOT NULL-- TEST
SELECT COUNT(*) FROM #_lnk_APC_CSDS WHERE Unique_ServiceRequestID IS NOT NULL

DROP TABLE IF EXISTS #_lnk_APC_ASC2
SELECT DISTINCT * 
INTO #_lnk_APC_ASC2
FROM #_lnk_APC_ASC1
WHERE Event_Start_Date IS NOT NULL AND [Request:_Route_of_Access] = 'Discharge from Hospital' AND [Service_Type] LIKE 'Short Term%' 
ORDER BY Der_Pseudo_NHS_Number;

-- Assign pathways
DROP TABLE IF EXISTS #_lnk_APC_ASC3
SELECT  A.*,
	    CASE   -- Assign pathway
			When [Service_Component] = 'Short Term Residential Care' then 1
			When [Pathway] = 'DK' then 12
			When [Pathway]= 'Other' AND [Service_Component] = 'Reablement' then 12
			When [Pathway]= 'Other' AND [Service_Component] = 'Short Term Nursing Care' then 12
			When [Pathway]= 'Other' AND [Service_Component] = 'Other Short Term Support' then 12
			When [Pathway]= 'Pathway 0' AND [Service_Component] = 'Reablement' then 1
			When [Pathway]= 'Pathway 0' AND [Service_Component] = 'Short Term Nursing Care' then 1
			When [Pathway]= 'Pathway 0' AND [Service_Component] = 'Other Short Term Support' then 1
			When [Pathway]= 'Pathway 0/1' AND [Service_Component] = 'Reablement' then 1
			When [Pathway]= 'Pathway 0/1' AND [Service_Component] = 'Short Term Nursing Care' then 1
			When [Pathway]= 'Pathway 0/1' AND [Service_Component] = 'Other Short Term Support' then 1
			When [Pathway]= 'Pathway 2' AND [Service_Component] = 'Reablement' then 2
			When [Pathway]= 'Pathway 2' AND [Service_Component] = 'Short Term Nursing Care' then 2
			When [Pathway]= 'Pathway 2' AND [Service_Component] = 'Other Short Term Support' then 2
			When [Pathway]= 'Pathway 2/3' AND [Service_Component] = 'Reablement' then 2
			When [Pathway]= 'Pathway 2/3' AND [Service_Component] = 'Short Term Nursing Care' then 2
			When [Pathway]= 'Pathway 2/3' AND [Service_Component] = 'Other Short Term Support' then 2
			When [Pathway]= 'Pathway 3' AND [Service_Component] = 'Reablement' then 2
			When [Pathway]= 'Pathway 3' AND [Service_Component] = 'Short Term Nursing Care' then 2
			When [Pathway]= 'Pathway 3' AND [Service_Component] = 'Other Short Term Support' then 2
		END AS Der_ASC_Pathway
INTO #_lnk_APC_ASC3
FROM #_lnk_APC_ASC2 A

-- Create table in [<ICB Schema>_RW]
DROP TABLE IF EXISTS [<ICB Schema>_RW].[KD_NDL_IC_APCStoASC]
SELECT * INTO [<ICB Schema>_RW].[KD_NDL_IC_APCStoASC] FROM #_lnk_APC_ASC3 

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Finalise Core Cohort assigning 0,1,2,and 3 pathways.
----------------------------------------------------------------------------

-- Select unique rows - CSDS dataset
DROP TABLE IF EXISTS #_clean_CSDS
SELECT  
	Der_Pseudo_NHS_Number,
	Admission_Date,
	MIN(ReferralRequest_ReceivedDate) AS Referral_Date,
	COUNT(Contact_Date) AS Contact_Counts,
	MIN(Contact_Date) AS Contact_Start_Date,
	MAX(Contact_Date) AS Contact_End_Date,
	MIN(DaysBetweenR) AS DaysBetweenR,
	MIN(DaysBetweenC) AS DaysBetweenC,
	MAX(Der_CSDS_Pathway) AS Der_CSDS_Pathway
INTO #_clean_CSDS
FROM [<ICB Schema>_RW].[KD_NDL_IC_APCStoCSDS]
GROUP BY Der_Pseudo_NHS_Number, Admission_Date

-- Select unique rows - ASC dataset
DROP TABLE IF EXISTS #_clean_ASC
SELECT  
	Der_Pseudo_NHS_Number,
	Admission_Date,
	COUNT(Event_Start_Date) AS Event_Counts,
	MIN(Event_Start_Date) AS Event_Start_Date,
	MAX(Event_End_Date) AS Event_End_Date,
	MIN(DaysBetween) AS DaysBetween,
	MAX(Der_ASC_Pathway) AS Der_ASC_Pathway
INTO #_clean_ASC
FROM [<ICB Schema>_RW].[KD_NDL_IC_APCStoASC]
GROUP BY Der_Pseudo_NHS_Number, Admission_Date

-- Create final linked core cohort
DROP TABLE IF EXISTS #_final_core_cohort
SELECT DISTINCT
    A.*,
	B.Referral_Date,
	B.Contact_Start_Date,
	B.Contact_End_Date,
	B.Contact_Counts,
	B.DaysBetweenR,
	B.DaysBetweenC,
	B.Der_CSDS_Pathway,
	C.Event_Start_Date,
	C.Event_End_Date,
	C.Event_Counts,
	C.DaysBetween,
	C.Der_ASC_Pathway
INTO #_final_core_cohort
FROM [<ICB Schema>_RW].[KD_NDL_IC_CoreCohort] A
LEFT JOIN
    #_clean_CSDS B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number AND 
	B.Admission_Date = A.Admission_Date
LEFT JOIN
    #_clean_ASC C ON A.Der_Pseudo_NHS_Number = C.Der_Pseudo_NHS_Number AND 
	C.Admission_Date = A.Admission_Date

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Get GP_Patient IDs - filter by cohort patients 
DROP TABLE IF EXISTS #_link_cohort_gp
SELECT DISTINCT
    A.Der_Pseudo_NHS_Number,
    A.Admission_Date,
    A.Discharge_Date,
    B.PK_Patient_ID
INTO #_link_cohort_gp
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>].[Patient] B ON A.Der_Pseudo_NHS_Number = B.Pseudo_NHS_Number

-- Linkage with GP_Encounters window of 30 days
DROP TABLE IF EXISTS #_link_cohort_gp0
SELECT 
    A.*,
    B.EncounterDate,
	B.EncounterDescription
INTO #_link_cohort_gp0
FROM #_link_cohort_gp A
LEFT JOIN
    [<ICB Schema>].[GP_Encounters] B ON A.PK_Patient_ID = B.FK_Patient_ID AND 
	B.EncounterDate BETWEEN A.Discharge_Date AND DATEADD(DAY, 30, A.Discharge_Date);

-- Delete Patients with no GP Encounters within 30 days after hospital discharge date
DELETE FROM #_link_cohort_gp0
WHERE EncounterDate IS NULL

-- Count GP Encounters
DROP TABLE IF EXISTS #_link_cohort_gp1
SELECT 
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
    COUNT(*) AS GP_Enc_Count
INTO #_link_cohort_gp1
FROM #_link_cohort_gp0
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date

--------------------------------------------------------------------------------------
-- Linkage with GP_Events window of 30 days
DROP TABLE IF EXISTS #_link_cohort_gp0a
SELECT DISTINCT
    A.*,
    B.EventDate
INTO #_link_cohort_gp0a
FROM #_link_cohort_gp A
LEFT JOIN
    [<ICB Schema>].[GP_Events] B ON A.PK_Patient_ID = B.FK_Patient_ID AND 
	B.EventDate BETWEEN A.Discharge_Date AND DATEADD(DAY, 30, A.Discharge_Date);

-- Delete Patients with no GP event within 30 days after hospital discharge date
DELETE FROM #_link_cohort_gp0a
WHERE EventDate IS NULL

-- Count events
DROP TABLE IF EXISTS #_link_cohort_gp1a
SELECT 
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MIN(EventDate) AS GP_Event_Date,
    COUNT(*) AS GP_Events_Count
INTO #_link_cohort_gp1a
FROM #_link_cohort_gp0a
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

-- Linkage with APCS admission -  window of 30 days
DROP TABLE IF EXISTS #_link_cohort_apcs
SELECT 
    A.*,
    B.Admission_Date AS R_Adm30_Date
INTO #_link_cohort_apcs
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>].[vw_SUS_Faster_APCS] B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number AND 
	B.Admission_Date BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 30, A.Discharge_Date)

-- Delete Patients with no APC admission within 30 days after hospital discharge date
DELETE FROM #_link_cohort_apcs
WHERE R_Adm30_Date IS NULL

-- Count admissions
DROP TABLE IF EXISTS #_link_cohort_apcs30
SELECT 
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MIN(R_Adm30_Date) AS R_Adm30_Date,
    COUNT(*) AS R_Adm30_Count
INTO #_link_cohort_apcs30
FROM #_link_cohort_apcs
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Linkage with APCS admission -  window of 60 days
DROP TABLE IF EXISTS #_link_cohort_apcs
SELECT 
    A.*,
    B.Admission_Date AS R_Adm60_Date
INTO #_link_cohort_apcs
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>].[vw_SUS_Faster_APCS] B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number AND 
	B.Admission_Date BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 60, A.Discharge_Date)

SELECT COUNT(*) FROM #_link_cohort_apcs
-- Delete Patients with no APC admission within 60 days after hospital discharge date
DELETE FROM #_link_cohort_apcs
WHERE R_Adm60_Date IS NULL

-- Count admissions
DROP TABLE IF EXISTS #_link_cohort_apcs60
SELECT 
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MIN(R_Adm60_Date) AS R_Adm60_Date,
    COUNT(*) AS R_Adm60_Count
INTO #_link_cohort_apcs60
FROM #_link_cohort_apcs
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Linkage with APCS admission -  window of 90 days
DROP TABLE IF EXISTS #_link_cohort_apcs
SELECT 
    A.*,
    B.Admission_Date AS R_Adm90_Date
INTO #_link_cohort_apcs
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>].[vw_SUS_Faster_APCS] B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number AND 
	B.Admission_Date BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 90, A.Discharge_Date)

-- Delete Patients with no APC admission within 90 days after hospital discharge date
DELETE FROM #_link_cohort_apcs
WHERE R_Adm90_Date IS NULL

-- Count admissions
DROP TABLE IF EXISTS #_link_cohort_apcs90
SELECT 
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MIN(R_Adm90_Date) AS R_Adm90_Date,
    COUNT(*) AS R_Adm90_Count
INTO #_link_cohort_apcs90
FROM #_link_cohort_apcs
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Linkage with A&E attendance -  window of 30 days
DROP TABLE IF EXISTS #_link_cohort_ae
SELECT 
    A.*,
    B.Arrival_Date AS R_Att_Date
INTO #_link_cohort_ae
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>].[vw_SUS_Faster_ECDS] B ON A.Der_Pseudo_NHS_Number = B.CMv2_Pseudo_Number AND 
	B.Arrival_Date BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 30, A.Discharge_Date)

-- Delete Patients with no A&E attedances within 30 days after hospital discharge date
DELETE FROM #_link_cohort_ae
WHERE R_Att_Date IS NULL

-- Count attedances
DROP TABLE IF EXISTS #_link_cohort_ae0
SELECT 
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MIN(R_Att_Date) AS R_Att_Date,
    COUNT(*) AS R_Att_Count
INTO #_link_cohort_ae0
FROM #_link_cohort_ae
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Linkage with 111 calls -  window of 30 days
DROP TABLE IF EXISTS #_link_cohort_111
SELECT 
    A.*,
    B.Triage_Start_Date AS R_111_Date
INTO #_link_cohort_111
FROM #_final_core_cohort A
LEFT JOIN   -- ????????????????????? Access to <ICB Schema> schema - Tom is okay with this
    [<ICB Schema>].[vw_NWAS_111_Data] B ON A.Der_Pseudo_NHS_Number = B.Z_PSEUDO_NHS_NUMBER AND 
	B.Triage_Start_Date BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 30, A.Discharge_Date)

-- Delete Patients with no 111 calls within 30 days after hospital discharge date
DELETE FROM #_link_cohort_111
WHERE R_111_Date IS NULL


-- Count appointments
DROP TABLE IF EXISTS #_link_cohort_111a
SELECT 
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MIN(R_111_Date) AS R_111_Date,
	COUNT(*) AS R_111_Count
INTO #_link_cohort_111a
FROM #_link_cohort_111
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date



----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Linkage with APCS admission -  past 12 months
DROP TABLE IF EXISTS #_link_cohort_apcs
SELECT 
    A.*,
    B.Admission_Date AS Adm12_Date
INTO #_link_cohort_apcs
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>].[vw_SUS_Faster_APCS] B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number AND 
	B.Admission_Date BETWEEN DATEADD(MONTH, -12, A.Admission_Date) AND DATEADD(DAY,-1, A.Admission_Date)
SELECT TOP(100) * FROM #_link_cohort_apcs12 ORDER BY Adm12_Date
-- Delete Patients with no APC admission within 30 days after hospital discharge date
DELETE FROM #_link_cohort_apcs
WHERE Adm12_Date IS NULL

-- Count admissions
DROP TABLE IF EXISTS #_link_cohort_apcs12
SELECT DISTINCT
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MAX(Adm12_Date) AS Adm12_Date,
    COUNT(*) AS Adm12_Count
INTO #_link_cohort_apcs12
FROM #_link_cohort_apcs
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Linkage with Mortality -  window of 30 days
DROP TABLE IF EXISTS #_link_cohort_death30a
SELECT 
    A.*,
    Z1.Date_of_Death AS DoD30
INTO #_link_cohort_death30a
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>_RW].[RP002_MPI] Z1 ON A.Der_Pseudo_NHS_Number = Z1.Pseudo_NHS_Number AND 
	Z1.Date_of_Death BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 30, A.Discharge_Date)

DELETE FROM #_link_cohort_death30a
WHERE DoD30 IS NULL

DROP TABLE IF EXISTS #_link_cohort_death30
SELECT DISTINCT
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MAX(DoD30) AS DoD30
INTO #_link_cohort_death30
FROM #_link_cohort_death30a
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date


-- Linkage with Mortality -  window of 60 days
DROP TABLE IF EXISTS #_link_cohort_death60a
SELECT 
    A.*,
    Z1.Date_of_Death AS DoD60
INTO #_link_cohort_death60a
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>_RW].[RP002_MPI] Z1 ON A.Der_Pseudo_NHS_Number = Z1.Pseudo_NHS_Number AND 
	Z1.Date_of_Death BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 60, A.Discharge_Date)

DELETE FROM #_link_cohort_death60a
WHERE DoD60 IS NULL

DROP TABLE IF EXISTS #_link_cohort_death60
SELECT DISTINCT
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MAX(DoD60) AS DoD60
INTO #_link_cohort_death60
FROM #_link_cohort_death60a
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date

-- Linkage with Mortality -  window of 90 days
DROP TABLE IF EXISTS #_link_cohort_death90a
SELECT 
    A.*,
    Z1.Date_of_Death AS DoD90
INTO #_link_cohort_death90a
FROM #_final_core_cohort A
LEFT JOIN
    [<ICB Schema>_RW].[RP002_MPI] Z1 ON A.Der_Pseudo_NHS_Number = Z1.Pseudo_NHS_Number AND 
	Z1.Date_of_Death BETWEEN DATEADD(DAY,1, A.Discharge_Date) AND DATEADD(DAY, 90, A.Discharge_Date)

DELETE FROM #_link_cohort_death90a
WHERE DoD90 IS NULL

DROP TABLE IF EXISTS #_link_cohort_death90
SELECT DISTINCT
    Der_Pseudo_NHS_Number,
    Admission_Date,
    Discharge_Date,
	MAX(DoD90) AS DoD90
INTO #_link_cohort_death90
FROM #_link_cohort_death90a
GROUP BY Der_Pseudo_NHS_Number,Admission_Date,Discharge_Date
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Combine all
DROP TABLE IF EXISTS #_link_all
SELECT DISTINCT
    A.*,
	L.FrailtyScore,
	M.IMD_decile,
	N.TotalHousehold,
	N.LivingAlone,
	N.LivingWithUnder18,
	N.Carer,
	N.Segment,
	N.Hypertension,
	N.Cancer,
	N.Diabetes,
	N.CVD,
	N.Heart_failure,
	N.CKD,
	N.Asthma,
	N.COPD,
	N.Depression,
	BB.GP_Event_Date,
	BB.GP_Events_Count,
	C0.Adm12_Date,
	C0.Adm12_Count,
	C1.R_Adm30_Date,
	C1.R_Adm30_Count,
	Z1.DoD30,
	C2.R_Adm60_Date,
	C2.R_Adm60_Count,
	Z2.DoD60,
	C3.R_Adm90_Date,
	C3.R_Adm90_Count,
	Z3.DoD90,
	D.R_Att_Count,
	E.R_111_Count
INTO #_link_all
FROM #_final_core_cohort A
LEFT JOIN
    #_link_cohort_gp1 B ON A.Der_Pseudo_NHS_Number = B.Der_Pseudo_NHS_Number AND 
	B.Discharge_Date = A.Discharge_Date
LEFT JOIN
    #_link_cohort_gp1a BB ON A.Der_Pseudo_NHS_Number = BB.Der_Pseudo_NHS_Number AND 
	BB.Discharge_Date = A.Discharge_Date
LEFT JOIN
    #_link_cohort_apcs12 C0 ON A.Der_Pseudo_NHS_Number = C0.Der_Pseudo_NHS_Number AND 
	C0.Admission_Date = A.Admission_Date
LEFT JOIN
    #_link_cohort_apcs30 C1 ON A.Der_Pseudo_NHS_Number = C1.Der_Pseudo_NHS_Number AND 
	C1.Discharge_Date = A.Discharge_Date
LEFT JOIN
    #_link_cohort_apcs60 C2 ON A.Der_Pseudo_NHS_Number = C2.Der_Pseudo_NHS_Number AND 
	C2.Discharge_Date = A.Discharge_Date
LEFT JOIN
    #_link_cohort_apcs90 C3 ON A.Der_Pseudo_NHS_Number = C3.Der_Pseudo_NHS_Number AND 
	C3.Discharge_Date = A.Discharge_Date
LEFT JOIN
    #_link_cohort_ae0 D ON A.Der_Pseudo_NHS_Number = D.Der_Pseudo_NHS_Number AND 
	D.Discharge_Date = A.Discharge_Date
LEFT JOIN
    #_link_cohort_111a E ON A.Der_Pseudo_NHS_Number = E.Der_Pseudo_NHS_Number AND 
	E.Discharge_Date = A.Discharge_Date
LEFT JOIN
    [<ICB Schema>_RW].[RP003_MPI] L ON A.Der_Pseudo_NHS_Number  = L.Pseudo_NHS_Number
LEFT JOIN
    [<ICB Schema>_RW].[JWRefIMD] M ON A.LSOA11  = M.LSOA_code_2011
LEFT JOIN
    [<ICB Schema>_RW].[RP103_Segmentation] N ON A.Der_Pseudo_NHS_Number  = N.Pseudo_NHS_Number
LEFT JOIN
	#_link_cohort_death30 Z1 ON A.Der_Pseudo_NHS_Number  = Z1.Der_Pseudo_NHS_Number AND 
	Z1.Discharge_Date = A.Discharge_Date
LEFT JOIN
	#_link_cohort_death60 Z2 ON A.Der_Pseudo_NHS_Number  = Z2.Der_Pseudo_NHS_Number AND 
	Z2.Discharge_Date = A.Discharge_Date
LEFT JOIN
	#_link_cohort_death90 Z3 ON A.Der_Pseudo_NHS_Number  = Z3.Der_Pseudo_NHS_Number AND 
	Z3.Discharge_Date = A.Discharge_Date


-- Create table in [<ICB Schema>_RW]
DROP TABLE IF EXISTS [<ICB Schema>_RW].[KD_NDL_IC_LinkedCoreCohort]
SELECT * INTO [<ICB Schema>_RW].[KD_NDL_IC_LinkedCoreCohort] FROM #_link_all 

