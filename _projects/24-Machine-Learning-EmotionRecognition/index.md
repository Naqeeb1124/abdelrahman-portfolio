---
layout: default
categories: [Machine Learning, Audio Processing, Python]
title: "Emotion Recognition from Audio"
image: "confusion_matrix.png"
description: "This project implements an automated system to recognize emotions from audio signals. It focuses on three primary emotions: happy, sad, and angry. The system uses Mel-Frequency Cepstral Coefficients (MFCC) for feature extraction and a Random Forest Classifier for emotion detection. "
files:
  - name: "Python Script"
    path: "CodeAlpha_EmotionRecognition.py"
  - name: "Results Report"
    path: "results.txt"
---

## Methodology
The pipeline involves several key steps:
1. **Audio Loading**: Loading audio files and handling errors by synthesizing tones if necessary.
2. **Feature Extraction**: Extracting MFCCs from the audio signals, which provide a representation of the short-term power spectrum of a sound.
3. **Data Preparation**: Flattening the MFCC features and splitting the dataset into training and testing sets.
4. **Model Training**: Training a Random Forest Classifier on the extracted features.
5. **Evaluation**: Assessing the model using accuracy scores, classification reports, and a confusion matrix.

## Results
The model achieved high accuracy in distinguishing between the different emotions in a controlled environment. 
- **Accuracy**: 100% (on synthetic/demo data)
- **Visuals**: Included MFCC spectrograms and a confusion matrix to visualize model performance.

## Conclusion
MFCC features combined with ensemble learning methods like Random Forest provide a robust baseline for audio-based emotion recognition tasks.
