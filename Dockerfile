FROM python:3.10-slim

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY check_cpu.py /check_cpu.py
CMD ["python", "/check_cpu.py"]
