#!/usr/bin/env python3
"""
macOS开发环境验证脚本
针对macOS和Apple Silicon优化
"""
import subprocess
import sys
import platform
import os

def run_command(cmd):
    """执行命令并返回输出"""
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"ERROR: {e.stderr.strip()}"

def check_brew():
    """检查Homebrew状态"""
    print("🍺 检查Homebrew...")
    if not os.path.exists("/opt/homebrew/bin/brew") and not os.path.exists("/usr/local/bin/brew"):
        print("   ❌ Homebrew未安装")
        print("   建议运行: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
        return False
    
    brew_path = run_command("which brew")
    print(f"   ✅ Homebrew位置: {brew_path}")
    
    # 检查Apple Silicon还是Intel
    arch = platform.machine()
    print(f"   📱 处理器架构: {arch}")
    
    return True

def check_mac_specific():
    """macOS特化检查"""
    print("\n🍎 macOS系统检查...")
    
    # 系统版本
    version = run_command("sw_vers -productVersion")
    print(f"   ✅ macOS版本: {version}")
    
    # 检查Rosetta 2（如果是Apple Silicon）
    arch = platform.machine()
    if arch == "arm64":
        rosetta = run_command("pgrep oahd > /dev/null 2>&1 && echo '已安装' || echo '未安装'")
        print(f"   🔄 Rosetta 2: {rosetta}")
    
    # 检查终端
    terminal = os.environ.get('TERM_PROGRAM', 'Unknown')
    print(f"   💻 终端: {terminal}")
    
    # 检查Shell
    shell = os.environ.get('SHELL', 'Unknown')
    print(f"   🐚 Shell: {shell}")

def main():
    print("=" * 60)
    print("macOS开发环境验证")
    print("=" * 60)
    
    # 基础检查
    checks = [
        ("操作系统", f"echo {platform.system()} {platform.machine()}"),
        ("Python", "python3 --version", "Python"),
        ("Node.js", "node --version", "v21"),
        ("npm", "npm --version", None),
        ("Git", "git --version", "git"),
        ("Docker", "docker --version", "Docker"),
        ("Docker Compose", "docker-compose --version", "v5"),
    ]
    
    # Homebrew特化检查
    if not check_brew():
        print("⚠️  Homebrew是macOS开发的推荐工具，建议安装")
    
    # macOS特化检查
    check_mac_specific()
    
    print("\n" + "=" * 60)
    
    # 执行标准检查
    passed = 0
    for name, cmd, *keywords in checks:
        expected = keywords[0] if keywords else None
        output = run_command(cmd)
        
        if "ERROR" in output:
            print(f"❌ {name}: 未安装或配置错误")
        elif expected and expected not in output:
            print(f"⚠️  {name}: 版本可能不匹配 ({output})")
        else:
            print(f"✅ {name}: {output.split()[0] if output else 'OK'}")
            passed += 1
    
    print("=" * 60)
    print(f"检查完成：{passed}/{len(checks)} 项通过")
    
    if passed == len(checks):
        print("🎉 所有环境检查通过！可以开始开发了。")
        return 0
    else:
        print("\n🔧 建议操作：")
        print("   1. 确保已安装Homebrew: https://brew.sh")
        print("   2. 通过Homebrew安装缺失工具: brew install git node python@3.11 docker")
        print("   3. 重启终端使配置生效")
        return 1

if __name__ == "__main__":
    sys.exit(main())
