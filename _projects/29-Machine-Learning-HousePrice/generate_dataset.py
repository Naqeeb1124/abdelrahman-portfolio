"""
Generate a realistic synthetic House Prices dataset matching the Kaggle
House Prices - Advanced Regression Techniques structure (1460 rows, 80 columns).

This allows the project scripts to run without depending on an external URL.
"""
import numpy as np
import pandas as pd
import os

np.random.seed(42)
N = 1460

# ---- Helper ----
def rand_int(low, high, size=N):
    return np.random.randint(low, high + 1, size=size)

def rand_float(low, high, size=N):
    return np.round(np.random.uniform(low, high, size=size), 1)

def rand_choice(options, size=N):
    return np.random.choice(options, size=size)

# ---- ID ----
Id = np.arange(1, N + 1)

# ---- Numeric features matching the Kaggle description ----
MSSubClass = rand_choice([20, 30, 40, 45, 50, 60, 70, 75, 80, 85, 90, 120, 150, 160, 180, 190])
MSZoning = rand_choice(['RL', 'RM', 'C', 'FV', 'RH'])
LotFrontage = rand_float(21, 313)
LotArea = rand_float(1300, 215245)
OverallQual = rand_int(1, 10)
OverallCond = rand_int(1, 10)
YearBuilt = rand_int(1872, 2010)
YearRemodAdd = rand_int(1950, 2010)
MasVnrArea = rand_float(0, 1600)
BsmtFinSF1 = rand_float(0, 5644)
BsmtFinSF2 = rand_float(0, 1474)
BsmtUnfSF = rand_float(0, 2336)
TotalBsmtSF = rand_float(0, 6110)
FirstFlrSF = rand_float(334, 4692)  # 1stFlrSF
SecondFlrSF = rand_float(0, 2065)   # 2ndFlrSF
GrLivArea = rand_float(334, 5642)
BsmtFullBath = rand_int(0, 3)
BsmtHalfBath = rand_int(0, 2)
FullBath = rand_int(0, 3)
HalfBath = rand_int(0, 2)
BedroomAbvGr = rand_int(0, 8)
KitchenAbvGr = rand_int(0, 3)
TotRmsAbvGrd = rand_int(2, 14)
Fireplaces = rand_int(0, 3)
GarageYrBlt = rand_int(1900, 2010)
GarageCars = rand_int(0, 4)
GarageArea = rand_float(0, 1418)
WoodDeckSF = rand_float(0, 857)
OpenPorchSF = rand_float(0, 547)
EnclosedPorch = rand_float(0, 552)
SsnPorch = rand_float(0, 508)       # 3SsnPorch
ScreenPorch = rand_float(0, 480)
PoolArea = rand_int(0, 738).astype(float)
MiscVal = rand_float(0, 15500)
MoSold = rand_int(1, 12)
YrSold = rand_int(2006, 2010)

# ---- Categorical features ----
Street = rand_choice(['Pave', 'Grvl'])
Alley = rand_choice(['NA', 'Grvl', 'Pave'])
LotShape = rand_choice(['Reg', 'IR1', 'IR2', 'IR3'])
LandContour = rand_choice(['Lvl', 'Bnk', 'HLS', 'Low'])
Utilities = rand_choice(['AllPub', 'NoSeWa'])
LotConfig = rand_choice(['Inside', 'Corner', 'CulDSac', 'FR2', 'FR3'])
LandSlope = rand_choice(['Gtl', 'Mod', 'Sev'])
Neighborhood = rand_choice([ 'CollgCr','Veenker','Crawfor','NoRidge','Mitchel',
    'Somerst','NWAmes','OldTown','BrkSide','Sawyer','NridgHt','NAmes',
    'SawyerW','IDOTRR','MeadowV','Edwards','Timber','Gilbert','StoneBr',
    'ClearCr','NPkVill','Blmngtn','BrDale','SWISU','Blueste' ])
Condition1 = rand_choice(['Norm', 'Feedr', 'PosN', 'Artery', 'RRNn', 'PosA', 'RRAn', 'RRNe', 'RRAe'])
Condition2 = rand_choice(['Norm', 'Feedr', 'PosN', 'Artery', 'RRNn'])
BldgType = rand_choice(['1Fam', '2FmCon', 'Duplex', 'TwnhsE', 'Twnhs'])
HouseStyle = rand_choice(['1Story', '2Story', '1.5Fin', 'SLvl', 'SFoyer', '2.5Unf', '1.5Unf', '2.5Fin'])
RoofStyle = rand_choice(['Gable', 'Hip', 'Gambrel', 'Mansard', 'Flat', 'Shed'])
RoofMatl = rand_choice(['CompShg', 'Tar&Grv', 'WdShake', 'WdShngl', 'Metal', 'Membran', 'Roll', 'ClyTile'])
Exterior1st = rand_choice(['VinylSd', 'MetalSd', 'Wd Sdng', 'HdBoard', 'BrkFace', 'WdShing',
    'CemntBd', 'Plywood', 'AsbShng', 'Stucco', 'BrkComm', 'AsphShn',
    'Stone', 'ImStucc', 'CBlock'])
Exterior2nd = rand_choice(['VinylSd', 'MetalSd', 'Wd Sdng', 'HdBoard', 'BrkFace', 'WdShing',
    'CemntBd', 'Plywood', 'AsbShng', 'Stucco', 'BrkComm', 'AsphShn',
    'Stone', 'ImStucc', 'CBlock', 'Other'])
MasVnrType = rand_choice(['None', 'BrkFace', 'Stone', 'BrkCmn'])
ExterQual = rand_choice(['Ex', 'Gd', 'TA', 'Fa'])
ExterCond = rand_choice(['Ex', 'Gd', 'TA', 'Fa', 'Po'])
Foundation = rand_choice(['PConc', 'CBlock', 'BrkTil', 'Slab', 'Stone', 'Wood'])
BsmtQual = rand_choice(['Ex', 'Gd', 'TA', 'Fa', 'NA'])
BsmtCond = rand_choice(['Gd', 'TA', 'Fa', 'Po', 'NA'])
BsmtExposure = rand_choice(['Gd', 'Av', 'Mn', 'No', 'NA'])
BsmtFinType1 = rand_choice(['GLQ', 'ALQ', 'BLQ', 'Rec', 'LwQ', 'Unf', 'NA'])
BsmtFinType2 = rand_choice(['GLQ', 'ALQ', 'BLQ', 'Rec', 'LwQ', 'Unf', 'NA'])
Heating = rand_choice(['GasA', 'GasW', 'Grav', 'Wall', 'OthW', 'Floor'])
HeatingQC = rand_choice(['Ex', 'Gd', 'TA', 'Fa', 'Po'])
CentralAir = rand_choice(['Y', 'N'])
Electrical = rand_choice(['SBrkr', 'FuseA', 'FuseF', 'FuseP', 'Mix'])
KitchenQual = rand_choice(['Ex', 'Gd', 'TA', 'Fa'])
Functional = rand_choice(['Typ', 'Min1', 'Min2', 'Mod', 'Maj1', 'Maj2', 'Sev', 'Sal'])
FireplaceQu = rand_choice(['Ex', 'Gd', 'TA', 'Fa', 'Po', 'NA'])
GarageType = rand_choice(['Attchd', 'Detchd', 'BuiltIn', 'Basment', '2Types', 'CarPort', 'NA'])
GarageFinish = rand_choice(['Fin', 'RFn', 'Unf', 'NA'])
GarageQual = rand_choice(['Ex', 'Gd', 'TA', 'Fa', 'Po', 'NA'])
GarageCond = rand_choice(['Ex', 'Gd', 'TA', 'Fa', 'Po', 'NA'])
PavedDrive = rand_choice(['Y', 'N', 'P'])
PoolQC = rand_choice(['Ex', 'Gd', 'Fa', 'NA'])
Fence = rand_choice(['GdPrv', 'MnPrv', 'GdWo', 'MnWw', 'NA'])
MiscFeature = rand_choice(['Elev', 'Gar2', 'Othr', 'Shed', 'TenC', 'NA'])
SaleType = rand_choice(['WD', 'New', 'COD', 'ConLI', 'Con', 'Oth', 'ConLw', 'CWD', 'VWD', 'ConLD'])
SaleCondition = rand_choice(['Normal', 'Abnorml', 'Partial', 'AdjLand', 'Alloca', 'Family'])

# ---- Generate SalePrice realistically ----
# Based on the most important features from the documentation
base_price = 50000
quality_effect = OverallQual * 20000
area_effect = GrLivArea * 50
garage_effect = GarageArea * 30
basement_effect = TotalBsmtSF * 20
bath_effect = FullBath * 10000
year_effect = (YearBuilt - 1900) * 500
fireplace_effect = Fireplaces * 5000
noise = np.random.normal(0, 25000, N)

SalePrice = base_price + quality_effect + area_effect + garage_effect + basement_effect + bath_effect + year_effect + fireplace_effect + noise
SalePrice = np.clip(SalePrice, 34900, 755000).astype(int)

# ---- Build DataFrame ----
df = pd.DataFrame({
    'Id': Id,
    'MSSubClass': MSSubClass,
    'MSZoning': MSZoning,
    'LotFrontage': LotFrontage,
    'LotArea': LotArea,
    'Street': Street,
    'Alley': Alley,
    'LotShape': LotShape,
    'LandContour': LandContour,
    'Utilities': Utilities,
    'LotConfig': LotConfig,
    'LandSlope': LandSlope,
    'Neighborhood': Neighborhood,
    'Condition1': Condition1,
    'Condition2': Condition2,
    'BldgType': BldgType,
    'HouseStyle': HouseStyle,
    'OverallQual': OverallQual,
    'OverallCond': OverallCond,
    'YearBuilt': YearBuilt,
    'YearRemodAdd': YearRemodAdd,
    'RoofStyle': RoofStyle,
    'RoofMatl': RoofMatl,
    'Exterior1st': Exterior1st,
    'Exterior2nd': Exterior2nd,
    'MasVnrType': MasVnrType,
    'MasVnrArea': MasVnrArea,
    'ExterQual': ExterQual,
    'ExterCond': ExterCond,
    'Foundation': Foundation,
    'BsmtQual': BsmtQual,
    'BsmtCond': BsmtCond,
    'BsmtExposure': BsmtExposure,
    'BsmtFinType1': BsmtFinType1,
    'BsmtFinSF1': BsmtFinSF1,
    'BsmtFinType2': BsmtFinType2,
    'BsmtFinSF2': BsmtFinSF2,
    'BsmtUnfSF': BsmtUnfSF,
    'TotalBsmtSF': TotalBsmtSF,
    'Heating': Heating,
    'HeatingQC': HeatingQC,
    'CentralAir': CentralAir,
    'Electrical': Electrical,
    '1stFlrSF': FirstFlrSF,
    '2ndFlrSF': SecondFlrSF,
    'LowQualFinSF': np.zeros(N),
    'GrLivArea': GrLivArea,
    'BsmtFullBath': BsmtFullBath,
    'BsmtHalfBath': BsmtHalfBath,
    'FullBath': FullBath,
    'HalfBath': HalfBath,
    'BedroomAbvGr': BedroomAbvGr,
    'KitchenAbvGr': KitchenAbvGr,
    'KitchenQual': KitchenQual,
    'TotRmsAbvGrd': TotRmsAbvGrd,
    'Functional': Functional,
    'Fireplaces': Fireplaces,
    'FireplaceQu': FireplaceQu,
    'GarageType': GarageType,
    'GarageYrBlt': GarageYrBlt,
    'GarageFinish': GarageFinish,
    'GarageCars': GarageCars,
    'GarageArea': GarageArea,
    'GarageQual': GarageQual,
    'GarageCond': GarageCond,
    'PavedDrive': PavedDrive,
    'WoodDeckSF': WoodDeckSF,
    'OpenPorchSF': OpenPorchSF,
    'EnclosedPorch': EnclosedPorch,
    '3SsnPorch': SsnPorch,
    'ScreenPorch': ScreenPorch,
    'PoolArea': PoolArea,
    'PoolQC': PoolQC,
    'Fence': Fence,
    'MiscFeature': MiscFeature,
    'MiscVal': MiscVal,
    'MoSold': MoSold,
    'YrSold': YrSold,
    'SaleType': SaleType,
    'SaleCondition': SaleCondition,
    'SalePrice': SalePrice,
})

# Introduce some realistic missing values (as in the Kaggle dataset)
missing_cols = {
    'LotFrontage': 0.17,
    'Alley': 0.94,
    'MasVnrType': 0.01,
    'MasVnrArea': 0.01,
    'BsmtQual': 0.03,
    'BsmtCond': 0.03,
    'BsmtExposure': 0.03,
    'BsmtFinType1': 0.03,
    'BsmtFinType2': 0.03,
    'Electrical': 0.001,
    'FireplaceQu': 0.47,
    'GarageType': 0.05,
    'GarageYrBlt': 0.05,
    'GarageFinish': 0.05,
    'GarageQual': 0.05,
    'GarageCond': 0.05,
    'PoolQC': 1.0,
    'Fence': 0.81,
    'MiscFeature': 0.96,
}
for col, frac in missing_cols.items():
    mask = np.random.random(N) < frac
    df.loc[mask, col] = np.nan

# Save
os.makedirs('data', exist_ok=True)
df.to_csv('data/house_prices.csv', index=False)
print(f"Generated synthetic dataset: {df.shape[0]} rows x {df.shape[1]} columns")
print(f"Saved to: data/house_prices.csv")
print(f"Price range: ${df['SalePrice'].min():,.0f} - ${df['SalePrice'].max():,.0f}")
print(f"Avg price: ${df['SalePrice'].mean():,.0f}")
