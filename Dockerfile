FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    MODEL_PATH=/app/checkpoints/e9_full_referable_best.pt

WORKDIR /app

COPY requirements.inference.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.inference.txt

COPY app ./app
COPY training ./training
COPY checkpoints/e9_full_referable_best.pt ./checkpoints/e9_full_referable_best.pt

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD python -c "import json, os, urllib.request; port = os.environ.get('PORT', '8000'); health = json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/health', timeout=5)); assert health['status'] == 'ok' and health['model_loaded']"

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
