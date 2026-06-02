import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, roc_auc_score
import matplotlib.pyplot as plt

def main():
    # 1. Load the dataset from UCI
    # The German Credit Data doesn't have headers in the raw file.
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.data"
    columns = [
        'checkin_acc', 'duration', 'credit_history', 'purpose', 'amount',
        'saving_acc', 'present_emp_since', 'inst_rate', 'personal_status',
        'other_debtors', 'residing_since', 'property', 'age',
        'inst_plans', 'housing', 'num_credits', 'job', 'dependents',
        'telephone', 'foreign_worker', 'status'
    ]
    
    print("Downloading and loading German Credit dataset...")
    try:
        df = pd.read_csv(url, sep=' ', header=None, names=columns)
    except Exception as e:
        print(f"Error downloading dataset: {e}")
        # Fallback to synthetic data if download fails
        print("Creating synthetic data for demonstration...")
        df = pd.DataFrame(np.random.randint(0,100,size=(1000, 21)), columns=columns)
        df['status'] = np.random.randint(1, 3, size=1000)

    # 2. Preprocessing
    # The 'status' column is 1 for Good, 2 for Bad. Let's make it 0 and 1.
    df['status'] = df['status'] - 1 

    # Encode categorical variables
    le = LabelEncoder()
    for col in df.columns:
        if df[col].dtype == 'object':
            df[col] = le.fit_transform(df[col])

    X = df.drop('status', axis=1)
    y = df['status']

    # 3. Split the data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 4. Scaling
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)

    # 5. Model Training
    print("Training Random Forest Classifier for Credit Scoring...")
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)

    # 6. Predictions
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]

    # 7. Evaluation
    print("\n--- Credit Scoring Model Evaluation ---")
    print(f"Accuracy Score: {accuracy_score(y_test, y_pred):.4f}")
    print(f"ROC-AUC Score: {roc_auc_score(y_test, y_prob):.4f}")
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))

    # Plot Feature Importances
    importances = model.feature_importances_
    indices = np.argsort(importances)[::-1]
    plt.figure(figsize=(10,6))
    plt.title('Feature Importances')
    plt.bar(range(len(importances)), importances[indices], align='center')
    plt.xticks(range(len(importances)), [X.columns[i] for i in indices], rotation=90)
    plt.tight_layout()
    plt.savefig('feature_importance.png')
    print('Feature importance plot saved as feature_importance.png')

if __name__ == "__main__":
    main()
