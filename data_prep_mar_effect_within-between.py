import pandas as pd

# Step 1: Load the dataset
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

df = pd.read_stata(file_path)  # Load the dataset into df

# Debugging step: Check the columns
print("Dataset Columns:", df.columns.tolist())

# Define controls
controls = ["lngdppc", "trade", "pop_wdi", "urban", "renew", "forest", "annexI", "island", "latitude"]


