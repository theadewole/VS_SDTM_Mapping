#Importing the dataset
library(haven)
library(lubridate)
library(tidyverse)
Vs <- read_sas("C:\\Users\\Adewole\\Documents\\AFSS\\Safety Domains\\3.VS - Vital Signs\\vsraw.sas7bdat")

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

#creating dataset as specified in SDTM IG for the original value and unit
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
  VSORRESU=="°F"~ round((as.numeric(VSORRES)-32)/9*5,1),
  T~as.numeric(VSORRES)))

VSSTRESC <- value_unit |> 
  mutate(VSSTRESC=as.character(VSSTRESN)) |> 
  select(USUBJID,VISIT,EPOCH,VSDTC,VSTEST,VSTESTCD,VSORRES,VSORRESU,VSSTRESN,VSSTRESC,VSSTRESU)


