-- Supabase Security & Performance Fixes (CORRECTED VERSION)
-- Execute this in Supabase SQL Editor

-- =====================================================
-- 1. CHECK WHICH TABLES ACTUALLY EXIST
-- =====================================================
DO $$ 
DECLARE
    table_record RECORD;
BEGIN
    RAISE NOTICE 'Checking existing tables...';
    FOR table_record IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        RAISE NOTICE 'Found table: %', table_record.tablename;
    END LOOP;
END $$;

-- =====================================================
-- 2. PERFORMANCE OPTIMIZATIONS FOR EXISTING TABLES
-- =====================================================

-- Fix RLS performance for tasks table
DROP POLICY IF EXISTS "Users can view own tasks" ON public.tasks;
CREATE POLICY "Users can view own tasks" 
    ON public.tasks FOR SELECT 
    USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can insert own tasks" ON public.tasks;
CREATE POLICY "Users can insert own tasks" 
    ON public.tasks FOR INSERT 
    WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can update own tasks" ON public.tasks;
CREATE POLICY "Users can update own tasks" 
    ON public.tasks FOR UPDATE 
    USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can delete own tasks" ON public.tasks;
CREATE POLICY "Users can delete own tasks" 
    ON public.tasks FOR DELETE 
    USING (user_id = (SELECT auth.uid()));

-- Fix RLS performance for projects table
DROP POLICY IF EXISTS "Users can view own projects" ON public.projects;
CREATE POLICY "Users can view own projects" 
    ON public.projects FOR SELECT 
    USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can insert own projects" ON public.projects;
CREATE POLICY "Users can insert own projects" 
    ON public.projects FOR INSERT 
    WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can update own projects" ON public.projects;
CREATE POLICY "Users can update own projects" 
    ON public.projects FOR UPDATE 
    USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can delete own projects" ON public.projects;
CREATE POLICY "Users can delete own projects" 
    ON public.projects FOR DELETE 
    USING (user_id = (SELECT auth.uid()));

-- Fix RLS performance for contractors table
DROP POLICY IF EXISTS "Users can view own contractors" ON public.contractors;
CREATE POLICY "Users can view own contractors" 
    ON public.contractors FOR SELECT 
    USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can insert own contractors" ON public.contractors;
CREATE POLICY "Users can insert own contractors" 
    ON public.contractors FOR INSERT 
    WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can update own contractors" ON public.contractors;
CREATE POLICY "Users can update own contractors" 
    ON public.contractors FOR UPDATE 
    USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "Users can delete own contractors" ON public.contractors;
CREATE POLICY "Users can delete own contractors" 
    ON public.contractors FOR DELETE 
    USING (user_id = (SELECT auth.uid()));

-- =====================================================
-- 3. ADD RLS FOR NOTES TABLE (if exists)
-- =====================================================

DO $$ 
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'notes') THEN
        -- Enable RLS if not already enabled
        ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
        
        -- Drop existing policies if any
        DROP POLICY IF EXISTS "Users can view own notes" ON public.notes;
        DROP POLICY IF EXISTS "Users can insert own notes" ON public.notes;
        DROP POLICY IF EXISTS "Users can update own notes" ON public.notes;
        DROP POLICY IF EXISTS "Users can delete own notes" ON public.notes;
        
        -- Create optimized policies
        CREATE POLICY "Users can view own notes" 
            ON public.notes FOR SELECT 
            USING (user_id = (SELECT auth.uid()));
            
        CREATE POLICY "Users can insert own notes" 
            ON public.notes FOR INSERT 
            WITH CHECK (user_id = (SELECT auth.uid()));
            
        CREATE POLICY "Users can update own notes" 
            ON public.notes FOR UPDATE 
            USING (user_id = (SELECT auth.uid()));
            
        CREATE POLICY "Users can delete own notes" 
            ON public.notes FOR DELETE 
            USING (user_id = (SELECT auth.uid()));
            
        RAISE NOTICE 'Notes table RLS policies created';
    ELSE
        RAISE NOTICE 'Notes table does not exist yet';
    END IF;
END $$;

-- =====================================================
-- 4. CREATE INDEXES FOR BETTER PERFORMANCE
-- =====================================================

-- Create indexes on user_id for faster queries (if not exists)
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON public.projects(user_id);
CREATE INDEX IF NOT EXISTS idx_contractors_user_id ON public.contractors(user_id);

-- Create indexes on commonly queried fields
CREATE INDEX IF NOT EXISTS idx_tasks_deadline ON public.tasks(deadline);
CREATE INDEX IF NOT EXISTS idx_tasks_building ON public.tasks(building);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON public.tasks(status);
CREATE INDEX IF NOT EXISTS idx_projects_status ON public.projects(status);

-- Create index for notes if table exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'notes') THEN
        CREATE INDEX IF NOT EXISTS idx_notes_user_id ON public.notes(user_id);
        RAISE NOTICE 'Notes index created';
    END IF;
END $$;

-- =====================================================
-- 5. ADD MISSING updated_at COLUMN (for sync)
-- =====================================================

-- Add updated_at to tasks if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'tasks' 
                   AND column_name = 'updated_at') THEN
        ALTER TABLE public.tasks ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at to tasks table';
    END IF;
END $$;

-- Add updated_at to projects if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'projects' 
                   AND column_name = 'updated_at') THEN
        ALTER TABLE public.projects ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at to projects table';
    END IF;
END $$;

-- Add updated_at to contractors if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'contractors' 
                   AND column_name = 'updated_at') THEN
        ALTER TABLE public.contractors ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at to contractors table';
    END IF;
END $$;

-- =====================================================
-- 6. CREATE TRIGGER FOR AUTO-UPDATE updated_at
-- =====================================================

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for each table
DROP TRIGGER IF EXISTS update_tasks_updated_at ON public.tasks;
CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON public.tasks 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_projects_updated_at ON public.projects;
CREATE TRIGGER update_projects_updated_at 
    BEFORE UPDATE ON public.projects 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_contractors_updated_at ON public.contractors;
CREATE TRIGGER update_contractors_updated_at 
    BEFORE UPDATE ON public.contractors 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 7. FINAL VERIFICATION
-- =====================================================

-- Show current table structure
SELECT 
    schemaname,
    tablename,
    rowsecurity,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = t.tablename) as policy_count
FROM pg_tables t
WHERE schemaname = 'public'
ORDER BY tablename;

-- Show all RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;