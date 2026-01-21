echo "🎯 一键修复编译问题..."

# 1. 创建新的虚拟环境
echo "1. 创建新的虚拟环境..."
rm -rf venv_fixed
python3 -m venv venv_fixed --clear
source venv_fixed/bin/activate

# 2. 升级 pip
echo "2. 升级 pip..."
pip install --upgrade pip setuptools wheel -q

# 3. 使用国内镜像安装基础包
echo "3. 安装基础包..."
pip install \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --trusted-host pypi.tuna.tsinghua.edu.cn \
    --prefer-binary \
    --no-cache-dir \
    fastapi \
    uvicorn \
    sqlalchemy \
    -q

# 4. 尝试安装有问题的包（使用特定版本）
echo "4. 尝试安装有问题的包..."
PROBLEM_PACKAGES=(
    "psycopg2-binary==2.9.9"
    "asyncpg==0.28.0"
    "pydantic==2.5.0"
    "pydantic-core==2.14.5"
)

for package in "${PROBLEM_PACKAGES[@]}"; do
    echo "安装 $package..."
    pip install \
        -i https://pypi.tuna.tsinghua.edu.cn/simple \
        --trusted-host pypi.tuna.tsinghua.edu.cn \
        --prefer-binary \
        --no-cache-dir \
        "$package" -q 2>/dev/null || echo "  ⚠️   $package 安装失败，尝试替代方案..."
done
