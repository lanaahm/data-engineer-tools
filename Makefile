machine ?= docker

%-up:
	$(machine)-compose --profile $* up -d

%-up-build:
	$(machine)-compose --profile $* up -d --build

%-down:
	$(machine)-compose --profile $* down

%-down-v:
	$(machine)-compose --profile $* down -v
	rm -rf airflow/logs/*

%-logs:
	$(machine)-compose --profile $* logs

%-restart:
	$(machine)-compose --profile $* restart
	@echo "Waiting for Airflow to be ready..."
	@until curl -f http://localhost:8080/health > /dev/null 2>&1; do \
		sleep 5; \
	done
	@echo "Airflow UI available at: http://localhost:8080"

all-up:
	$(machine)-compose --profile airflow --profile db up -d
	@echo "Waiting for Airflow to be ready..."
	@until curl -f http://localhost:8080/health > /dev/null 2>&1; do \
		sleep 5; \
	done
	@echo "Airflow UI available at: http://localhost:8080"

all-down:
	$(machine)-compose --profile airflow --profile db down

all-down-v:
	$(machine)-compose --profile airflow --profile db down -v
	rm -rf airflow/logs/*

help:
	@echo "Usage: make <profile>-<command>"
	@echo ""
	@echo "Available profiles:"
	@echo "  airflow    - Airflow services (webserver, scheduler, postgres)"
	@echo "  db         - Database services (postgres-source, mysql-target)"
	@echo ""
	@echo "Available commands:"
	@echo "  up         - Start services"
	@echo "  up-build   - Start services with build"
	@echo "  down       - Stop services (keep volumes)"
	@echo "  down-v     - Stop services, remove volumes and logs"
	@echo "  logs       - View service logs"
	@echo "  restart    - Restart services"
	@echo ""
	@echo "Special commands:"
	@echo "  all-up     - Start all services and open Airflow UI"
	@echo "  all-down   - Stop all services (keep volumes)"
	@echo "  all-down-v - Stop all services, remove volumes and logs"
	@echo ""
	@echo "Examples:"
	@echo "  make airflow-up      # Start Airflow services"
	@echo "  make db-up           # Start database services"
	@echo "  make all-up          # Start all services and open UI"
	@echo "  make all-down        # Stop everything (keep volumes)"
	@echo "  make all-down-v      # Stop everything (remove volumes & logs)"
	@echo "  make airflow-logs    # View Airflow logs"
	@echo "  make db-logs         # View database logs"
	@echo "  make db-restart      # Restart database services"

# Catch invalid commands and show help
%:
	@echo "Error: Invalid command '$@'"
	@echo ""
	@make help