#!/bin/bash

# Script to fix Xcode Firebase configuration
# This script ensures GoogleService-Info.plist is properly included in the Xcode project

set -e

echo "🔧 Fixing Xcode Firebase configuration..."

# Check if we're in the right directory
if [ ! -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Not in the correct project directory. Please run this script from the project root."
    exit 1
fi

# Check if GoogleService-Info.plist exists
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "❌ Error: GoogleService-Info.plist not found in ios/Runner/"
    exit 1
fi

echo "✅ GoogleService-Info.plist found"

# Create a backup of the project file
echo "📦 Creating backup of project.pbxproj..."
cp ios/Runner.xcodeproj/project.pbxproj ios/Runner.xcodeproj/project.pbxproj.backup

# Function to check if GoogleService-Info.plist is already included
check_existing_inclusion() {
    if grep -q "GoogleService-Info.plist" ios/Runner.xcodeproj/project.pbxproj; then
        echo "✅ GoogleService-Info.plist is already included in the project"
        return 0
    else
        echo "⚠️  GoogleService-Info.plist not found in project file"
        return 1
    fi
}

# Function to add GoogleService-Info.plist to the project
add_google_service_info() {
    echo "📝 Adding GoogleService-Info.plist to Xcode project..."
    
    # Generate a unique UUID for the file reference
    UUID=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-')
    
    # Create a temporary file for the modified project
    TEMP_FILE=$(mktemp)
    
    # Add the file reference to PBXFileReference section
    sed '/\/\* Begin PBXFileReference section \*\//,/\*\/ End PBXFileReference section \*\// {
        /97C147021CF9000F007C117D \/\* Info.plist \/\*/a\
		'"$UUID"' /* GoogleService-Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; name = GoogleService-Info.plist; path = Runner/GoogleService-Info.plist; sourceTree = "<group>"; };
    }' ios/Runner.xcodeproj/project.pbxproj > "$TEMP_FILE"
    
    # Add the file to the Runner group
    sed -i '' '/97C147021CF9000F007C117D \/\* Info.plist \/\*/a\
				'"$UUID"' /* GoogleService-Info.plist */,\
' "$TEMP_FILE"
    
    # Add the file to the Resources build phase
    sed -i '' '/97C146FC1CF9000F007C117D \/\* Main.storyboard in Resources \/\*/a\
				'"$UUID"' /* GoogleService-Info.plist in Resources */,\
' "$TEMP_FILE"
    
    # Move the temporary file to the original location
    mv "$TEMP_FILE" ios/Runner.xcodeproj/project.pbxproj
    
    echo "✅ GoogleService-Info.plist added to Xcode project"
}

# Function to verify the fix
verify_fix() {
    echo "🔍 Verifying the fix..."
    
    if check_existing_inclusion; then
        echo "✅ Verification successful: GoogleService-Info.plist is now properly included"
        return 0
    else
        echo "❌ Verification failed: GoogleService-Info.plist is still not included"
        return 1
    fi
}

# Main execution
if check_existing_inclusion; then
    echo "🎯 No action needed - GoogleService-Info.plist is already properly configured"
else
    add_google_service_info
    if verify_fix; then
        echo "🎉 Xcode Firebase configuration fix completed successfully!"
        echo ""
        echo "📋 Summary of changes:"
        echo "  - Added GoogleService-Info.plist file reference to PBXFileReference section"
        echo "  - Added GoogleService-Info.plist to Runner group"
        echo "  - Added GoogleService-Info.plist to Resources build phase"
        echo ""
        echo "💡 Next steps:"
        echo "  - Open Xcode and verify the file appears in the project navigator"
        echo "  - Clean and rebuild your project"
        echo "  - Test Firebase functionality"
    else
        echo "❌ Failed to fix the configuration. Please check the project file manually."
        exit 1
    fi
fi

echo ""
echo "✨ Firebase configuration fix completed!"