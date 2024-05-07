import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final IconData iconData;
  final Color iconColor;
  final Color dividerColor;

  const MenuItem({
    Key? key,
    required this.name,
    required this.onTap,
    required this.iconData,
    this.iconColor = Colors.black, // Default icon color
    this.dividerColor = Colors.amber, // Default divider color
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
                width: 60,
                height: 60,
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 40,
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
