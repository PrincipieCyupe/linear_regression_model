import pickle
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from pathlib import Path # For handling file paths in a more robust way across different operating systems

# Path to the models declaration 
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "../linear_regression/best_model.pkl"
FEATURE_COLUMNS_PATH = BASE_DIR / "../linear_regression/feature_columns.pkl"

# Load the saved Random Forest model as was the best performing model
with open(MODEL_PATH, "rb") as f:
    model = pickle.load(f)

# List of all item columns (one-hot) in order as they are in the dataset
ITEM_COLUMNS = [
    "Item_Avocados","Item_Bananas","Item_Beans, dry","Item_Cabbages",
    "Item_Carrots and turnips","Item_Cassava, fresh",
    "Item_Chillies and peppers, green (Capsicum spp. and Pimenta spp.)",
    "Item_Coffee, green","Item_Eggplants (aubergines)","Item_Groundnuts, excluding shelled",
    "Item_Leeks and other alliaceous vegetables","Item_Lemons and limes","Item_Maize (corn)",
    "Item_Mangoes, guavas and mangosteens","Item_Millet",
    "Item_Onions and shallots, dry (excluding dehydrated)","Item_Oranges","Item_Other beans, green",
    "Item_Other fruits, n.e.c.","Item_Other stimulant, spice and aromatic crops, n.e.c.",
    "Item_Other tropical fruits, n.e.c.","Item_Other vegetables, fresh n.e.c.",
    "Item_Papayas","Item_Peas, dry","Item_Pepper (Piper spp.), raw","Item_Pineapples",
    "Item_Plantains and cooking bananas","Item_Potatoes","Item_Pumpkins, squash and gourds",
    "Item_Pyrethrum, dried flowers","Item_Rice","Item_Sorghum","Item_Soya beans",
    "Item_Sugar cane","Item_Sweet potatoes","Item_Taro","Item_Tea leaves","Item_Tomatoes",
    "Item_Unmanufactured tobacco","Item_Wheat","Item_Yams"
]

# List of flag columns again in order
FLAG_COLUMNS = [
    "Area Flag_Estimated value","Area Flag_Imputed value","Area Flag_Official figure","Area Flag_Unofficial figure",
    "Yield Flag_Estimated value","Yield Flag_Official figure",
    "Production Flag_Estimated value","Production Flag_Imputed value","Production Flag_Official figure","Production Flag_Unofficial figure"
]

# function for Prediction
def predict_production(year: int, area_ha: float, item_name: str) -> float:
    """
    Predict production using the saved best performing model (Random Forest Regression Model).

    Required parameters:
    - year (int): Year of the record
    - area_ha (float): Area harvested in hectares
    - item_name (str): Name of the crop, must match one of the ITEM_COLUMNS

    Expected return:
    - float: Predicted Production (tonnes)
    """

    # Build the one-hot item dictionary
    item_dict = {col: False for col in ITEM_COLUMNS}
    # Make the selected item True
    matching_cols = [col for col in ITEM_COLUMNS if item_name.lower() in col.lower()]
    if not matching_cols:
        raise ValueError(f"Item '{item_name}' not recognized. Check spelling!")
    item_dict[matching_cols[0]] = True

    # Set flag columns to False by default ( Not crucuial for the prediction)
    flag_dict = {col: False for col in FLAG_COLUMNS}

    # Build the full DataFrame
    input_data = pd.DataFrame([{
        "Year": year,
        "Area (ha)": area_ha,
        **item_dict,
        **flag_dict
    }])

    # Predict the user input
    predicted_value = model.predict(input_data)

    return float(predicted_value[0])


# Load training feature columns
with open(FEATURE_COLUMNS_PATH, "rb") as f:
    TRAINING_COLUMNS = pickle.load(f)

# Function to retrain the model with new dataset

def retrain_model(df: pd.DataFrame):
    global model

    expected_columns = [
        "Item","Year","Area (ha)","Area Flag", "Yield (hg/ha)","Yield Flag", "Production (tonnes)","Production Flag"
    ]

    if list(df.columns) != expected_columns:
        raise ValueError(f"Dataset must have columns: {expected_columns}")

    df = df.dropna().reset_index(drop=True)

    numerical_data = pd.get_dummies(df)

    X = numerical_data.drop(["Yield (hg/ha)", "Production (tonnes)"], axis=1)
    y = numerical_data["Production (tonnes)"]

    X = X.reindex(columns=TRAINING_COLUMNS, fill_value=False)

    new_model = RandomForestRegressor(random_state=42)
    new_model.fit(X, y)
    # Save as I overwrite new retrained model result
    with open(MODEL_PATH, "wb") as f:
        pickle.dump(new_model, f)

    model = new_model

    return {
        "message": "Model retrained successfully",
        "rows_used": len(df),
        "features_used": X.shape[1]
    }