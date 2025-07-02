-- Fix RLS Security Issues for Property Manager
-- Execute this in Supabase SQL Editor to fix the security warnings

-- 1. Enable RLS for task_shares table
ALTER TABLE task_shares ENABLE ROW LEVEL SECURITY;

-- 2. Enable RLS for activity_log table  
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies for task_shares
-- Only task owners can create shares
CREATE POLICY "Task owners can create shares" 
    ON task_shares FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_shares.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

-- Task owners and share recipients can view shares
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

-- Only task owners can update shares
CREATE POLICY "Task owners can update shares" 
    ON task_shares FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_shares.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

-- Only task owners can delete shares
CREATE POLICY "Task owners can delete shares" 
    ON task_shares FOR DELETE 
    USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_shares.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

-- 4. Create RLS Policies for activity_log
-- Users can only view their own activity
CREATE POLICY "Users can view own activity" 
    ON activity_log FOR SELECT 
    USING (auth.uid() = user_id);

-- Users can insert their own activity
CREATE POLICY "Users can insert own activity" 
    ON activity_log FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Activity logs cannot be updated (audit trail integrity)
-- No UPDATE policy created intentionally

-- Activity logs cannot be deleted (audit trail integrity)
-- No DELETE policy created intentionally

-- 5. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_task_shares_task_id ON task_shares(task_id);
CREATE INDEX IF NOT EXISTS idx_task_shares_shared_with ON task_shares(shared_with_email);
CREATE INDEX IF NOT EXISTS idx_activity_log_user_id ON activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_created_at ON activity_log(created_at DESC);

-- 6. Verify RLS is enabled on all tables
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM 
    pg_tables
WHERE 
    schemaname = 'public'
    AND tablename IN ('tasks', 'projects', 'contractors', 'task_shares', 'activity_log')
ORDER BY 
    tablename;

-- Expected result: All tables should show rowsecurity = true