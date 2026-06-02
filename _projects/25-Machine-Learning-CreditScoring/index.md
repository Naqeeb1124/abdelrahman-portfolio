---
layout: default
categories: [Machine Learning, Finance, Python]
title: "Credit Scoring Model"
image: "feature_importance.png"
description: "This project develops a credit scoring model to predict whether a loan applicant is a good or bad credit risk. It utilizes the well-known German Credit dataset and employs machine learning techniques to automate the assessment process. "
files:
  - name: "Python Script"
    path: "CodeAlpha_CreditScoring.py"
  - name: "Results Report"
    path: "results.txt"
---

## Methodology
The project follows a standard machine learning workflow:
1. **Data Acquisition**: Loading the German Credit dataset from the UCI Machine Learning Repository.
2. **Preprocessing**: Handling categorical variables and scaling features to prepare them for the model.
3. **Model Selection**: Using a Random Forest Classifier, which is effective for handling both numerical and categorical data with complex interactions.
4. **Evaluation**: Measuring performance using Accuracy and ROC-AUC scores, providing a comprehensive view of the model's predictive power.

## Results
- **Accuracy Score**: 0.8150
- **ROC-AUC Score**: 0.8291
- **Key Features**: Feature importance analysis revealed which factors (e.g., checking account status, duration, credit history) most significantly impact credit risk.

## Conclusion
Machine learning models can significantly enhance the accuracy and efficiency of credit risk assessment, helping financial institutions make more informed lending decisions.
