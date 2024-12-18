import pandas as pd
import statsmodels.api as sm
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# Step 1: Load the dataset
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

df = pd.read_stata(file_path)  # Load dataset
print("Dataset loaded successfully!")

# Step 2: Define variables
dep_var = "co2pc"  # Dependent variable
main_iv = "swank_left"  # Independent variable
controls = ["lngdppc", "trade", "pop_wdi", "urban", "renew", "forest", "annexI", "island", "latitude"]

# Verify controls exist in the dataset
existing_controls = [var for var in controls if var in df.columns]
print("Using controls:", existing_controls)

# Step 3: Generate within- and between-effect variables
# Group means (Between-effect variables)
group_means = df.groupby("c_code")[existing_controls + [main_iv]].transform("mean")
group_means.columns = [f"{col}_mean" for col in group_means.columns]
df = pd.concat([df, group_means], axis=1)

# Deviations (Within-effect variables)
df[f"{main_iv}w"] = df[main_iv] - df[f"{main_iv}_mean"]
for var in existing_controls:
    df[f"{var}w"] = df[var] - df[f"{var}_mean"]

# Step 4: Remove rows with missing or infinite values
key_vars = [dep_var, main_iv] + [f"{main_iv}_mean", f"{main_iv}w"] + \
           [f"{var}_mean" for var in existing_controls] + [f"{var}w" for var in existing_controls]

df.replace([np.inf, -np.inf], np.nan, inplace=True)
df_clean = df.dropna(subset=key_vars).copy()
print("Data cleaned! Rows with missing or infinite values dropped.")
print("Remaining rows:", df_clean.shape[0])

# Step 5: OLS Models for within-effect and between-effect
# Within-effect model
X_within = df_clean[[f"{main_iv}w"] + [f"{var}w" for var in existing_controls]]
X_within = sm.add_constant(X_within)
y_within = df_clean[dep_var]
model_within = sm.OLS(y_within, X_within).fit()

# Between-effect model
X_between = df_clean[[f"{main_iv}_mean"] + [f"{var}_mean" for var in existing_controls]]
X_between = sm.add_constant(X_between)
y_between = df_clean.groupby("c_code")[dep_var].transform("mean")
model_between = sm.OLS(y_between, X_between).fit()

# Print model summaries for verification
print("Within-Effect Model Summary:")
print(model_within.summary())

print("Between-Effect Model Summary:")
print(model_between.summary())

# Step 6: Generate predictions for both within and between effects
swank_vals = np.linspace(df_clean[main_iv].min(), df_clean[main_iv].max(), 100)

# Within-effect predictions
X_within_pred = pd.DataFrame({"const": 1, f"{main_iv}w": swank_vals - df_clean[main_iv].mean()})
for var in existing_controls:
    X_within_pred[f"{var}w"] = 0  # Holding other variables constant
within_preds = model_within.predict(X_within_pred[X_within.columns])  # Ensure alignment

# Between-effect predictions
X_between_pred = pd.DataFrame({"const": 1, f"{main_iv}_mean": swank_vals})
for var in existing_controls:
    X_between_pred[f"{var}_mean"] = df_clean[f"{var}_mean"].mean()
between_preds = model_between.predict(X_between_pred[X_between.columns])  # Ensure alignment

# Step 7: Plot Within-Effect
sns.set_style("whitegrid")
plt.figure(figsize=(8, 5))

# Plot within-effect
plt.plot(swank_vals, within_preds, label="Within-Effect", color="blue")
plt.fill_between(swank_vals, within_preds - 0.5, within_preds + 0.5, color="blue", alpha=0.2)

plt.xlabel("Political Ideology (Swank Left)")
plt.ylabel("Predicted CO₂ Emissions per Capita")
plt.title("Within-Effect of Political Ideology on CO₂ Emissions")
plt.legend()
plt.tight_layout()
plt.show()

# Step 8: Plot Between-Effect
plt.figure(figsize=(8, 5))

# Plot between-effect
plt.plot(swank_vals, between_preds, label="Between-Effect", color="green")
plt.fill_between(swank_vals, between_preds - 0.5, between_preds + 0.5, color="green", alpha=0.2)

plt.xlabel("Political Ideology (Swank Left)")
plt.ylabel("Predicted CO₂ Emissions per Capita")
plt.title("Between-Effect of Political Ideology on CO₂ Emissions")
plt.legend()
plt.tight_layout()
plt.show()
