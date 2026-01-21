-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统管理员
INSERT INTO users (username, email, hashed_password, full_name, role, is_active, is_verified) 
VALUES 
('admin', 'admin@olympiad.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '系统管理员', 'admin', TRUE, TRUE),
('demo_student', 'student@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示学生', 'student', TRUE, TRUE),
('demo_teacher', 'teacher@demo.local', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '演示老师', 'teacher', TRUE, TRUE);

-- 插入初始知识点（奥赛数学分类）
INSERT INTO knowledge_points (name, code, parent_id, level, description, sort_order) VALUES
-- 一级知识点
('算术', 'arithmetic', NULL, 1, '基础算术运算', 1),
('代数', 'algebra', NULL, 1, '代数表达式和方程', 2),
('几何', 'geometry', NULL, 1, '平面和立体几何', 3),
('组合数学', 'combinatorics', NULL, 1, '计数和概率', 4),
('数论', 'number_theory', NULL, 1, '整数性质', 5),

-- 二级知识点 - 算术
('整数运算', 'arithmetic.integer', 1, 2, '整数四则运算', 1),
('分数小数', 'arithmetic.fraction', 1, 2, '分数小数运算', 2),
('百分数', 'arithmetic.percentage', 1, 2, '百分数应用', 3),
('比例', 'arithmetic.ratio', 1, 2, '比例和比例分配', 4),

-- 二级知识点 - 代数
('代数式', 'algebra.expression', 2, 2, '代数式化简', 1),
('方程', 'algebra.equation', 2, 2, '一元一次方程', 2),
('方程组', 'algebra.equation_system', 2, 2, '二元一次方程组', 3),
('不等式', 'algebra.inequality', 2, 2, '一元一次不等式', 4),

-- 二级知识点 - 几何
('平面几何', 'geometry.plane', 3, 2, '平面图形性质', 1),
('立体几何', 'geometry.solid', 3, 2, '立体图形性质', 2),
('几何变换', 'geometry.transformation', 3, 2, '平移旋转对称', 3),
('坐标几何', 'geometry.coordinate', 3, 2, '坐标系和图形', 4),

-- 二级知识点 - 组合数学
('计数原理', 'combinatorics.counting', 4, 2, '排列组合', 1),
('概率', 'combinatorics.probability', 4, 2, '简单概率计算', 2),
('逻辑推理', 'combinatorics.logic', 4, 2, '逻辑推理问题', 3),

-- 二级知识点 - 数论
('整除性质', 'number_theory.divisibility', 5, 2, '整除和余数', 1),
('质数与合数', 'number_theory.prime', 5, 2, '质数合数性质', 2),
('最大公约数', 'number_theory.gcd', 5, 2, '最大公约数应用', 3);

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, is_public) VALUES
('system.name', '"Math Olympiad AI Platform"', '系统名称', TRUE),
('system.version', '"1.0.0"', '系统版本', TRUE),
('practice.default_question_count', '20', '默认练习题目数量', TRUE),
('practice.time_limit', '3600', '默认练习时间限制（秒）', TRUE),
('difficulty.levels', '["入门", "基础", "中等", "困难", "挑战"]', '难度级别名称', TRUE),
('knowledge_point.weight_default', '1.0', '知识点默认权重', FALSE),
('recommendation.enabled', 'false', '是否启用智能推荐', FALSE);

-- 插入示例题目（AMC8风格）
INSERT INTO problems (title, content, options, correct_answer, difficulty, source_type, source_year, is_published) VALUES
('简单的算术运算',
 '小明有15个苹果，他给了小红3个，又给了小刚5个，最后自己吃了1个。请问小明现在还有几个苹果？',
 '{"A": "6个", "B": "7个", "C": "8个", "D": "9个", "E": "10个"}',
 'A',
 1,
 'AMC8',
 2020,
 TRUE),

('分数加法',
 '计算：$\frac{1}{2} + \frac{1}{3} = $',
 '{"A": "$\frac{2}{5}$", "B": "$\frac{5}{6}$", "C": "$\frac{3}{5}$", "D": "$\frac{1}{6}$", "E": "$\frac{5}{3}$"}',
 'B',
 2,
 'AMC8',
 2019,
 TRUE),

('几何面积',
 '一个正方形的边长是6厘米，那么它的面积是多少平方厘米？',
 '{"A": "12", "B": "24", "C": "30", "D": "36", "E": "42"}',
 'D',
 1,
 '迎春杯',
 2021,
 TRUE),

('代数方程',
 '如果 $2x + 5 = 15$，那么 $x$ 的值是多少？',
 '{"A": "3", "B": "4", "C": "5", "D": "6", "E": "7"}',
 'C',
 2,
 '华杯赛',
 2022,
 TRUE),

('逻辑推理',
 '三个数的平均数是12，其中两个数分别是8和15，第三个数是多少？',
 '{"A": "10", "B": "11", "C": "12", "D": "13", "E": "14"}',
 'D',
 3,
 'AMC8',
 2023,
 TRUE);

-- 关联题目和知识点
INSERT INTO problem_knowledge_points (problem_id, knowledge_point_id, is_primary) VALUES
(1, 6, TRUE),  -- 算术 -> 整数运算
(1, 7, FALSE), -- 算术 -> 分数小数（次要）
(2, 7, TRUE),  -- 算术 -> 分数小数
(3, 13, TRUE), -- 几何 -> 平面几何
(4, 10, TRUE), -- 代数 -> 方程
(5, 6, TRUE);  -- 算术 -> 整数运算

-- 创建演示学生能力画像
INSERT INTO student_profiles (user_id) 
SELECT id FROM users WHERE username = 'demo_student';

-- 更新知识点题目计数
UPDATE knowledge_points kp
SET problem_count = (
    SELECT COUNT(DISTINCT problem_id)
    FROM problem_knowledge_points pkp
    WHERE pkp.knowledge_point_id = kp.id
);

-- 创建初始练习会话
INSERT INTO practice_sessions (user_id, session_type, config, status, total_questions, completed_questions, started_at) 
SELECT 
    id, 
    'random', 
    '{"difficulty": [1,2,3], "count": 5}'::jsonb,
    'completed',
    5,
    5,
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM users 
WHERE username = 'demo_student';

-- 创建初始答题记录
INSERT INTO answer_records (session_id, problem_id, user_id, user_answer, is_correct, time_spent, answered_at)
SELECT 
    ps.id,
    p.id,
    u.id,
    CASE p.id
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'D'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'A'  -- 故意答错一题
    END,
    CASE p.id
        WHEN 5 THEN FALSE
        ELSE TRUE
    END,
    CASE p.id
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 30
        WHEN 4 THEN 75
        WHEN 5 THEN 90
    END,
    CURRENT_TIMESTAMP - INTERVAL '1 day' + (p.id * INTERVAL '5 minutes')
FROM practice_sessions ps
CROSS JOIN problems p
CROSS JOIN users u
WHERE u.username = 'demo_student'
AND ps.user_id = u.id
AND p.id BETWEEN 1 AND 5;

-- 自动生成错题记录
INSERT INTO mistake_collections (user_id, problem_id, first_wrong_at, last_wrong_at, wrong_count, error_types)
SELECT 
    ar.user_id,
    ar.problem_id,
    MIN(ar.answered_at),
    MAX(ar.answered_at),
    COUNT(*),
    ARRAY['concept_unclear']
FROM answer_records ar
WHERE ar.is_correct = FALSE
GROUP BY ar.user_id, ar.problem_id
ON CONFLICT (user_id, problem_id) DO UPDATE 
SET 
    last_wrong_at = EXCLUDED.last_wrong_at,
    wrong_count = mistake_collections.wrong_count + EXCLUDED.wrong_count;
