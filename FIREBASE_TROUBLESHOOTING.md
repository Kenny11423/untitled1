# Hướng dẫn xử lý lỗi Firebase Authentication

## Đã cải thiện

✅ **Xử lý lỗi đã được cải thiện hoàn toàn:**
- Thêm tất cả các error codes phổ biến của Firebase Auth
- Thông báo lỗi rõ ràng, dễ hiểu bằng tiếng Việt
- Logging chi tiết để debug
- Xử lý lỗi mạng và timeout
- Validation tốt hơn

## Các lỗi thường gặp và cách xử lý

### 1. Lỗi "operation-not-allowed"

**Nguyên nhân:** Email/Password authentication chưa được bật trong Firebase Console.

**Cách sửa:**
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Authentication > Sign-in method**
4. Bật **Email/Password** provider
5. Nhấn **Save**

### 2. Lỗi "network-request-failed"

**Nguyên nhân:** Không có kết nối internet hoặc Firebase không thể kết nối.

**Cách sửa:**
- Kiểm tra kết nối internet
- Kiểm tra firewall/antivirus có chặn không
- Thử lại sau vài phút

### 3. Lỗi "invalid-api-key" hoặc "app-not-authorized"

**Nguyên nhân:** Firebase chưa được cấu hình đúng.

**Cách sửa:**
1. Kiểm tra file `lib/firebase_options.dart` có đúng không
2. Đảm bảo `google-services.json` đã được thêm vào `android/app/` (nếu cần)
3. Chạy lại FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

### 4. Lỗi "user-not-found" (khi đăng nhập)

**Nguyên nhân:** Email chưa được đăng ký.

**Giải pháp:** Đăng ký tài khoản mới trước.

### 5. Lỗi "email-already-in-use" (khi đăng ký)

**Nguyên nhân:** Email đã được sử dụng.

**Giải pháp:** Đăng nhập với email đó hoặc sử dụng email khác.

### 6. Lỗi "weak-password"

**Nguyên nhân:** Mật khẩu quá yếu (ít hơn 6 ký tự).

**Giải pháp:** Sử dụng mật khẩu có ít nhất 6 ký tự.

## Kiểm tra cấu hình Firebase

### 1. Kiểm tra Firebase đã được khởi tạo

Khi chạy app, kiểm tra log:
- ✅ `Firebase initialized successfully` - Firebase đã sẵn sàng
- ❌ `Firebase initialization error` - Có lỗi khi khởi tạo

### 2. Kiểm tra Authentication đã được bật

1. Vào Firebase Console
2. Authentication > Sign-in method
3. Đảm bảo **Email/Password** đã được bật

### 3. Kiểm tra Firebase Options

File `lib/firebase_options.dart` phải có:
- `apiKey`: API key hợp lệ
- `appId`: App ID hợp lệ
- `projectId`: Project ID hợp lệ

## Debug

### Xem log chi tiết

Khi chạy app, xem log trong terminal hoặc Android Studio:
- `🔐 Attempting to sign in` - Đang thử đăng nhập
- `📝 Attempting to sign up` - Đang thử đăng ký
- `Firebase Auth Error: [code] - [message]` - Lỗi cụ thể

### Test với email/mật khẩu mẫu

1. **Đăng ký:**
   - Email: `test@example.com`
   - Mật khẩu: `test123456` (ít nhất 6 ký tự)

2. **Đăng nhập:**
   - Sử dụng email/mật khẩu đã đăng ký

## Thông báo lỗi mới

Bây giờ app sẽ hiển thị thông báo lỗi rõ ràng thay vì chỉ "Đã xảy ra lỗi":

- ✅ "Email này đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác."
- ✅ "Mật khẩu không đúng. Vui lòng thử lại."
- ✅ "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại."
- ✅ "Phương thức đăng nhập này không được phép." (cần bật Email/Password trong Firebase)

## Nếu vẫn gặp lỗi

1. **Kiểm tra log:**
   - Xem log trong terminal/Android Studio
   - Tìm dòng có `Firebase Auth Error` hoặc `Unexpected error`

2. **Kiểm tra Firebase Console:**
   - Xem Authentication > Users có user nào không
   - Xem Authentication > Sign-in method có bật Email/Password không

3. **Thử lại:**
   - Restart app
   - Clean và rebuild:
     ```bash
     flutter clean
     flutter pub get
     flutter run
     ```

4. **Kiểm tra internet:**
   - Đảm bảo có kết nối internet
   - Thử trên mạng khác nếu cần

## Lưu ý

- Tất cả các error codes đã được xử lý
- Thông báo lỗi đã được dịch sang tiếng Việt
- Có logging để debug dễ dàng
- Xử lý cả lỗi mạng và timeout

