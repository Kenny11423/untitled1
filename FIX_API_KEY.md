# Sửa lỗi "API key not valid"

## Vấn đề

Lỗi: `API key not valid. Please pass a valid API key.`
Error Code: `unknown`

## Nguyên nhân

1. API key trong `firebase_options.dart` không đúng hoặc đã hết hạn
2. Thiếu file `google-services.json` trong `android/app/`
3. Firebase project chưa được cấu hình đúng

## Cách sửa

### Cách 1: Sử dụng FlutterFire CLI (Khuyến nghị)

1. **Cài đặt FlutterFire CLI (nếu chưa có):**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Cấu hình lại Firebase:**
   ```bash
   flutterfire configure
   ```

3. **Chọn platform:**
   - Chọn Android
   - Chọn project Firebase của bạn

4. **File sẽ được tự động cập nhật:**
   - `lib/firebase_options.dart` - API key mới
   - `android/app/google-services.json` - File cấu hình Android

### Cách 2: Cấu hình thủ công

#### Bước 1: Lấy API key từ Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn (`cookguideapp`)
3. Vào **Project Settings** (⚙️ ở góc trên bên trái)
4. Trong tab **General**, tìm **Your apps**
5. Chọn app Android của bạn
6. Copy các thông tin:
   - **API Key** (Browser key hoặc Android key)
   - **App ID**
   - **Project ID**
   - **Messaging Sender ID**

#### Bước 2: Tải file google-services.json

1. Trong Firebase Console > Project Settings
2. Scroll xuống phần **Your apps**
3. Nhấn vào icon download (⬇️) để tải `google-services.json`
4. Copy file vào: `android/app/google-services.json`

#### Bước 3: Cập nhật firebase_options.dart

Mở file `lib/firebase_options.dart` và cập nhật:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_NEW_API_KEY_HERE',  // ← Thay bằng API key mới
  appId: 'YOUR_APP_ID',              // ← Thay bằng App ID
  messagingSenderId: 'YOUR_SENDER_ID', // ← Thay bằng Messaging Sender ID
  projectId: 'cookguideapp',         // ← Kiểm tra lại Project ID
  storageBucket: 'cookguideapp.firebasestorage.app',
);
```

#### Bước 4: Clean và rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### Cách 3: Kiểm tra API key hiện tại

1. **Kiểm tra API key trong firebase_options.dart:**
   - File: `lib/firebase_options.dart`
   - Dòng 56: `apiKey: 'AIzaSyCazrQ57hLsp0fDEDUwb5_rX5fjjqpAxPcI'`

2. **So sánh với Firebase Console:**
   - Vào Firebase Console > Project Settings
   - Kiểm tra xem API key có khớp không

3. **Nếu không khớp:**
   - Copy API key mới từ Firebase Console
   - Cập nhật trong `firebase_options.dart`

## Kiểm tra sau khi sửa

1. **Đảm bảo file google-services.json tồn tại:**
   ```bash
   ls -la android/app/google-services.json
   ```

2. **Kiểm tra API key đã được cập nhật:**
   ```bash
   grep "apiKey" lib/firebase_options.dart
   ```

3. **Chạy lại app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Thử đăng nhập/đăng ký lại**

## Lưu ý quan trọng

- ⚠️ **Không commit API key vào public repository**
- ✅ File `google-services.json` nên được thêm vào `.gitignore` nếu là private project
- ✅ API key trong `firebase_options.dart` có thể public (đã được Firebase bảo vệ)

## Nếu vẫn gặp lỗi

1. **Kiểm tra Firebase Console:**
   - Đảm bảo project `cookguideapp` đang active
   - Kiểm tra app Android đã được thêm vào project

2. **Kiểm tra Android package name:**
   - File: `android/app/build.gradle.kts`
   - `applicationId = "com.example.untitled1"`
   - Phải khớp với package name trong Firebase Console

3. **Kiểm tra SHA-1/SHA-256:**
   - Vào Firebase Console > Project Settings > Your apps
   - Thêm SHA-1 và SHA-2 của debug keystore:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```

4. **Thử lại với FlutterFire CLI:**
   ```bash
   flutterfire configure --platforms=android
   ```

## Tài liệu tham khảo

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

