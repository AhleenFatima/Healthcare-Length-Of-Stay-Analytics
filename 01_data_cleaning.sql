SELECT * FROM raw_length_of_stay LIMIT 10;
CREATE OR REPLACE VIEW vw_hospital_admissions AS
WITH DataCleaningCTE AS (
    SELECT 
        eid AS patient_id,
        gender,
        facid AS facility_id,
        
        TO_DATE(vdate, 'MM/DD/YYYY') AS admission_date,
        TO_DATE(discharged, 'MM/DD/YYYY') AS discharge_date,
        
        lengthofstay,
        
        -- Business Logic (CASE WHEN): BMI Categories banana
        CASE 
            WHEN bmi < 18.5 THEN 'Underweight'
            WHEN bmi >= 18.5 AND bmi < 25.0 THEN 'Normal'
            WHEN bmi >= 25.0 AND bmi < 30.0 THEN 'Overweight'
            ELSE 'Obese'
        END AS bmi_category,
        
        CASE 
            WHEN dialysisrenalendstage = 1 OR asthma = 1 OR pneum = 1 OR hemo = 1 THEN 'High Risk - Medical'
            WHEN psychologicaldisordermajor = 1 OR depress = 1 THEN 'Medium Risk - Psych'
            ELSE 'Standard'
        END AS risk_category
        
    FROM raw_length_of_stay
)
SELECT 
    *,
    RANK() OVER (PARTITION BY facility_id ORDER BY lengthofstay DESC) AS los_rank_per_facility
FROM DataCleaningCTE;