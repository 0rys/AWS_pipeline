# Start with a minimal base
FROM amazonlinux:2

# install python
RUN yum install -y python3 python3-pip

# working directory
WORKDIR /app

# requirements file inclusion
COPY requirements.txt .

# install dependencies (assuming they're already available in the build environment)
RUN pip install --no-cache-dir -r requirements.txt

# project files inclusion
COPY . .

# startup script execution
CMD ["bash", "startup_script.sh"]
