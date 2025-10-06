.PHONY: help start stop restart logs status clean setup

# Default target

help:
	@echo "🚀 MinIO Management Commands"
	@echo "=========================="
	@echo "setup    - Initial MinIO setup and start"
	@echo "start    - Start MinIO"
	@echo "stop     - Stop MinIO"
	@echo "restart  - Restart MinIO"
	@echo "logs     - Show MinIO logs"
	@echo "status   - Show MinIO status"
	@echo "clean    - Remove MinIO and all data"
	@echo ""
	@echo "🌐 MinIO Console: http://localhost:9001"
	@echo "👤 User: admin | 🔑 Pass: password123"


setup:
	@echo "🚀 Initial MinIO setup..."
	@chmod +x setup.sh
	@./setup.sh


start:
	@echo "▶️ Starting MinIO..."
	@docker-compose up -d
	@echo "✅ MinIO started: http://localhost:9001"


stop:
	@echo "⏹️ Stopping MinIO..."
	@docker-compose down


restart:
	@echo "🔄 Restarting MinIO..."
	@docker-compose restart


logs:
	@echo "📋 MinIO logs:"
	@docker-compose logs -f


status:
	@echo "📊 MinIO status:"
	@docker-compose ps


clean:
	@echo "🗑️ Removing MinIO and all data..."
	@docker-compose down -v
	@docker system prune -f
	@echo "✅ All data removed"
