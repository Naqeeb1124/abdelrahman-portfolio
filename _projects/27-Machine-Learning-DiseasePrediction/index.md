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
The project utilizes the Scikit-learn Breast Cancer Wisconsin dataset. The workflow includes data normalization, model training with ensemble methods, and rigorous evaluation using cross-validation and performance metrics like the area under the ROC curve.

## Results
The Random Forest model provides a high-confidence diagnostic tool, achieving significant accuracy and a strong ROC-AUC score, which is crucial for medical applications where minimizing false negatives is vital.

## Conclusion
Integrating machine learning into medical diagnostics can provide clinicians with valuable second opinions, potentially leading to earlier and more accurate cancer detection.
