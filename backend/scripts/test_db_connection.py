import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

try:
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD')
    )
    
    cursor = conn.cursor()
    cursor.execute("SELECT version();")
    db_version = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
    table_count = cursor.fetchone()
    
    print("✅ 数据库连接成功！")
    print(f"📊 PostgreSQL版本: {db_version[0]}")
    print(f"📈 数据表数量: {table_count[0]}")
    
    # 检查各个表的数据量
    tables = ['users', 'problems', 'knowledge_points', 'answer_records']
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table};")
        count = cursor.fetchone()[0]
        print(f"  {table}: {count} 条记录")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ 数据库连接失败: {e}")
