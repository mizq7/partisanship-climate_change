import pandas as pd
import numpy as np

# Original file path
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

# Load the dataset
df = pd.read_stata(file_path)

# Check that the required columns are in the dataset
required_cols = ['leftc', 'leftgs', 'lefts', 'llc', 'llgs', 'llseat']
for col in required_cols:
    if col not in df.columns:
        raise ValueError(f"Column {col} not found. Please adjust the code to match your data.")

# Create the intermediate and final variables
df['left_sum'] = df['leftc'] + df['leftgs'] + df['lefts']
df['lib_sum'] = df['llc'] + df['llgs'] + df['llseat']
df['left_sum_mean'] = df['left_sum'] / 3
df['lib_sum_mean'] = df['lib_sum'] / 3
df['swank_left'] = df['left_sum_mean'] + df['lib_sum_mean']

# If you want to clean up and remove the intermediate variables:
# df.drop(['left_sum', 'lib_sum', 'left_sum_mean', 'lib_sum_mean'], axis=1, inplace=True)

# Save the modified dataset to a new .dta file
modified_file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/modified_dataset_with_swank_left.dta"
df.to_stata(modified_file_path, write_index=False)

print("The variable swank_left (and intermediate variables) has been created and the modified dataset is saved.")
