#!/usr/bin/env bash

# Script to check if the Zoom Meeting SDK setup is complete

echo "🔍 Checking Zoom Meeting SDK Setup..."
echo ""

ERRORS=0
WARNINGS=0

# Check if config.toml exists
if [ ! -f "config.toml" ]; then
    echo "❌ ERROR: config.toml not found"
    echo "   Run: cp sample.config.toml config.toml"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ config.toml exists"
    
    # Check if credentials are filled in
    if grep -q 'client-id=""' config.toml; then
        echo "⚠️  WARNING: client-id is empty in config.toml"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "✅ client-id is configured"
    fi
    
    if grep -q 'client-secret=""' config.toml; then
        echo "⚠️  WARNING: client-secret is empty in config.toml"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "✅ client-secret is configured"
    fi
fi

# Check if SDK directory exists
if [ ! -d "lib/zoomsdk" ]; then
    echo "❌ ERROR: lib/zoomsdk directory not found"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ lib/zoomsdk directory exists"
fi

# Check for required SDK files
if [ ! -f "lib/zoomsdk/libmeetingsdk.so" ]; then
    echo "❌ ERROR: lib/zoomsdk/libmeetingsdk.so not found"
    echo "   You need to download the Zoom Meeting SDK from:"
    echo "   https://marketplace.zoom.us/ → Develop → Build App → Meeting SDK"
    echo "   Then extract it to lib/zoomsdk/"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ libmeetingsdk.so found"
fi

if [ ! -d "lib/zoomsdk/h" ]; then
    echo "❌ ERROR: lib/zoomsdk/h directory not found (header files)"
    echo "   This should be included in the SDK download"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ SDK header files directory exists"
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ ERROR: Docker is not installed"
    echo "   Install Docker from: https://www.docker.com/"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Docker is installed"
fi

if ! command -v docker compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "⚠️  WARNING: docker compose may not be available"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ docker compose is available"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ Setup looks good! You can run: docker compose up"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Setup has $WARNINGS warning(s) but should work"
    exit 0
else
    echo "❌ Setup has $ERRORS error(s) that need to be fixed"
    exit 1
fi





