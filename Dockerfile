# python version
ARG BASE_IMAGE=amazonlinux:2
FROM ${BASE_IMAGE}

# install linux
RUN amazon-linux-extras enable python3.9 && yum install -y python39-pip && yum clean all

# set python3.9 as the default
RUN alternatives --install /usr/bin/python python /usr/bin/python3.9 1 && alternatives --set python /usr/bin/python3.9 && python -m pip install --upgrade pip

# working directory
WORKDIR /app

# requirements file inclusion
COPY requirements.txt .

# install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# project files inclusion
COPY . .

# startup script execution
CMD ["bash", "startup_script.sh"]
