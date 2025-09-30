# Bank_Loan_Analysis_Project
30/09/2025

Today, I will be writing the write-up for this project.
## 📌 Project Overview
### 🔍 Objectives
I built an end-to-end interactive <b>bank loan dashboard in Power BI, anchored by SQL queries</b> and a clearly defined problem statement. The dashboards give a bank or financial institution a holistic view of loan portfolio health, with a focus on <b>KPI tracking, loan status analysis, and drill-down insights.</b> 
  
This project is designed to be practical for real-world analytics roles, showing how to move from raw data to decision-ready visuals and documentation.
  
<h5>What I delivered:</h5>

1.  A three-dashboard portfolio: Summary KPI dashboard, Overview dashboard with deeper analytics, and a Details/Grid view.

2.	Dynamic, filter-driven visuals that let stakeholders explore loan data by state, grade, home ownership, loan purpose, term, and more.
   
3.	SQL-based data preparation and validation, backed by a documented problem statement and data-domain knowledge to ensure business relevance.
   
4.	Power BI features including KPI visuals, field parameters for dynamic measures, and smooth navigation between dashboards.  

<img width="1000" height="1000" alt="Express-collage" src="https://github.com/user-attachments/assets/df1b1859-516c-46b1-afdd-738b31458c29" />


---

### 🔍 Data and Domain Knowledge
**•	Data set:** Bank loan data with roughly 38k rows and 24 fields (e.g., ID, address_state, application_type, emp_length, loan_amount, total_payment, int_rate, loan_status etc.).


<img width="1001" height="128" alt="image" src="https://github.com/user-attachments/assets/31756840-25a9-49af-bf4c-d2cf8532eca9" />


**•	Domain concepts I relied on:**

  *	Loan types and statuses (good loans: current or fully paid; bad loans: charged off).

<img width="710" height="128" alt="image" src="https://github.com/user-attachments/assets/e38b7746-bac1-4ee5-be1b-f8437a12222c" />



  *	Core metrics: total loan applications, total funded amount, total amount received, month-to-date (MTD) values, and month-on-month (MOM) changes.

<img width="691" height="255" alt="image" src="https://github.com/user-attachments/assets/63d42dbb-8c56-40c9-a519-a5588a47a5b0" />


  *	Business terms such as DTI (debt-to-income ratio), loan term (e.g., 36/60 months), home ownership status, loan purposes, etc.

<img width="662" height="221" alt="image" src="https://github.com/user-attachments/assets/cddaefe4-3359-48f9-b1a7-b744d905958c" />


**•	Domain Knowledge Documents:** I used reference materials from the course materials to define problem statements, domain terminology, and metric interpretations which I have uploaded in my documents folder of this project.

---

### 🔍 What I built
#### 1.	Summary Dashboard (KPI-first view)
* Core KPIs I implemented:
  *	Total loan applications (count of loan IDs)
  *	Total funded amount (sum of loan amounts disbursed)
  * Total amount received (sum of total payments received)
  *	MTD and MOM changes for these measures
  *	Average interest rate and average DTI
*	Visuals I used:
    *	KPI cards for the core metrics
    *	A high-level view of loan status distribution (good vs. bad loans)
    *	A donut chart showing the proportion of good vs. bad loans
*	Interactivity:
    *	Filters by state, grade, home ownership, loan purpose, and other fields
    *	Dynamic header and chart titles that reflect the selected measures
    *	Field parameters to toggle between different measures (total applications, funded amount, amount received)
#### 2.	Overview Dashboard (Deep-dive analytics)
*	Key views I included:
    *	Monthly trends by issue date (line chart showing applications, funded amount, and amount received)
    * Regional analysis by state (map or regional visualization)
    *	Loan term analysis (donut chart by term)
    *	Employee length analysis (bar chart by years of experience)
    *	Home ownership and loan purpose breakdowns (tree map and stacked visuals)
*	SQL validation:
    *	All visuals are supported by SQL queries that reproduce the same results as shown in Power BI
    *	I followed a problem-statement-driven approach to ensure business relevance
*	Interactivity:
    *	Slicers for state, grade, and loan purpose
    *	Subtle, readable formatting with a consistent color palette
    *	Cross-filtering among charts for cohesive insights
#### 3.	Details Dashboard (Grid view)
*	A detailed table view of loans with fields like loan ID, issue date, home ownership, grade, subgrade, funded amount, interest rate, installments, and amount received
*	Secondary visuals to summarize per-row metrics without losing granular context
*	Presentation:
    *	Clean grid with readable formatting, aligned headers, and legible font sizing
    *	Focus on enabling stakeholders to inspect individual loans while keeping broader trends visible


---

26/09/2025
I am going to add the first power Bi file and image of the dashboard that I have built. After completing all the dashboards I am going to write the complete write up for this project.

<img width="1710" height="965" alt="Screenshot 2025-09-26 at 12 22 03 PM" src="https://github.com/user-attachments/assets/4e367863-fd4a-45f2-8e47-2cb5a33340b7" />





I am going to add one more image of the same dashboard by selecting the option from the slicer and as these slicers have a lot of other options I am just going to add one screenshot.




<img width="1710" height="965" alt="Screenshot 2025-09-26 at 12 22 14 PM" src="https://github.com/user-attachments/assets/2fe4e70c-0f01-441b-b9c5-30230843a450" />




27/09/2025

Today I have added some more features to the dashboards and added one more dashboard pages to this report that I am working on.

This page is about the Overview of the measure which I am going to showcase using some screenshots of the dashbords.

Please take a look on the screenshots that I am going to add now.

-- Total Funded Amount Overview 
<img width="1710" height="965" alt="Screenshot 2025-09-27 at 1 01 14 PM" src="https://github.com/user-attachments/assets/f61ecf17-0a26-4db9-826f-02f98d38828f" />


-- Total loan application overview
<img width="1710" height="965" alt="Screenshot 2025-09-27 at 1 01 28 PM" src="https://github.com/user-attachments/assets/aa608d1c-26fa-4468-ad47-b5877ece57b5" />


--Total Amount recieved measure overview
<img width="1710" height="965" alt="Screenshot 2025-09-27 at 1 01 48 PM" src="https://github.com/user-attachments/assets/23e01178-2d96-45a5-aac6-7d9629bfae0d" />

-- I have also added interaction to the overview page as when one of the KPI is clicked the whole page shows according to the selected KPI

Here I have selected term as 36 months and the whole overview page is showing according to this page 


<img width="1710" height="965" alt="Screenshot 2025-09-27 at 1 02 00 PM" src="https://github.com/user-attachments/assets/c18ce669-f2cc-45a9-a790-a8f26f8a526a" />
