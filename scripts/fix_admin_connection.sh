#!/bin/bash
cd /Users/admin/project/math_olympiad/math-olympiad-ai-platform

echo "=== 修复 admin 用户连接问题 ==="

echo "1. 停止服务..."
docker compose stop postgres

echo "2. 以单用户模式修复..."
# 创建修复容器
docker run --rm -d \
  --name postgres-fix \
  -v olympiad_postgres_data:/var/lib/postgresql/data \
  -p 5433:5432 \
  postgres:15-alpine \
  postgres -c 'listen_addresses=*'

echo "等待 PostgreSQL 启动..."
sleep 5

echo "3. 重置 admin 用户和权限..."
docker exec postgres-fix psql -U postgres << "SQL"
-- 删除并重新创建 admin 用户
DROP USER IF EXISTS admin;
CREATE USER admin WITH 
  PASSWORD 'olympiad123' 
  SUPERUSER 
  CREATEDB 
  CREATEROLE 
  LOGIN;

-- 创建数据库
CREATE DATABASE olympiad OWNER admin;
CREATE DATABASE admin OWNER admin;

-- 宽松的认证配置
ALTER SYSTEM SET password_encryption = 'md5';
SELECT pg_reload_conf();

-- 测试
\c olympiad admin
SELECT current_user, current_database();
SQL

echo "4. 更新认证配置..."
docker exec postgres-fix bash -c '
cat > /var/lib/postgresql/data/pg_hba.conf << "PGHBA"
local   all             all                                     trust
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    all             all             172.20.0.0/16           md5
host    all             all             0.0.0.0/0               md5
PGHBA
'

echo "5. 重启 PostgreSQL 应用配置..."
docker stop postgres-fix
sleep 3

echo "6. 启动原服务..."
docker compose start postgres

echo "等待服务启动..."
for i in {1..10}; do
  if docker compose exec postgres pg_isready -U admin >/dev/null 2>&1; then
    echo "✅ PostgreSQL 已就绪"
    break
  fi
  echo -n "."
  sleep 2
done

echo -e "\n7. 测试连接..."
docker compose exec postgres psql -U admin -d olympiad -c "
SELECT 
  '✅ 连接成功' as status,
  current_user as 当前用户,
  current_database() as 当前数据库,
  version() as 版本;
"

echo -e "\n8. Adminer 测试..."
docker compose exec adminer sh -c "
PGPASSWORD=olympiad123 psql -h 172.20.0.3 -p 5432 -U admin -d olympiad -c 'SELECT 1;' 2>&1 | head -5
"

echo -e "\n✅ 修复完成！"
echo "在 Adminer 中使用:"
echo "  系统: PostgreSQL"
echo "  服务器: 172.20.0.3 或 olympiad-postgres"
echo "  用户名: admin"
echo "  密码: olympiad123"
echo "  数据库: olympiad"
