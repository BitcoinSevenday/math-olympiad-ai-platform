-- ============================================
-- 索引定义
-- 针对查询模式优化
-- ============================================

-- users表索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- problems表索引
CREATE INDEX idx_problems_difficulty ON problems(difficulty);
CREATE INDEX idx_problems_source_type ON problems(source_type);
CREATE INDEX idx_problems_source_year ON problems(source_year);
CREATE INDEX idx_problems_is_published ON problems(is_published) WHERE is_published = TRUE;
CREATE INDEX idx_problems_created_at ON problems(created_at DESC);
CREATE INDEX idx_problems_review_status ON problems(review_status);

-- 全文搜索索引
CREATE INDEX idx_problems_search ON problems USING GIN(search_vector);

-- knowledge_points表索引
CREATE INDEX idx_knowledge_points_parent_id ON knowledge_points(parent_id);
CREATE INDEX idx_knowledge_points_code ON knowledge_points(code);
CREATE INDEX idx_knowledge_points_level ON knowledge_points(level);

-- problem_knowledge_points表索引
CREATE INDEX idx_pkp_knowledge_point_id ON problem_knowledge_points(knowledge_point_id);
CREATE INDEX idx_pkp_problem_id ON problem_knowledge_points(problem_id);

-- practice_sessions表索引
CREATE INDEX idx_sessions_user_id ON practice_sessions(user_id);
CREATE INDEX idx_sessions_status ON practice_sessions(status);
CREATE INDEX idx_sessions_started_at ON practice_sessions(started_at DESC);
CREATE INDEX idx_sessions_user_status ON practice_sessions(user_id, status);

-- answer_records表索引（查询最频繁的表）
CREATE INDEX idx_answers_user_id ON answer_records(user_id);
CREATE INDEX idx_answers_problem_id ON answer_records(problem_id);
CREATE INDEX idx_answers_session_id ON answer_records(session_id);
CREATE INDEX idx_answers_is_correct ON answer_records(is_correct);
CREATE INDEX idx_answers_answered_at ON answer_records(answered_at DESC);
CREATE INDEX idx_answers_user_problem ON answer_records(user_id, problem_id);
CREATE INDEX idx_answers_knowledge_points ON answer_records USING GIN(knowledge_point_ids);

-- mistake_collections表索引
CREATE INDEX idx_mistakes_user_id ON mistake_collections(user_id);
CREATE INDEX idx_mistakes_is_mastered ON mistake_collections(is_mastered);
CREATE INDEX idx_mistakes_next_review ON mistake_collections(next_review_at) WHERE NOT is_mastered;

-- student_profiles表索引
CREATE INDEX idx_profiles_user_id ON student_profiles(user_id);
CREATE INDEX idx_profiles_updated_at ON student_profiles(updated_at DESC);

-- ============================================
-- 触发器函数
-- ============================================

-- 自动更新updated_at时间戳
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有需要updated_at的表创建触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_knowledge_points_updated_at BEFORE UPDATE ON knowledge_points
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_problems_updated_at BEFORE UPDATE ON problems
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mistake_collections_updated_at BEFORE UPDATE ON mistake_collections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_student_profiles_updated_at BEFORE UPDATE ON student_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_configs_updated_at BEFORE UPDATE ON system_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 自动更新知识点题目数量
CREATE OR REPLACE FUNCTION update_knowledge_point_problem_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE knowledge_points 
        SET problem_count = problem_count + 1
        WHERE id = NEW.knowledge_point_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE knowledge_points 
        SET problem_count = problem_count - 1
        WHERE id = OLD.knowledge_point_id;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_kp_count AFTER INSERT OR DELETE ON problem_knowledge_points
    FOR EACH ROW EXECUTE FUNCTION update_knowledge_point_problem_count();

-- 自动填充answer_records的知识点数组
CREATE OR REPLACE FUNCTION fill_answer_knowledge_points()
RETURNS TRIGGER AS $$
BEGIN
    SELECT array_agg(knowledge_point_id)
    INTO NEW.knowledge_point_ids
    FROM problem_knowledge_points
    WHERE problem_id = NEW.problem_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER fill_knowledge_points BEFORE INSERT ON answer_records
    FOR EACH ROW EXECUTE FUNCTION fill_answer_knowledge_points();
