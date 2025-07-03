// Supabase Configuration with Retry Logic
// Wait for environment variables to be loaded
let SUPABASE_CONFIG = {
    url: '',
    anonKey: ''
};

// Function to check and update config
function updateSupabaseConfig() {
    if (window.SUPABASE_URL && window.SUPABASE_ANON_KEY) {
        SUPABASE_CONFIG.url = window.SUPABASE_URL;
        SUPABASE_CONFIG.anonKey = window.SUPABASE_ANON_KEY;
        return true;
    }
    return false;
}

// Initialize Supabase client
let supabase = null;

// Debug: Log configuration status
console.log('🔍 Supabase Debug Info:', {
    windowURL: window.SUPABASE_URL,
    windowKey: window.SUPABASE_ANON_KEY ? 'Key exists' : 'No key',
    configURL: SUPABASE_CONFIG.url,
    hasKey: !!SUPABASE_CONFIG.anonKey,
    hasSupabaseLib: !!(window.supabase && window.supabase.createClient),
    supabaseVersion: window.supabase ? 'Loaded' : 'Not loaded'
});

// Try to initialize immediately if possible
updateSupabaseConfig();

function initializeSupabaseClient() {
    if (typeof window !== 'undefined' && window.supabase && SUPABASE_CONFIG.url && SUPABASE_CONFIG.anonKey) {
        try {
            supabase = window.supabase.createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey, {
                auth: {
                    persistSession: true,
                    autoRefreshToken: true
                }
            });
            console.log('✅ Supabase client initialized successfully');
            return true;
        } catch (error) {
            console.error('Failed to initialize Supabase:', error);
            return false;
        }
    }
    return false;
}

// Initial attempt
initializeSupabaseClient();

// Sync Manager Class
class SyncManager {
    constructor(propertyManager) {
        this.propertyManager = propertyManager;
        this.syncQueue = [];
        this.isSyncing = false;
        this.lastSyncTime = localStorage.getItem('lastSyncTime') || null;
        this.syncInterval = null;
        this.offlineChanges = JSON.parse(localStorage.getItem('offlineChanges') || '[]');
        
        // Initialize sync with retry mechanism
        this.retryCount = 0;
        this.maxRetries = 10;
        this.retryDelay = 1000; // Start with 1 second
        
        this.attemptInitialization();
    }
    
    attemptInitialization() {
        // Update config and try to initialize
        updateSupabaseConfig();
        
        if (initializeSupabaseClient() && supabase) {
            console.log('✅ SyncManager: Supabase ready, initializing sync');
            this.initializeSync();
        } else if (this.retryCount < this.maxRetries) {
            this.retryCount++;
            console.log(`⏳ SyncManager: Waiting for credentials (attempt ${this.retryCount}/${this.maxRetries})`);
            this.updateSyncStatus('offline');
            
            // Retry with exponential backoff
            setTimeout(() => {
                this.attemptInitialization();
            }, this.retryDelay);
            
            // Increase delay for next retry (max 10 seconds)
            this.retryDelay = Math.min(this.retryDelay * 1.5, 10000);
        } else {
            console.warn('❌ SyncManager: Max retries reached. Running in offline mode.');
            this.updateSyncStatus('offline');
        }
    }
    
    initializeSync() {
        // Set up periodic sync (every 30 seconds when online)
        this.startPeriodicSync();
        
        // Sync on online event
        window.addEventListener('online', () => {
            this.syncAll();
        });
        
        // Track offline changes
        window.addEventListener('beforeunload', () => {
            this.saveOfflineChanges();
        });
        
        // Initial sync
        if (navigator.onLine) {
            this.syncAll();
        }
    }
    
    startPeriodicSync() {
        this.syncInterval = setInterval(() => {
            if (navigator.onLine && !this.isSyncing) {
                this.syncAll();
            }
        }, 30000); // 30 seconds
    }
    
    async syncAll() {
        if (!supabase || this.isSyncing) return;
        
        this.isSyncing = true;
        this.updateSyncStatus('syncing');
        
        try {
            // Authenticate anonymously if not authenticated
            await this.ensureAuthenticated();
            
            // Sync each data type
            await this.syncTasks();
            await this.syncProjects();
            await this.syncContractors();
            await this.syncDocuments();
            
            // Update last sync time
            this.lastSyncTime = new Date().toISOString();
            localStorage.setItem('lastSyncTime', this.lastSyncTime);
            
            // Clear offline changes
            this.offlineChanges = [];
            localStorage.setItem('offlineChanges', '[]');
            
            this.updateSyncStatus('success');
        } catch (error) {
            // Sync error - update UI status instead of logging
            this.updateSyncStatus('error');
        } finally {
            this.isSyncing = false;
        }
    }
    
    async ensureAuthenticated() {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (!session) {
            // Sign in anonymously
            const { data, error } = await supabase.auth.signInAnonymously();
            if (error) throw error;
        }
    }
    
    async syncTasks() {
        const localTasks = this.propertyManager.state.tasks;
        
        // Push local changes
        for (const task of localTasks) {
            await this.upsertRecord('tasks', task);
        }
        
        // Pull remote changes
        const { data: remoteTasks, error } = await supabase
            .from('tasks')
            .select('*')
            .order('updated_at', { ascending: false });
            
        if (error) throw error;
        
        // Merge with local data (last-write-wins based on updated_at)
        this.mergeData('tasks', remoteTasks);
    }
    
    async syncProjects() {
        const localProjects = this.propertyManager.state.projects;
        
        for (const project of localProjects) {
            await this.upsertRecord('projects', project);
        }
        
        const { data: remoteProjects, error } = await supabase
            .from('projects')
            .select('*')
            .order('updated_at', { ascending: false });
            
        if (error) throw error;
        
        this.mergeData('projects', remoteProjects);
    }
    
    async syncContractors() {
        const localContractors = this.propertyManager.state.contractors;
        
        for (const contractor of localContractors) {
            await this.upsertRecord('contractors', contractor);
        }
        
        const { data: remoteContractors, error } = await supabase
            .from('contractors')
            .select('*')
            .order('updated_at', { ascending: false });
            
        if (error) throw error;
        
        this.mergeData('contractors', remoteContractors);
    }
    
    async syncDocuments() {
        const localDocuments = this.propertyManager.state.documents;
        
        for (const document of localDocuments) {
            await this.upsertRecord('documents', document);
        }
        
        const { data: remoteDocuments, error } = await supabase
            .from('documents')
            .select('*')
            .order('updated_at', { ascending: false });
            
        if (error) throw error;
        
        this.mergeData('documents', remoteDocuments);
    }
    
    async upsertRecord(table, record) {
        // Add updated_at timestamp
        const recordWithTimestamp = {
            ...record,
            updated_at: new Date().toISOString()
        };
        
        const { error } = await supabase
            .from(table)
            .upsert(recordWithTimestamp, { onConflict: 'id' });
            
        if (error) throw error;
    }
    
    mergeData(dataType, remoteData) {
        if (!remoteData || remoteData.length === 0) return;
        
        const localData = this.propertyManager.state[dataType];
        const mergedData = new Map();
        
        // Add all local data to map
        localData.forEach(item => {
            mergedData.set(item.id, item);
        });
        
        // Merge remote data (last-write-wins)
        remoteData.forEach(remoteItem => {
            const localItem = mergedData.get(remoteItem.id);
            
            if (!localItem || new Date(remoteItem.updated_at) > new Date(localItem.updated_at || 0)) {
                mergedData.set(remoteItem.id, remoteItem);
            }
        });
        
        // Update local state
        this.propertyManager.state[dataType] = Array.from(mergedData.values());
        this.propertyManager.saveToLocalStorage();
        
        // Refresh UI if on relevant view
        if (this.propertyManager.currentView === dataType) {
            this.propertyManager.render();
        }
    }
    
    trackChange(dataType, operation, data) {
        if (!navigator.onLine) {
            this.offlineChanges.push({
                dataType,
                operation,
                data,
                timestamp: new Date().toISOString()
            });
            this.saveOfflineChanges();
        }
    }
    
    saveOfflineChanges() {
        localStorage.setItem('offlineChanges', JSON.stringify(this.offlineChanges));
    }
    
    updateSyncStatus(status) {
        const syncIndicator = document.getElementById('syncStatus');
        if (!syncIndicator) return;
        
        switch (status) {
            case 'syncing':
                syncIndicator.innerHTML = '<span class="sync-icon syncing">🔄</span> Synchronisiere...';
                syncIndicator.className = 'sync-status syncing';
                break;
            case 'success':
                syncIndicator.innerHTML = '<span class="sync-icon">✅</span> Synchronisiert';
                syncIndicator.className = 'sync-status success';
                setTimeout(() => {
                    syncIndicator.innerHTML = '<span class="sync-icon">☁️</span> Online';
                    syncIndicator.className = 'sync-status online';
                }, 2000);
                break;
            case 'error':
                syncIndicator.innerHTML = '<span class="sync-icon">⚠️</span> Sync-Fehler';
                syncIndicator.className = 'sync-status error';
                break;
            case 'offline':
                syncIndicator.innerHTML = '<span class="sync-icon">📵</span> Offline';
                syncIndicator.className = 'sync-status offline';
                break;
        }
    }
    
    getLastSyncDisplay() {
        if (!this.lastSyncTime) return 'Noch nie synchronisiert';
        
        const lastSync = new Date(this.lastSyncTime);
        const now = new Date();
        const diffMinutes = Math.floor((now - lastSync) / 60000);
        
        if (diffMinutes < 1) return 'Gerade eben';
        if (diffMinutes < 60) return `Vor ${diffMinutes} Minuten`;
        if (diffMinutes < 1440) return `Vor ${Math.floor(diffMinutes / 60)} Stunden`;
        return `Vor ${Math.floor(diffMinutes / 1440)} Tagen`;
    }
    
    destroy() {
        if (this.syncInterval) {
            clearInterval(this.syncInterval);
        }
    }
}