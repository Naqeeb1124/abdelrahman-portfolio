# House Price Prediction - Machine Learning Model

**Task 8: Advanced Level Machine Learning Project**

## 📋 Overview

This project builds a machine learning model to predict house prices based on property features. The goal is to develop a regression model that can accurately estimate residential property values using real-world data.

### Problem Statement
Real estate pricing is influenced by numerous property features like location, size, age, and condition. This project implements an end-to-end machine learning pipeline to predict house prices, comparing the performance of linear and tree-based regression models.

---

## 📊 Dataset

**Source:** Kaggle House Prices Dataset
- **Total Records:** 1,460 houses
- **Features:** 80 property characteristics (numerical & categorical)
- **Target Variable:** SalePrice (continuous, in dollars)
- **Features Include:**
  - Structural features (basement, garage, rooms)
  - Geographical info (neighborhood, lot size)
  - Condition metrics (overall quality, age)
  - Amenities (fireplace, patio, etc.)

---

## 🔄 Workflow

### 1. **Data Loading & Exploration**
- Load dataset from Kaggle
- Analyze dataset structure and missing values
- Generate descriptive statistics

### 2. **Data Cleaning & Preprocessing**
- **Handle Missing Values:**
  - Numerical columns: Fill with median
  - Categorical columns: Fill with mode
- **Encode Categorical Variables:** One-hot encoding
- **Result:** Clean dataset ready for modeling

### 3. **Exploratory Data Analysis (EDA)**
- Price distribution analysis
- Feature correlation with target
- Identify outliers and patterns
- Visualization of key relationships

### 4. **Feature Engineering & Selection**
- Select relevant features
- Feature scaling (StandardScaler)
- Train-test split (80-20)

### 5. **Model Development**

#### Model 1: Linear Regression
- Simple baseline model
- Suitable for linear relationships
- Fast training and inference

#### Model 2: Random Forest Regressor
- Ensemble learning approach
- Handles non-linear relationships
- Better generalization capability

### 6. **Model Evaluation**
Metrics used:
- **RMSE (Root Mean Squared Error):** Primary metric for regression
- **MAE (Mean Absolute Error):** Average absolute deviation
- **R² Score:** Coefficient of determination (0-1)

### 7. **Model Comparison & Selection**
- Compare performance metrics
- Choose best-performing model
- Analyze prediction accuracy

---

## 📈 Results

### Model Performance Comparison

| Model | Test RMSE | Test MAE | Test R² Score |
|-------|-----------|----------|---------------|
| Linear Regression | ~$25,000 | ~$17,000 | ~0.78 |
| Random Forest | ~$20,000 | ~$13,000 | ~0.85 |

**Best Model:** Random Forest
- **Improvement:** ~20% better RMSE than Linear Regression
- **R² Score:** 0.85 (explains 85% of price variance)
- **Average Prediction Error:** ~$13,000

### Key Insights

1. **Top 3 Most Important Features:**
   - Overall Quality
   - Living Area (GrLivArea)
   - Garage Area

2. **Model Performance:**
   - Random Forest outperforms Linear Regression
   - Handles non-linear relationships better
   - Strong predictive power for most price ranges

3. **Prediction Accuracy:**
   - Average prediction error: ~$13,000 (Random Forest)
   - Higher accuracy for mid-range properties
   - Some difficulty with extreme price outliers

---

## 📂 Project Structure

```
synent-task8-houseprices-abdelrahman/
├── README.md                           # This file
├── requirements.txt                    # Python dependencies
├── train_model.py                      # Training script
├── house_price_prediction.ipynb        # Jupyter notebook
│
├── data/                               # Data directory
│   └── house_prices.csv               # Dataset (if downloaded)
│
├── models/                             # Trained models
│   ├── linear_regression.pkl          # Linear Regression model
│   ├── random_forest.pkl              # Random Forest model
│   └── scaler.pkl                     # Feature scaler
│
└── results/                            # Results and visualizations
    ├── model_comparison.csv            # Performance comparison
    ├── actual_vs_predicted.png         # Prediction plots
    └── feature_importance.png          # Feature importance chart
```

---

## 🚀 Getting Started

### Prerequisites
- Python 3.7+
- pip or conda

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/[username]/synent-task8-houseprices-abdelrahman.git
cd synent-task8-houseprices-abdelrahman
```

2. **Install dependencies:**
```bash
pip install -r requirements.txt
```

### Running the Model

#### Option 1: Run Training Script
```bash
python train_model.py
```

#### Option 2: Use Jupyter Notebook
```bash
jupyter notebook house_price_prediction.ipynb
```

### Using the Trained Models

```python
import pickle
import pandas as pd
from sklearn.preprocessing import StandardScaler

# Load models
with open('models/random_forest.pkl', 'rb') as f:
    rf_model = pickle.load(f)

with open('models/scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)

# Make predictions on new data
# Assuming X_new is prepared data with same features as training
predictions = rf_model.predict(X_new)
```

---

## 📊 Visualizations Generated

1. **Price Distribution:** Histogram and boxplot of house prices
2. **Feature Correlation:** Bar chart of top features correlated with price
3. **Actual vs Predicted:** Scatter plots for model comparison
4. **Feature Importance:** Top 15 most important features (Random Forest)
5. **Model Comparison:** Performance metrics comparison

---

## 🔍 Technical Details

### Libraries Used
- **pandas:** Data manipulation and analysis
- **numpy:** Numerical computations
- **scikit-learn:** Machine learning models and metrics
- **matplotlib & seaborn:** Data visualization
- **jupyter:** Interactive notebook environment

### Model Details

**Linear Regression:**
- Algorithm: Least Squares
- Features: Standardized
- Complexity: O(n·m) where n=samples, m=features

**Random Forest:**
- Algorithm: Bootstrap Aggregating with Decision Trees
- Hyperparameters:
  - n_estimators: 100 trees
  - max_depth: Auto
  - random_state: 42 (reproducibility)
- Advantages: Handles non-linearity, feature importance

---

## 📈 Performance Analysis

### Strengths
- ✅ Random Forest provides excellent prediction accuracy
- ✅ Handles both numerical and categorical features
- ✅ Interpretable feature importance rankings
- ✅ No need for feature scaling in RF model

### Limitations
- ⚠️ Struggles with extreme outliers
- ⚠️ Extrapolation beyond training data range is unreliable
- ⚠️ Requires sufficient training data for good generalization

---

## 💡 Future Improvements

1. **Hyperparameter Tuning:**
   - Grid search for optimal Random Forest parameters
   - Cross-validation for better evaluation

2. **Feature Engineering:**
   - Create derived features (e.g., price per sq ft)
   - Polynomial features for Linear Regression

3. **Additional Models:**
   - Gradient Boosting (XGBoost, LightGBM)
   - Neural Networks
   - Ensemble methods (Stacking, Blending)

4. **Outlier Handling:**
   - Implement robust scaling techniques
   - Use RANSAC or other robust regression methods

5. **Deployment:**
   - Flask/FastAPI web service
   - Streamlit interactive dashboard
   - Docker containerization

---

## 📝 Key Learnings

1. **Data Quality Matters:** Proper preprocessing significantly impacts model performance
2. **Feature Selection:** Not all features are equally important for prediction
3. **Model Trade-offs:** Complex models may overfit; simpler models may underfit
4. **Evaluation Metrics:** RMSE alone doesn't tell the full story; use multiple metrics
5. **Domain Knowledge:** Real estate features' relationships with price are often non-linear

---

## 📄 Files Description

| File | Purpose |
|------|---------|
| `train_model.py` | Automated training pipeline |
| `house_price_prediction.ipynb` | Interactive notebook with visualizations |
| `requirements.txt` | Python package dependencies |
| `models/*.pkl` | Serialized trained models |
| `results/` | Generated outputs and metrics |

---

## 👤 Author

- **Name:** Abdelrahman
- **Project:** Synent Technologies - Data Science Internship
- **Task:** Task 8 - Machine Learning Model
- **Date:** 2026

---

## 📞 Contact & Support

For questions or issues:
- Check the notebook for step-by-step explanations
- Review the training script comments
- Refer to scikit-learn documentation

---

## 📜 License

This project is part of the Synent Technologies Data Science Internship Program.

---

## 🙏 Acknowledgments

- **Kaggle:** For the House Prices dataset
- **Scikit-learn:** For excellent ML tools
- **Synent Technologies:** For the internship opportunity

---

**Happy Learning! 🚀**
