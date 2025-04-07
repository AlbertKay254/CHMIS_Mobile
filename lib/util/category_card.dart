import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
 
  final iconImagePath;
  final String categoryName;

  CategoryCard({
    required this.iconImagePath,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return  
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(12),
         decoration: BoxDecoration(
             color: const Color.fromARGB(255, 113, 216, 218),
             borderRadius: BorderRadius.circular(12)
         ),
        child: Row(
          children: [
            Image.asset(
              iconImagePath,
              height:50,
              ),
            const SizedBox(width: 8),
            Text(categoryName),
          ],
        ),
      ),
    );
}
}