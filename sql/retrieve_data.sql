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


---------------------- GOOD LOAN KPI'S -----------------------------------------------------

select DISTINCT loan_status from financial_loan;


5.Good loan application percentage


Select 
    Round((count(case when loan_status='Fully Paid' or loan_status='Current' then id end))
    /
    count(id) * 100,2) as good_loan_percentage
From financial_loan;



Output
+----------------------+
| good_loan_percentage |
+----------------------+
|                86.18 |
+----------------------+
1 row in set (0.08 sec)




6. Good loan applications 


Select count(id) as Good_loan_applications from financial_loan
where loan_status = 'Fully paid' or loan_status = 'current';


Output 
+------------------------+
| Good_loan_applications |
+------------------------+
|                  33243 |
+------------------------+
1 row in set (0.03 sec)


7. Good loan funded amount 


Select sum(loan_amount) as Good_loan_funded_amount from financial_loan
where loan_status = 'Fully paid' or loan_status = 'current';


Output
+-------------------------+
| Good_loan_funded_amount |
+-------------------------+
|               370224850 |
+-------------------------+
1 row in set (0.03 sec)



8. Good Loan total amount recieved 


Select sum(total_payment) as Good_loan_total_amount_received from financial_loan
where loan_status = 'Fully paid' or loan_status = 'current';


Output
+---------------------------------+
| Good_loan_total_amount_received |
+---------------------------------+
|                       435786170 |
+---------------------------------+
1 row in set (0.03 sec)




---------------------- BAD LOAN KPI'S -----------------------------------------------------


9. Bad loan application percentage 


Select 
    Round((count(case when loan_status='Charged off' then id end))
    /
    count(id) * 100,2) as Bad_loan_percentage
From financial_loan;



Output 
+----------------------+
| Bad_loan_percentage  |
+----------------------+
|                13.82 |
+----------------------+
1 row in set (0.03 sec)



10. Bad Loan Applications


Select count(id) as Good_loan_applications from financial_loan
where loan_status = 'Charged Off';


Output  
+------------------------+
| Good_loan_applications |
+------------------------+
|                   5333 |
+------------------------+
1 row in set (0.05 sec)




11. Bad loan funded amount


Select sum(loan_amount) as Bad_loan_funded_amount from financial_loan
where loan_status = 'Charged Off';


Output
+------------------------+
| Bad_loan_funded_amount |
+------------------------+
|               65532225 |
+------------------------+
1 row in set (0.05 sec)



12. Bad Loan total amount recieved



Select sum(total_payment) as Bad_loan_total_pahyment_recieved from financial_loan
where loan_status = 'Charged Off';



Output
+----------------------------------+
| Bad_loan_total_pahyment_recieved |
+----------------------------------+
|                         37284763 |
+----------------------------------+
1 row in set (0.03 sec)


13. Total loss incurred by the bank against the bad loans 



Select sum(loan_amount)-sum(total_payment) from financial_loan
where loan_status = 'charged off';



output
+-------------------------------------+
| sum(loan_amount)-sum(total_payment) |
+-------------------------------------+
|                            28247462 |
+-------------------------------------+
1 row in set (0.04 sec)




14 . Loan status grid view 

WITH base_data AS (
    SELECT 
        loan_status,
        COUNT(id) AS total_loan_applications,
        SUM(loan_amount) AS total_funded_amount,
        SUM(total_payment) AS total_amount_received,
        Round(AVG(int_rate) * 100,2) AS avg_interest_rate,
        ROUND(AVG(dti)*100,2) AS avg_dti,
        SUM(loan_amount) as MTD_total_funded_amount,
        SUM(total_payment) AS mtd_amount_received
    FROM financial_loan
    GROUP BY loan_status
)
SELECT *
FROM base_data



output 
+-------------+-------------------------+---------------------+-----------------------+-------------------+---------+-------------------------+---------------------+
| loan_status | total_loan_applications | total_funded_amount | total_amount_received | avg_interest_rate | avg_dti | MTD_total_funded_amount | mtd_amount_received |
+-------------+-------------------------+---------------------+-----------------------+-------------------+---------+-------------------------+---------------------+
| Fully Paid  |                   32145 |           351358350 |             411586256 |             11.64 |   13.17 |               351358350 |           411586256 |
| Charged Off |                    5333 |            65532225 |              37284763 |             13.88 |      14 |                65532225 |            37284763 |
| Current     |                    1098 |            18866500 |              24199914 |              15.1 |   14.72 |                18866500 |            24199914 |
+-------------+-------------------------+---------------------+-----------------------+-------------------+---------+-------------------------+---------------------+
3 rows in set (0.07 sec)



15. Monthly Trends by Issue Date (Line Chart):  To identify seasonality and long-term trends in lending activities




Select 
    Month(issue_date) as Month_number,
    DATE_FORMAT(issue_date,'%M') as Month_name,
    Count(id) as Total_applications,
    Sum(loan_amount) as total_funded_amount,
    Sum(total_payment) as Total_payment_recieved
From financial_loan
Group by Month(issue_date), DATE_FORMAT(Issue_date,'%M')
order by Month(issue_date) asc;


Output
+--------------+------------+--------------------+---------------------+------------------------+
| Month_number | Month_name | Total_applications | total_funded_amount | Total_payment_recieved |
+--------------+------------+--------------------+---------------------+------------------------+
|            1 | January    |               2332 |            25031650 |               27578836 |
|            2 | February   |               2279 |            24647825 |               27717745 |
|            3 | March      |               2627 |            28875700 |               32264400 |
|            4 | April      |               2755 |            29800800 |               32495533 |
|            5 | May        |               2911 |            31738350 |               33750523 |
|            6 | June       |               3184 |            34161475 |               36164533 |
|            7 | July       |               3366 |            35813900 |               38827220 |
|            8 | August     |               3441 |            38149600 |               42682218 |
|            9 | September  |               3536 |            40907725 |               43983948 |
|           10 | October    |               3796 |            44893800 |               49399567 |
|           11 | November   |               4035 |            47754825 |               50132030 |
|           12 | December   |               4314 |            53981425 |               58074380 |
+--------------+------------+--------------------+---------------------+------------------------+
12 rows in set (0.09 sec)




16. Regional Analysis by State (Filled Map): To identify regions with significant lending activity and assess regional disparities



Select 
    address_state,
    Count(id) as Total_applications,
    Sum(loan_amount) as total_funded_amount,
    Sum(total_payment) as Total_payment_recieved
From financial_loan
Group by address_state
order by Sum(loan_amount) desc;


Output (ordered by address state)
+---------------+--------------------+---------------------+------------------------+
| address_state | Total_applications | total_funded_amount | Total_payment_recieved |
+---------------+--------------------+---------------------+------------------------+
| AK            |                 78 |             1031800 |                1108570 |
| AL            |                432 |             4949225 |                5492272 |
| AR            |                236 |             2529700 |                2777875 |
| AZ            |                833 |             9206000 |               10041986 |
| CA            |               6894 |            78484125 |               83901234 |
| CO            |                770 |             8976000 |                9845810 |
| CT            |                730 |             8435575 |                9357612 |
| DC            |                214 |             2652350 |                2921854 |
| DE            |                110 |             1138100 |                1269136 |
| FL            |               2773 |            30046125 |               31601905 |
| GA            |               1355 |            15480325 |               16728040 |
| HI            |                170 |             1850525 |                2080184 |
| IA            |                  5 |               56450 |                  64482 |
| ID            |                  6 |               59750 |                  65329 |
| IL            |               1486 |            17124225 |               18875941 |
| IN            |                  9 |               86225 |                  85521 |
| KS            |                260 |             2872325 |                3247394 |
| KY            |                320 |             3504100 |                3792530 |
| LA            |                426 |             4498900 |                5001160 |
| MA            |               1310 |            15051000 |               16676279 |
| MD            |               1027 |            11911400 |               12985170 |
| ME            |                  3 |                9200 |                  10808 |
| MI            |                685 |             7829900 |                8543660 |
| MN            |                592 |             6302600 |                6750746 |
| MO            |                660 |             7151175 |                7692732 |
| MS            |                 19 |              139125 |                 149342 |
| MT            |                 79 |              829525 |                 892047 |
| NC            |                759 |             8787575 |                9534813 |
| NE            |                  5 |               31700 |                  24542 |
| NH            |                161 |             1917900 |                2101386 |
| NJ            |               1822 |            21657475 |               23425159 |
| NM            |                183 |             1916775 |                2084485 |
| NV            |                482 |             5307375 |                5451443 |
| NY            |               3701 |            42077050 |               46108181 |
| OH            |               1188 |            12991375 |               14330148 |
| OK            |                293 |             3365725 |                3712649 |
| OR            |                436 |             4720150 |                4966903 |
| PA            |               1482 |            15826525 |               17462908 |
| RI            |                196 |             1883025 |                2001774 |
| SC            |                464 |             5080475 |                5462458 |
| SD            |                 63 |              606150 |                 656514 |
| TN            |                 17 |              162175 |                 141522 |
| TX            |               2664 |            31236650 |               34392715 |
| UT            |                252 |             2849225 |                2952412 |
| VA            |               1375 |            15982650 |               17711443 |
| VT            |                 54 |              504100 |                 534973 |
| WA            |                805 |             8855525 |                9531739 |
| WI            |                446 |             5070450 |                5485161 |
| WV            |                167 |             1830525 |                1991936 |
| WY            |                 79 |              890750 |                1046050 |
+---------------+--------------------+---------------------+------------------------+
50 rows in set (0.09 sec)




Output (Ordered by sum of total funded amount by bank)
+---------------+--------------------+---------------------+------------------------+
| address_state | Total_applications | total_funded_amount | Total_payment_recieved |
+---------------+--------------------+---------------------+------------------------+
| CA            |               6894 |            78484125 |               83901234 |
| NY            |               3701 |            42077050 |               46108181 |
| TX            |               2664 |            31236650 |               34392715 |
| FL            |               2773 |            30046125 |               31601905 |
| NJ            |               1822 |            21657475 |               23425159 |
| IL            |               1486 |            17124225 |               18875941 |
| VA            |               1375 |            15982650 |               17711443 |
| PA            |               1482 |            15826525 |               17462908 |
| GA            |               1355 |            15480325 |               16728040 |
| MA            |               1310 |            15051000 |               16676279 |
| OH            |               1188 |            12991375 |               14330148 |
| MD            |               1027 |            11911400 |               12985170 |
| AZ            |                833 |             9206000 |               10041986 |
| CO            |                770 |             8976000 |                9845810 |
| WA            |                805 |             8855525 |                9531739 |
| NC            |                759 |             8787575 |                9534813 |
| CT            |                730 |             8435575 |                9357612 |
| MI            |                685 |             7829900 |                8543660 |
| MO            |                660 |             7151175 |                7692732 |
| MN            |                592 |             6302600 |                6750746 |
| NV            |                482 |             5307375 |                5451443 |
| SC            |                464 |             5080475 |                5462458 |
| WI            |                446 |             5070450 |                5485161 |
| AL            |                432 |             4949225 |                5492272 |
| OR            |                436 |             4720150 |                4966903 |
| LA            |                426 |             4498900 |                5001160 |
| KY            |                320 |             3504100 |                3792530 |
| OK            |                293 |             3365725 |                3712649 |
| KS            |                260 |             2872325 |                3247394 |
| UT            |                252 |             2849225 |                2952412 |
| DC            |                214 |             2652350 |                2921854 |
| AR            |                236 |             2529700 |                2777875 |
| NH            |                161 |             1917900 |                2101386 |
| NM            |                183 |             1916775 |                2084485 |
| RI            |                196 |             1883025 |                2001774 |
| HI            |                170 |             1850525 |                2080184 |
| WV            |                167 |             1830525 |                1991936 |
| DE            |                110 |             1138100 |                1269136 |
| AK            |                 78 |             1031800 |                1108570 |
| WY            |                 79 |              890750 |                1046050 |
| MT            |                 79 |              829525 |                 892047 |
| SD            |                 63 |              606150 |                 656514 |
| VT            |                 54 |              504100 |                 534973 |
| TN            |                 17 |              162175 |                 141522 |
| MS            |                 19 |              139125 |                 149342 |
| IN            |                  9 |               86225 |                  85521 |
| ID            |                  6 |               59750 |                  65329 |
| IA            |                  5 |               56450 |                  64482 |
| NE            |                  5 |               31700 |                  24542 |
| ME            |                  3 |                9200 |                  10808 |
+---------------+--------------------+---------------------+------------------------+
50 rows in set (0.09 sec)




17. Loan Term Analysis (Donut Chart): To allow the client to understand the distribution of loans across various term lengths.



select 
    term,
    count(id) as Total_loan_applications,
    sum(loan_amount) as Total_funded_applications,
    sum(total_payment) as total_amount_recieved
From financial_loan
group by term
order By term;




Output
+------------+-------------------------+---------------------------+-----------------------+
| term       | Total_loan_applications | Total_funded_applications | total_amount_recieved |
+------------+-------------------------+---------------------------+-----------------------+
|  36 months |                   28237 |                 273041225 |             294709458 |
|  60 months |                   10339 |                 162715850 |             178361475 |
+------------+-------------------------+---------------------------+-----------------------+
2 rows in set (0.25 sec)


