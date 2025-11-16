#!/bin/bash
# Script kiểm tra cấu hình Waydroid cho Android Studio

echo "🔍 Kiểm tra cấu hình Waydroid..."
echo ""

# 1. Kiểm tra Waydroid status
echo "1️⃣ Kiểm tra Waydroid status:"
if command -v waydroid &> /dev/null; then
    waydroid status 2>/dev/null || echo "   ⚠️  Không thể kiểm tra waydroid status"
else
    echo "   ⚠️  Waydroid command không tìm thấy"
fi
echo ""

# 2. Kiểm tra ADB devices
echo "2️⃣ Kiểm tra ADB devices:"
if command -v adb &> /dev/null; then
    ADB_DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)
    if [ "$ADB_DEVICES" -gt 0 ]; then
        echo "   ✅ Tìm thấy $ADB_DEVICES device(s):"
        adb devices | grep "device" | grep -v "List"
    else
        echo "   ❌ Không tìm thấy device nào"
        echo "   💡 Thử chạy: adb connect 192.168.240.112:5555"
    fi
else
    echo "   ❌ ADB không được cài đặt"
fi
echo ""

# 3. Kiểm tra Flutter devices
echo "3️⃣ Kiểm tra Flutter devices:"
if command -v flutter &> /dev/null; then
    FLUTTER_WAYDROID=$(flutter devices 2>/dev/null | grep -i waydroid)
    if [ -n "$FLUTTER_WAYDROID" ]; then
        echo "   ✅ Flutter nhận diện Waydroid:"
        echo "   $FLUTTER_WAYDROID"
    else
        echo "   ❌ Flutter không nhận diện Waydroid"
    fi
else
    echo "   ❌ Flutter không được cài đặt"
fi
echo ""

# 4. Kiểm tra device ID
echo "4️⃣ Device ID hiện tại:"
DEVICE_ID=$(flutter devices 2>/dev/null | grep -i waydroid | awk '{print $5}')
if [ -n "$DEVICE_ID" ]; then
    echo "   ✅ Device ID: $DEVICE_ID"
    echo "   📝 Cập nhật trong Android Studio nếu cần"
else
    echo "   ⚠️  Không tìm thấy device ID"
fi
echo ""

# 5. Tóm tắt
echo "📋 Tóm tắt:"
if [ -n "$DEVICE_ID" ]; then
    echo "   ✅ Waydroid đã sẵn sàng!"
    echo "   💡 Trong Android Studio:"
    echo "      1. Chọn Run Configuration: 'main.dart (Waydroid)'"
    echo "      2. Chọn Device: '$DEVICE_ID'"
    echo "      3. Nhấn Run (▶️)"
else
    echo "   ❌ Cần cấu hình thêm"
    echo "   💡 Xem hướng dẫn trong ANDROID_STUDIO_SETUP.md"
fi

