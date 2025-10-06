#!/bin/bash
echo "🚀 MinIO Community Edition Setup"
echo "=================================="

# Kiểm tra Docker và Docker Compose
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "📖 Install guide: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "📖 Install guide: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are ready."
echo ""
echo "📦 Starting MinIO container..."

# Dừng container cũ nếu có
docker-compose down 2>/dev/null || docker compose down 2>/dev/null

# Khởi động MinIO bằng Docker Compose
echo "🔄 Starting MinIO..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

# Kiểm tra trạng thái
echo "⏳ Checking status..."
sleep 5
if docker ps | grep -q minio; then
    echo ""
    echo "✅ MinIO started successfully!"
    echo ""
    echo "🌐 MinIO Console: http://localhost:9001"
    echo "🌐 MinIO API: http://localhost:9000"
    echo "👤 Username: admin"
    echo "🔑 Password: password123"
    echo ""
    echo "💡 Tip: To stop MinIO: docker-compose down"
    echo "💡 Tip: To view logs: docker-compose logs -f"
    echo ""
    echo "🎉 Enjoy using MinIO!"
else
    echo "❌ Failed to start MinIO."
    echo "📋 Detailed logs:"
    if command -v docker-compose &> /dev/null; then
        docker-compose logs
    else
        docker compose logs
    fi
fi