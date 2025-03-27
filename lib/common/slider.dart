import 'package:flutter/material.dart';

class BeautySlider extends StatefulWidget {
  final List<Map<String, String>> items;

  BeautySlider({required this.items});

  @override
  _BeautySliderState createState() => _BeautySliderState();
}

class _BeautySliderState extends State<BeautySlider> {
  late PageController _pageController;
  late int _currentPage;
  late final List<Map<String, String>> items;

  @override
  void initState() {
    super.initState();
    items = widget.items;
    _pageController = PageController();
    _currentPage = 0;

    // Auto slide functionality
    Future.delayed(Duration(seconds: 3), _autoSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Auto slide function
  void _autoSlide() {
    if (_currentPage < items.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }

    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(Duration(seconds: 3), _autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
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
