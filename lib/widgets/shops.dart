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
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StationsItems extends StatelessWidget {
  final String name;
  final String number;
  final int index;
  final VoidCallback onTap;

  final Color dividerColor;

  const StationsItems({
    Key? key,
    required this.name,
    required this.onTap,
    // Default icon color
    this.dividerColor = Colors.amber,
    required this.number, // Default divider color
    required this.index, // Default divider color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              backgroundColor: dividerColor,
              radius: 15,
            ),
            Text(
              index.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        title: Text(
          "$name",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "(${index})",
              style: TextStyle(
                  color: dividerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
