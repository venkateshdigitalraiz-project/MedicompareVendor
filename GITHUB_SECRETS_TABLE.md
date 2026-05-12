# GitHub Secrets Setup - iOS Deployment

| File | GitHub Secret Name | Encoding Required | Description |
|------|-------------------|------------------|-------------|
| `Certificates.p12` | `IOS_CERTIFICATE_BASE64` | ✅ Yes (Base64) | Distribution certificate for code signing |
| `AuthKey_5NQM2B6S4L.p8` | `APP_STORE_CONNECT_API_KEY_BASE64` | ✅ Yes (Base64) | App Store Connect API key for uploads |
| `Medicompare_vendor_profile.mobileprovision` | `IOS_PROVISIONING_PROFILE_BASE64` | ✅ Yes (Base64) | App Store provisioning profile |

## Text-Based Secrets (No Encoding Required)

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `IOS_CERTIFICATE_PASSWORD` | *Your .p12 export password* | Password used when exporting certificate |
| `IOS_KEYCHAIN_PASSWORD` | *Create secure password* | Temporary keychain password for workflow |
| `APP_STORE_CONNECT_API_KEY_ID` | `5NQM2B6S4L` | API Key ID (from .p8 filename) |
| `APP_STORE_CONNECT_ISSUER_ID` | *Your issuer ID* | Apple Developer account issuer ID |
| `IOS_DEVELOPMENT_TEAM` | *Your Team ID* | Apple Developer Team ID (10-character string) |
| `IOS_PROVISIONING_PROFILE_SPECIFIER` | *Your profile name* | Exact name of your provisioning profile |

## Files NOT Needed

| File | Reason |
|------|--------|
| `CertificateSigningRequest.certSigningRequest` | Used only for certificate creation |
| `distribution.cer` | Already included in .p12 file |

## Base64 Encoding Commands

```bash
# Navigate to your iosfiles directory
cd iosfiles

# Encode certificate (copy to clipboard)
base64 -i Certificates.p12 | pbcopy

# Encode API key (copy to clipboard)  
base64 -i AuthKey_5NQM2B6S4L.p8 | pbcopy

# Encode provisioning profile (copy to clipboard)
base64 -i Medicompare_vendor_profile.mobileprovision | pbcopy
```

## Setup Steps

1. **Go to your GitHub repository**
2. **Settings → Secrets and variables → Actions**
3. **Click "New repository secret"**
4. **Add each secret from the tables above**
5. **Use the encoded values** for files requiring Base64
6. **Use plain text values** for text-based secrets
