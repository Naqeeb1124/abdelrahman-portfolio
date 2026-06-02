"""
House Price Prediction ML Model
Training script for Linear Regression and Random Forest models
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import pickle
import os
import warnings

warnings.filterwarnings('ignore')

def load_data():
    """Load the house prices dataset"""
    import os
    print("Loading dataset...")
    local_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data', 'house_prices.csv')
    if os.path.exists(local_path):
        df = pd.read_csv(local_path)
    else:
        url = 'https://raw.githubusercontent.com/harsh317/House-Prices---Advanced-Regression-Techniques-KAGGLE/master/train.csv'
        df = pd.read_csv(url)
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        df.to_csv(local_path, index=False)
    print(f"Dataset shape: {df.shape}")
    return df

def preprocess_data(df):
    """Clean and preprocess the data"""
    print("\nPreprocessing data...")
    df_clean = df.copy()
    
    # Handle missing values for numerical columns
    numerical_cols = df_clean.select_dtypes(include=['int64', 'float64']).columns
    for col in numerical_cols:
        if df_clean[col].isnull().sum() > 0:
            df_clean[col].fillna(df_clean[col].median(), inplace=True)
    
    # Handle missing values for categorical columns
    categorical_cols = df_clean.select_dtypes(include=['object']).columns
    for col in categorical_cols:
        if df_clean[col].isnull().sum() > 0:
            df_clean[col].fillna(df_clean[col].mode()[0], inplace=True)
    
    # Encode categorical variables
    df_encoded = pd.get_dummies(df_clean, drop_first=True)
    # Fill any remaining NaNs (e.g., from unseen categories) with 0
    df_encoded = df_encoded.fillna(0)
    print(f"Shape after preprocessing: {df_encoded.shape}")
    
    return df_encoded

def prepare_features(df_encoded):
    """Prepare features and target"""
    print("\nPreparing features...")
    X = df_encoded.drop(['SalePrice', 'Id'], axis=1)
    y = df_encoded['SalePrice']
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    print(f"Training set size: {X_train.shape[0]}")
    print(f"Test set size: {X_test.shape[0]}")
    print(f"Number of features: {X.shape[1]}")
    
    return X_train, X_test, X_train_scaled, X_test_scaled, y_train, y_test, scaler, X, y

def train_linear_regression(X_train_scaled, X_test_scaled, y_train, y_test):
    """Train Linear Regression model"""
    print("\nTraining Linear Regression...")
    model = LinearRegression()
    model.fit(X_train_scaled, y_train)
    
    y_pred = model.predict(X_test_scaled)
    
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    mae = mean_absolute_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    
    print(f"Linear Regression Results:")
    print(f"  Test RMSE: ${rmse:,.2f}")
    print(f"  Test MAE:  ${mae:,.2f}")
    print(f"  Test R²:   {r2:.4f}")
    
    return model, rmse, mae, r2

def train_random_forest(X_train, X_test, y_train, y_test):
    """Train Random Forest model"""
    print("\nTraining Random Forest...")
    model = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    mae = mean_absolute_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    
    print(f"Random Forest Results:")
    print(f"  Test RMSE: ${rmse:,.2f}")
    print(f"  Test MAE:  ${mae:,.2f}")
    print(f"  Test R²:   {r2:.4f}")
    
    return model, rmse, mae, r2

def save_models(lr_model, rf_model, scaler):
    """Save trained models"""
    print("\nSaving models...")
    os.makedirs('models', exist_ok=True)
    
    with open('models/linear_regression.pkl', 'wb') as f:
        pickle.dump(lr_model, f)
    print("✓ Saved: models/linear_regression.pkl")
    
    with open('models/random_forest.pkl', 'wb') as f:
        pickle.dump(rf_model, f)
    print("✓ Saved: models/random_forest.pkl")
    
    with open('models/scaler.pkl', 'wb') as f:
        pickle.dump(scaler, f)
    print("✓ Saved: models/scaler.pkl")

def save_results(lr_results, rf_results):
    """Save evaluation results"""
    print("\nSaving results...")
    os.makedirs('results', exist_ok=True)
    
    results_df = pd.DataFrame({
        'Model': ['Linear Regression', 'Random Forest'],
        'Test RMSE': [lr_results[0], rf_results[0]],
        'Test MAE': [lr_results[1], rf_results[1]],
        'Test R² Score': [lr_results[2], rf_results[2]]
    })
    
    results_df.to_csv('results/model_comparison.csv', index=False)
    print("✓ Saved: results/model_comparison.csv")

def main():
    """Main training pipeline"""
    print("="*60)
    print("HOUSE PRICE PREDICTION - ML MODEL TRAINING")
    print("="*60)
    
    # Load and preprocess data
    df = load_data()
    df_encoded = preprocess_data(df)
    X_train, X_test, X_train_scaled, X_test_scaled, y_train, y_test, scaler, X, y = prepare_features(df_encoded)
    
    # Train models
    lr_model, lr_rmse, lr_mae, lr_r2 = train_linear_regression(X_train_scaled, X_test_scaled, y_train, y_test)
    rf_model, rf_rmse, rf_mae, rf_r2 = train_random_forest(X_train, X_test, y_train, y_test)
    
    # Save models and results
    save_models(lr_model, rf_model, scaler)
    save_results((lr_rmse, lr_mae, lr_r2), (rf_rmse, rf_mae, rf_r2))
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"Dataset: {len(df)} houses with {X.shape[1]} features")
    print(f"Price Range: ${y.min():,.0f} - ${y.max():,.0f}")
    print(f"Average Price: ${y.mean():,.0f}")
    print()
    
    best_model = "Random Forest" if rf_rmse < lr_rmse else "Linear Regression"
    improvement = abs((rf_rmse - lr_rmse) / max(rf_rmse, lr_rmse) * 100)
    
    print(f"✓ Best Model: {best_model}")
    print(f"✓ Performance Improvement: {improvement:.2f}%")
    print("="*60)

if __name__ == "__main__":
    main()
