import pandas as pd
import numpy as np

# Original file path
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

# Load the dataset
df = pd.read_stata(file_path)

# Create lngdppc = log(gdppc)
# Ensure gdppc exists and is positive (as log of non-positive values is undefined)
if 'gdppc' not in df.columns:
    raise ValueError("The column 'gdppc' does not exist in the dataset. Please verify the column name.")

# Check for non-positive gdppc values to avoid errors
if (df['gdppc'] <= 0).any():
    raise ValueError("Some gdppc values are zero or negative, cannot take log. Clean data before creating lngdppc.")

df['lngdppc'] = np.log(df['gdppc'])

# Save the modified dataset to a new .dta file
modified_file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/modified_dataset_with_lngdppc.dta"
df.to_stata(modified_file_path, write_index=False)

print("The variable lngdppc has been created and the modified dataset is saved.")
