import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../constants/app_colors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<AppUser>> _usersFuture;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _usersFuture = _firebaseService.getAllUsers();
    });
    final user = await _firebaseService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _updateUserRole(AppUser user, UserRole newRole) async {
    final success = await _firebaseService.updateUserRole(user.id, newRole);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã ${newRole == UserRole.admin ? "cấp" : "hủy"} quyền quản lý cho ${user.email}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể cập nhật quyền'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleUserActive(AppUser user) async {
    final success = await _firebaseService.toggleUserActive(user.id, !user.isActive);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isActive
                ? 'Đã vô hiệu hóa tài khoản ${user.email}'
                : 'Đã kích hoạt tài khoản ${user.email}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    if (user.id == _currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không thể xóa tài khoản của chính mình'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: Text('Bạn có chắc muốn xóa tài khoản ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _firebaseService.deleteUser(user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa tài khoản ${user.email}'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài khoản'),
      ),
      body: FutureBuilder<List<AppUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text('Chưa có người dùng nào'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isCurrentUser = user.id == _currentUser?.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isAdmin
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      child: Icon(
                        user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      user.email,
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.isAdmin ? 'Quản lý' : 'Người dùng',
                          style: TextStyle(
                            color: user.isAdmin ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (user.displayName != null)
                          Text(user.displayName!),
                        Text(
                          user.isActive ? 'Đang hoạt động' : 'Đã vô hiệu hóa',
                          style: TextStyle(
                            color: user.isActive ? AppColors.success : AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        if (!isCurrentUser)
                          PopupMenuItem(
                            value: 'role',
                            child: Row(
                              children: [
                                Icon(
                                  user.isAdmin ? Icons.person : Icons.admin_panel_settings,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(user.isAdmin ? 'Hủy quyền quản lý' : 'Cấp quyền quản lý'),
                              ],
                            ),
                          ),
                        if (!isCurrentUser)
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  user.isActive ? Icons.block : Icons.check_circle,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                              ],
                            ),
                          ),
                        if (!isCurrentUser)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Xóa tài khoản', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'role':
                            _updateUserRole(
                              user,
                              user.isAdmin ? UserRole.user : UserRole.admin,
                            );
                            break;
                          case 'toggle':
                            _toggleUserActive(user);
                            break;
                          case 'delete':
                            _deleteUser(user);
                            break;
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

