FROM python:3.12-slim

WORKDIR /app

# Copy the wheel and requirements file
COPY notebooklm_py-0.8.0a3-py3-none-any.whl /app/
COPY requirements.txt /app/

# Install the dependencies and the wheel
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . /app/

# Cloud Run defaults to port 8080
EXPOSE 8080

# Run the server
CMD ["python", "webhook_server.py"]
