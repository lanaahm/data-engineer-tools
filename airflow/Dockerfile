FROM apache/airflow:2.10.5-python3.11

USER root

# Install system dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
        default-mysql-client \
        libmariadb-dev \
        postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER airflow

# Install additional Python packages
RUN pip install --no-cache-dir \
    apache-airflow-providers-postgres==5.6.0 \
    apache-airflow-providers-mysql==5.2.1 \
    psycopg2-binary==2.9.7 \
    pymysql==1.1.0 \
    mysql-connector-python==8.1.0 \
    pandas==2.0.3 \
    numpy==1.24.3 \
    python-dotenv==1.0.0 \
    requests==2.31.0
