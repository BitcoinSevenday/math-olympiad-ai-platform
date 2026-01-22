#!/bin/bash
echo "=== 修复 Node.js 环境 ==="

echo "1. 卸载现有 Node.js..."
brew uninstall --force node node@21 2>/dev/null || true

echo "2. 清理残留文件..."
sudo rm -f /usr/local/bin/node
sudo rm -f /usr/local/bin/npm
sudo rm -rf /usr/local/lib/node_modules 2>/dev/null || true
sudo rm -rf ~/.npm 2>/dev/null || true

echo "3. 修复 icu4c..."
brew reinstall icu4c 2>/dev/null || brew install icu4c
brew link --overwrite icu4c 2>/dev/null || true

echo "4. 安装 Node.js..."
brew install node

echo "5. 验证安装..."
if command -v node &> /dev/null; then
    echo "✅ Node.js 版本: $(node --version)"
else
    echo "❌ Node.js 安装失败，尝试使用 nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.zshrc
    nvm install --lts
    nvm use --lts
fi

echo "完成！"
