-- As I am using macbook for this proeject I will be using the docker and azure data studio simuntaneously to
-- load my raw data to the database. I am also going to give an overview of how to do the same and also
-- I am going to write the table creation and cleaning data sql query if anybody needs it.


show databases;

use Bank_loan_db;


show tables;


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
    annual_income DECIMAL(15,2),
    dti DECIMAL(10,4),
    installment DECIMAL(10,2),
    int_rate DECIMAL(6,4),
    loan_amount INT,
    total_acc INT,
    total_payment BIGINT
);


-- this enables the LOCAL INFILE feature in MySQL, 
--which allows the server to read data files from the local file system.
Set global local_infile = 1;



-- now lets add data from local to the table that I just now created using the 
--load data query
LOAD DATA LOCAL INFILE 
'/Users/shahjadaemirsaqualain/Documents/Data analyst projects/Bank Loan Analysis Project/financial_loan.csv'
INTO TABLE financial_loan
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- now lets check if the data is loaded properly or not
Select * from financial_loan;


-- lets check if the rows match the rows in the csv file
select count(id) as total_loan_applications from financial_loan;


-- here while pushing this file to the github repo you might face the isssue of 
-- Git: RPC failed; HTTP 400 curl 56 The requested URL returned error: 400

-- so you need to write one line of code to increase the size of the git's buffer size using the below mentioned line 

git config --global http.postBuffer 524288000