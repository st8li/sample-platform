"""hello — generated from the platform golden path."""
import os
import time

from fastapi import FastAPI, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

SERVICE = os.getenv("SERVICE_NAME", "hello")
VERSION = os.getenv("VERSION", "dev")

app = FastAPI(title=SERVICE)

REQUESTS = Counter("http_requests_total", "HTTP requests", ["path", "status"])
LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["path"])


@app.middleware("http")
async def observe(request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    path = request.url.path
    if path != "/metrics":
        REQUESTS.labels(path, str(response.status_code)).inc()
        LATENCY.labels(path).observe(time.perf_counter() - start)
    return response


@app.get("/")
def root():
    return {"service": SERVICE, "version": VERSION, "message": "Hello from the golden path!"}


@app.get("/healthz")
def healthz():
    """Liveness: the process is up."""
    return {"status": "ok"}


@app.get("/readyz")
def readyz():
    """Readiness: add dependency checks (DB, cache) here."""
    return {"status": "ready"}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
