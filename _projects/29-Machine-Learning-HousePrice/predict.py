"""
Prediction script for House Price Model
Use trained models to make predictions on new data
"""

import pickle
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler

class PricePredictor:
    """Class to handle predictions using trained models"""
    
    def __init__(self, model_type='random_forest'):
        """
        Initialize predictor with trained model
        
        Args:
            model_type (str): 'random_forest' or 'linear_regression'
        """
        self.model_type = model_type
        self.model = None
        self.scaler = None
        self.load_models()
    
    def load_models(self):
        """Load trained model and scaler"""
        try:
            with open(f'models/{self.model_type}.pkl', 'rb') as f:
                self.model = pickle.load(f)
            
            with open('models/scaler.pkl', 'rb') as f:
                self.scaler = pickle.load(f)
            
            print(f"✓ Loaded {self.model_type} model successfully")
        except FileNotFoundError:
            print(f"✗ Model file not found. Please ensure models are trained first.")
            raise
    
    def predict_single(self, features):
        """
        Make prediction for a single house
        
        Args:
            features (array-like): Feature vector for the house
        
        Returns:
            float: Predicted price
        """
        if self.model_type == 'linear_regression':
            features_scaled = self.scaler.transform([features])
            prediction = self.model.predict(features_scaled)[0]
        else:  # random_forest
            prediction = self.model.predict([features])[0]
        
        return prediction
    
    def predict_batch(self, features_df):
        """
        Make predictions for multiple houses
        
        Args:
            features_df (pd.DataFrame): DataFrame with feature vectors
        
        Returns:
            np.array: Array of predicted prices
        """
        if self.model_type == 'linear_regression':
            features_scaled = self.scaler.transform(features_df)
            predictions = self.model.predict(features_scaled)
        else:  # random_forest
            predictions = self.model.predict(features_df)
        
        return predictions
    
    def explain_prediction(self, features, prediction):
        """
        Provide explanation for prediction (for Random Forest)
        
        Args:
            features (array-like): Feature vector
            prediction (float): Predicted price
        
        Returns:
            dict: Explanation info
        """
        explanation = {
            'predicted_price': prediction,
            'price_formatted': f"${prediction:,.2f}",
        }
        
        if self.model_type == 'random_forest':
            # Get feature importances for this prediction
            feature_importances = self.model.feature_importances_
            top_features_idx = np.argsort(feature_importances)[-5:]
            
            explanation['top_contributing_features'] = {
                f"Feature {idx}": feature_importances[idx] 
                for idx in top_features_idx
            }
        
        return explanation


def main():
    """Example usage of the predictor"""
    
    print("="*60)
    print("HOUSE PRICE PREDICTION - INFERENCE")
    print("="*60)
    
    # Initialize predictor with best model (Random Forest)
    predictor = PricePredictor(model_type='random_forest')
    
    # Example: Create sample features
    # Note: These should match the training data features (excluding Id and SalePrice)
    print("\nExample: Making predictions with Random Forest model")
    print("-"*60)
    
    # You would normally load your test data here
    # For demonstration, we show the usage pattern
    print("""
    To make predictions:
    
    1. Load your feature data (must match training features):
       from sklearn.preprocessing import StandardScaler
       X_new = pd.read_csv('your_data.csv')
    
    2. Make predictions:
       predictor = PricePredictor(model_type='random_forest')
       predictions = predictor.predict_batch(X_new)
    
    3. Get explanation:
       explanation = predictor.explain_prediction(features, prediction)
    """)


if __name__ == "__main__":
    main()
