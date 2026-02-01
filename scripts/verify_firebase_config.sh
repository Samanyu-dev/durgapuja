#!/bin/bash

# Script to verify Firebase configuration across iOS and Android platforms

set -e

echo "🔍 Verifying Firebase Configuration..."
echo "====================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in the correct project directory. Please run this script from the project root."
    exit 1
fi

echo "📁 Project Structure Check"
echo "---------------------------"

# Check iOS Firebase configuration
echo "📱 iOS Configuration:"
echo "---------------------"

# Check if GoogleService-Info.plist exists
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_status 0 "GoogleService-Info.plist exists"
    
    # Check if it's properly included in Xcode project
    if grep -q "GoogleService-Info.plist" ios/Runner.xcodeproj/project.pbxproj; then
        print_status 0 "GoogleService-Info.plist is included in Xcode project"
    else
        print_status 1 "GoogleService-Info.plist is NOT included in Xcode project"
    fi
    
    # Check if it's in the Resources build phase
    if grep -q "GoogleService-Info.plist in Resources" ios/Runner.xcodeproj/project.pbxproj; then
        print_status 0 "GoogleService-Info.plist is in Resources build phase"
    else
        print_status 1 "GoogleService-Info.plist is NOT in Resources build phase"
    fi
    
    # Check if it's in the Runner group
    if grep -q "97C147031CF9000F007C117D.*GoogleService-Info.plist" ios/Runner.xcodeproj/project.pbxproj; then
        print_status 0 "GoogleService-Info.plist is in Runner group"
    else
        print_status 1 "GoogleService-Info.plist is NOT in Runner group"
    fi
    
else
    print_status 1 "GoogleService-Info.plist does not exist"
fi

# Check Info.plist for Firebase configuration
if [ -f "ios/Runner/Info.plist" ]; then
    print_status 0 "Info.plist exists"
    
    # Check for Google URL schemes
    if grep -q "com.googleusercontent.apps.883266614954-23de0b1f1f7e0c158c42d3" ios/Runner/Info.plist; then
        print_status 0 "Google URL scheme is configured"
    else
        print_warning "Google URL scheme not found in Info.plist"
    fi
    
    # Check for microphone permissions
    if grep -q "NSMicrophoneUsageDescription" ios/Runner/Info.plist; then
        print_status 0 "Microphone usage description is configured"
    else
        print_warning "Microphone usage description not found"
    fi
    
    # Check for speech recognition permissions
    if grep -q "NSSpeechRecognitionUsageDescription" ios/Runner/Info.plist; then
        print_status 0 "Speech recognition usage description is configured"
    else
        print_warning "Speech recognition usage description not found"
    fi
else
    print_status 1 "Info.plist does not exist"
fi

echo ""
echo "🤖 Android Configuration:"
echo "------------------------"

# Check if google-services.json exists
if [ -f "android/app/google-services.json" ]; then
    print_status 0 "google-services.json exists"
    
    # Check project ID
    if grep -q "idolmakers-e7c0c" android/app/google-services.json; then
        print_status 0 "Correct Firebase project ID"
    else
        print_status 1 "Incorrect or missing Firebase project ID"
    fi
    
    # Check package name
    if grep -q "com.example.durgapuja" android/app/google-services.json; then
        print_status 0 "Correct package name"
    else
        print_status 1 "Incorrect or missing package name"
    fi
else
    print_status 1 "google-services.json does not exist"
fi

# Check Android build configuration
if [ -f "android/app/build.gradle.kts" ]; then
    print_status 0 "Android app build.gradle.kts exists"
    
    # Check for Google Services plugin
    if grep -q "com.google.gms.google-services" android/app/build.gradle.kts; then
        print_status 0 "Google Services plugin is configured"
    else
        print_status 1 "Google Services plugin is NOT configured"
    fi
    
    # Check package name in build.gradle
    if grep -q "com.example.durgapuja" android/app/build.gradle.kts; then
        print_status 0 "Package name is configured in build.gradle"
    else
        print_status 1 "Package name is NOT configured in build.gradle"
    fi
else
    print_status 1 "Android app build.gradle.kts does not exist"
fi

echo ""
echo "📦 Dependencies Check:"
echo "---------------------"

# Check pubspec.yaml for Firebase dependencies
if [ -f "pubspec.yaml" ]; then
    print_status 0 "pubspec.yaml exists"
    
    # Check for firebase_core
    if grep -q "firebase_core:" pubspec.yaml; then
        print_status 0 "firebase_core dependency is present"
    else
        print_status 1 "firebase_core dependency is missing"
    fi
    
    # Check for firebase_auth
    if grep -q "firebase_auth:" pubspec.yaml; then
        print_status 0 "firebase_auth dependency is present"
    else
        print_status 1 "firebase_auth dependency is missing"
    fi
    
    # Check for cloud_firestore
    if grep -q "cloud_firestore:" pubspec.yaml; then
        print_status 0 "cloud_firestore dependency is present"
    else
        print_status 1 "cloud_firestore dependency is missing"
    fi
    
    # Check for firebase_storage
    if grep -q "firebase_storage:" pubspec.yaml; then
        print_status 0 "firebase_storage dependency is present"
    else
        print_status 1 "firebase_storage dependency is missing"
    fi
else
    print_status 1 "pubspec.yaml does not exist"
fi

echo ""
echo "🔧 Podfile Check:"
echo "-----------------"

# Check Podfile for Firebase pods
if [ -f "ios/Podfile" ]; then
    print_status 0 "Podfile exists"
    
    # Check for Firebase pods
    if grep -q "pod 'Firebase/" ios/Podfile; then
        print_status 0 "Firebase pods are configured"
    else
        print_warning "Firebase pods may not be explicitly configured"
    fi
else
    print_status 1 "Podfile does not exist"
fi

echo ""
echo "📊 Summary:"
echo "-----------"

# Count successful checks
total_checks=0
passed_checks=0

# iOS checks
total_checks=$((total_checks + 4))
if [ -f "ios/Runner/GoogleService-Info.plist" ] && grep -q "GoogleService-Info.plist" ios/Runner.xcodeproj/project.pbxproj && grep -q "GoogleService-Info.plist in Resources" ios/Runner.xcodeproj/project.pbxproj && grep -q "97C147031CF9000F007C117D.*GoogleService-Info.plist" ios/Runner.xcodeproj/project.pbxproj; then
    passed_checks=$((passed_checks + 4))
fi

total_checks=$((total_checks + 3))
if [ -f "ios/Runner/Info.plist" ] && grep -q "com.googleusercontent.apps.883266614954-23de0b1f1f7e0c158c42d3" ios/Runner/Info.plist && grep -q "NSMicrophoneUsageDescription" ios/Runner/Info.plist; then
    passed_checks=$((passed_checks + 3))
fi

# Android checks
total_checks=$((total_checks + 3))
if [ -f "android/app/google-services.json" ] && grep -q "idolmakers-e7c0c" android/app/google-services.json && grep -q "com.example.durgapuja" android/app/google-services.json; then
    passed_checks=$((passed_checks + 3))
fi

total_checks=$((total_checks + 2))
if [ -f "android/app/build.gradle.kts" ] && grep -q "com.google.gms.google-services" android/app/build.gradle.kts; then
    passed_checks=$((passed_checks + 2))
fi

# Dependencies check
total_checks=$((total_checks + 4))
if [ -f "pubspec.yaml" ] && grep -q "firebase_core:" pubspec.yaml && grep -q "firebase_auth:" pubspec.yaml && grep -q "cloud_firestore:" pubspec.yaml; then
    passed_checks=$((passed_checks + 4))
fi

# Podfile check
total_checks=$((total_checks + 1))
if [ -f "ios/Podfile" ]; then
    passed_checks=$((passed_checks + 1))
fi

percentage=$((passed_checks * 100 / total_checks))

if [ $percentage -eq 100 ]; then
    echo -e "${GREEN}🎉 All Firebase configuration checks passed! (${passed_checks}/${total_checks})${NC}"
    echo ""
    echo "✨ Your Firebase configuration is complete and ready for use!"
    echo ""
    echo "💡 Next steps:"
    echo "  - Run 'flutter pub get' to ensure all dependencies are installed"
    echo "  - Run 'cd ios && pod install' to install iOS dependencies"
    echo "  - Test Firebase functionality in your app"
elif [ $percentage -ge 80 ]; then
    echo -e "${YELLOW}⚠️  Most Firebase configuration checks passed! (${passed_checks}/${total_checks})${NC}"
    echo ""
    echo "🔧 Some minor issues were found. Please review the warnings above."
else
    echo -e "${RED}❌ Firebase configuration has issues! (${passed_checks}/${total_checks})${NC}"
    echo ""
    echo "🚨 Please address the failed checks above before proceeding."
fi

echo ""
echo "🏁 Firebase Configuration Verification Complete!"