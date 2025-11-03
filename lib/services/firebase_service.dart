import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔥 Lấy danh sách công thức nấu ăn từ Firestore
  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _db.collection('recipes').get();
    return snapshot.docs.map((doc) => Recipe.fromMap(doc.data())).toList();
  }

  /// 🧑‍🍳 Đăng ký tài khoản người dùng mới
  Future<bool> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
