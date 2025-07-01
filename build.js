#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read the index.html file
const indexPath = path.join(__dirname, 'index.html');
let indexContent = fs.readFileSync(indexPath, 'utf8');

// Replace environment variable placeholders with actual values
const replacements = {
    '%NEXT_PUBLIC_SUPABASE_URL%': process.env.NEXT_PUBLIC_SUPABASE_URL || '',
    '%NEXT_PUBLIC_SUPABASE_ANON_KEY%': process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''
};

for (const [placeholder, value] of Object.entries(replacements)) {
    indexContent = indexContent.replace(new RegExp(placeholder, 'g'), value);
}

// Write the processed file to the output directory
const outputDir = path.join(__dirname, 'dist');
if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
}

// Copy all files to dist
const filesToCopy = [
    'manifest.json',
    'service-worker.js',
    'supabase-config.js',
    'supabase-schema.sql',
    'icon-96.png',
    'icon-192.png',
    'icon-512.png'
];

// Write processed index.html
fs.writeFileSync(path.join(outputDir, 'index.html'), indexContent);

// Copy other files
filesToCopy.forEach(file => {
    const srcPath = path.join(__dirname, file);
    const destPath = path.join(outputDir, file);
    
    if (fs.existsSync(srcPath)) {
        fs.copyFileSync(srcPath, destPath);
        console.log(`Copied ${file}`);
    } else {
        console.warn(`Warning: ${file} not found`);
    }
});

console.log('Build completed! Environment variables injected.');
console.log('Supabase URL:', process.env.NEXT_PUBLIC_SUPABASE_URL ? 'Set' : 'Not set');
console.log('Supabase Key:', process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ? 'Set' : 'Not set');