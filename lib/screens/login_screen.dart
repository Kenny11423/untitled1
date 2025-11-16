import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiểm tra email và password không rỗng
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng nhập đầy đủ email và mật khẩu'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      // Kiểm tra Firebase đã được khởi tạo chưa
      try {
        // Thử truy cập Firebase Auth để kiểm tra
        _auth.currentUser;
      } catch (e) {
        debugPrint('⚠️  Firebase may not be initialized: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Firebase chưa được khởi tạo. Vui lòng khởi động lại ứng dụng.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      if (isLogin) {
        debugPrint('🔐 Attempting to sign in with email: $email');
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ Sign in successful');
      } else {
        debugPrint('📝 Attempting to sign up with email: $email');
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ Sign up successful');
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Log error chi tiết để debug
      debugPrint('❌ Firebase Auth Error Code: ${e.code}');
      debugPrint('❌ Firebase Auth Error Message: ${e.message}');
      debugPrint('❌ Firebase Auth Error Details: ${e.toString()}');
      
      String errorMessage = _getErrorMessage(e.code, isLogin);
      
      // Kiểm tra nếu là lỗi API key trong message
      if (e.message != null && e.message!.toLowerCase().contains('api key')) {
        errorMessage = 'API key không hợp lệ.\n\nVui lòng kiểm tra:\n1. Firebase Console > Project Settings\n2. Copy API key mới\n3. Cập nhật firebase_options.dart\n4. Thêm google-services.json vào android/app/';
      }
      // Nếu vẫn là message mặc định, thêm thông tin chi tiết
      else if (errorMessage.contains('Đã xảy ra lỗi:')) {
        // Thêm message từ Firebase nếu có
        if (e.message != null && e.message!.isNotEmpty) {
          errorMessage = '${errorMessage}\n\nChi tiết: ${e.message}';
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      // Log lỗi không mong đợi chi tiết
      debugPrint('❌ Unexpected error type: ${e.runtimeType}');
      debugPrint('❌ Unexpected error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      String errorMessage = 'Đã xảy ra lỗi không mong đợi.';
      
      // Kiểm tra các loại lỗi phổ biến
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('network') || 
          errorString.contains('internet') ||
          errorString.contains('connection') ||
          errorString.contains('socket')) {
        errorMessage = 'Không có kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại.';
      } else if (errorString.contains('timeout')) {
        errorMessage = 'Hết thời gian chờ. Vui lòng thử lại.';
      } else if (errorString.contains('firebase') && errorString.contains('not initialized')) {
        errorMessage = 'Firebase chưa được khởi tạo. Vui lòng khởi động lại ứng dụng.';
      } else if (errorString.contains('permission') || errorString.contains('denied')) {
        errorMessage = 'Không có quyền thực hiện thao tác này.';
      } else if (errorString.contains('format') || errorString.contains('invalid')) {
        errorMessage = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin đã nhập.';
      } else {
        // Hiển thị thông tin lỗi chi tiết
        errorMessage = 'Đã xảy ra lỗi: ${e.toString().split(':').first}.\nVui lòng thử lại hoặc liên hệ hỗ trợ.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Lấy thông báo lỗi dựa trên error code
  String _getErrorMessage(String errorCode, bool isLoginMode) {
    switch (errorCode) {
      // Lỗi đăng nhập
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này. Vui lòng kiểm tra lại email.';
      case 'wrong-password':
        return 'Mật khẩu không đúng. Vui lòng thử lại.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau vài phút.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này không được phép.';
      
      // Lỗi đăng ký
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu có ít nhất 6 ký tự.';
      case 'invalid-email':
        return 'Email không hợp lệ. Vui lòng nhập email đúng định dạng.';
      
      // Lỗi chung
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại.';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này.';
      case 'invalid-verification-code':
        return 'Mã xác thực không hợp lệ.';
      case 'invalid-verification-id':
        return 'ID xác thực không hợp lệ.';
      case 'session-expired':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 'missing-email':
        return 'Vui lòng nhập email.';
      case 'missing-password':
        return 'Vui lòng nhập mật khẩu.';
      case 'invalid-action-code':
        return 'Mã hành động không hợp lệ.';
      case 'expired-action-code':
        return 'Mã hành động đã hết hạn.';
      case 'credential-already-in-use':
        return 'Thông tin đăng nhập này đã được sử dụng bởi tài khoản khác.';
      case 'account-exists-with-different-credential':
        return 'Đã tồn tại tài khoản với email này nhưng sử dụng phương thức đăng nhập khác.';
      
      // Lỗi Firebase
      case 'app-not-authorized':
        return 'Ứng dụng chưa được ủy quyền. Vui lòng kiểm tra cấu hình Firebase.';
      case 'internal-error':
        return 'Lỗi hệ thống. Vui lòng thử lại sau.';
      case 'invalid-api-key':
        return 'API key không hợp lệ. Vui lòng kiểm tra cấu hình Firebase.\n\nCách sửa:\n1. Vào Firebase Console\n2. Project Settings > General\n3. Copy API key mới\n4. Cập nhật trong firebase_options.dart';
      case 'project-not-found':
        return 'Không tìm thấy dự án Firebase. Vui lòng kiểm tra cấu hình.';
      case 'unknown':
        // Xử lý lỗi unknown - có thể là API key không hợp lệ
        return 'Lỗi cấu hình Firebase: API key không hợp lệ.\n\nVui lòng:\n1. Kiểm tra Firebase Console\n2. Đảm bảo API key đúng\n3. Thêm file google-services.json vào android/app/\n4. Chạy lại: flutterfire configure';
      
      default:
        // Nếu không tìm thấy error code, hiển thị error code và hướng dẫn
        final formattedCode = errorCode.replaceAll('-', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
        
        return 'Đã xảy ra lỗi: $formattedCode.\n\nVui lòng thử lại hoặc kiểm tra:\n- Kết nối internet\n- Cấu hình Firebase\n- Email và mật khẩu đã nhập đúng';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.surfaceDark,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      isLogin ? 'Chào mừng trở lại!' : 'Tạo tài khoản mới',
                      style: AppStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLogin 
                          ? 'Đăng nhập để khám phá công thức nấu ăn'
                          : 'Đăng ký để bắt đầu hành trình nấu ăn',
                      style: AppStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: AppStyles.inputDecoration('Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: AppStyles.inputDecoration('Mật khẩu').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (!isLogin && value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                isLogin ? 'Đăng nhập' : 'Đăng ký',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Toggle login/signup
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() => isLogin = !isLogin);
                            },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: isLogin
                                  ? 'Chưa có tài khoản? '
                                  : 'Đã có tài khoản? ',
                            ),
                            TextSpan(
                              text: isLogin ? 'Đăng ký' : 'Đăng nhập',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
