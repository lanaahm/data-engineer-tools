# Data Engineer Tools 🚀

A robust data engineering project featuring Apache Airflow with Docker, designed for ETL operations between PostgreSQL and MySQL databases.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This project provides a complete data engineering solution with:

- **Apache Airflow** for workflow orchestration (LocalExecutor - no Redis needed)
- **PostgreSQL** as the source database
- **MySQL** as the target database
- **Docker Compose** for easy deployment with profiles
- **Environment-based configuration** (.env files)
- **Robust ETL pipelines** with data quality checks
- **Simple Makefile commands** for easy management


## 📋 Prerequisites

- Docker Desktop (4.0+)
- Docker Compose (2.0+)
- Make (optional, for convenience commands)
- 4GB+ RAM recommended (reduced from 8GB due to no Redis)
- 5GB+ free disk space

## 🚀 Quick Start

### 1. Quick Start (Recommended)

```bash
# Navigate to your project directory
cd "/Users/maulana.maliki/DE Dibimbing/data-engineer-tools"

# Start everything with one command
make all-up
```

### 2. Manual Setup (Alternative)

```bash
# Build custom Airflow image
make airflow-up-build

# Start database services
make db-up

# Or start everything manually
docker-compose --profile airflow --profile db up -d
```

### 3. Access the Services

- **Airflow UI**: http://localhost:8080
  - Username: `airflow`
  - Password: `airflow`
- **PostgreSQL (Source)**: `localhost:5433`
  - Username: `sourceuser`
  - Password: `sourcepass`
  - Database: `sourcedb`
- **MySQL (Target)**: `localhost:3306`
  - Username: `targetuser`
  - Password: `targetpass`
  - Database: `targetdb`

## 📁 Project Structure

```
data-engineer-tools/
├── airflow/
│   ├── dags/                    # Airflow DAGs
│   │   ├── postgres_to_mysql_etl.py
│   │   └── test_connections.py
│   ├── logs/                    # Airflow logs (auto-generated)
│   ├── plugins/                 # Custom Airflow plugins
│   └── .env                     # Airflow environment variables
├── db/
│   ├── .env                     # Database environment variables
│   ├── postgresql/
│   │   └── init-source-db.sql   # PostgreSQL initialization script
│   └── mysql/
│       └── init-target-db.sql   # MySQL initialization script
├── docker-compose.yaml          # Docker services definition with profiles
├── Makefile                     # Convenience commands
└── README.md                    # This file
```

## ⚙️ Configuration

### Environment Variables

The project uses environment variables organized in separate .env files:

**airflow/.env** - Airflow configuration:
```bash
AIRFLOW_UID=50000
AIRFLOW__CORE__EXECUTOR=LocalExecutor
AIRFLOW__CORE__LOAD_EXAMPLES=false
_AIRFLOW_WWW_USER_USERNAME=airflow
_AIRFLOW_WWW_USER_PASSWORD=airflow
# Note: All configuration managed via environment variables
```

**Dependencies**: Managed via custom Dockerfile in airflow/:
- Apache Airflow providers for PostgreSQL and MySQL
- Database connectors (psycopg2-binary, pymysql)
- System dependencies (gcc, postgresql-client, mysql-client)

**db/.env** - Database configuration:
```bash
# PostgreSQL Source Database
POSTGRES_USER=sourceuser
POSTGRES_PASSWORD=sourcepass
POSTGRES_DB=sourcedb

# MySQL Target Database
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_DATABASE=targetdb
MYSQL_USER=targetuser
MYSQL_PASSWORD=targetpass
```


## 🔧 Usage

### Available Make Commands

```bash
# Start services
make all-up              # Start all services and open Airflow UI
make airflow-up          # Start only Airflow services
make db-up               # Start only database services

# Stop services
make all-down            # Stop all services (keep volumes)
make all-down-v          # Stop all services (remove volumes & logs)
make airflow-down        # Stop only Airflow (keep volumes)
make db-down-v           # Stop only databases (remove volumes)

# Monitoring and maintenance
make airflow-logs        # View Airflow logs
make db-logs             # View database logs
make airflow-restart     # Restart Airflow services
make db-restart          # Restart database services

# Help
make help                # Show all available commands
```

### Database Connection Setup

After starting the services, you need to create database connections in Airflow:

#### Option 1: Via Airflow UI (Recommended)

1. **Access Airflow UI**: http://localhost:8080 (airflow/airflow)
2. **Navigate to**: Admin → Connections
3. **Add PostgreSQL Source Connection**:
   - Click the `+` button
   - **Connection Id**: `postgres_source`
   - **Connection Type**: `Postgres`
   - **Host**: `postgres-source`
   - **Schema**: `sourcedb`
   - **Login**: `sourceuser`
   - **Password**: `sourcepass`
   - **Port**: `5432`
   - Click **Save**

4. **Add MySQL Target Connection**:
   - Click the `+` button
   - **Connection Id**: `mysql_target`
   - **Connection Type**: `MySQL`
   - **Host**: `mysql-target`
   - **Schema**: `targetdb`
   - **Login**: `targetuser`
   - **Password**: `targetpass`
   - **Port**: `3306`
   - Click **Save**

#### Option 2: Via Airflow CLI

```bash
# Add PostgreSQL source connection
docker-compose exec airflow-webserver airflow connections add 'postgres_source' \
    --conn-type 'postgres' \
    --conn-host 'postgres-source' \
    --conn-schema 'sourcedb' \
    --conn-login 'sourceuser' \
    --conn-password 'sourcepass' \
    --conn-port 5432

# Add MySQL target connection
docker-compose exec airflow-webserver airflow connections add 'mysql_target' \
    --conn-type 'mysql' \
    --conn-host 'mysql-target' \
    --conn-schema 'targetdb' \
    --conn-login 'targetuser' \
    --conn-password 'targetpass' \
    --conn-port 3306
```

#### Verify Connections

```bash
# Test connections using the test_connections DAG
# 1. Enable the DAG in Airflow UI
# 2. Trigger it manually
# 3. Check logs to verify connections are working
```

### Running ETL Pipeline

1. **Start services**: `make all-up` (automatically opens Airflow UI)
2. **Setup connections**: Follow the [Database Connection Setup](#database-connection-setup) steps above
3. **Access Airflow UI**: http://localhost:8080 (airflow/airflow)
4. **Enable DAGs**: Toggle the DAGs you want to run
5. **Trigger DAG**: Click the play button to start execution
6. **Monitor Progress**: View task status and logs in real-time


## 🔍 Troubleshooting

### Common Issues

#### 1. Services Won't Start

```bash
# Check Docker resources
docker system df

# Clean up and restart
make all-down-v
make all-up
```

#### 2. Service Issues

```bash
# Check service status
docker-compose ps

# Check environment variables in .env files
cat airflow/.env
cat db/.env

# Restart specific services
make airflow-restart
make db-restart
```

#### 3. Permission Issues

```bash
# Fix Airflow permissions
sudo chown -R $USER:$USER airflow/
```

#### 4. Database Issues

```bash
# Reset databases (complete cleanup)
make all-down-v
make all-up

# Check database logs
make db-logs
```

### Logs and Debugging

```bash
# View logs by profile
make airflow-logs        # View Airflow service logs
make db-logs            # View database service logs

# View specific service logs
docker-compose logs -f airflow-scheduler
docker-compose logs -f postgres-source
docker-compose logs -f mysql-target

# Access service shells
docker-compose exec airflow-webserver bash
docker-compose exec postgres-source psql -U sourceuser -d sourcedb
docker-compose exec mysql-target mysql -u targetuser -ptargetpass targetdb
```


---

**Happy Data Engineering!** 🎉
