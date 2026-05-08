# iOS Deployment Workflow - Required Changes

## ✅ Changes Made

### 1. Updated Workflow File (`.github/workflows/ios_deploy.yml`)
- Replaced hardcoded team ID `GGRJQ7RAX2` with placeholder `YOUR_TEAM_ID`
- Replaced hardcoded profile name `Amaran_AppStore_Profile` with placeholder `YOUR_PROVISIONING_PROFILE_NAME`

### 2. Updated Export Options (`ios/exportOptions.plist`)
- Changed signing style from `automatic` to `manual` to match workflow

## 🔧 Action Items - YOU MUST UPDATE THESE

### 1. Replace Placeholders in Workflow
Replace these placeholders in `.github/workflows/ios_deploy.yml`:
- `YOUR_TEAM_ID` → Your actual Apple Developer Team ID
- `YOUR_PROVISIONING_PROFILE_NAME` → Your App Store provisioning profile name

### 2. Replace Placeholders in Export Options
Replace these placeholders in `ios/exportOptions.plist`:
- `YOUR_TEAM_ID` → Your actual Apple Developer Team ID  
- `YOUR_PROVISIONING_PROFILE_NAME` → Your App Store provisioning profile name

### 3. Required GitHub Secrets
Add these secrets to your GitHub repository:
- `IOS_CERTIFICATE_BASE64` - Base64 encoded .p12 certificate
- `IOS_CERTIFICATE_PASSWORD` - Certificate password
- `IOS_KEYCHAIN_PASSWORD` - Keychain password
- `IOS_PROVISIONING_PROFILE_BASE64` - Base64 encoded provisioning profile
- `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API Key ID
- `APP_STORE_CONNECT_ISSUER_ID` - App Store Connect Issuer ID
- `APP_STORE_CONNECT_API_KEY_BASE64` - Base64 encoded .p8 API key

## 📋 Workflow Configuration Details

### Current Settings
- **Flutter Version**: 3.41.9 (stable)
- **Xcode Version**: 26
- **Runner**: macos-15
- **Signing**: Manual
- **Export Method**: app-store

### Build Process
1. Sets up Flutter 3.41.9
2. Installs CocoaPods
3. Configures manual code signing
4. Builds IPA with export options
5. Uploads to App Store Connect using API key

## ⚠️ Important Notes

1. **Bundle Identifier**: Ensure your app's bundle identifier matches your provisioning profile
2. **Certificate**: Use a distribution certificate for App Store uploads
3. **Provisioning Profile**: Must be an App Store distribution profile
4. **API Key**: Must have App Manager role in App Store Connect

## 🚀 Testing the Workflow

Before deploying to production:
1. Test with a test flight build first
2. Verify all secrets are correctly configured
3. Ensure the workflow runs successfully on a test branch
4. Check that the IPA uploads correctly to App Store Connect

## 📱 App Store Connect Setup

1. Create app in App Store Connect
2. Set bundle identifier to match your app
3. Configure app metadata and screenshots
4. Set up API key with appropriate permissions
5. Ensure app is ready for submission
