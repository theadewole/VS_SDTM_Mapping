# Mapping VS dataset to SDTM compliant 

##  Objective
The purpose of this documentation is to outline the process of transforming a raw dataset containing vital signs (VS) parameters in a horizontal format into the standard Study Data Tabulation Model (SDTM) format. The SDTM format requires listing all VS parameters under a single variable and converting dates into the standard format specified by the SDTM Implementation Guide (SDTMIG).

## Data Description
- **Raw Dataset** <br>
The dataset contains vital signs parameters such as temperature, blood pressure, heart rate, etc., in separate columns (horizontal format).
Each row represents a single subject visit or measurement.

## Steps for Transformation
- **Standardize Date Format** <br>
Convert all date fields in the dataset to the standard ISO 8601 date format (YYYY-MM-DD), as required by the SDTMIG.
- **Reshape Data to Vertical Format** <br>
Convert the horizontal format data, where each VS parameter is a separate column, into a vertical format. In the SDTM format, each record should represent a single measurement, and all VS parameters should be listed under one variable.

## Implementation
### Date Conversion
- Identify all date fields in the dataset.
- Convert the date fields to the standard ISO 8601 format using the appropriate date conversion 
### Reshape Data
- Identify all the columns representing different VS parameters in the raw dataset.
- Use data manipulation techniques to transpose the dataset from wide to long format.
- In the resulting dataset, create a new variable (e.g., VSORRES) to store the VS result values.

## Task
- Map the given VS raw dataset into SDTM compliant VS dataset.
- Derive the baseline and add as a new record

## Input
- Vsraw
