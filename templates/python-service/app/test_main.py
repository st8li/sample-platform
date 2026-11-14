from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_root():
    r = client.get("/")
    assert r.status_code == 200
    assert "service" in r.json()


def test_health_endpoints():
    assert client.get("/healthz").status_code == 200
    assert client.get("/readyz").status_code == 200


def test_metrics_exposed():
    client.get("/")
    r = client.get("/metrics")
    assert r.status_code == 200
    assert "http_requests_total" in r.text
