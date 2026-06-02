# Disease Prediction

This project uses machine learning to classify medical data, specifically focused on **Breast Cancer** diagnosis using the Scikit-learn Breast Cancer dataset.

## Features
- **Data Scaling**: Uses \StandardScaler\ to normalize medical features for better model performance.
- **Model**: Implements a \RandomForestClassifier\.
- **Evaluation**: Includes detailed metrics such as Accuracy, ROC-AUC, and a full Classification Report.
- **Visualization**: Saves an \oc_curve.png\ to visualize the model's diagnostic performance.

## Requirements
- pandas
- numpy
- scikit-learn
- matplotlib

## How to Run
1. Navigate to this directory:
   \\\ash
   cd CodeAlpha_DiseasePrediction
   \\\
2. Install dependencies:
   \\\ash
   pip install -r requirements.txt
   \\\
3. Run the script:
   \\\ash
   python CodeAlpha_DiseasePrediction.py
   \\\
