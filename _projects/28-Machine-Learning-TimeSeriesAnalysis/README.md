# synent-task7-timeseriesanalysis-naqeeb1124

## Project Overview

**Task 7 – Time Series Analysis**

This project performs a basic time‑series analysis on a stock price dataset (Apple Inc. – `AAPL`). The analysis includes:

- **Data acquisition** using `yfinance`
- **Trend analysis** with a 30‑day rolling mean
- **Seasonality detection** using `statsmodels` `seasonal_decompose`
- **(Optional) Forecasting** with Facebook's `Prophet` (if installed)

The script generates three key plots (`price_plot.png`, `trend_plot.png`, `seasonality_decompose.png`) and an optional forecast plot (`forecast.png`).

## Repository Structure

```
.
├── analysis.py          # Main Python script for the analysis
├── README.md            # Project description (this file)
├── requirements.txt     # Python dependencies
├── price_plot.png       # Raw price time‑series plot (generated)
├── trend_plot.png       # Trend analysis plot (generated)
├── seasonality_decompose.png  # Seasonal decomposition plot (generated)
└── forecast.png         # Forecast plot (generated when Prophet is available)
```

## Setup & Installation

1. **Clone the repository** (once it is pushed to GitHub)
2. Install the required packages:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the analysis script:
   ```bash
   python analysis.py
   ```

The script will download the stock data, perform the analyses, and save the plots in the repository root.

## Results & Insights

- **Trend**: The 30‑day rolling mean smooths out daily noise, highlighting the long‑term upward movement of `AAPL`.
- **Seasonality**: Weekly resampling and yearly decomposition reveal any repeating yearly patterns in the adjusted close price.
- **Forecast** (optional): When `prophet` is installed, the model predicts the next 180 days, providing a visual forecast.

## Deliverables

- All source code (`analysis.py`)
- Generated visualizations (PNG files)
- `README.md` with instructions and insights
- `requirements.txt`

## Licensing

This work is provided under the MIT License – feel free to reuse and adapt.

---

*Internship submission for Synent Technologies – Data Science Internship Program*