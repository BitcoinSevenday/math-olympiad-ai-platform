#!/bin/bash
# macOS开发环境快速设置脚本

set -e  # 遇到错误退出

echo "🚀 开始设置Math Olympiad AI Platform开发环境..."

# 1. 检查Homebrew
if ! command -v brew &> /dev/null; then
    echo "安装Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. 安装基础工具
echo "安装基础工具..."
brew install git node@21 python@3.14 postgresql@15 redis

# 3. 配置Python虚拟环境
echo "设置Python虚拟环境..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

# 4. 配置Git
#echo "配置Git..."
#read -p "请输入Git用户名: " git_name
#read -p "请输入Git邮箱: " git_email
#git config --global user.name "$git_name"
#git config --global user.email "$git_email"

# 5. 安装VS Code扩展（如果已安装code命令）
if command -v code &> /dev/null; then
    echo "安装VS Code扩展..."
    code --install-extension Vue.volar
    code --install-extension ms-python.python
    code --install-extension ms-azuretools.vscode-docker
fi

echo "✅ 环境设置完成！"
echo "📝 下一步："
echo "   1. 启动虚拟环境: source venv/bin/activate"
echo "   2. 安装Python依赖: pip install -r requirements.txt 暂时没细化这些依赖文件"
echo "   3. 启动开发服务: docker-compose up -d"
