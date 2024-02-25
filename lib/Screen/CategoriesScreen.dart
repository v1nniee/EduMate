import 'package:flutter/material.dart';
import 'package:edumateapp/Widgets/CategoryGrid.dart';
import 'package:edumateapp/Models/Category.dart';

//to create grid category - home page
//call  CategoriesScreen(categories: ,backgroundColor: )

class CategoriesScreen extends StatelessWidget {
  final List<Category> categories;
  final Color backgroundColor;
  final double fontSize;
  final double iconSize;
  final double imageSize;

  const CategoriesScreen({
    super.key,
    required this.categories,
    required this.backgroundColor,
   this.fontSize = 16.0, 
    this.iconSize = 35.0, 
    this.imageSize = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryGridItem(
            category: category,
            onSelectCategory: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => category.nextPage),
              );
            },
            fontSize: fontSize,
            iconSize: iconSize,
            imageSize: imageSize,
          );
        },
      ),
    );
  }
}
