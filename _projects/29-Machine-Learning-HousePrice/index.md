---
layout: default
categories: [Machine Learning, Regression, Python]
title: "House Price Prediction"
image: "image.png"
description: "This project builds a machine learning pipeline to predict house prices based on various property features. It addresses the regression problem of estimating continuous property values using a dataset of 1,460 houses with 80 features. "
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

## Results
- **Best Model**: Random Forest (or Linear Regression depending on feature selection).
- **Key Drivers**: Overall Quality, Living Area (GrLivArea), and Neighborhood were identified as the most significant predictors of house price.
- **Performance**: Achieved an R² score of ~0.85-0.92, explaining a large portion of the price variance.

## Conclusion
Accurate house price prediction requires careful feature engineering and the comparison of multiple modeling techniques. Ensemble methods like Random Forest often provide superior performance by handling complex feature interactions.
