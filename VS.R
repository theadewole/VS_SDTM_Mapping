#Loading libarary
library(haven)
library(lubridate)
library(tidyverse)
library(labelled)
library(openxlsx)

#importinmg the dataset
Vs <- read_sas("C:/Users/PC/Documents/AFSS/Safety Domains/3.VS - Vital Signs/vsraw.sas7bdat")

#creating Vital Signs Date/Time of Collection
Vsdtc <- Vs |> 
  mutate(VSDTC=paste0(ymd(VS_Date),"T",paste0(substr(Time,1,2),":",substr(Time,3,4))))

#Transposing the dataset  and selecting needed variables
Transposed <- Vsdtc |> 
  pivot_longer(cols = c(Systolic, Diastolic, Temperature,Respiratory_Rate, Heart_Rate), 
               names_to = "VSTEST", 
               values_to = "VSORRES") |> 
  select(Patient,timepoint,visit,VSDTC,VSORRES,VSTEST) |> 
  rename(USUBJID=Patient,
         EPOCH=timepoint,
         VISIT=visit)

#creating dataset as specified in SDTMIG for the original value and unit
value_unit <- Transposed |> 
  mutate(VSTESTCD=case_when(
  VSTEST =="Systolic"~"SYSBP",
  VSTEST =="Diastolic"~"DIAPB",
  VSTEST =="Respiratory_Rate"~"RESP",
  VSTEST =="Heart_Rate"~"PULSE",
  VSTEST =="Temperature"~"TEMP"),
  VSSTRESU=case_when(
  VSTEST %in% c("Systolic","Diastolic")~"mmHg",
  VSTEST %in% c("Respiratory_Rate","Heart_Rate")~"BPM",
  VSTEST =="Temperature"~"°C"),
  VSORRESU=case_when(
  VSORRES == 96 ~ "°F",
  VSORRES > 96 & VSORRES <= 99.8 ~ '°F',
  VSORRES == 36.4 ~ '°C',
  VSORRES > 36.4 & VSORRES <= 36.9 ~ '°C',
  TRUE ~VSTESTCD),
  VSSTRESN=case_when(
  VSORRESU=="°F"~ round((as.numeric(VSORRES)-32)/9*5,2),
  T~as.numeric(VSORRES)))

#standardizing result and unit
VSSTRESC <- value_unit |> 
  mutate(VSSTRESC=as.character(VSSTRESN)) |> 
  select(USUBJID,VISIT,EPOCH,VSDTC,VSTEST,VSTESTCD,VSORRES,VSORRESU,VSSTRESN,VSSTRESC,VSSTRESU)

#Calculating baseline
VSSTRESN <- VSSTRESC |> 
  arrange(USUBJID,VISIT,VSTEST,VSSTRESU,VSORRESU) |> 
  group_by(USUBJID,VISIT,VSTEST,VSSTRESU,VSORRESU) |>
  summarise(VSSTRESN=round(mean(VSSTRESN),2)) |> 
  mutate(VISIT=case_when(
    VISIT=="Screening"~"Baseline"
  ))

#merging dataset and creating baseline flag
merged <- bind_rows(VSSTRESC,VSSTRESN) |> 
  arrange(USUBJID,VSTEST) |> 
  mutate(VSSTRESC=as.character(VSSTRESN),
         VSDRVFL=case_when(
           VISIT=="Baseline"~"Y"),
         VSBLFL=case_when(
           VISIT=="Baseline"~"Y")) |> 
  group_by(USUBJID) |> 
  mutate(VSSEQ=row_number()) |> 
  ungroup() |> 
  select(14,1:13)

#labelling the dataset
final <- merged |> 
  set_variable_labels(
    VSSEQ="Sequentialnumber of the observation",
    USUBJID="Unique Subject Identifier",
    VISIT="Visit name or number",
    EPOCH="Epoch in the study",
    VSDTC="Date and Time of Collection",
    VSTEST="Vital Signs Test Name",
    VSTESTCD="Vital Signs Test Code",
    VSORRES="Original Result",
    VSORRESU="Original Result Unit",
    VSSTRESN="Standardized Numeric Result",
    VSSTRESC="Standardized Character Result",
    VSSTRESU="Standardized Unit",
    VSDRVFL="Derived Record Flag",
    VSBLFL="Baseline Record Flag"
  )

#writing the final dataset into excel  
write.xlsx(final,"C:/Users/PC/Documents/AFSS/R/Project/vs_sdtm_mapped.xlsx")
