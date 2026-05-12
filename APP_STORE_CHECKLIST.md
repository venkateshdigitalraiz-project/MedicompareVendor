# App Store Submission Checklist - Medicompares Vendor

## ✅ Completed Configurations

### 1. Info.plist Configuration
- [x] NSCameraUsageDescription - Camera access for profile/product photos
- [x] NSPhotoLibraryUsageDescription - Photo library access for image selection
- [x] NSMicrophoneUsageDescription - Microphone access for audio features
- [x] ITSAppUsesNonExemptEncryption - Set to false
- [x] UIRequiredDeviceCapabilities - armv7 requirement
- [x] UIStatusBarStyle - Light content style
- [x] UIViewControllerBasedStatusBarAppearance - Set to false

### 2. App Icons
- [x] All required icon sizes present (20x20 to 1024x1024)
- [x] Proper Contents.json configuration
- [x] Icons generated using icons_launcher

### 3. Export Configuration
- [x] exportOptions.plist created for App Store uploads

### 4. Legal & Privacy
- [x] Privacy Policy document created (PRIVACY_POLICY.md)

## 🔔 Action Items Before Submission

### 1. Apple Developer Account Setup
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Create App Store Connect account
- [ ] Generate Distribution Certificate
- [ ] Create App Store Distribution Provisioning Profile
- [ ] Update exportOptions.plist with your Team ID and Profile Name

### 2. App Store Connect Configuration
- [ ] Create new app in App Store Connect
- [ ] Fill in app metadata:
  - [ ] App name: "Medicompares Vendor"
  - [ ] Description
  - [ ] Keywords
  - [ ] Support URL
  - [ ] Marketing URL
  - [ ] Privacy Policy URL (host your PRIVACY_POLICY.md)
- [ ] Upload app screenshots (required for all device sizes)
- [ ] Set app category and age rating
- [ ] Configure pricing and availability

### 3. Build & Archive
- [ ] Update bundle identifier in Xcode
- [ ] Set version number (currently 1.0.1+2)
- [ ] Clean build folder
- [ ] Archive the app
- [ ] Upload to App Store Connect

### 4. Testing
- [ ] Test on physical iOS devices
- [ ] Verify all permissions work correctly
- [ ] Test payment integration (Razorpay)
- [ ] Test image picker functionality
- [ ] Test all app features

### 5. Final Verification
- [ ] Ensure app follows iOS Human Interface Guidelines
- [ ] Verify no crashes or memory leaks
- [ ] Check app launch time (< 20 seconds)
- [ ] Verify app size is reasonable (< 100MB preferred)

## 📋 Required Information for App Store

### App Metadata
- App Name: Medicompares Vendor
- Bundle ID: com.yourcompany.medicomparevendor (update as needed)
- Version: 1.0.1
- Category: Business/Medical
- Age Rating: 12+ (due to medical content)

### Privacy Information
- Data Collection: Yes (name, email, photos, usage data)
- Data Types: Contact info, photos, usage data
- Purpose: App functionality, analytics, support
- Data Sharing: No (except with service providers)

### Technical Requirements
- iOS Version: iOS 12.0 or higher
- Device Support: iPhone, iPad
- Orientation: Portrait + Landscape
- App Size: TBD after build

## 🚀 Build Commands

### Clean and Build
```bash
cd ios
flutter clean
flutter pub get
flutter build ios --release
```

### Archive and Upload
```bash
# Open in Xcode
open ios/Runner.xcworkspace
# Then use Xcode to archive and upload
```

## 📞 Support Information
- Support Email: support@medicompares.com
- Privacy Policy: [Upload PRIVACY_POLICY.md to your website]
- Marketing Website: [Your website URL]

## ⚠️ Common Issues to Avoid
- Don't use placeholder text in app metadata
- Ensure all permissions have clear descriptions
- Test on multiple iOS versions and devices
- Verify app works without network connection
- Check for memory warnings and crashes
- Ensure proper error handling throughout the app

## 📊 App Review Guidelines
- [ ] App follows Apple's App Store Review Guidelines
- [ ] No mention of other platforms in app description
- [ ] App provides real value to users
- [ ] No misleading information or functionality
- [ ] Proper handling of user data and privacy
