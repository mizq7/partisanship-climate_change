import pandas as pd
import numpy as np

# Step 1: Load the dataset
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

try:
    df = pd.read_stata(file_path)  # Ensure the file exists and the path is correct
    print("Dataset loaded successfully.")
except FileNotFoundError:
    print(f"Error: File not found at {file_path}")
    exit()
except Exception as e:
    print(f"An error occurred while loading the dataset: {e}")
    exit()

# Step 2: Define dependent variable, independent variable, and control variables
dep_var = "co2pc"
main_iv = "swank_left"
controls = ["lngdppc", "trade", "pop", "urban", "renew", "forest", "annexI", "island", "latitude"]

# Step 3: Combine variables into a single list
model_vars = [dep_var, main_iv] + controls

# Debugging: Print model_vars and DataFrame columns to verify
print("Defined model_vars:", model_vars)
print("DataFrame columns:", df.columns.tolist())

# Step 4: Check if all model_vars exist in the dataset
missing_columns = [col for col in model_vars if col not in df.columns]
if missing_columns:
    print("The following columns are missing in the dataset:", missing_columns)
    exit()

# Step 5: Replace infinities with NaN and drop rows with missing values
try:
    df = df.replace([np.inf, -np.inf], np.nan)  # Replace infinities with NaN
    df = df.dropna(subset=model_vars)  # Drop rows with missing values in model_vars
    print("Rows with missing or infinite values in model_vars have been removed.")
except Exception as e:
    print(f"An error occurred during data preparation: {e}")
    exit()

# Step 6: Final debugging output
print("Data preparation complete. Final DataFrame shape:", df.shape)
print("Sample rows:")
print(df.head())