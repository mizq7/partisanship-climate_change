import pandas as pd
import statsmodels.api as sm
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# Step 1: Load the dataset
file_path = "/Users/mizq7/Desktop/RESEARCH/_MANUSCRIPT/UNDER PREPARATION/Left-Right Partisan Ideology/Dataset_Left-Right_Ideology/Dataset_Final & Last Version_created on Oct 15, 2020/muinul.partisanship.dta"

def load_dataset(path):
    try:
        df = pd.read_stata(path)
        print("Dataset loaded successfully.")
        return df
    except FileNotFoundError:
        print(f"Error: File not found at {path}")
        exit()
    except Exception as e:
        print(f"An error occurred while loading the dataset: {e}")
        exit()

df = load_dataset(file_path)

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
def clean_data(df, model_vars):
    try:
        df = df.replace([np.inf, -np.inf], np.nan)  # Replace infinities with NaN
        df = df.dropna(subset=model_vars)  # Drop rows with missing values in model_vars
        print("Rows with missing or infinite values in model_vars have been removed.")
        return df
    except Exception as e:
        print(f"An error occurred during data cleaning: {e}")
        exit()

df = clean_data(df, model_vars)

# Step 6: Prepare the design matrix (X) and response variable (y)
X = df[[main_iv] + controls]
X = sm.add_constant(X)
y = df[dep_var]

# Step 7: Fit the OLS model
def fit_model(X, y, df, cluster_col="c_code"):
    try:
        if cluster_col in df.columns:
            model = sm.OLS(y, X).fit(cov_type='cluster', cov_kwds={'groups': df[cluster_col]})
        else:
            model = sm.OLS(y, X).fit(cov_type='HC3')
        print(model.summary())
        return model
    except Exception as e:
        print(f"An error occurred during model fitting: {e}")
        exit()

model = fit_model(X, y, df)

# Step 8: Generate predictions for the marginal effect plot
swank_vals = np.linspace(df[main_iv].min(), df[main_iv].max(), 100)
X_means = X.mean()
pred_data = pd.DataFrame({col: X_means[col] for col in X.columns}, index=range(len(swank_vals)))
pred_data[main_iv] = swank_vals

try:
    predictions = model.get_prediction(pred_data)
    pred_mean = predictions.predicted_mean
    pred_ci = predictions.conf_int()

    # Step 9: Plot the marginal effects
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
except Exception as e:
    print(f"An error occurred during prediction or plotting: {e}")
