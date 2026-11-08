---
layout: default
categories: [Machine Learning, Regression, Python]
title: "House Price Prediction"
image: "image.png"
description: "Machine learning pipeline for house-price regression, comparing Linear Regression and Random Forest. It runs on a synthetic dataset generated to mirror the structure of the Kaggle House Prices data (1,460 houses, 80 features)."
files:
  - name: "Training Script"
    path: "train_model.py"
  - name: "Evaluation Script"
    path: "evaluate.py"
  - name: "Jupyter Notebook"
    path: "house_price_prediction.ipynb"
---

## Methodology
1. **Exploratory Data Analysis (EDA)**: Analyzing price distributions and feature correlations.
2. **Preprocessing**: Handling missing values, encoding categorical variables, and scaling numerical features.
3. **Modeling**: Comparing two different approaches:
   - **Linear Regression**: A baseline model for linear relationships.
   - **Random Forest Regressor**: An ensemble method for capturing non-linear patterns.
4. **Evaluation**: Using RMSE (Root Mean Squared Error), MAE (Mean Absolute Error), and R² Score to benchmark performance.

## Results (test set, from `results/model_evaluation.csv`)

| Model | RMSE | MAE | R² | MAPE |
|---|---|---|---|---|
| Linear Regression | 28,536 | 22,774 | 0.916 | 5.6% |
| Random Forest | 37,883 | 30,793 | 0.853 | 7.5% |

Linear Regression beat Random Forest on this data, which is expected. The synthetic generator (`generate_dataset.py`) builds each price as a linear sum of features plus Gaussian noise (σ = $25,000), so a linear model is the right model class, and its RMSE of about $28.5k sits close to that noise floor. Results on the real Kaggle data would differ.
