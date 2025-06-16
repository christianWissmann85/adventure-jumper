# Required Secrets

This file documents the required secrets and environment variables for the project.

## Android Signing (Optional)

If you want to sign your Android releases, you'll need to set up signing configuration:

1. Generate a keystore file if you don't have one:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create a file named `key.properties` in the `android` folder (DO NOT commit this file):
   ```
   storePassword=<password-from-previous-step>
   keyPassword=<password-from-previous-step>
   keyAlias=upload
   storeFile=<location-of-the-keystore-file>
   ```

3. Add the keystore file to your `.gitignore`.
4. Set up GitHub Actions secrets for the keystore file and passwords.
