-- Simplified Architecture for Anonymous Users
-- Only use this if you want device-specific data (no real user accounts)

-- Option 1: Device-specific data (current approach)
-- Each anonymous user = one device
-- Data is isolated per device

-- Option 2: Shared workspace approach
-- All users share the same data (like a shared Google Doc)

-- For shared workspace (if desired):
DROP POLICY IF EXISTS "Users can view own tasks" ON public.tasks;
CREATE POLICY "All users can view all tasks" 
    ON public.tasks FOR SELECT 
    USING (true);

CREATE POLICY "All users can modify all tasks" 
    ON public.tasks FOR ALL 
    USING (true)
    WITH CHECK (true);

-- But this removes data isolation!
-- Only use if you want a truly collaborative workspace