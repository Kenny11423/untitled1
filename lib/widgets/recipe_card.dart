import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';
import '../constants/app_colors.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/add_edit_recipe_screen.dart';
import '../services/firebase_service.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onDeleted;

  const RecipeCard({super.key, required this.recipe, this.onDeleted});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  final _firebaseService = FirebaseService();
  bool _canDelete = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDeletePermission();
  }

  Future<void> _checkDeletePermission() async {
    if (widget.recipe.id == null) {
      setState(() {
        _canDelete = false;
        _isChecking = false;
      });
      return;
    }

    final canDelete = await _firebaseService.canDeleteRecipe(widget.recipe.id!);
    setState(() {
      _canDelete = canDelete;
      _isChecking = false;
    });
  }

  Future<void> _deleteRecipe() async {
    if (widget.recipe.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa công thức'),
        content: const Text('Bạn có chắc muốn xóa công thức này?'),
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
      final success = await _firebaseService.deleteRecipe(widget.recipe.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa công thức thành công'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onDeleted?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xóa công thức'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _editRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRecipeScreen(recipe: widget.recipe),
      ),
    );
    if (result == true && mounted) {
      widget.onDeleted?.call(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && widget.recipe.userId == currentUser.uid;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: widget.recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.textLight.withOpacity(0.2),
                    child: widget.recipe.imageUrl.isNotEmpty
                        ? Image.network(
                      widget.recipe.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 180,
                                color: AppColors.textLight.withOpacity(0.1),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),
                  ),
                  // Category badge và action buttons
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.recipe.category.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.recipe.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        // Action buttons
                        if (!_isChecking && _canDelete)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOwner)
                                Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    color: Colors.white,
                                    onPressed: () {
                                      _editRecipe();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, size: 18),
                                  color: Colors.white,
                                  onPressed: () {
                                    _deleteRecipe();
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Info row
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.restaurant,
                        '${widget.recipe.ingredients.length} nguyên liệu',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.list_alt,
                        '${widget.recipe.steps.length} bước',
                      ),
                      if (widget.recipe.userName != null) ...[
                        const Spacer(),
                        Text(
                          'Bởi: ${widget.recipe.userName}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight.withOpacity(0.3),
            AppColors.accent.withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 64,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}