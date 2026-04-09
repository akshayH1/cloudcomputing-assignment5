FROM python:3.9-slim

WORKDIR /app

# Requirement 1: Copy requirements.txt
ADD requirements.txt ./requirements.txt

# Requirement 2: Install requirements.txt
RUN pip install -r ./requirements.txt

# Copy code into the current working directory
COPY . .

# Requirement 3: Add the CMD command
CMD ["python", "app.py"]
