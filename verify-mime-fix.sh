#!/bin/bash

echo "🔍 MIME Type Verification Script"
echo "================================"
echo ""

# Wait for deployment
echo "⏳ Waiting 10 seconds for deployment to complete..."
sleep 10

# Test URLs
BASE_URL="https://pp-manager.vercel.app"
TEST_FILES=(
  "/supabase-config.js"
  "/service-worker.js"
  "/api/env.js"
  "/manifest.webmanifest"
  "/index.html"
  "/non-existent-route"
)

echo "📊 Testing MIME Types:"
echo ""

for file in "${TEST_FILES[@]}"; do
  echo "Testing: $file"
  
  # Get headers
  HEADERS=$(curl -sI "$BASE_URL$file" | grep -i "content-type" | head -1)
  STATUS=$(curl -sI "$BASE_URL$file" | grep "HTTP" | head -1)
  
  echo "  Status: $STATUS"
  echo "  Headers: $HEADERS"
  
  # Check expected content type
  if [[ "$file" == *.js ]]; then
    if [[ "$HEADERS" == *"application/javascript"* ]]; then
      echo "  ✅ PASS: JavaScript MIME type correct"
    else
      echo "  ❌ FAIL: Expected application/javascript"
    fi
  elif [[ "$file" == *.webmanifest ]]; then
    if [[ "$HEADERS" == *"application/manifest+json"* ]] || [[ "$HEADERS" == *"application/json"* ]]; then
      echo "  ✅ PASS: Manifest MIME type acceptable"
    else
      echo "  ⚠️  WARNING: Expected application/manifest+json"
    fi
  elif [[ "$file" == *.html ]] || [[ "$file" == "/non-existent-route" ]]; then
    if [[ "$HEADERS" == *"text/html"* ]]; then
      echo "  ✅ PASS: HTML MIME type correct"
    else
      echo "  ❌ FAIL: Expected text/html"
    fi
  fi
  
  echo ""
done

echo "🔧 Testing Service Worker Registration:"
echo ""

# Test if service worker can be fetched
SW_TEST=$(curl -s "$BASE_URL/service-worker.js" | head -c 100)
if [[ "$SW_TEST" == *"Service Worker"* ]] || [[ "$SW_TEST" == *"self.addEventListener"* ]]; then
  echo "✅ Service Worker content is JavaScript"
else
  echo "❌ Service Worker might be returning HTML"
  echo "First 100 chars: $SW_TEST"
fi

echo ""
echo "✅ Verification Complete"