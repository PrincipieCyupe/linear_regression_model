# Linear Regression Model - Rwanda Crop Production Prediction

## Mission and Problem Description

My mission of modernizing the agriculture in Rwanda especially in my local community by using technology and Machine Learning approach which help the farmers to maximize the crop production. The problem I look forward to solve is the terrible production losses made by the farmers which affect their lives negatively. by helping them to predict crop production based on area, and crop type, it will enable them to make informed decisions and optimize their yields.

## Data Source

The dataset I used is the Rwanda Crop AgroVars Raw Data (2014-2020), collected from real local farmers in Rwanda. This dataset contains comprehensive agricultural data including area harvested, yield, and production for various crops grown in Rwanda.

**Source**: https://figshare.com/articles/dataset/Crop_AgroVars_rawdata_Rwanda_2014-2020_csv/22574101?file=40057642

## Dataset Description

- **Time Period**: 2014-2020
- **Location**: Rwanda
- **Target Variable**: Production (tonnes)
- **Features**: Year, Area (hectares), Crop Type (Item), and various flag descriptions
- **Dataset Size**: Rich dataset with multiple crop varieties including Bananas, Cassava, Maize, Coffee, and many others

## Models Implemented

1. **Linear Regression** - Basic regression model
2. **Decision Tree Regressor** - Tree-based model
3. **Random Forest Regressor** - Ensemble model
4. **SGD Regressor** - Linear regression with Gradient Descent optimization

## Best Performing Model

The **Random Forest Regressor** achieved the best performance based on MSE (Mean Squared Error) evaluation, this was the one with the least error. The model has been saved as `best_model.pkl`.

## Prediction Script (Python Script)

A prediction script is included that uses the best model to predict crop production based on user inputs (year, area, and crop type). You can check the last code cell in the notebook provided inside `summative/linear_regression/ directory` and see `predict_production()` function in the notebook.


## API Endpoint

A publicly available API endpoint is provided for predictions:

**Prediction Endpoint**: [https://cropproductionpredictionapi.onrender.com/docs](https://cropproductionpredictionapi.onrender.com/docs)

And next select **/predict** endpoint totry it out and return the prediction

_**#### NB:** You may need to wait for some seconds (<60 seconds) for a URL to return back online, because I used a free basic plan on render hosting platform!!_


### How It Works

The API accepts POST requests with the following input parameters:
- `year` (int): Year of production (1900-2100)
- `area_ha` (float): Area harvested in hectares (0-1,000,000)
- `item_name` (str): Crop name (e.g., "Maize", "Beans", "Cassava")

The prediction is handled by two main files:
- **[`summative/API/prediction.py`](summative/API/prediction.py)**: Defines the FastAPI endpoints (`/predict` and `/retrain`) and handles HTTP requests
- **[`summative/API/model_script.py`](summative/API/model_script.py)**: Contains the `predict_production()` function that loads the trained Random Forest model and returns predictions

### Example Request

```json
{
  "year": 2015,
  "area_ha": 234,
  "item_name": "Avocados"
}
```

### Example Response

```json
{
  "The predicted production is": 7514.76 tonnes
}
```

You can test the API using Swagger UI at: `https://cropproductionpredictionapi.onrender.com/docs` ( mentioned above)

## Video Demo

[Watch the YouTube video demo here](https://youtu.be/WeoYU65GUhg)

## How to Run the Mobile App (CropPulse)

The mobile app is located in the `summative/FlutterApp/croppulse` directory. Follow these steps to run it:

### Prerequisites

1. **Install Flutter SDK**: Download and install Flutter from [flutter.dev](https://flutter.dev)
2. **Android Studio or VS Code**: Install an IDE with Flutter support
3. **Android Emulator or Physical Device**: For testing on Android

### Installation Steps

1. **Navigate to the app directory**:
   ```bash
   cd summative/FlutterApp/croppulse
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Using the App

1. **Launch the app** - The CropPulse app will open with a dark-themed interface
2. **Enter the Year** - Input the year for prediction (e.g., 2024)
3. **Enter the Area** - Input the area harvested in hectares (e.g., 100.0)
4. **Select a Crop** - Choose from the dropdown list of available crops (e.g., Maize, Beans, Cassava)
5. **Get Prediction** - Tap the "Predict Production" button to get your prediction
6. **View Result** - The predicted production in tonnes will be displayed

### Optional: Retrain the Model

The app also allows you to retrain the model with new data:
1. Tap the "Upload CSV" button
2. Select a CSV file with the required format (columns: Item, Year, Area (ha), Area Flag, Yield (hg/ha), Yield Flag, Production (tonnes), Production Flag)
3. Tap "Retrain Model" to retrain with the new data

## Files Structure

```
linear_regression_model/
├── README.md
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb
│   ├── API/
│   │   ├── prediction.py
│   │   ├── model_script.py
│   ├── FlutterApp/
│   │   ├── croppulse/...
```
