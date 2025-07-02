-- Supabase SQL Schema für Property Manager
-- Führen Sie dieses Script im Supabase SQL Editor aus

-- Tasks Tabelle
CREATE TABLE tasks (
    id BIGINT PRIMARY KEY,
    title TEXT NOT NULL,
    building TEXT NOT NULL,
    deadline DATE NOT NULL,
    priority TEXT NOT NULL,
    recurrence TEXT,
    contractor BIGINT,
    budget DECIMAL(10,2) DEFAULT 0,
    stakeholders TEXT[],
    description TEXT,
    status TEXT DEFAULT 'todo',
    completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id)
);

-- Projects Tabelle
CREATE TABLE projects (
    id BIGINT PRIMARY KEY,
    title TEXT NOT NULL,
    building TEXT NOT NULL,
    status TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(10,2) NOT NULL,
    milestones JSONB,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id)
);

-- Contractors Tabelle
CREATE TABLE contractors (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    contact TEXT,
    phone TEXT NOT NULL,
    email TEXT,
    services TEXT[],
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id)
);

-- Indizes für Performance
CREATE INDEX idx_tasks_user_deadline ON tasks(user_id, deadline);
CREATE INDEX idx_projects_user_status ON projects(user_id, status);
CREATE INDEX idx_contractors_user_name ON contractors(user_id, name);

-- Row Level Security aktivieren
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE contractors ENABLE ROW LEVEL SECURITY;

-- RLS Policies für Tasks
CREATE POLICY "Users can view own tasks" 
    ON tasks FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" 
    ON tasks FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" 
    ON tasks FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks" 
    ON tasks FOR DELETE 
    USING (auth.uid() = user_id);

-- RLS Policies für Projects
CREATE POLICY "Users can view own projects" 
    ON projects FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects" 
    ON projects FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects" 
    ON projects FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects" 
    ON projects FOR DELETE 
    USING (auth.uid() = user_id);

-- RLS Policies für Contractors
CREATE POLICY "Users can view own contractors" 
    ON contractors FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own contractors" 
    ON contractors FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own contractors" 
    ON contractors FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own contractors" 
    ON contractors FOR DELETE 
    USING (auth.uid() = user_id);

-- Optional: Team-Funktionen vorbereiten
CREATE TABLE task_shares (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT REFERENCES tasks(id) ON DELETE CASCADE,
    shared_with_email TEXT NOT NULL,
    permission TEXT DEFAULT 'view',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Optional: Audit-Log
CREATE TABLE activity_log (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id BIGINT,
    changes JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for optional tables
ALTER TABLE task_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies for task_shares
CREATE POLICY "Task owners can create shares" 
    ON task_shares FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_shares.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "View task shares" 
    ON task_shares FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_shares.task_id 
            AND tasks.user_id = auth.uid()
        )
        OR 
        shared_with_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    );

CREATE POLICY "Task owners can update shares" 
    ON task_shares FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_shares.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Task owners can delete shares" 
    ON task_shares FOR DELETE 
    USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_shares.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

-- RLS Policies for activity_log
CREATE POLICY "Users can view own activity" 
    ON activity_log FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activity" 
    ON activity_log FOR INSERT 
    WITH CHECK (auth.uid() = user_id);