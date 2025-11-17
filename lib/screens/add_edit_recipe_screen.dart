import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/firebase_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // null nếu là thêm mới

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _descriptionController.text = widget.recipe!.description;
      _imageUrlController.text = widget.recipe!.imageUrl;
      _categoryController.text = widget.recipe!.category;
      
      // Load ingredients
      for (var ingredient in widget.recipe!.ingredients) {
        final controller = TextEditingController(text: ingredient.toString());
        _ingredientControllers.add(controller);
      }
      
      // Load steps
      for (var step in widget.recipe!.steps) {
        final controller = TextEditingController(text: step.toString());
        _stepControllers.add(controller);
      }
    } else {
      // Thêm ít nhất 1 ingredient và 1 step
      _ingredientControllers.add(TextEditingController());
      _stepControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ingredients = _ingredientControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      final steps = _stepControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng thêm ít nhất một nguyên liệu')),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng thêm ít nhất một bước thực hiện')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final user = await _firebaseService.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thông tin người dùng')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final recipe = Recipe(
        id: widget.recipe?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        ingredients: ingredients,
        steps: steps,
        category: _categoryController.text.trim(),
        userId: user.id,
        userName: user.displayName ?? user.email.split('@')[0],
        createdAt: widget.recipe?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (widget.recipe == null) {
        // Thêm mới
        final recipeId = await _firebaseService.addRecipe(recipe);
        success = recipeId != null;
      } else {
        // Cập nhật
        success = await _firebaseService.updateRecipe(recipe);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipe == null
                ? 'Đã thêm công thức thành công!'
                : 'Đã cập nhật công thức thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true để refresh
      } else {
        throw Exception('Không thể lưu công thức');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Thêm công thức mới' : 'Chỉnh sửa công thức'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveRecipe,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: AppStyles.inputDecoration('Tên công thức *'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên công thức';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: AppStyles.inputDecoration('Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Image URL
            TextFormField(
              controller: _imageUrlController,
              decoration: AppStyles.inputDecoration('URL hình ảnh'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: AppStyles.inputDecoration('Danh mục *'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập danh mục';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Ingredients Section
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Nguyên liệu *',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: _addIngredient,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._ingredientControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Nguyên liệu ${index + 1}',
                          suffixIcon: _ingredientControllers.length > 1
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: AppColors.error),
                                  onPressed: () => _removeIngredient(index),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Steps Section
            Row(
              children: [
                const Icon(Icons.list_alt, color: AppColors.accent),
                const SizedBox(width: 8),
                const Text(
                  'Các bước thực hiện *',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.accent),
                  onPressed: _addStep,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._stepControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Bước ${index + 1}',
                          suffixIcon: _stepControllers.length > 1
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: AppColors.error),
                                  onPressed: () => _removeStep(index),
                                )
                              : null,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRecipe,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.recipe == null ? 'Thêm công thức' : 'Cập nhật công thức',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

