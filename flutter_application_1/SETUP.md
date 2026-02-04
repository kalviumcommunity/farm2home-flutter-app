# Farm2Home App Setup

## Features Implemented

### 🔐 Authentication
- **Email/Password Authentication** - Users can sign up and log in with email
- **Google Sign-In** - One-tap Google authentication enabled
- Beautiful gradient login UI with Farm2Home branding

### 🏠 Home Pages
The app has 3 main sections accessible via bottom navigation:

1. **Products Page** (🛒)
   - Grid view of fresh farm products
   - Add new products with name, price, and unit
   - Real-time updates via Firebase Firestore
   - Each product shows farmer info

2. **Farmers Page** (🚜)
   - Browse local farmers
   - View farmer profiles (coming soon)
   - Connect directly with farmers

3. **Profile Page** (👤)
   - User profile with email
   - My Orders section
   - Favorites
   - Delivery Address
   - Settings
   - Sign Out button

## Firebase Setup Required

For Google Sign-In to work, you need to:

1. **Enable Google Sign-In in Firebase Console:**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable "Google" as a sign-in provider
   - Add your support email

2. **For Android:**
   - Add SHA-1 fingerprint to Firebase project
   - Download updated `google-services.json`
   - Run: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

3. **For iOS:**
   - Download updated `GoogleService-Info.plist`
   - Add URL schemes in Info.plist (auto-configured)

4. **For Web:**
   - Add your web app domain to authorized domains in Firebase

## Running the App

```bash
# Navigate to project directory
cd flutter_application_1

# Install dependencies (already done)
flutter pub get

# Run on connected device/emulator
flutter run

# Or run on specific platform
flutter run -d chrome  # Web
flutter run -d windows # Windows
flutter run -d android # Android
```

## Project Structure

```
lib/
├── main.dart           # App entry point with Material theme
├── login_page.dart     # Login/SignUp with Google auth
├── home_page.dart      # Main app with 3 tabs (Products, Farmers, Profile)
└── firebase_options.dart # Firebase configuration
```

## Technologies Used

- Flutter 3.x
- Firebase Authentication
- Cloud Firestore (real-time database)
- Firebase Storage
- Google Sign-In
- Material Design 3

## Next Steps

To enhance the app, consider adding:
- Product images using Firebase Storage
- Shopping cart functionality
- Order management system
- Real farmer profiles with ratings
- Search and filter products
- Payment integration
- Delivery tracking
- Push notifications
