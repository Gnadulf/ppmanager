// Test script to verify MIME types locally
const http = require('http');
const fs = require('fs');
const path = require('path');

const testFiles = [
  '/index.html',
  '/supabase-config.js',
  '/service-worker.js',
  '/api/env.js',
  '/manifest.webmanifest',
  '/non-existent-route'  // Should return index.html
];

async function testMimeTypes() {
  console.log('🔍 Testing MIME Types on Local Server...\n');
  
  for (const file of testFiles) {
    await testFile(file);
  }
}

function testFile(filePath) {
  return new Promise((resolve) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: filePath,
      method: 'GET'
    };

    const req = http.request(options, (res) => {
      console.log(`📄 ${filePath}`);
      console.log(`   Status: ${res.statusCode}`);
      console.log(`   Content-Type: ${res.headers['content-type'] || 'Not set'}`);
      console.log(`   Expected: ${getExpectedMimeType(filePath)}`);
      console.log(`   ✅ ${res.headers['content-type']?.includes(getExpectedMimeType(filePath)) ? 'PASS' : '❌ FAIL'}\n`);
      resolve();
    });

    req.on('error', (e) => {
      console.error(`   ❌ Error: ${e.message}\n`);
      resolve();
    });

    req.end();
  });
}

function getExpectedMimeType(filePath) {
  if (filePath.endsWith('.js')) return 'application/javascript';
  if (filePath.endsWith('.html') || filePath === '/non-existent-route') return 'text/html';
  if (filePath.endsWith('.webmanifest')) return 'application/manifest+json';
  return 'unknown';
}

// Run after server starts
setTimeout(testMimeTypes, 2000);