-- init-db.sql
-- 启用 pgvector 扩展
CREATE EXTENSION IF NOT EXISTS vector;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建记忆/文档表 (集成向量存储)
CREATE TABLE IF NOT EXISTS memories (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500),
    content TEXT NOT NULL,
    content_type VARCHAR(50) DEFAULT 'text',
    embedding vector(1536),  -- OpenAI embedding 维度
    metadata JSONB DEFAULT '{}',
    url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建向量相似度搜索索引
CREATE INDEX IF NOT EXISTS memories_embedding_cosine_idx 
ON memories USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 100);

-- 创建常规索引
CREATE INDEX IF NOT EXISTS memories_user_id_idx ON memories(user_id);
CREATE INDEX IF NOT EXISTS memories_created_at_idx ON memories(created_at DESC);
CREATE INDEX IF NOT EXISTS memories_content_type_idx ON memories(content_type);

-- 创建全文搜索索引
CREATE INDEX IF NOT EXISTS memories_content_fts_idx 
ON memories USING gin(to_tsvector('english', content));