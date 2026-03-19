# Linear Regression Model - Rwanda Crop Production Prediction

## Mission and Problem Description

My mission of modernizing the agriculture in Rwanda especially in my local community by using technology and Machine Learning approach which help the farmers to maximize the crop production. The problem I look forward to solve is the terrible production losses made by the farmers which affect their lives negatively. by helping them to predict crop production based on area, and crop type, it will enable them to make informed decisions and optimize their yields.

## Data Source

The dataset I used is the **Rwanda Crop AgroVars Raw Data (2014-2020)**, collected from real local farmers in Rwanda. This dataset contains comprehensive agricultural data including area harvested, yield, and production for various crops grown in Rwanda.

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

## Files Structure

```
linear_regression_model/
├── README.md
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb
│   ├── API/
│   ├── FlutterApp/
```
