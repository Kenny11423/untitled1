import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';
import '../services/firebase_service.dart';
import '../widgets/recipe_card.dart';
import '../constants/app_colors.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Recipe>> _recipesFuture;
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _recipesFuture = _loadRecipes();
  }

  Future<List<Recipe>> _loadRecipes() async {
    final recipes = await _firebaseService.getRecipes();
    _allRecipes = recipes;
    _filteredRecipes = recipes;
    return recipes;
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        final matchesSearch = recipe.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            recipe.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        final matchesCategory =
            _selectedCategory == 'Tất cả' || recipe.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> get _categories {
    final categories = _allRecipes.map((r) => r.category).toSet().toList();
    categories.sort();
    return ['Tất cả', ...categories];
  }

  Future<void> _refreshRecipes() async {
    setState(() {
      _recipesFuture = _loadRecipes();
    });
    await _recipesFuture;
    _filterRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email?.split('@')[0] ?? 'Người dùng',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        color: AppColors.textSecondary,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Đăng xuất'),
                              content: const Text('Bạn có chắc muốn đăng xuất?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Đăng xuất'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && mounted) {
                            await FirebaseAuth.instance.signOut();
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm công thức...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filterRecipes();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterRecipes();
                      });
                    },
                  ),
                ],
              ),
            ),
            // Category Filter
            FutureBuilder<List<Recipe>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Lỗi: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshRecipes,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: Column(
                    children: [
                      // Category Chips
                      if (_categories.length > 1)
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = category == _selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = category;
                                      _filterRecipes();
                                    });
                                  },
                                  selectedColor: AppColors.primary,
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      // Recipes List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshRecipes,
                          child: _filteredRecipes.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: AppColors.textLight,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isNotEmpty ||
                                                _selectedCategory != 'Tất cả'
                                            ? 'Không tìm thấy công thức nào'
                                            : 'Chưa có công thức nào',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: _filteredRecipes.length,
                                  itemBuilder: (context, index) =>
                                      RecipeCard(recipe: _filteredRecipes[index]),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
