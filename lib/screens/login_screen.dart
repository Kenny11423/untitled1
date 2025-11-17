import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'home_screen.dart';
import 'user_management_screen.dart';

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

  /// Default role when registering
  String _selectedRole = "user";

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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
      /// Kiểm tra Firebase init
      try {
        _auth.currentUser;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firebase chưa được khởi tạo. Vui lòng khởi động lại ứng dụng.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // =============== ĐĂNG NHẬP ===============
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);

        // Lấy ROLE trong Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .get();

        final String role = userDoc["role"];

        // Điều hướng theo role
        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }

        return;
      }

      // =============== ĐĂNG KÝ ===============
      else {
        UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Lưu role vào Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "email": email,
          "role": _selectedRole,
          "created_at": Timestamp.now(),
        });

        // Điều hướng theo role
        if (_selectedRole == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }

        return;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? "Đã xảy ra lỗi";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
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
                    // Logo
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
                    const SizedBox(height: 10),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: AppStyles.inputDecoration('Email'),
                      validator: (value) =>
                      value == null || !value.contains('@')
                          ? 'Email không hợp lệ'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: AppStyles.inputDecoration('Mật khẩu').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? 'Vui lòng nhập mật khẩu'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // ================== DROPDOWN ROLE ==================
                    if (!isLogin)
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: AppStyles.inputDecoration('Chọn vai trò'),
                        items: const [
                          DropdownMenuItem(
                            value: "user",
                            child: Text("Người dùng"),
                          ),
                          DropdownMenuItem(
                            value: "admin",
                            child: Text("Quản lý (Admin)"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value!);
                        },
                      ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                            : Text(
                          isLogin ? "Đăng nhập" : "Đăng ký",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Toggle login / register
                    TextButton(
                      onPressed: () =>
                          setState(() => isLogin = !isLogin),
                      child: RichText(
                        text: TextSpan(
                          style: AppStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: isLogin
                                  ? 'Chưa có tài khoản? '
                                  : 'Đã có tài khoản? ',
                            ),
                            TextSpan(
                              text:
                              isLogin ? 'Đăng ký' : 'Đăng nhập',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
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
