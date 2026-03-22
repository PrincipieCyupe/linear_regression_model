from fastapi import FastAPI, HTTPException, UploadFile, File
import pandas as pd
import uvicorn
import io
from model_script import predict_production, retrain_model
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware

class PredictionInput(BaseModel):
    year: int = Field(..., ge=1900, le=2100, description="Year of production")
    area_ha: float = Field(..., gt=0, le=1_000_000, description="Area harvested in hectares")
    item_name: str = Field(..., min_length=2, description="Crop name")

class RetrainInput(BaseModel):
    file_path: str = Field(..., description="Path to new dataset (new_df format)")

app = FastAPI(
    title="Crop Production Prediction API",
    description="Predict crop production and retrain model",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://cropproductionpredictionapi.onrender.com"],
    allow_origin_regex=r"http://localhost:\d+",
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)

# First endpoint responding to the root URL
@app.get("/")
def home():
    return {"message": "API is running successfully. Use /predict to get production predictions and /retrain to retrain the model with new data."}

# Predict production endpoint
@app.post("/predict")
def predict(input_data: PredictionInput):
    try:
        return {
            "The predicted production is": predict_production(
                input_data.year,
                input_data.area_ha,
                input_data.item_name
            )
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
# Retrain the new uploaded dataset endpoint
@app.post("/retrain")
async def retrain(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        df = pd.read_csv(io.BytesIO(contents))
        result = retrain_model(df)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Run the API with uvicorn
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)