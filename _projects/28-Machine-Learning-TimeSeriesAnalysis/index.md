---
layout: default
categories: [Machine Learning, Data Analysis, Finance]
title: "Stock Price Time Series Analysis"
image: "forecast.png"
description: "This project performs a comprehensive time-series analysis on Apple Inc. (AAPL) stock prices. It aims to identify long-term trends, seasonal patterns, and provide future price forecasts using advanced statistical and machine learning models. "
files:
  - name: "Python Analysis Script"
    path: "analysis.py"
  - name: "Jupyter Notebook"
    path: "analysis.ipynb"
---

## Methodology
The analysis includes:
- **Data Acquisition**: Fetching historical stock data using `yfinance`.
- **Trend Analysis**: Calculating 30-day and 100-day rolling means to smooth out daily volatility.
- **Seasonal Decomposition**: Using `statsmodels` to decompose the time series into trend, seasonal, and residual components.
- **Forecasting**: Employing Facebook's `Prophet` model to predict future price movements based on historical patterns.

## Results
- **Trend**: Identified a consistent long-term upward trend for AAPL, with significant growth periods.
- **Seasonality**: Revealed repeating yearly patterns in stock performance.
- **Forecast**: Provided a 180-day forecast with confidence intervals, highlighting potential future price ranges.

## Visualizations
The project generates several key plots:
- `price_plot.png`: Raw historical prices.
- `trend_plot.png`: Price with rolling averages.
- `seasonality_decompose.png`: Decomposition of the time series.
- `forecast.png`: Future price predictions.

## Conclusion
Time-series analysis and forecasting models like Prophet are powerful tools for understanding market dynamics and assisting in financial decision-making.
