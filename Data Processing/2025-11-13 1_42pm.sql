SELECT
    USERID,
    gender,
    race,
    age,
    province
FROM
    "BRIGHTTV"."ANALYSIS"."USER_PROFILES";
---------------------------break down gender
SELECT
    DISTINCT --- this snippet of code we use to combine null and none into one called unknown
    CASE
        WHEN gender IS NULL THEN 'unknown'
        WHEN gender = 'None' THEN 'unknown'
        ELSE gender
    END AS gender
FROM
    BRIGHTTV.ANALYSIS.USER_PROFILES;
----------Province
SELECT
    DISTINCT CASE
        WHEN province IS NULL THEN 'unknown'
        WHEN province = 'None' THEN 'unknown'
        ELSE province
    END AS province
FROM
    BRIGHTTV.ANALYSIS.USER_PROFILES;
    ------race
SELECT
    DISTINCT CASE
        WHEN race IN ('other', 'None') THEN 'unknown'
        WHEN race is NULL THEN 'unknown'
        ELSE race
    END AS race
FROM
    BRIGHTTV.ANALYSIS.USER_PROFILES;
    ------Province
SELECT
    DISTINCT CASE
        WHEN province IS NULL THEN 'unknown'
        WHEN province = 'None' THEN 'unknown'
        ELSE province
    END AS province
FROM
    BRIGHTTV.ANALYSIS.USER_PROFILES;
--------
SELECT
    *
FROM
    BRIGHTTV.ANALYSIS.USER_PROFILES
WHERE
    age IS NULL;
--------checking for duplicates
SELECT
    COUNT(*) rowCount,
    userid
FROM
    BRIGHTTV.ANALYSIS.USER_PROFILES
GROUP BY
    userid
HAVING
    COUNT (*) > 1;
-----------------------------------------------------------
    CREATE
    OR REPLACE TEMP TABLE PROFILES AS
SELECT
    userid,
    CASE
        WHEN province IS NULL
        OR province = 'None' THEN 'unknown'
        ELSE province
    END AS province,
    CASE
        WHEN race IN ('other', 'None')
        OR race IS NULL THEN 'unknown'
        ELSE race
    END AS race,
    CASE
        WHEN gender IS NULL
        OR gender = 'None' THEN 'unknown'
        ELSE gender
    END AS gender,
    CASE
        WHEN age < 18 THEN 'Children'
        WHEN age BETWEEN 18
        AND 64 THEN 'Adult'
        WHEN age >= 65 THEN 'Elderly'
        ELSE 'Unknown'
    END AS AGE_BUCKET
FROM
    BRIGHTTV.ANALYSIS.USER_PROFILES;
-- Step 1: View original data (optional)
SELECT
    USERID,
    CHANNEL2,
    RECORDDATE2,
    DURATION2
FROM
    BRIGHTTV.ANALYSIS.VIEWERSHIP;
-- Step 2: Create a TEMP table with a proper timestamp column
    CREATE
    OR REPLACE TEMP TABLE VIEWS AS
SELECT
    USERID,
    CHANNEL2,
    TRY_TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI') AS RECORD_TS,
    TO_DATE(RECORD_TS) AS watch_date,
    DAYNAME(RECORD_TS) AS day_name,
    MONTHNAME(RECORD_TS) AS month_name,
    TO_CHAR(RECORD_TS, 'YYYYMM') AS monthID,
    duration2,
    CASE
        WHEN HOUR(RECORD_TS) BETWEEN 5
        AND 11 THEN 'Morning'
        WHEN HOUR(RECORD_TS) BETWEEN 12
        AND 16 THEN 'Midday'
        WHEN HOUR(RECORD_TS) BETWEEN 17
        AND 23 THEN 'Evening'
        ELSE 'Late Night'
    END AS TIME_BUCKET
FROM
    BRIGHTTV.ANALYSIS.VIEWERSHIP;
SELECT
    A.USERID AS view_userid,
    B.USERID AS profile_userid,
    A.CHANNEL2,
    A.RECORD_TS,
    A.WATCH_DATE,
    A.DAY_NAME,
    A.MONTH_NAME,
    A.MONTHID,
    A.DURATION2,
    A.TIME_BUCKET,
    B.PROVINCE,
    B.RACE,
    B.GENDER,
    B.AGE_BUCKET
FROM
    VIEWS A
    LEFT JOIN PROFILES B ON A.USERID = B.USERID;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT USERID) AS distinct_users
FROM
    BRIGHTTV.ANALYSIS.VIEWERSHIP;
WITH per_user AS (
        SELECT
            USERID,
            COUNT(*) AS views_per_user
        FROM
            BRIGHTTV.ANALYSIS.VIEWERSHIP
        GROUP BY
            USERID
    )
SELECT
    COUNT(*) AS user_count,
    SUM(views_per_user) AS total_views,
    AVG(views_per_user) AS avg_views_per_user,
    MIN(views_per_user) AS min_views_per_user,
    MAX(views_per_user) AS max_views_per_user
FROM
    per_user;