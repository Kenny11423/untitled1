# Sửa lỗi Gradle Build

## Vấn đề đã được sửa

**Lỗi:** `Could not determine java version from '21.0.8'`

**Nguyên nhân:** 
- Gradle wrapper đang dùng version 2.14.1 (từ 2015)
- Gradle 2.14.1 không hỗ trợ Java 21+
- Android Gradle Plugin 8.9.1 cần Gradle 8.0+

**Giải pháp đã áp dụng:**
- ✅ Cập nhật Gradle wrapper từ 2.14.1 lên 8.11.1 (yêu cầu tối thiểu cho AGP 8.9.1)
- ✅ Clean project và Gradle caches

## Các bước đã thực hiện

1. **Cập nhật Gradle wrapper:**
   - File: `android/gradle/wrapper/gradle-wrapper.properties`
   - Từ: `gradle-2.14.1-all.zip`
   - Thành: `gradle-8.11.1-all.zip` (yêu cầu tối thiểu cho Android Gradle Plugin 8.9.1)

2. **Clean project:**
   ```bash
   flutter clean
   rm -rf android/.gradle android/app/.gradle ~/.gradle/caches
   flutter pub get
   ```

## Thử lại

Bây giờ bạn có thể thử chạy lại trong Android Studio:

1. Chọn Run Configuration: **"main.dart (Waydroid)"**
2. Chọn Device: **"192.168.240.112:5555"**
3. Nhấn **Run** (▶️)

Hoặc từ terminal:
```bash
flutter run -d 192.168.240.112:5555
```

## Nếu vẫn gặp lỗi

### Lỗi: "Gradle sync failed"

**Giải pháp:**
1. Trong Android Studio: **File > Sync Project with Gradle Files**
2. Nếu vẫn lỗi, thử:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

### Lỗi: "Unsupported class file major version"

**Giải pháp:**
- Đảm bảo đang dùng Java 11-21 (không phải Java 25)
- Kiểm tra Java version:
  ```bash
  java -version
  ```
- Nếu cần, cài đặt Java 21:
  ```bash
  # Arch Linux
  sudo pacman -S jdk-openjdk
  ```

### Lỗi: "SDK location not found"

**Giải pháp:**
- Kiểm tra file `android/local.properties`:
  ```
  sdk.dir=/home/kennysk/Android/Sdk
  flutter.sdk=/usr/lib/flutter
  ```

### Lỗi liên quan đến Google Services

Nếu bạn đang dùng Firebase và gặp lỗi về Google Services:

1. Đảm bảo file `android/app/google-services.json` tồn tại
2. Nếu không có, tải từ Firebase Console:
   - Vào Firebase Console > Project Settings
   - Tải `google-services.json` và đặt vào `android/app/`

## Kiểm tra cấu hình

Sau khi sửa, kiểm tra:

```bash
# 1. Kiểm tra Gradle version
cd android && ./gradlew --version

# 2. Kiểm tra Java version
java -version

# 3. Kiểm tra Flutter
flutter doctor -v

# 4. Thử build
flutter build apk --debug
```

## Thông tin phiên bản

- **Gradle:** 8.11.1 (yêu cầu tối thiểu cho AGP 8.9.1)
- **Android Gradle Plugin:** 8.9.1
- **Kotlin:** 2.1.0
- **Java:** 21.0.8 (hoặc 25.0.1)
- **Flutter:** 3.35.7

## Lưu ý

- Gradle 8.11.1 hỗ trợ Java 8-21
- Android Gradle Plugin 8.9.1 yêu cầu Gradle 8.11.1 tối thiểu
- Nếu bạn đang dùng Java 25, có thể cần downgrade về Java 21 hoặc chờ Gradle version mới hơn hỗ trợ Java 25

