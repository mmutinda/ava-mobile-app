import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BeautySlider extends StatelessWidget {
  final List<Map<String, String>> items;

  BeautySlider({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // CachedNetworkImage(
                  //   imageUrl: items[index]['image']!,
                  //   fit: BoxFit.cover,
                  //   placeholder: (context, url) => const Center(
                  //     child: CircularProgressIndicator(),
                  //   ),
                  //   errorWidget: (context, url, error) => const Icon(
                  //     Icons.broken_image,
                  //     size: 50,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                  Image.asset(
                    items[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[index]['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          items[index]['description']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
