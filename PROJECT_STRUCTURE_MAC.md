math-olympiad-ai-platform/
├── backend/                 # FastAPI后端
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── models/
│   │   ├── schemas/
│   │   └── services/
│   ├── alembic/            # 数据库迁移（macOS推荐Alembic）
│   ├── tests/
│   └── requirements.txt
├── frontend/               # Vue3前端
│   ├── public/
│   └── src/
│       ├── components/
│       ├── views/
│       ├── router/
│       ├── stores/
│       └── utils/
├── docker/                 # Docker相关配置
│   ├── db/                # 数据库初始化脚本
│   └── nginx/             # Nginx配置（生产环境）
├── docs/
│   ├── api/
│   ├── decisions/
│   ├── logs/              # 开发日志（macOS版）
│   └── mac-setup.md       # macOS特化设置指南
├── scripts/
│   ├── dev/               # 开发脚本
│   └── deploy/            # 部署脚本
├── docker-compose.yml
├── docker-compose.dev.yml  # 开发环境配置
├── .env.example
├── .python-version        # pyenv版本文件
├── .node-version         # nvm版本文件
├── .prettierrc           # 前端代码格式化
├── .flake8              # Python代码检查
└── README.md
