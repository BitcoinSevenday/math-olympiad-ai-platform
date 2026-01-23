import sys
sys.path.append('.')

from passlib.context import CryptContext

# 初始化密码上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 数据库中的哈希密码
stored_hash = "$2b$12$o/09sdvm6tWbTY9CghAA0OWoxK38UIfwg.Twe6Y7UMMEn0AyHiUP6"

# 测试常用密码
test_passwords = [
    "admin123",
    "admin",
    "password",
    "123456",
    "admin@123",
    "Admin123",
    "Admin@123",
    "administrator",
    "root",
    "test",
    "matholympiad",
    "olympiad",
    "math123",
]

print(f"测试哈希: {stored_hash}")
print("-" * 50)

for pwd in test_passwords:
    try:
        if pwd_context.verify(pwd, stored_hash):
            print(f"✅ 找到了正确的密码: '{pwd}'")
            break
        else:
            print(f"❌ 不是: '{pwd}'")
    except Exception as e:
        print(f"❌ 测试 '{pwd}' 时出错: {e}")
