---
layout: default
categories: [Machine Learning, Healthcare, Finance]
title: "Medical Insurance Premium Prediction"
image: "image.png"
description: "This project is an end-to-end data science solution for predicting medical insurance premiums. It features a production-grade Streamlit application that allows users to estimate premiums and understand the risk factors driving their costs. "
files:
  - name: "Streamlit App"
    path: "app.py"
  - name: "Training Pipeline"
    path: "src/train.py"
  - name: "Inference API"
    path: "src/predict.py"
---

## Features
- **Personalized Calculator**: Estimates premiums based on age, BMI, smoking status, and more.
- **Interactive EDA**: Visualizes demographic correlations and charge distributions.
- **Model Analytics**: Benchmarks multiple models (Linear Regression, Random Forest, Gradient Boosting).
- **Cost Driver Analysis**: Breaks down how each factor (e.g., smoking, obesity) contributes to the final premium.

## Methodology
- **Data Preprocessing**: Modular pipeline for cleaning and transforming medical cost datasets.
- **Machine Learning**: Random Forest Regressor achieved over 89% accuracy, outperforming other baseline models.
- **Deployment**: A multi-page Streamlit dashboard providing a professional user interface for the predictive engine.

## Results
- **Accuracy**: 89.87% R² Score with Random Forest.
- **Insights**: Smoking was identified as the #1 cost driver, accounting for nearly 49% of the premium determination.
- **Performance**: Significantly reduced prediction errors compared to simple linear models.

## Conclusion
By combining robust machine learning models with interactive web applications, we can make complex predictive insights accessible and actionable for both providers and individuals.
