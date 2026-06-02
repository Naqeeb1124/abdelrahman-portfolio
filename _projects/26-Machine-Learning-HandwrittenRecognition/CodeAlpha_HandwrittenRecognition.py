import numpy as np
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import matplotlib.pyplot as plt

def main():
    # 1. Load the Digits dataset (8x8 images, built-in to sklearn)
    print("Loading Digits dataset...")
    digits = load_digits()
    X = digits.data
    y = digits.target
    
    # Scale data to [0, 1]
    X = X / 16.0
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 2. Model Training: Multi-Layer Perceptron (Deep Learning)
    # We use a 2-layer hidden structure (64, 32)
    print("Training Multi-Layer Perceptron (Neural Network)...")
    mlp = MLPClassifier(hidden_layer_sizes=(64, 32), max_iter=500, alpha=1e-4,
                        solver='adam', verbose=False, random_state=42,
                        learning_rate_init=.001)

    mlp.fit(X_train, y_train)

    # 3. Predictions
    print("Evaluating model...")
    y_pred = mlp.predict(X_test)

    # 4. Evaluation
    print("\n--- Handwritten Digit Recognition Evaluation ---")
    print(f"Accuracy Score: {accuracy_score(y_test, y_pred):.4f}")
    
    print("\nConfusion Matrix:")
    cm = confusion_matrix(y_test, y_pred)
    print(cm)

    # Plot Confusion Matrix heatmap
    plt.figure(figsize=(6,5))
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title('Confusion Matrix')
    plt.colorbar()
    tick_marks = np.arange(len(cm))
    plt.xticks(tick_marks, tick_marks)
    plt.yticks(tick_marks, tick_marks)
    plt.xlabel('Predicted')
    plt.ylabel('True')
    plt.tight_layout()
    plt.savefig('confusion_matrix.png')
    print('Confusion matrix plot saved as confusion_matrix.png')

    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))

    print("\nProject complete. Note: MLP architecture used as a robust deep learning approach for digit recognition.")

if __name__ == "__main__":
    main()
