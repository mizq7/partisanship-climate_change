import pandas as pd
import statsmodels.api as sm
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# File path to your Stata .dta data file
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

# Load the dataset from a Stata file
df = pd.read_stata(file_path)
print(df.columns)

# List of variables to include in the model:
dep_var = "co2pc"
main_iv = "swank_left"
controls = ["lngdppc", "trade", "pop", "urban", "renew", "forest", "annexI", "island", "latitude"]

# Drop rows with missing values in these variables if necessary
model_vars = [dep_var, main_iv] + controls

# Prepare the design matrix (X) and response variable (y)
X = df[[main_iv] + controls]
X = sm.add_constant(X)
y = df[dep_var]

# Fit the OLS model:
# If 'c_code' exists (country identifier), cluster SEs by 'c_code', otherwise use robust HC3
if 'c_code' in df.columns:
    model = sm.OLS(y, X).fit(cov_type='cluster', cov_kwds={'groups': df['c_code']})
else:
    model = sm.OLS(y, X).fit(cov_type='HC3')

print(model.summary())

# Generate a range of swank_left values for plotting predictions
swank_vals = np.linspace(df[main_iv].min(), df[main_iv].max(), 100)

# Hold all other variables at their mean
X_means = X.mean()

# Create a DataFrame for predictions at average values of controls
pred_data = pd.DataFrame({col: X_means[col] for col in X.columns}, index=range(len(swank_vals)))
pred_data[main_iv] = swank_vals

predictions = model.get_prediction(pred_data)
pred_mean = predictions.predicted_mean
pred_ci = predictions.conf_int()

# Plotting the predicted CO2pc against swank_left
sns.set_style("whitegrid")
plt.figure(figsize=(8, 6))
plt.plot(swank_vals, pred_mean, color='blue', label='Predicted CO₂pc')
plt.fill_between(swank_vals, pred_ci[:, 0], pred_ci[:, 1], color='blue', alpha=0.2, label='95% CI')

plt.xlabel("Swank Left (Political Ideology)")
plt.ylabel("Predicted CO₂ emissions per capita")
plt.title("Predicted CO₂ Emissions vs. Political Ideology (Holding Controls at Mean)")
plt.legend()
plt.tight_layout()
plt.show()

#checking errors
print(df.columns)
