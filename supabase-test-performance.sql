-- Test Performance Improvements
-- Run this in Supabase SQL Editor to see the speed difference

-- 1. Check if updated_at columns were added
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
AND column_name = 'updated_at'
ORDER BY table_name;

-- 2. Check indexes
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 3. Test query performance (should be faster now)
EXPLAIN ANALYZE
SELECT * FROM tasks 
WHERE user_id = (SELECT auth.uid())
LIMIT 10;

-- 4. Check table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
    n_live_tup AS row_count
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;