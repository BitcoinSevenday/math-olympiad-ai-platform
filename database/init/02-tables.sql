-- ============================================
-- 表结构定义
-- 遵循命名规范：复数表名，小写加下划线
-- ============================================

-- 用户表
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) NOT NULL DEFAULT 'student' 
        CHECK (role IN ('student', 'teacher', 'admin', 'parent')),
    
    -- 学生特定字段
    grade VARCHAR(20),  -- 年级：如 '初一'、'初二'
    school VARCHAR(100), -- 学校
    
    -- 账户状态
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    
    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- 元数据
    metadata JSONB DEFAULT '{}'::jsonb
);

COMMENT ON TABLE users IS '用户表';
COMMENT ON COLUMN users.role IS '用户角色：student(学生), teacher(老师), admin(管理员), parent(家长)';
COMMENT ON COLUMN users.metadata IS '扩展元数据，如头像URL、偏好设置等';

-- 知识点表（树形结构）
CREATE TABLE knowledge_points (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,  -- 知识点名称
    code VARCHAR(50) UNIQUE NOT NULL,  -- 知识点编码，如 'geometry.plane.area'
    parent_id INTEGER REFERENCES knowledge_points(id) ON DELETE CASCADE,
    level INTEGER NOT NULL DEFAULT 1,  -- 层级：1-一级，2-二级...
    description TEXT,
    
    -- 排序和权重
    sort_order INTEGER DEFAULT 0,
    weight FLOAT DEFAULT 1.0,  -- 在考试中的权重
    
    -- 统计信息（预计算）
    problem_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE knowledge_points IS '知识点表（支持多级分类）';
COMMENT ON COLUMN knowledge_points.code IS '知识点编码，用于快速查询和关联，如 algebra.equation.quadratic';

-- 题目表
CREATE TABLE problems (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,  -- 题目标题
    content TEXT NOT NULL,  -- 题目内容（支持Markdown）
    content_type VARCHAR(20) DEFAULT 'text' 
        CHECK (content_type IN ('text', 'markdown', 'latex')),
    
    -- 选项（JSON格式）
    options JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 答案和解析
    correct_answer VARCHAR(10) NOT NULL,  -- 如 'A', 'B', 'C', 'D'
    solution TEXT,  -- 解题步骤
    solution_type VARCHAR(20) DEFAULT 'text',
    
    -- 难度和分类
    difficulty INTEGER NOT NULL DEFAULT 3 
        CHECK (difficulty >= 1 AND difficulty <= 5),
    source_type VARCHAR(50),  -- 来源类型：'AMC8', '迎春杯', '华杯赛'
    source_year INTEGER,  -- 年份
    source_detail VARCHAR(100),  -- 详细来源
    
    -- 预估属性
    estimated_time INTEGER,  -- 预估解题时间（秒）
    success_rate FLOAT,  -- 历史正确率
    
    -- 状态控制
    is_published BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    
    -- 审核信息
    reviewed_by INTEGER REFERENCES users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_status VARCHAR(20) DEFAULT 'pending' 
        CHECK (review_status IN ('pending', 'approved', 'rejected')),
    
    -- 统计信息
    total_attempts INTEGER DEFAULT 0,
    correct_attempts INTEGER DEFAULT 0,
    
    -- 时间戳
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 全文搜索支持
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(content, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(solution, '')), 'C')
    ) STORED
);

COMMENT ON TABLE problems IS '题目表';
COMMENT ON COLUMN problems.options IS '题目选项，JSON格式：{"A": "选项A内容", "B": "选项B内容", ...}';
COMMENT ON COLUMN problems.search_vector IS '全文搜索向量，用于快速搜索题目';

-- 题目-知识点关联表（多对多）
CREATE TABLE problem_knowledge_points (
    problem_id INTEGER NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    knowledge_point_id INTEGER NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,  -- 是否主要知识点
    weight FLOAT DEFAULT 1.0,  -- 在该题中的权重
    
    PRIMARY KEY (problem_id, knowledge_point_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE problem_knowledge_points IS '题目-知识点关联表';

-- 练习会话表
CREATE TABLE practice_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 练习配置
    session_type VARCHAR(50) NOT NULL DEFAULT 'random' 
        CHECK (session_type IN ('random', 'knowledge_point', 'difficulty', 'exam')),
    config JSONB DEFAULT '{}'::jsonb,  -- 练习配置：如知识点、题数、难度
    
    -- 状态
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress' 
        CHECK (status IN ('in_progress', 'completed', 'abandoned')),
    
    -- 统计信息
    total_questions INTEGER DEFAULT 0,
    completed_questions INTEGER DEFAULT 0,
    correct_questions INTEGER DEFAULT 0,
    
    -- 时间跟踪
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    total_duration INTEGER,  -- 总用时（秒）
    
    -- 性能指标
    average_time_per_question FLOAT,
    accuracy_rate FLOAT,
    
    -- 元数据
    device_info JSONB DEFAULT '{}'::jsonb,
    ip_address INET
);

COMMENT ON TABLE practice_sessions IS '练习会话表';
COMMENT ON COLUMN practice_sessions.config IS '练习配置JSON，如 {"knowledge_points": [1,2,3], "difficulty": [3,4], "count": 20}';

-- 答题记录表（核心学习数据）
CREATE TABLE answer_records (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES practice_sessions(id) ON DELETE CASCADE,
    problem_id INTEGER NOT NULL REFERENCES problems(id),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 答题详情
    user_answer VARCHAR(10),  -- 用户答案
    is_correct BOOLEAN,
    confidence_level INTEGER CHECK (confidence_level >= 1 AND confidence_level <= 5),  -- 自信程度
    
    -- 时间分析
    time_spent INTEGER NOT NULL,  -- 用时（秒）
    first_response_time INTEGER,  -- 第一次响应时间
    review_count INTEGER DEFAULT 0,  -- 检查次数
    
    -- 步骤数据（为后续分析预留）
    steps JSONB DEFAULT '[]'::jsonb,  -- 解题步骤记录
    hesitation_points JSONB DEFAULT '[]'::jsonb,  -- 犹豫点
    
    -- 反馈
    user_feedback VARCHAR(20) CHECK (user_feedback IN ('too_easy', 'appropriate', 'too_hard', 'unclear')),
    note TEXT,  -- 用户备注
    
    -- 时间戳
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 索引字段（优化查询）
    knowledge_point_ids INTEGER[]  -- 该题关联的知识点ID数组
);

COMMENT ON TABLE answer_records IS '答题记录表（核心学习数据）';
COMMENT ON COLUMN answer_records.steps IS '解题步骤记录，格式：[{"time": 10, "action": "read_question"}, ...]';
COMMENT ON COLUMN answer_records.knowledge_point_ids IS '知识点ID数组，用于快速查询和分析';

-- 错题本表
CREATE TABLE mistake_collections (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    problem_id INTEGER NOT NULL REFERENCES problems(id),
    
    -- 错题信息
    first_wrong_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_wrong_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    wrong_count INTEGER DEFAULT 1,
    
    -- 掌握情况
    is_mastered BOOLEAN DEFAULT FALSE,
    mastered_at TIMESTAMP WITH TIME ZONE,
    
    -- 分析信息
    error_types VARCHAR(50)[],  -- 错误类型：如 'careless', 'concept_unclear', 'calculation'
    weak_knowledge_points INTEGER[],  -- 薄弱知识点
    
    -- 练习计划
    next_review_at TIMESTAMP WITH TIME ZONE,  -- 下次复习时间
    review_count INTEGER DEFAULT 0,
    
    UNIQUE(user_id, problem_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE mistake_collections IS '错题本表';

-- 学生能力画像表
CREATE TABLE student_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 总体统计
    total_practice_time INTEGER DEFAULT 0,  -- 总练习时间（秒）
    total_problems_attempted INTEGER DEFAULT 0,
    overall_accuracy FLOAT DEFAULT 0,
    
    -- 知识点掌握度（JSON格式）
    knowledge_mastery JSONB DEFAULT '{}'::jsonb,
    -- 格式: {"knowledge_point_id": {"score": 0.85, "attempts": 10, "last_practiced": "2024-05-21"}}
    
    -- 难度表现
    difficulty_performance JSONB DEFAULT '{}'::jsonb,
    
    -- 学习习惯
    preferred_practice_time VARCHAR(20),  -- 偏好练习时间
    average_session_duration INTEGER,  -- 平均单次练习时长
    
    -- 趋势数据
    weekly_progress JSONB DEFAULT '{}'::jsonb,
    monthly_trend JSONB DEFAULT '{}'::jsonb,
    
    -- 推荐系统相关
    recommended_problems INTEGER[],  -- 推荐题目ID列表
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_calculated_at TIMESTAMP WITH TIME ZONE  -- 上次计算时间
);

COMMENT ON TABLE student_profiles IS '学生能力画像表';
COMMENT ON COLUMN student_profiles.knowledge_mastery IS '知识点掌握度，JSON格式存储';

-- 系统配置表
CREATE TABLE system_configs (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE system_configs IS '系统配置表';
