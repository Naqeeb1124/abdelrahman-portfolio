import os
import numpy as np
import librosa
import librosa.display
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score

DATA_DIR = os.path.dirname(__file__)

# Map filenames to emotion labels (demo)
LABEL_MAP = {
    'happy.wav': 0,
    'sad.wav': 1,
    'angry.wav': 2,
}

def load_audio(file_path, label):
    """Load an audio file. If it cannot be loaded, synthesize a simple tone.
    label: int – used to choose frequency for synthetic signal.
    """
    try:
        y, sr = librosa.load(file_path, sr=22050)
        return y, sr
    except Exception as e:
        print(f'Could not load {file_path}: {e}. Generating synthetic tone.')
        sr = 22050
        duration = 2.0  # seconds
        t = np.linspace(0, duration, int(sr * duration), False)
        # Choose frequency based on label (0: happy high, 1: sad low, 2: angry mid)
        freq = {0: 440, 1: 220, 2: 330}.get(label, 440)
        y = 0.5 * np.sin(2 * np.pi * freq * t)
        return y, sr

def extract_mfcc(y, sr, n_mfcc=20, max_pad_len=130):
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=n_mfcc)
    # Pad or truncate to fixed length
    if mfcc.shape[1] < max_pad_len:
        pad_width = max_pad_len - mfcc.shape[1]
        mfcc = np.pad(mfcc, pad_width=((0,0),(0,pad_width)), mode='constant')
    else:
        mfcc = mfcc[:, :max_pad_len]
    return mfcc

def save_mfcc_image(mfcc, out_path='mfcc_example.png'):
    plt.figure(figsize=(6,4))
    librosa.display.specshow(mfcc, x_axis='time')
    plt.title('MFCC')
    plt.colorbar()
    plt.tight_layout()
    plt.savefig(out_path)
    plt.close()
    print(f'MFCC example saved as {out_path}')

def main():
    X = []
    y = []
    samples_per_class = 5
    for fname, label in LABEL_MAP.items():
        # Generate multiple synthetic samples per emotion
        for i in range(samples_per_class):
            # Use dummy path (not needed for synthetic generation)
            audio, sr = load_audio('dummy.wav', label)
            mfcc = extract_mfcc(audio, sr)
            X.append(mfcc.flatten())
            y.append(label)
            # Save MFCC image for the first sample only
            if len(X) == 1:
                save_mfcc_image(mfcc, out_path='mfcc_example.png')
    X = np.array(X)
    y = np.array(y)
    # Train/test split (no stratify due to synthetic balanced data)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.33, random_state=42)
    # Model – Random Forest
    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf.fit(X_train, y_train)
    y_pred = clf.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print('\n--- Emotion Recognition Evaluation ---')
    print(f'Accuracy: {acc:.4f}')
    print('\nClassification Report:')
    target_names = list(LABEL_MAP.keys())
    print(classification_report(y_test, y_pred, target_names=target_names))
    cm = confusion_matrix(y_test, y_pred)
    # Plot confusion matrix
    plt.figure(figsize=(5,4))
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title('Confusion Matrix')
    plt.colorbar()
    tick_marks = np.arange(len(target_names))
    plt.xticks(tick_marks, target_names, rotation=45)
    plt.yticks(tick_marks, target_names)
    plt.xlabel('Predicted')
    plt.ylabel('True')
    plt.tight_layout()
    plt.savefig('confusion_matrix.png')
    print('Confusion matrix plot saved as confusion_matrix.png')

if __name__ == '__main__':
    main()
