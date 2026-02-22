FROM python:3.11.11-slim-bookworm

RUN apt-get update \
  && apt-get -y upgrade \
  && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN addgroup --system app && adduser --system --ingroup app --home /app app

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade "pip<27" "setuptools==78.1.1" "wheel>=0.46.2"

RUN /opt/venv/bin/pip install --no-cache-dir -r /app/requirements.txt

ENV PATH="/opt/venv/bin:$PATH"

COPY --chown=app:app main.py /app/main.py

USER app

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
