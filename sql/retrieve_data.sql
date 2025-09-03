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
limit 3;

+-------+---------------+------------------+------------+------------------------+-------+----------------+------------+-----------------------+-------------------+-------------+-------------------+-----------+--------------------+-----------+------------+---------------------+---------------+--------+-------------+----------+-------------+-----------+---------------+
| id    | address_state | application_type | emp_length | emp_title              | grade | home_ownership | issue_date | last_credit_pull_date | last_payment_date | loan_status | next_payment_date | member_id | purpose            | sub_grade | term       | verification_status | annual_income | dti    | installment | int_rate | loan_amount | total_acc | total_payment |
+-------+---------------+------------------+------------+------------------------+-------+----------------+------------+-----------------------+-------------------+-------------+-------------------+-----------+--------------------+-----------+------------+---------------------+---------------+--------+-------------+----------+-------------+-----------+---------------+
| 54734 | CA            | INDIVIDUAL       | < 1 year   |                        | B     | RENT           | 2021-08-09 | 2021-08-12            | 2021-10-11        | Fully Paid  | 2021-11-11        |     80364 | Debt consolidation | B4        |  36 months | Verified            |         85000 | 0.1948 |       829.1 |   0.1189 |       25000 |        42 |         29330 |
| 55742 | NY            | INDIVIDUAL       | < 1 year   | CNN                    | B     | RENT           | 2021-05-08 | 2021-08-12            | 2021-06-11        | Fully Paid  | 2021-07-11        |    114426 | credit card        | B5        |  36 months | Not Verified        |         65000 | 0.1429 |      228.22 |   0.1071 |        7000 |         7 |          8216 |
| 57245 | TX            | INDIVIDUAL       | 10+ years  | city of beaumont texas | C     | OWN            | 2021-03-10 | 2021-05-16            | 2021-03-13        | Fully Paid  | 2021-04-13        |    138150 | Debt consolidation | C2        |  36 months | Not Verified        |         54000 | 0.0547 |        40.5 |   0.1311 |        1200 |        31 |          1458 |
+-------+---------------+------------------+------------+------------------------+-------+----------------+------------+-----------------------+-------------------+-------------+-------------------+-----------+--------------------+-----------+------------+---------------------+---------------+--------+-------------+----------+-------------+-----------+---------------+


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


Select count(id) as Total_loan_applications_in_2021 from financial_loan;

Output
+---------------------------------+
| Total_loan_applications_in_2021 |
+---------------------------------+
|                           38576 |
+---------------------------------+
1 row in set (0.07 sec)


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


Select sum(loan_amount) from financial_loan;

Output
+------------------+
| sum(loan_amount) |
+------------------+
|        435757075 |
+------------------+
1 row in set (0.03 sec)



Select sum(loan_amount) as MonthtoMonth_Total_amount_recieved from financial_loan
where MONTH(issue_date) = 12 and year(issue_date) = 2021;


Output 
+------------------------------------+
| MonthtoMonth_Total_amount_recieved |
+------------------------------------+
|                           53981425 |
+------------------------------------+
1 row in set (0.03 sec)



WITH monthly_funded AS (
    SELECT 
        DATE_FORMAT(issue_date, '%Y-%m') AS month,
        SUM(loan_amount) AS total_funded_current_month
    FROM financial_loan
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
)
SELECT 
    month,
    total_funded_current_month,
    LAG(total_funded_current_month) OVER (ORDER BY month) AS prev_month_funded,
    ROUND(
        (total_funded_current_month - LAG(total_funded_current_month) OVER (ORDER BY month)) 
        / NULLIF(LAG(total_funded_current_month) OVER (ORDER BY month), 0) * 100, 2
    ) AS MoM_change_percent,
    SUM(total_funded_current_month) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_funded
FROM monthly_funded
ORDER BY month;




Output 
+---------+----------------------------+-------------------+--------------------+-------------------+
| month   | total_funded_current_month | prev_month_funded | MoM_change_percent | cumulative_funded |
+---------+----------------------------+-------------------+--------------------+-------------------+
| 2021-01 |                   25031650 |              NULL |               NULL |          25031650 |
| 2021-02 |                   24647825 |          25031650 |              -1.53 |          49679475 |
| 2021-03 |                   28875700 |          24647825 |              17.15 |          78555175 |
| 2021-04 |                   29800800 |          28875700 |               3.20 |         108355975 |
| 2021-05 |                   31738350 |          29800800 |               6.50 |         140094325 |
| 2021-06 |                   34161475 |          31738350 |               7.63 |         174255800 |
| 2021-07 |                   35813900 |          34161475 |               4.84 |         210069700 |
| 2021-08 |                   38149600 |          35813900 |               6.52 |         248219300 |
| 2021-09 |                   40907725 |          38149600 |               7.23 |         289127025 |
| 2021-10 |                   44893800 |          40907725 |               9.74 |         334020825 |
| 2021-11 |                   47754825 |          44893800 |               6.37 |         381775650 |
| 2021-12 |                   53981425 |          47754825 |              13.04 |         435757075 |
+---------+----------------------------+-------------------+--------------------+-------------------+
12 rows in set (0.05 sec)




3. Total Amount Received: Tracking the total amount received from borrowers is essential for assessing the banks cash flow and loan repayment. 
We should analyse the Month-to-Date (MTD) Total Amount Received and observe the Month-over-Month (MoM) changes.



select sum(total_payment) as total_payment_recieved from financial_loan;


Output
+------------------------+
| total_payment_recieved |
+------------------------+
|              473070933 |
+------------------------+
1 row in set (0.01 sec)


select sum(total_payment) as total_payment_recieved_dec from financial_loan
where MONTH(issue_date) = 12 and year(issue_date) = 2021;


Output
+----------------------------+
| total_payment_recieved_dec |
+----------------------------+
|                   58074380 |
+----------------------------+
1 row in set (0.05 sec)




 WITH monthly_received AS (
    SELECT 
        DATE_FORMAT(issue_date, '%Y-%m') AS month,
        SUM(total_payment) AS total_received_each_month
    FROM financial_loan
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
)
SELECT 
    month,
    total_received_each_month,
    LAG(total_received_each_month) OVER (ORDER BY month) AS prev_month_received,
    ROUND(
        (total_received_each_month - LAG(total_received_each_month) OVER (ORDER BY month)) 
        / NULLIF(LAG(total_received_each_month) OVER (ORDER BY month), 0) * 100, 2
    ) AS MoM_change_percent,
    SUM(total_received_each_month) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_received
FROM monthly_received
ORDER BY month;


Output
+---------+---------------------------+---------------------+--------------------+---------------------+
| month   | total_received_each_month | prev_month_received | MoM_change_percent | cumulative_received |
+---------+---------------------------+---------------------+--------------------+---------------------+
| 2021-01 |                  27578836 |                NULL |               NULL |            27578836 |
| 2021-02 |                  27717745 |            27578836 |               0.50 |            55296581 |
| 2021-03 |                  32264400 |            27717745 |              16.40 |            87560981 |
| 2021-04 |                  32495533 |            32264400 |               0.72 |           120056514 |
| 2021-05 |                  33750523 |            32495533 |               3.86 |           153807037 |
| 2021-06 |                  36164533 |            33750523 |               7.15 |           189971570 |
| 2021-07 |                  38827220 |            36164533 |               7.36 |           228798790 |
| 2021-08 |                  42682218 |            38827220 |               9.93 |           271481008 |
| 2021-09 |                  43983948 |            42682218 |               3.05 |           315464956 |
| 2021-10 |                  49399567 |            43983948 |              12.31 |           364864523 |
| 2021-11 |                  50132030 |            49399567 |               1.48 |           414996553 |
| 2021-12 |                  58074380 |            50132030 |              15.84 |           473070933 |
+---------+---------------------------+---------------------+--------------------+---------------------+
12 rows in set (0.05 sec)



4. Average Interest Rate: Calculating the average interest rate across all loans, MTD, and monitoring the Month-over-Month (MoM) 
variations in interest rates will provide insights into our lending portfolios overall cost.


SELECT ROUND(AVG(int_rate) * 100, 2) AS Avg_interest_rate FROM financial_loan;

Output
+-------------------+
| Avg_interest_rate |
+-------------------+
|             12.05 |
+-------------------+
1 row in set (0.05 sec)



SELECT ROUND(AVG(int_rate) * 100, 2) AS Avg_interest_rate FROM financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021;


Output 
+-------------------+
| Avg_interest_rate |
+-------------------+
|             12.36 |
+-------------------+
1 row in set (0.03 sec)



WITH monthly_interest AS (
    SELECT 
        DATE_FORMAT(issue_date, '%Y-%m') AS month,
        ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate -- convert fraction to %
    FROM financial_loan
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
)
SELECT 
    month,
    avg_interest_rate,
    LAG(avg_interest_rate) OVER (ORDER BY month) AS prev_month_rate,
    ROUND(
        (avg_interest_rate - LAG(avg_interest_rate) OVER (ORDER BY month)) 
        / NULLIF(LAG(avg_interest_rate) OVER (ORDER BY month), 0) * 100, 2
    ) AS MoM_change_percent
FROM monthly_interest
ORDER BY month;


Output
+---------+-------------------+-----------------+--------------------+
| month   | avg_interest_rate | prev_month_rate | MoM_change_percent |
+---------+-------------------+-----------------+--------------------+
| 2021-01 |             11.46 |            NULL |               NULL |
| 2021-02 |             11.72 |           11.46 |               2.27 |
| 2021-03 |             11.86 |           11.72 |               1.19 |
| 2021-04 |             11.74 |           11.86 |              -1.01 |
| 2021-05 |             12.26 |           11.74 |               4.43 |
| 2021-06 |             12.27 |           12.26 |               0.08 |
| 2021-07 |             12.24 |           12.27 |              -0.24 |
| 2021-08 |              12.3 |           12.24 |               0.49 |
| 2021-09 |                12 |            12.3 |              -2.44 |
| 2021-10 |             12.02 |              12 |               0.17 |
| 2021-11 |             11.94 |           12.02 |              -0.67 |
| 2021-12 |             12.36 |           11.94 |               3.52 |
+---------+-------------------+-----------------+--------------------+
12 rows in set (0.06 sec)




5. Average Debt-to-Income Ratio (DTI): Evaluating the average DTI for our borrowers helps us gauge their financial health. 
We need to compute the average DTI for all loans, MTD, and track Month-over-Month (MoM) fluctuations.


select round(avg(dti)*100,2) as Avg_debt_to_income from financial_loan;


output
+--------------------+
| Avg_debt_to_income |
+--------------------+
|              13.33 |
+--------------------+
1 row in set (0.03 sec)



select round(avg(dti)*100,2) as Avg_debt_to_income from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021;



Output
+--------------------+
| Avg_debt_to_income |
+--------------------+
|              13.67 |
+--------------------+
1 row in set (0.03 sec)


WITH monthly_dti AS (
    SELECT 
        DATE_FORMAT(issue_date, '%Y-%m') AS month,
        ROUND(AVG(dti)*100, 2) AS avg_dti 
    FROM financial_loan
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
)
SELECT 
    month,
    avg_dti,
    LAG(avg_dti) OVER (ORDER BY month) AS prev_month_dti,
    ROUND(
        (avg_dti - LAG(avg_dti) OVER (ORDER BY month)) 
        / NULLIF(LAG(avg_dti) OVER (ORDER BY month), 0) * 100, 2
    ) AS MoM_change_percent
FROM monthly_dti
ORDER BY month;



Output
+---------+---------+----------------+--------------------+
| month   | avg_dti | prev_month_dti | MoM_change_percent |
+---------+---------+----------------+--------------------+
| 2021-01 |   12.94 |           NULL |               NULL |
| 2021-02 |   13.41 |          12.94 |               3.63 |
| 2021-03 |   13.22 |          13.41 |              -1.42 |
| 2021-04 |   13.22 |          13.22 |                  0 |
| 2021-05 |   13.33 |          13.22 |               0.83 |
| 2021-06 |   13.24 |          13.33 |              -0.68 |
| 2021-07 |   13.29 |          13.24 |               0.38 |
| 2021-08 |   13.35 |          13.29 |               0.45 |
| 2021-09 |    13.3 |          13.35 |              -0.37 |
| 2021-10 |   13.41 |           13.3 |               0.83 |
| 2021-11 |    13.3 |          13.41 |              -0.82 |
| 2021-12 |   13.67 |           13.3 |               2.78 |
+---------+---------+----------------+--------------------+
12 rows in set (0.04 sec)
