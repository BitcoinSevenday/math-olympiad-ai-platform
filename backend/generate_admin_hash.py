from passlib.context import CryptContext

# 初始化密码上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 要哈希的密码
password = "admin123"

# 生成哈希
hashed_password = pwd_context.hash(password)

print("=" * 60)
print("🔐 生成的 bcrypt 哈希:")
print("=" * 60)
print(f"密码: {password}")
print(f"哈希: {hashed_password}")
print("=" * 60)

# 验证哈希
is_valid = pwd_context.verify(password, hashed_password)
print(f"✅ 验证结果: {is_valid}")

# 生成多个可能的哈希（不同成本因子）
print("\n" + "=" * 60)
print("📊 不同成本因子的哈希:")
print("=" * 60)

for rounds in [10, 12, 14]:
    hashed = pwd_context.using(rounds=rounds).hash(password)
    print(f"\n成本因子 {rounds}:")
    print(f"{hashed}")
    print(f"长度: {len(hashed)} 字符")
