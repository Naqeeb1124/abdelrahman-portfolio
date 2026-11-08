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
This is a pipeline demonstration. No recorded speech dataset is included, so the script trains and tests on synthetic tones (one frequency per emotion label).
- **Accuracy:** 100% on 5 synthetic test samples. This only confirms the pipeline runs end to end; it says nothing about real emotion recognition.
- **Visuals:** MFCC spectrogram and confusion matrix.

## Next step
Evaluating on a real labeled speech corpus (e.g. RAVDESS or TESS) is required before drawing any conclusion about performance.
