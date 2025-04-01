import pytest
import requests
from flask import Flask
from hello_world import app

@pytest.fixture
def test_client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_world_with_client(test_client):
    """test using flask test client"""
    response = test_client.get('/')
    assert response.status_code == 200
    assert response.data.decode('utf-8') == 'Hello, World!'

def test_request_headers(test_client):
    """test response headers"""
    response = test_client.get('/')
    assert response.headers['Content-Type'] == 'text/html; charset=utf-8'

def test_request_methods(test_client):
    """test request methods"""
    assert test_client.get('/').status_code == 200
    assert test_client.post('/').status_code == 405
    assert test_client.put('/').status_code == 405
    assert test_client.delete('/').status_code == 405