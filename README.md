# 📚 Book Duel

A real-time, head-to-head reading challenge built with Flutter and Firebase. Gamify your reading habit by dueling friends over who can finish more pages!

---

## 🚀 Quickstart

### 1. Prerequisites

- **Flutter SDK** (≥ 3.0): [Install Flutter](https://flutter.dev/docs/get-started/install) and verify with:
  ```bash
  flutter --version
  ```

- **Dart SDK** (comes with Flutter)

- **Firebase CLI** (for emulators & deploy):
  ```bash
  npm install -g firebase-tools
  firebase login
  ```

- **Optional** (if you plan to run the Cloud Functions):
  - Node.js (≥ 14.x)
  - npm or yarn

### 2. Clone & Install

```bash
# Clone your repo
git clone https://github.com/your-username/book_duel.git
cd book_duel

# Get Flutter packages
flutter pub get

# (Optional) Install Functions dependencies
cd functions
npm install
cd ..
```

### 3. Firebase Setup

1. Copy your Firebase config into `lib/firebase_options.dart`. If you initialized with `flutterfire_cli`, this file is auto-generated; otherwise, run:
   ```bash
   flutterfire configure
   ```

2. Start local emulators (Auth & Realtime Database):
   ```bash
   firebase emulators:start --only auth,database
   ```
   
   > **Tip:** In production you'll point at your live Firebase project by removing the emulator flags.

### 4. Run the App

**Android / iOS / Simulator:**
```bash
flutter run
```

**Web:**
```bash
flutter run -d chrome
```

**Desktop (Linux/macOS/Windows):**
```bash
flutter run -d linux   # or macos, windows
```

### 5. Testing

Run your unit & widget tests:
```bash
flutter test
```

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/my-improvement`
3. Commit & push:
   ```bash
   git add .
   git commit -m "feat: describe change"
   git push origin feat/my-improvement
   ```
4. Open a PR against `main`

---

Happy dueling! 🎉
