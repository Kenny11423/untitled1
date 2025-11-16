# Cooking Guide - Ứng dụng Công thức Nấu ăn

Ứng dụng Flutter để quản lý và xem công thức nấu ăn với Firebase Authentication và Firestore.

## Tính năng

- 🔐 Đăng nhập/Đăng ký với Firebase Authentication
- 🔍 Tìm kiếm công thức
- 🏷️ Lọc theo danh mục
- 📱 Giao diện hiện đại với Material Design 3
- 🖼️ Hiển thị hình ảnh công thức
- 📝 Chi tiết công thức với nguyên liệu và các bước

## Yêu cầu

- Flutter SDK (3.9.2+)
- Android SDK
- Firebase project đã được cấu hình
- Waydroid (để chạy trên Linux)

## Cài đặt

1. Clone repository:
```bash
git clone <repository-url>
cd untitled1
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Cấu hình Firebase:
   - Đảm bảo file `android/app/google-services.json` đã được thêm vào project
   - File `lib/firebase_options.dart` đã được tạo từ Firebase CLI

## Chạy ứng dụng

### Trên Waydroid (Android container)

#### Với Android Studio:
1. Mở project trong Android Studio
2. Chọn Run Configuration: **"main.dart (Waydroid)"** (ở góc trên bên phải)
3. Chọn Device: **"192.168.240.112:5555"** hoặc **"WayDroid x86 64 Device"**
4. Nhấn **Run** (▶️) hoặc **Debug** (🐛)

**Nếu gặp vấn đề:** Xem hướng dẫn chi tiết trong [ANDROID_STUDIO_SETUP.md](ANDROID_STUDIO_SETUP.md)

#### Với VS Code/Cursor:
1. Nhấn `F5` và chọn **"Flutter: Run on Waydroid"**

#### Từ Terminal:
```bash
flutter run -d 192.168.240.112:5555
```

**Kiểm tra cấu hình:**
```bash
./check_waydroid.sh
```

### Trên Linux Desktop

```bash
flutter run -d linux
```

### Trên Android Device/Emulator

```bash
flutter run
```

## Cấu trúc Project

```
lib/
├── constants/          # Colors và Styles
├── models/            # Data models
├── screens/           # Các màn hình
├── services/          # Firebase services
└── widgets/           # Reusable widgets
```

## Tài liệu

- [Hướng dẫn chạy trên Waydroid](WAYDROID_SETUP.md)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

## License

This project is a starting point for a Flutter application.
