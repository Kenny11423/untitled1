# Hướng dẫn cấu hình Android Studio để chạy trên Waydroid

## Vấn đề
Android Studio không hiển thị lựa chọn device Android hoặc không thể ấn nút Run.

## Giải pháp

### Bước 1: Kiểm tra Flutter Plugin

1. Mở Android Studio
2. Vào **File > Settings** (hoặc **Android Studio > Preferences** trên macOS)
3. Vào **Plugins**
4. Tìm và đảm bảo **Flutter** và **Dart** plugins đã được cài đặt và kích hoạt
5. Nếu chưa có, cài đặt từ Marketplace
6. Restart Android Studio sau khi cài đặt

### Bước 2: Kiểm tra Flutter SDK Path

1. Vào **File > Settings > Languages & Frameworks > Flutter**
2. Đảm bảo **Flutter SDK path** trỏ đúng đến Flutter SDK của bạn
   - Thường là: `/usr/lib/flutter` hoặc `/opt/flutter`
3. Nhấn **Apply** và **OK**

### Bước 3: Kiểm tra Android SDK

1. Vào **File > Settings > Appearance & Behavior > System Settings > Android SDK**
2. Đảm bảo đã cài đặt:
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
3. Nhấn **Apply** để cài đặt nếu thiếu

### Bước 4: Kết nối Waydroid với ADB

1. Mở Terminal và chạy:
   ```bash
   adb devices
   ```
2. Nếu không thấy Waydroid, kết nối:
   ```bash
   adb connect 192.168.240.112:5555
   ```
3. Xác nhận device đã kết nối:
   ```bash
   adb devices
   ```
   Kết quả nên hiển thị: `192.168.240.112:5555    device`

### Bước 5: Cấu hình Run Configuration trong Android Studio

#### Cách 1: Sử dụng Run Configuration có sẵn (Đã được tạo tự động)

1. Mở Android Studio
2. Ở góc trên bên phải, tìm dropdown **Run Configuration** (bên cạnh nút Run)
3. Chọn **"main.dart (Waydroid)"**
4. Nhấn nút **Run** (▶️) hoặc **Debug** (🐛)

#### Cách 2: Tạo Run Configuration mới thủ công

1. Vào **Run > Edit Configurations...**
2. Nhấn dấu **+** ở góc trên bên trái
3. Chọn **Flutter**
4. Đặt tên: `main.dart (Waydroid)`
5. Trong **Target device**, chọn **192.168.240.112:5555** từ dropdown
   - Nếu không thấy trong dropdown, nhập trực tiếp: `192.168.240.112:5555`
6. Nhấn **Apply** và **OK**

### Bước 6: Chọn Device trong Android Studio

1. Ở góc trên bên phải, tìm dropdown **Device** (bên cạnh Run Configuration)
2. Nếu không thấy Waydroid, nhấn vào dropdown và chọn **"192.168.240.112:5555"**
3. Nếu vẫn không thấy:
   - Vào **Tools > Device Manager**
   - Đảm bảo Waydroid được liệt kê
   - Nếu không, nhấn **Refresh** hoặc **Rescan Devices**

### Bước 7: Sync Project

1. Vào **File > Sync Project with Gradle Files**
2. Đợi quá trình sync hoàn tất

### Bước 8: Chạy ứng dụng

1. Chọn Run Configuration: **"main.dart (Waydroid)"**
2. Chọn Device: **"192.168.240.112:5555"** hoặc **"WayDroid x86 64 Device"**
3. Nhấn **Run** (▶️) hoặc **Debug** (🐛)

## Troubleshooting

### Vấn đề: Không thấy nút Run

**Giải pháp:**
1. Đảm bảo file `lib/main.dart` đang mở hoặc được chọn trong Project view
2. Vào **View > Tool Windows > Run** để mở cửa sổ Run
3. Restart Android Studio

### Vấn đề: Device không hiển thị trong dropdown

**Giải pháp:**
1. Kiểm tra ADB connection:
   ```bash
   adb devices
   ```
2. Nếu device không có, kết nối lại:
   ```bash
   adb kill-server
   adb start-server
   adb connect 192.168.240.112:5555
   ```
3. Trong Android Studio: **Tools > Device Manager > Refresh**

### Vấn đề: "No devices found"

**Giải pháp:**
1. Đảm bảo Waydroid đang chạy:
   ```bash
   waydroid status
   ```
2. Kiểm tra ADB:
   ```bash
   adb devices
   ```
3. Restart ADB:
   ```bash
   adb kill-server
   adb start-server
   ```

### Vấn đề: Flutter không nhận diện device

**Giải pháp:**
1. Trong Terminal, chạy:
   ```bash
   flutter devices
   ```
2. Nếu không thấy Waydroid, kiểm tra:
   - Flutter SDK path trong Android Studio
   - ADB connection
   - Waydroid đang chạy

### Vấn đề: Build failed

**Giải pháp:**
1. Clean project:
   ```bash
   flutter clean
   flutter pub get
   ```
2. Trong Android Studio: **Build > Clean Project**
3. Sau đó: **Build > Rebuild Project**

## Lưu ý quan trọng

- Device ID của Waydroid có thể thay đổi. Nếu ID khác, cập nhật trong:
  - `.idea/runConfigurations/main_dart_waydroid.xml`
  - Run Configuration trong Android Studio
- Để tìm device ID hiện tại:
  ```bash
  flutter devices | grep -i waydroid
  ```
- Nếu vẫn gặp vấn đề, thử chạy từ Terminal trước:
  ```bash
  flutter run -d 192.168.240.112:5555
  ```
  Nếu chạy được từ Terminal nhưng không chạy được từ Android Studio, vấn đề là ở cấu hình Android Studio.

## Kiểm tra nhanh

Chạy các lệnh sau để kiểm tra:

```bash
# 1. Kiểm tra Waydroid đang chạy
waydroid status

# 2. Kiểm tra ADB connection
adb devices

# 3. Kiểm tra Flutter devices
flutter devices

# 4. Kiểm tra Flutter doctor
flutter doctor -v
```

Tất cả đều phải hiển thị Waydroid/Android device để Android Studio có thể nhận diện.

