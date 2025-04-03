import warnings
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import xgboost as xgb
from catboost import CatBoostRegressor
from lightgbm import LGBMRegressor
from sklearn.cross_decomposition import PLSRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression, Ridge, Lasso, HuberRegressor
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsRegressor
from sklearn.svm import SVR
from sklearn.tree import DecisionTreeRegressor
from sklearn.model_selection import cross_val_score
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

warnings.filterwarnings('ignore', category=UserWarning)
plt.close('all')

# Setting up matplotlib to support Chinese displays
plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['axes.unicode_minus'] = False

# Retrieve data
data_path = r"Input data.xlsx"  # Using relative paths
output_path = 'Predictive data.xlsx'  # Output path
data = pd.read_excel(data_path, sheet_name="Sheet1", index_col=0)

# Reading data from the prediction set
predict_data_path = r"predict_data.xlsx"  # Prediction set data path
predict_data = pd.read_excel(predict_data_path, sheet_name="Sheet1", index_col=0)

# Use the same feature column to get X_pred
X_pred = predict_data.iloc[:, 0:24].values

# Delineation of characteristics and target variables
X = data.iloc[:, 0:24].values
y = data.iloc[:, 26].values

# Slicing the dataset
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=1)

# Creating and storing models
models = {
    'KNN': KNeighborsRegressor(),
    'Linear': LinearRegression(),
    'Ridge': Ridge(),
    'Lasso': Lasso(),
    'Decision': DecisionTreeRegressor(),
    'SVR': SVR(),
    'Huber': HuberRegressor(),
    'XGB': xgb.XGBRegressor(),
    'RF': RandomForestRegressor(),
    'PLS': PLSRegression(),
    'LGBM': LGBMRegressor(),
    'CatBoost': CatBoostRegressor()
}

# Make sure y_test is 1-dimensional
if not isinstance(y_test, (pd.Series, np.ndarray)) or y_test.ndim > 1:
    y_test = y_test.ravel()

# Training and forecasting
y_pred_train = {}
y_pred_test = {}
for name, model in models.items():
    model.fit(X_train, y_train)
    y_pred_test[name] = model.predict(X_test).flatten()
    y_pred_train[name] = model.predict(X_train).flatten()

# Save forecast data to Excel
prediction_data = {'real value': y_test}
prediction_data.update(y_pred_test)
prediction_df = pd.DataFrame(prediction_data)
prediction_df.to_excel(output_path, index=False)


# Create an empty dictionary to store predictions
y_predict = {}
num_rows = predict_data.shape[0]

# Predictions for each model
for name, model in models.items():
    y_pred = model.predict(X_pred).flatten()
    y_predict[name] = y_pred

# Save predictions to Excel
predict_output_path = 'Required forecast data.xlsx'
prediction_data1 = {'serial number': range(1, num_rows+1)}
prediction_data1.update(y_predict)
prediction_df1 = pd.DataFrame(prediction_data1)
prediction_df1.to_excel(predict_output_path, index=False)

# assessment model
mse_test = {}
mae_test = {}
R2_test = {}
R2_train = {}

for name, y_pred in y_pred_test.items():
    y_train_pred = y_pred_train[name]
    mse_test[name] = mean_squared_error(y_test, y_pred)
    mae_test[name] = mean_absolute_error(y_test, y_pred)
    R2_test[name] = r2_score(y_test, y_pred)
    R2_train[name] = r2_score(y_train, y_train_pred)

# Plotting training and test set R² histograms
plt.figure(figsize=(12, 6))
index=np.arange(len(models))
bar_width=0.4

train_bars=plt.bar(index, R2_train.values(), bar_width,
                         label='training set', color='orange', alpha=0.7)
test_bars=plt.bar(index + bar_width, R2_test.values(), bar_width,
                            label='test set', color='blue', alpha=0.7)

def add_value_labels(bars):
    for bar in bars:
        height = bar.get_height()
        plt.annotate(f'{height:.2f}', xy=(bar.get_x() + bar.get_width() / 2, height),
                     xytext=(0, 3), textcoords="offset points",
                     ha='center', va='bottom')

add_value_labels(train_bars)
add_value_labels(test_bars)
plt.xlabel('mould')
plt.ylabel(r'$R^2$score')
plt.title('Comparison of model fitting performance on training and test sets')
plt.xticks(index + bar_width / 2, R2_test.keys(), rotation=45)
plt.legend(loc='upper left', bbox_to_anchor=(1.01, 1), borderaxespad=0.)
plt.tight_layout()
plt.show()

# Plotting test set MSE and MAE comparisons
plt.figure(figsize=(10, 6))

index_mse = np.arange(len(mse_test))
mse_bars = plt.bar(index_mse, mse_test.values(), bar_width, label='MSE', color='skyblue', alpha=0.7)
mae_bars = plt.bar(index_mse + bar_width, mae_test.values(), bar_width, label='MAE', color='salmon', alpha=0.7)

add_value_labels(mse_bars)
add_value_labels(mae_bars)

plt.xlabel('mould')
ax1 = plt.gca()
ax1.set_ylabel('MSE', color='skyblue')
ax1.tick_params('y', colors='skyblue')
ax2 = ax1.twinx()
ax2.set_ylabel('MAE', color='salmon')
ax2.tick_params('y', colors='salmon')
plt.xticks(index_mse + bar_width / 2, mse_test.keys(), rotation=45)
ax1.legend(loc='upper left')
ax2.legend(loc='upper right')
plt.tight_layout()
plt.show()

# Plotting training set fitting effects
plt.figure(figsize=(12, 8))

for i, name in enumerate(models.keys()):
    plt.subplot(4, 3, i + 1)
    plt.scatter(y_train, y_pred_train[name], label=name, marker='o', color='blue', s=10)
    plt.plot([y_train.min(), y_train.max()], [y_train.min(), y_train.max()], linestyle='--', color='orange')
    plt.xlabel('real value')
    plt.ylabel('Predicted values (training set)')
    plt.title(f'{name} arithmetic')
    plt.legend()

plt.tight_layout()
plt.show()

# Plotting test set fitting effects
plt.figure(figsize=(12, 8))

for i, name in enumerate(models.keys()):
    plt.subplot(4, 3, i + 1)
    plt.scatter(y_test, y_pred_test[name], label=name, marker='o', color='red', s=10)
    plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], linestyle='--', color='gray')
    plt.xlabel('real value')
    plt.ylabel('Predicted value (test set)')
    plt.title(f'{name} arithmetic')
    plt.legend()

plt.tight_layout()
plt.show()

# Plotting test set predicted values against true values
plt.figure(figsize=(18, 9))

for i, name in enumerate(models.keys()):
    ax = plt.subplot(4, 3, i + 1)
    ax.plot(range(len(y_test)), y_test, label='real value', linestyle='-', color='green')
    ax.plot(range(len(y_test)), y_pred_test[name], label='projected value', linestyle='--', color='red')
    ax.set_xlabel('indexing')
    ax.set_ylabel('value')
    ax.set_title(f'{name} comparison of real and predicted values')
    ax.legend(loc='upper left', bbox_to_anchor=(1.02, 1), borderaxespad=0.)

plt.tight_layout()
plt.show()

# Adding assessment indicators
rmse_test = {name: np.sqrt(val) for name, val in mse_test.items()}  # RMSE
mae_test = {name: mean_absolute_error(y_test, y_pred) for name, y_pred in y_pred_test.items()}  # MAE

# Define the root mean square error RMSE
def rmse(y_true, y_pred):
    return np.sqrt(mean_squared_error(y_true, y_pred))

# Root Mean Square Error RMSE measure
rmse_test_metrics = {name: rmse(y_test, y_pred) for name, y_pred in y_pred_test.items()}

# Regression cross-validation metrics
cv_r2_scores = {name: cross_val_score(model, X, y, cv=5, scoring='r2').mean() for name, model in models.items()}

# Print the regression cross-validation metric
print("\nRegression Cross Validation R2 Scores:")
for name, cv_score in cv_r2_scores.items():
    print(f"{name}: {cv_score:.4f}")

# Define categorical cross-validation metrics
def classification_cv(model):
    cv_scores = cross_val_score(model, X, y, cv=5, scoring='accuracy')
    return cv_scores.mean()

# Categorical cross-validation metrics
classification_cv_scores = {name: classification_cv(model) for name, model in models.items()}

# Print categorized cross-validation metrics
print("\nClassification Cross Validation Accuracy Scores:")
for name, cv_score in classification_cv_scores.items():
    print(f"{name}: {cv_score:.4f}")

# Plotting regression cross-validation metric histograms
plt.figure(figsize=(10, 6))
plt.bar(cv_r2_scores.keys(), cv_r2_scores.values(), color='skyblue')
plt.xlabel('mould')
plt.ylabel('Cross-validation R2 score')
plt.title('Regression cross-validation R2 score')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()



