from hello_world import app

def test_hellow_world():
    with app.test_client() as client:
        response = client.get('/')
        assert response.status_code == 200
        assert response.data == b'Hello, World!'

def test_health_check():
    with app.test_client() as client:
        response = client.get('/health')
        assert response.status_code == 200
        assert response.data == b'OK'