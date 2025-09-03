import pandas as pd

# Load the raw CSV
df = pd.read_csv("/Users/shahjadaemirsaqualain/Documents/Data analyst projects/Bank Loan Analysis Project/financial_loan.csv")

# List of columns with dates
date_cols = ["issue_date", "last_credit_pull_date", "last_payment_date", "next_payment_date"]

# Function to parse multiple date formats
def parse_dates(x):
    for fmt in ("%m/%d/%y", "%d-%m-%Y", "%d/%m/%y", "%d/%m/%Y"):
        try:
            return pd.to_datetime(x, format=fmt)
        except (ValueError, TypeError):
            continue
    return pd.NaT  # if none of the formats match

# Apply parsing to each date column
for col in date_cols:
    df[col] = df[col].apply(parse_dates)

# Convert all dates to YYYY-MM-DD format (MySQL compatible)
for col in date_cols:
    df[col] = df[col].dt.strftime("%Y-%m-%d")

# Optional: Fill missing dates with NULL (if any)
df[date_cols] = df[date_cols].fillna('NULL')

# Save the cleaned CSV
df.to_csv("financial_loans_clean.csv", index=False)

print("Dates cleaned and saved to financial_loans_clean.csv")
