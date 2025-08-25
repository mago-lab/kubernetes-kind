# app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"msg": "Hello K8S!"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
