import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔥 Lấy danh sách công thức nấu ăn từ Firestore
  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _db.collection('recipes').get();
    return snapshot.docs
        .map((doc) => Recipe.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// ➕ Thêm công thức mới
  Future<String?> addRecipe(Recipe recipe) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final recipeData = recipe.toMap();
      recipeData['userId'] = user.uid;
      recipeData['userName'] = user.email?.split('@')[0] ?? 'Người dùng';

      final docRef = await _db.collection('recipes').add(recipeData);
      return docRef.id;
    } catch (e) {
      print('Lỗi khi thêm công thức: $e');
      return null;
    }
  }

  /// ✏️ Cập nhật công thức
  Future<bool> updateRecipe(Recipe recipe) async {
    try {
      if (recipe.id == null) return false;

      final recipeData = recipe.toMap();
      await _db.collection('recipes').doc(recipe.id).update(recipeData);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật công thức: $e');
      return false;
    }
  }

  /// 🗑️ Xóa công thức
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      await _db.collection('recipes').doc(recipeId).delete();
      return true;
    } catch (e) {
      print('Lỗi khi xóa công thức: $e');
      return false;
    }
  }

  /// ✅ Kiểm tra quyền xóa công thức
  Future<bool> canDeleteRecipe(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Kiểm tra nếu là admin
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData?['role'] == 'admin') return true;
      }

      // Kiểm tra nếu là chủ sở hữu công thức
      final recipeDoc = await _db.collection('recipes').doc(recipeId).get();
      if (recipeDoc.exists) {
        final recipeData = recipeDoc.data();
        return recipeData?['userId'] == user.uid;
      }

      return false;
    } catch (e) {
      print('Lỗi khi kiểm tra quyền: $e');
      return false;
    }
  }

  /// 👤 Lấy thông tin người dùng hiện tại
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return AppUser.fromMap(userDoc.data()!, userDoc.id);
      }

      // Tạo user mới nếu chưa có trong Firestore
      final newUser = AppUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(newUser.toMap());
      return newUser;
    } catch (e) {
      print('Lỗi khi lấy thông tin user: $e');
      return null;
    }
  }

  /// 👥 Lấy danh sách tất cả người dùng (chỉ admin)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách users: $e');
      return [];
    }
  }

  /// 🔄 Cập nhật role của user (chỉ admin)
  Future<bool> updateUserRole(String userId, UserRole role) async {
    try {
      await _db.collection('users').doc(userId).update({
        'role': role == UserRole.admin ? 'admin' : 'user',
      });
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật role: $e');
      return false;
    }
  }

  /// 🚫 Vô hiệu hóa/kích hoạt tài khoản (chỉ admin)
  Future<bool> toggleUserActive(String userId, bool isActive) async {
    try {
      await _db.collection('users').doc(userId).update({
        'isActive': isActive,
      });
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái user: $e');
      return false;
    }
  }

  /// 🗑️ Xóa tài khoản (chỉ admin)
  Future<bool> deleteUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      print('Lỗi khi xóa user: $e');
      return false;
    }
  }

  /// 🧑‍🍳 Đăng ký tài khoản người dùng mới
  Future<bool> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo user document trong Firestore
      final newUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(newUser.id).set(newUser.toMap());

      return true;
    } catch (e) {
      print('Lỗi khi đăng ký: $e');
      return false;
    }
  }

  /// 🔐 Đăng nhập người dùng
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      return false;
    }
  }

  /// 🚪 Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
