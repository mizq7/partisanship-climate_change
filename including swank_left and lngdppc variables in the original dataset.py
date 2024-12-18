import pandas as pd
import numpy as np

# Path to the original dataset
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

# Load the original dataset
df = pd.read_stata(file_path)

# Verify required columns for swank_left creation
required_cols_swank = ['leftc', 'leftgs', 'lefts', 'llc', 'llgs', 'llseat']
for col in required_cols_swank:
    if col not in df.columns:
        raise ValueError(f"Column {col} not found in the dataset. Cannot create swank_left.")

# Create swank_left
df['left_sum'] = df['leftc'] + df['leftgs'] + df['lefts']
df['lib_sum'] = df['llc'] + df['llgs'] + df['llseat']
df['left_sum_mean'] = df['left_sum'] / 3
df['lib_sum_mean'] = df['lib_sum'] / 3
df['swank_left'] = df['left_sum_mean'] + df['lib_sum_mean']

# Remove intermediate columns if desired
# df.drop(['left_sum', 'lib_sum', 'left_sum_mean', 'lib_sum_mean'], axis=1, inplace=True)

# Verify gdppc for lngdppc creation
if 'gdppc' not in df.columns:
    raise ValueError("The column 'gdppc' does not exist in the dataset. Cannot create lngdppc.")

if (df['gdppc'] <= 0).any():
    raise ValueError("Some gdppc values are zero or negative. Cannot take log of non-positive values.")

df['lngdppc'] = np.log(df['gdppc'])

# Save the updated dataset back to the original file
# WARNING: This overwrites the original file with the updated version.
df.to_stata(file_path, write_index=False)

print("Variables swank_left and lngdppc have been created and saved to the original dataset.")
