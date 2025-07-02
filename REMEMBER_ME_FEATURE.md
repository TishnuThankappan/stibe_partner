# Remember Me Functionality

The Stibe Partner app includes a "Remember Me" feature that allows users to stay logged in between app sessions.

## How it Works

1. When a user logs in with the "Remember Me" checkbox selected, their credentials (email and password) are securely stored in the device's secure storage.

2. On subsequent app launches, the app will automatically attempt to log in with the stored credentials if a valid session is not already present.

3. If the auto-login fails (e.g., due to changed password or expired credentials), the stored credentials are cleared, and the user will need to log in manually.

4. When a user logs out, the app preserves the "Remember Me" credentials by default, making it easier for users to log back in. This ensures a better user experience while maintaining security.

## Implementation Details

- Credentials are stored using Flutter's `flutter_secure_storage` package, which uses platform-specific secure storage mechanisms.
- On Android, credentials are stored in the Android Keystore.
- On iOS, credentials are stored in the iOS Keychain.

## Security Considerations

- The implementation is intentionally simple for demonstration purposes.
- In a production environment, consider implementing additional security measures:
  - Encrypting the password before storing it
  - Adding a timeout for stored credentials
  - Implementing biometric authentication before using stored credentials

## Testing the Feature

1. Login with the "Remember Me" checkbox selected
2. Close the app completely
3. Reopen the app - you should be automatically logged in

If you log out:
1. The "Remember Me" credentials are preserved
2. When you open the login screen, you'll still need to enter your credentials
3. When you log back in, check "Remember Me" again to maintain this functionality

To fully clear "Remember Me" credentials, you can log out with the option to preserve credentials set to false (this would typically be a separate "Clear all data" or "Forget me" option in a settings screen).
