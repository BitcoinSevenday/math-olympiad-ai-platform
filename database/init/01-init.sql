-- Math Olympiad AI Platform 数据库初始化脚本
-- 生成时间: $(date)
-- macOS环境: Apple Silicon

-- 设置数据库参数
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- 创建扩展（如果有需要）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- 用于模糊搜索
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";  -- SQL性能监控

-- 设置搜索路径
SET search_path = public, pg_catalog;

-- 注释
COMMENT ON DATABASE olympiad IS '奥赛AI平台主数据库';
COMMENT ON SCHEMA public IS '标准公共模式';