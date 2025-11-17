# Hướng dẫn tạo báo cáo Word từ repo

## Cách 1: Sử dụng Python script (Khuyến nghị)

### Bước 1: Cài đặt thư viện
```bash
pip install python-docx
```

### Bước 2: Chạy script
```bash
python3 convert_to_word.py
```

### Bước 3: Mở file
File `BAO_CAO_COOKING_GUIDE.docx` sẽ được tạo trong thư mục project.

## Cách 2: Sử dụng file Markdown

File `BAO_CAO.md` đã được tạo với đầy đủ nội dung. Bạn có thể:

1. **Mở bằng VS Code/Cursor** và sử dụng extension Markdown Preview
2. **Convert sang Word** bằng các công cụ online:
   - https://www.markdowntoword.com/
   - https://cloudconvert.com/md-to-docx
3. **Copy nội dung** vào Word và format lại

## Cách 3: Sử dụng Pandoc (nếu có)

```bash
# Cài đặt Pandoc
sudo pacman -S pandoc  # Arch Linux
# hoặc
sudo apt install pandoc  # Ubuntu/Debian

# Convert sang Word
pandoc BAO_CAO.md -o BAO_CAO.docx
```

## Nội dung báo cáo

Báo cáo bao gồm:
- ✅ Tổng quan dự án
- ✅ Kiến trúc hệ thống
- ✅ **Sơ đồ Use Case** (text-based và mermaid)
- ✅ Phân tích chức năng
- ✅ Công nghệ sử dụng
- ✅ Cấu trúc dự án
- ✅ Giao diện người dùng
- ✅ Kết luận

## Sơ đồ Use Case

Báo cáo có 2 loại sơ đồ:
1. **Text-based diagram**: Có thể copy vào Word
2. **Mermaid diagram**: Cần render (VS Code extension hoặc online)

## Lưu ý

- File Markdown (`BAO_CAO.md`) đã có đầy đủ nội dung
- Script Python sẽ tạo file Word với format đẹp
- Có thể chỉnh sửa script để thêm/sửa nội dung

