# ROLLBACK ANLEITUNG - Falls Build-Time Injection versagt

## Option 1: Manuelle Konfiguration
1. Erstelle `env-config.js` manuell:
```javascript
window.SUPABASE_URL = 'https://deine-url.supabase.co';
window.SUPABASE_ANON_KEY = 'dein-anon-key';
```

2. Lade diese Datei auf Vercel hoch

## Option 2: URL Parameter
1. Nutze Query Parameter: `?supabase_url=XXX&supabase_key=YYY`
2. Parse diese in JavaScript

## Option 3: Prompt für Credentials
```javascript
if (!window.SUPABASE_URL) {
    window.SUPABASE_URL = prompt('Supabase URL:');
    window.SUPABASE_ANON_KEY = prompt('Supabase Key:');
    localStorage.setItem('supabase_url', window.SUPABASE_URL);
    localStorage.setItem('supabase_key', window.SUPABASE_ANON_KEY);
}
```

## Option 4: Hardcoded Test-Credentials
Nur für Testing - NIEMALS in Production!