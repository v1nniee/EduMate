import 'package:edumateapp/Models/Category.dart';
import 'package:flutter/material.dart';

// design each category grid (put icon, image, or text)
//fontSize, iconSize, imageSize value can be changed when you call this class.

class CategoryGridItem extends StatelessWidget {
  const CategoryGridItem({
    super.key,
    required this.category,
    required this.onSelectCategory,
    this.fontSize = 17.0, 
    this.iconSize = 40.0, 
    this.imageSize = 50.0,
  });
  final Category category;
  final void Function() onSelectCategory;
  final double fontSize; 
  final double iconSize; 
  final double imageSize; 

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelectCategory,
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              category.color.withOpacity(0.55),
              category.color.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (category.imagePath != null && category.imagePath!.isNotEmpty)
              Image.asset(
                category.imagePath!,
                width: imageSize,  
                height: imageSize,   
                fit: BoxFit.cover,
              ),
            if (category.icon != null)
              Icon(
                category.icon,
                size: iconSize, 
                color: Theme.of(context).colorScheme.onBackground,
              ),
            SizedBox(height: 8),
            Text(
              category.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: fontSize, 
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
