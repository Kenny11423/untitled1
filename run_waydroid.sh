#!/bin/bash
# Script để chạy ứng dụng Flutter trên Waydroid

echo "🚀 Đang chạy ứng dụng trên Waydroid..."

# Kiểm tra Waydroid có được kết nối không
DEVICE_ID=$(flutter devices | grep -i waydroid | awk '{print $5}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Không tìm thấy Waydroid device!"
    echo "📋 Danh sách devices hiện có:"
    flutter devices
    exit 1
fi

echo "✅ Tìm thấy Waydroid: $DEVICE_ID"
echo "🔨 Đang build và chạy ứng dụng..."

# Chạy trên Waydroid với device ID cụ thể
flutter run -d "$DEVICE_ID" "$@"

