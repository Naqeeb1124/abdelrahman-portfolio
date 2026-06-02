# Time Series Analysis of Stock Prices

"""
This script performs basic time series analysis on a stock price dataset.
It demonstrates:
- Data acquisition (using yfinance to fetch historical data)
- Trend analysis via rolling mean
- Seasonality detection using seasonal_decompose (statsmodels)
- Optional forecasting with Prophet (if installed)
"""

import pandas as pd
import matplotlib.pyplot as plt
import yfinance as yf
from statsmodels.tsa.seasonal import seasonal_decompose

# Parameters
STOCK_TICKER = "AAPL"  # Apple Inc.
START_DATE = "2015-01-01"
END_DATE = "2024-12-31"

# Fetch data
print(f"Downloading {STOCK_TICKER} price data...")
df = yf.download(STOCK_TICKER, start=START_DATE, end=END_DATE)

# Keep only the Adjusted Close price
if "Adj Close" in df.columns:
    ts = df["Adj Close"].dropna()
else:
    ts = df["Close"].dropna()


ts.index = pd.to_datetime(ts.index)

# Plot raw time series
ts.plot(title=f"{STOCK_TICKER} Adjusted Close Price")
plt.xlabel("Date")
plt.ylabel("Price (USD)")
plt.tight_layout()
plt.savefig("price_plot.png")
plt.close()

# Trend analysis: rolling mean (30-day)
rolling_mean = ts.rolling(window=30, center=True).mean()
plt.figure(figsize=(10,5))
plt.plot(ts, label="Adj Close", alpha=0.6)
plt.plot(rolling_mean, label="30-Day Rolling Mean", color="red")
plt.title("Trend Analysis")
plt.legend()
plt.savefig("trend_plot.png")
plt.close()

# Seasonality detection
# Resample to weekly frequency to reduce noise
ts_weekly = ts.resample('W').mean()
result = seasonal_decompose(ts_weekly, model='additive', period=52)  # yearly seasonality approx

# Plot decomposition
result.plot()
plt.tight_layout()
plt.savefig("seasonality_decompose.png")
plt.close()

print("Analysis complete. Plots saved: price_plot.png, trend_plot.png, seasonality_decompose.png")

# Optional forecasting using Prophet (if installed)
try:
    from prophet import Prophet
    print("Running forecast with Prophet (next 180 days)...")
    # Prepare data for Prophet
    prophet_df = ts.reset_index()
    prophet_df.columns = ["ds", "y"]
    model = Prophet(yearly_seasonality=True, daily_seasonality=False, weekly_seasonality=False)
    model.fit(prophet_df)
    future = model.make_future_dataframe(periods=180)
    forecast = model.predict(future)
    # Plot forecast
    model.plot(forecast)
    plt.title("Forecast (180 days)")
    plt.savefig("forecast.png")
    plt.close()
    print("Forecast saved to forecast.png")
except Exception as e:
    print("Prophet not installed or forecasting failed:", e)

"""End of script"""
