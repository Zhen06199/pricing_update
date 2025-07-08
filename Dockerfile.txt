FROM python:3.10-slim

RUN pip install kubernetes

COPY check_cpu.py /check_cpu.py

ENTRYPOINT ["python", "/check_cpu.py"]
