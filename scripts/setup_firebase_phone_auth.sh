#!/bin/bash

# Firebase Phone Authentication Setup Script
# This script helps configure Firebase Phone Authentication without Xcode

echo "Firebase Phone Authentication Setup"
echo "===================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Error: Firebase CLI is not installed."
    echo "Please install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if logged into Firebase
if ! firebase auth:token &> /dev/null; then
    echo "Error: Not logged into Firebase CLI."
    echo "Please run: firebase login"
    exit 1
fi

echo "✓ Firebase CLI is installed and authenticated"

# Check if we're in a Firebase project
if [ ! -f "firebase.json" ]; then
    echo "Error: No firebase.json found. Please run this script from your project root."
    exit 1
fi

echo "✓ Firebase project detected"

# Instructions for manual setup
echo ""
echo "Manual Setup Required:"
echo "======================"
echo ""
echo "1. Go to Firebase Console: https://console.firebase.google.com/"
echo "2. Select your project"
echo "3. Go to Authentication > Sign-in method"
echo "4. Enable Phone Authentication"
echo ""
echo "5. For iOS App Verification Setup:"
echo "   a. Go to Project Settings > Cloud Messaging"
echo "   b. Under 'iOS app configuration', upload your APNs Authentication Key"
echo "   c. Enable 'Background Modes' in your iOS app capabilities:"
echo "      - Background fetch"
echo "      - Remote notifications"
echo ""
echo "6. Add test phone numbers (optional but recommended for development):"
echo "   a. In Authentication > Sign-in method"
echo "   b. Scroll to 'Phone numbers for testing'"
echo "   c. Add test numbers like +16505553434 with verification code 123456"
echo ""
echo "7. For reCAPTCHA configuration:"
echo "   a. Go to Project Settings > General"
echo "   b. Under 'Your apps', select your iOS app"
echo "   c. Note your App ID for reCAPTCHA configuration"
echo ""
echo "Important Notes:"
echo "================"
echo "- Test phone numbers must be fictional and not real numbers"
echo "- Test numbers are only for development, not production"
echo "- Background modes are required for silent push notifications"
echo "- APNs key is required for production apps"
echo ""
echo "After completing these steps, phone authentication should work."
echo "Test with your configured test numbers first before using real numbers."