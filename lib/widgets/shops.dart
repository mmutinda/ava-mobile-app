import 'package:flutter/material.dart';

class ShopItems extends StatelessWidget {
  final String name;
  final String number;
  final VoidCallback onTap;

  final Color dividerColor;

  const ShopItems({
    Key? key,
    required this.name,
    required this.onTap,
    // Default icon color
    this.dividerColor = Colors.amber,
    required this.number, // Default divider color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: dividerColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(
                color: dividerColor,
              ),
              Text(
                "$name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
