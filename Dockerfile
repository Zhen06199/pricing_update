FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY check_cpu.py.py .
CMD ["python", "check_cpu.py"]
