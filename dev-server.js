#!/usr/bin/env node

/**
 * Development server that injects environment variables
 * This allows local development with Supabase credentials without hardcoding them
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

// Load environment variables from .env.local if it exists
const envPath = path.join(__dirname, '.env.local');
if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    envContent.split('\n').forEach(line => {
        const trimmed = line.trim();
        if (trimmed && !trimmed.startsWith('#')) {
            const [key, ...valueParts] = trimmed.split('=');
            const value = valueParts.join('=').replace(/^["']|["']$/g, '');
            process.env[key] = value;
        }
    });
    console.log('✅ Loaded environment variables from .env.local');
} else {
    console.warn('⚠️  No .env.local file found. Copy env.example to .env.local and add your credentials.');
}

const PORT = process.env.PORT || 8000;
const MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.json': 'application/json',
    '.css': 'text/css',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.ico': 'image/x-icon',
    '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url);
    let pathname = `.${parsedUrl.pathname}`;
    
    // Default to index.html
    if (pathname === './') {
        pathname = './index.html';
    }
    
    const ext = path.extname(pathname).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'text/plain';
    
    fs.readFile(pathname, (err, data) => {
        if (err) {
            res.writeHead(404);
            res.end(`File ${pathname} not found!`);
            return;
        }
        
        // Inject environment variables into HTML files
        if (ext === '.html') {
            let content = data.toString();
            
            // Replace environment variable placeholders
            content = content.replace(/%NEXT_PUBLIC_SUPABASE_URL%/g, 
                process.env.NEXT_PUBLIC_SUPABASE_URL || '');
            content = content.replace(/%NEXT_PUBLIC_SUPABASE_ANON_KEY%/g, 
                process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '');
            
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content);
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(data);
        }
    });
});

server.listen(PORT, () => {
    console.log(`
🚀 Property Manager Development Server
   Running at: http://localhost:${PORT}
   
   Supabase URL: ${process.env.NEXT_PUBLIC_SUPABASE_URL ? '✅ Configured' : '❌ Not configured'}
   Supabase Key: ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ? '✅ Configured' : '❌ Not configured'}
   
   Press Ctrl+C to stop
`);
});