# python version
FROM python:3.9-slim

# working directory
WORKDIR /app

# requirements file inclusion
COPY requirements.txt .

# install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# project files inclusion
COPY . .

# startup script execution
CMD ["bash", "startup.sh"]
