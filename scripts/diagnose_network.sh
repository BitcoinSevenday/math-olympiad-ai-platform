#!/bin/bash
echo "=== 网络诊断 ==="

echo "1. 容器状态:"
docker compose ps

echo -e "\n2. PostgreSQL 监听地址:"
docker compose exec postgres netstat -tlnp | grep 5432

echo -e "\n3. 容器 IP 地址:"
echo "PostgreSQL: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' olympiad-postgres)"
echo "Adminer: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' olympiad-adminer)"

echo -e "\n4. 网络连通性测试:"
docker compose exec adminer sh -c "nc -zv olympiad-postgres 5432 2>&1 || echo '连接失败'"

echo -e "\n5. PostgreSQL 配置:"
docker compose exec postgres sh -c "cat /var/lib/postgresql/data/postgresql.conf 2>/dev/null | grep -i listen || echo '使用默认配置'"

echo -e "\n6. 防火墙/安全组检查:"
docker compose exec postgres sh -c "cat /var/lib/postgresql/data/pg_hba.conf 2>/dev/null | head -20 || echo '使用默认HBA配置'"
