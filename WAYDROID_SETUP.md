# Hướng dẫn chạy ứng dụng trên Waydroid

## Cách 1: Sử dụng VS Code/Cursor (Khuyến nghị)

1. Mở VS Code/Cursor
2. Nhấn `F5` hoặc vào menu **Run > Start Debugging**
3. Chọn cấu hình **"Flutter: Run on Waydroid"** từ dropdown
4. Ứng dụng sẽ tự động build và chạy trên Waydroid

## Cách 2: Sử dụng Terminal

### Chạy trực tiếp:
```bash
flutter run -d 192.168.240.112:5555
```

### Hoặc sử dụng script:
```bash
./run_waydroid.sh
```

## Cách 3: Chọn device tự động

Nếu Waydroid là device duy nhất được kết nối:
```bash
flutter run
```

## Kiểm tra devices đã kết nối

Để xem danh sách tất cả devices:
```bash
flutter devices
```

## Troubleshooting

### Waydroid không hiển thị trong danh sách devices

1. Đảm bảo Waydroid đang chạy:
   ```bash
   waydroid status
   ```

2. Kiểm tra ADB connection:
   ```bash
   adb devices
   ```

3. Nếu cần, kết nối lại ADB:
   ```bash
   adb connect 192.168.240.112:5555
   ```

### Lỗi khi build

1. Đảm bảo đã cài đặt Android SDK và chấp nhận licenses:
   ```bash
   flutter doctor --android-licenses
   ```

2. Clean và rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d 192.168.240.112:5555
   ```

## Lưu ý

- Device ID của Waydroid có thể thay đổi. Nếu ID khác, cập nhật trong `.vscode/launch.json`
- Để tìm device ID hiện tại: `flutter devices | grep -i waydroid`

