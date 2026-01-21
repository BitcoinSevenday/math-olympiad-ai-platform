# 检查所有相关端口
echo "=== 端口检查 ==="
for port in 5432 6379 5050 8080; do
    echo -n "端口 $port: "
    if lsof -i :$port > /dev/null 2>&1; then
        process=$(lsof -i :$port | grep LISTEN | awk '{print $1}')
        echo "✅ 被 $process 占用"
    else
        echo "❌ 空闲"
    fi
done

# 查看 Docker 容器映射的端口
docker compose ps --services | xargs -I {} sh -c 'echo "{}:" && docker compose port {}'

