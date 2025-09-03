-- Active: 1739013567819@@127.0.0.1@3306@Bank_Loan_DB
-- As I am using macbook for this proeject I will be using the docker and azure data studio simuntaneously to
-- load my raw data to the database. I am also going to give an overview of how to do the same and also
-- I am going to write the table creation and cleaning data sql query if anybody needs it.


show databases;

use Bank_loan_db;


show tables;

drop table financial_loan;
-- lets  create the table according to the csv file

CREATE TABLE financial_loan (
    id BIGINT PRIMARY KEY,
    address_state VARCHAR(5),
    application_type VARCHAR(50),
    emp_length VARCHAR(20),
    emp_title VARCHAR(255) DEFAULT NULL,
    grade CHAR(1),
    home_ownership VARCHAR(20),
    issue_date DATE,
    last_credit_pull_date DATE,
    last_payment_date DATE,
    loan_status VARCHAR(50),
    next_payment_date DATE,
    member_id BIGINT,
    purpose VARCHAR(100),
    sub_grade VARCHAR(5),
    term VARCHAR(20),
    verification_status VARCHAR(50),
    annual_income float,
    dti float,
    installment float,
    int_rate float,
    loan_amount INT,
    total_acc INT,
    total_payment BIGINT
);


-- this enables the LOCAL INFILE feature in MySQL, 
--which allows the server to read data files from the local file system.
Set global local_infile = 1;


-- as I had not cleaned the data set I was getting all 0s for the dates in the loaded data in the database 

-- so I used python to clean the data and change the date format to yyyy-mm-dd and then load the data to the table in DB

-- now lets add data from local to the table that I just now created using the 
--load data query
LOAD DATA LOCAL INFILE 
'/Users/shahjadaemirsaqualain/Documents/Data analyst projects/Bank Loan Analysis Project/financial_loans_clean.csv'
INTO TABLE financial_loan
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- now lets check if the data is loaded properly or not
Select * from financial_loan
limit 100;


-- lets check if the rows match the rows in the csv file
select count(id) as total_loan_applications from financial_loan;


-- here while pushing this file to the github repo you might face the isssue of 
-- Git: RPC failed; HTTP 400 curl 56 The requested URL returned error: 400

-- so you need to write one line of code to increase the size of the git's buffer size using the below mentioned line 

git config --global http.postBuffer 524288000


-- after this you will be able to commit the changes to the git hub



-- NOW LETS GO ACCORDING TO THE PROBLEM STATEMENTS (LETS EXCEUTE THE PROBLEMS ASKED)

1. Total Loan Applications: We need to calculate the total number of loan applications received during a specified period.
 Additionally, it is essential to monitor the Month-to-Date (MTD) Loan Applications and track changes Month-over-Month (MoM).

Select count(id) as MonthToDate_Total_loan_applications from financial_loan
where month(issue_date) = 12 and YEAR(issue_date) = 2021;


Output 
+-------------------------------------+
| MonthToDate_Total_loan_applications |
+-------------------------------------+
|                                4314 |
+-------------------------------------+
1 row in set (0.10 sec)



-- Now lets do the Month over Month (MOM)

WITH monthly_applications AS (
    SELECT 
        DATE_FORMAT(issue_date, '%Y-%m') AS month,
        COUNT(id) AS applications
    FROM financial_loan
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
)
SELECT 
    month,
    applications,
    LAG(applications) OVER (ORDER BY month) AS prev_month_applications,
    ROUND(
        (applications - LAG(applications) OVER (ORDER BY month)) 
        / NULLIF(LAG(applications) OVER (ORDER BY month),0) * 100, 2
    ) AS MoM_change_percent
FROM monthly_applications
ORDER BY month;


Output
+---------+--------------+-------------------------+--------------------+
| month   | applications | prev_month_applications | MoM_change_percent |
+---------+--------------+-------------------------+--------------------+
| 2021-01 |         2332 |                    NULL |               NULL |
| 2021-02 |         2279 |                    2332 |              -2.27 |
| 2021-03 |         2627 |                    2279 |              15.27 |
| 2021-04 |         2755 |                    2627 |               4.87 |
| 2021-05 |         2911 |                    2755 |               5.66 |
| 2021-06 |         3184 |                    2911 |               9.38 |
| 2021-07 |         3366 |                    3184 |               5.72 |
| 2021-08 |         3441 |                    3366 |               2.23 |
| 2021-09 |         3536 |                    3441 |               2.76 |
| 2021-10 |         3796 |                    3536 |               7.35 |
| 2021-11 |         4035 |                    3796 |               6.30 |
| 2021-12 |         4314 |                    4035 |               6.91 |
+---------+--------------+-------------------------+--------------------+
12 rows in set (0.07 sec)




2. Total Funded Amount: Understanding the total amount of funds disbursed as loans is crucial. 
We also want to keep an eye on the MTD Total Funded Amount and analyse the Month-over-Month (MoM) changes in this metric.



