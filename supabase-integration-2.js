// supabase-integration.js
// Fügen Sie dieses Script vor dem schließenden </body> Tag in Ihre HTML-Datei ein

// 1. Ersetzen Sie diese Werte mit Ihren Supabase-Credentials
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co'
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY'

// 2. Fügen Sie diese Script-Tags vor dem Integration-Script ein:
// <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

// Integration Code
const initSupabaseSync = async () => {
    // Supabase Client erstellen
    const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    
    // Sync Manager
    const syncManager = {
        syncInProgress: false,
        userId: null,
        
        async init() {
            try {
                // Anonyme Anmeldung
                const { data, error } = await supabaseClient.auth.signInAnonymously();
                if (error) throw error;
                
                this.userId = data.user.id;
                console.log('Supabase connected:', this.userId);
                
                // Initial sync
                await this.pullData();
                
                // Auto-sync every 30 seconds
                setInterval(() => this.sync(), 30000);
                
                // Sync on changes
                window.addEventListener('storage', () => this.pushData());
                
                return true;
            } catch (error) {
                console.error('Supabase init error:', error);
                return false;
            }
        },
        
        async pullData() {
            if (this.syncInProgress) return;
            this.syncInProgress = true;
            
            try {
                // Tasks laden
                const { data: tasks } = await supabaseClient
                    .from('tasks')
                    .select('*')
                    .order('deadline');
                
                // Projects laden
                const { data: projects } = await supabaseClient
                    .from('projects')
                    .select('*')
                    .order('start_date');
                
                // Contractors laden
                const { data: contractors } = await supabaseClient
                    .from('contractors')
                    .select('*')
                    .order('name');
                
                // In localStorage speichern
                if (tasks) localStorage.setItem('propertyTasks', JSON.stringify(tasks));
                if (projects) localStorage.setItem('propertyProjects', JSON.stringify(projects));
                if (contractors) localStorage.setItem('propertyContractors', JSON.stringify(contractors));
                
                // App neu laden
                if (window.app) {
                    window.app.loadData();
                    window.app.render();
                }
                
                this.showStatus('✅ Synchronisiert');
            } catch (error) {
                console.error('Pull error:', error);
                this.showStatus('❌ Sync fehlgeschlagen', 'error');
            } finally {
                this.syncInProgress = false;
            }
        },
        
        async pushData() {
            if (this.syncInProgress) return;
            this.syncInProgress = true;
            
            try {
                const tasks = JSON.parse(localStorage.getItem('propertyTasks') || '[]');
                const projects = JSON.parse(localStorage.getItem('propertyProjects') || '[]');
                const contractors = JSON.parse(localStorage.getItem('propertyContractors') || '[]');
                
                // Upsert mit user_id
                if (tasks.length > 0) {
                    await supabaseClient.from('tasks').upsert(
                        tasks.map(t => ({ ...t, user_id: this.userId }))
                    );
                }
                
                if (projects.length > 0) {
                    await supabaseClient.from('projects').upsert(
                        projects.map(p => ({ ...p, user_id: this.userId }))
                    );
                }
                
                if (contractors.length > 0) {
                    await supabaseClient.from('contractors').upsert(
                        contractors.map(c => ({ ...c, user_id: this.userId }))
                    );
                }
                
                this.showStatus('☁️ Gespeichert');
            } catch (error) {
                console.error('Push error:', error);
                this.showStatus('❌ Upload fehlgeschlagen', 'error');
            } finally {
                this.syncInProgress = false;
            }
        },
        
        async sync() {
            await this.pullData();
            await this.pushData();
        },
        
        showStatus(message, type = 'success') {
            if (window.app && window.app.showNotification) {
                window.app.showNotification(message, type);
            }
        }
    };
    
    // Sync starten
    await syncManager.init();
    
    // Sync-Button zum FAB-Menü hinzufügen
    const fabMenu = document.getElementById('fabMenu');
    if (fabMenu) {
        const syncOption = document.createElement('div');
        syncOption.className = 'fab-option';
        syncOption.innerHTML = '🔄 Jetzt synchronisieren';
        syncOption.onclick = () => syncManager.sync();
        fabMenu.insertBefore(syncOption, fabMenu.firstChild);
    }
    
    // Original saveData erweitern
    if (window.app) {
        const originalSaveData = window.app.saveData.bind(window.app);
        window.app.saveData = function() {
            originalSaveData();
            syncManager.pushData();
        };
    }
};

// Initialisierung nach App-Start
document.addEventListener('DOMContentLoaded', () => {
    setTimeout(initSupabaseSync, 1000);
});