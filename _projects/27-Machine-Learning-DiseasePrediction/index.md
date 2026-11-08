---
layout: default
categories: [Machine Learning, Healthcare, Python]
title: "Breast Cancer Diagnosis Prediction"
image: "roc_curve.png"
description: "This project leverages machine learning to assist in the diagnosis of breast cancer. By analyzing medical features extracted from digitized images of fine needle aspirates (FNA) of breast masses, the model classifies tumors as either malignant or benign. "
files:
  - name: "Python Script"
    path: "CodeAlpha_DiseasePrediction.py"
  - name: "Results Report"
    path: "results.txt"
---

## Features
- **Data Scaling**: Uses `StandardScaler` to normalize medical features for better model performance.
- **Model**: Implements a `RandomForestClassifier`.
- **Evaluation**: Includes detailed metrics such as Accuracy, ROC-AUC, and a full Classification Report.
- **Visualization**: Generates an ROC curve to visualize the model's diagnostic performance.

## Methodology
The project uses the Scikit-learn Breast Cancer Wisconsin dataset (569 samples, 30 features) with an 80/20 train/test split, feature standardization, and a Random Forest classifier.

## Results (held-out test set, 114 samples)
- **Accuracy:** 96.5%
- **ROC-AUC:** 0.995
- **Confusion matrix:** 40 / 3 / 1 / 70. Note that 3 malignant tumors were misclassified as benign; in a diagnostic setting, false negatives like these are the costly error.
