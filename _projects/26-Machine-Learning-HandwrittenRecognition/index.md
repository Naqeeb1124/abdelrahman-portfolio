---
layout: default
categories: [Machine Learning, Computer Vision, Python]
title: "Handwritten Digit Recognition"
image: "confusion_matrix.png"
description: "This project implements a handwritten digit recognition system using a Multi-Layer Perceptron (MLP) neural network. It uses the Scikit-learn Digits dataset, which consists of 8x8 pixel images of handwritten digits (0-9). "
files:
  - name: "Python Script"
    path: "CodeAlpha_HandwrittenRecognition.py"
  - name: "Results Report"
    path: "results.txt"
---

## Methodology
1. **Data Loading**: Using the `load_digits` function from Scikit-learn.
2. **Preprocessing**: Flattening the 8x8 images into 64-dimensional feature vectors and scaling the pixel intensities.
3. **Model Architecture**: A Multi-Layer Perceptron with one hidden layer of 100 neurons, using the ReLU activation function and the Adam optimizer.
4. **Training**: Training the network on 80% of the data.
5. **Evaluation**: Testing on the remaining 20% and generating a classification report and confusion matrix.

## Results
The model demonstrated exceptional performance:
- **Accuracy**: 97.22%
- **F1-Score**: Consistently high across all digit classes, indicating robust recognition capabilities.

## Conclusion
Neural networks, even with a relatively simple MLP architecture, are highly effective for image recognition tasks like digit classification.
