import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget gap() => const SizedBox(height: 16);
Widget width() => const SizedBox(width: 16);

class FacebookLikeShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  FacebookLikeShimmer({
    this.width = 200.0,
    this.height = 20.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(12),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ErrorMessageWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry; // Callback for retry action, if needed

  ErrorMessageWidget({required this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 80.0,
          ),
          SizedBox(height: 20.0),
          Text(
            'Oops!',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) // Show retry button if callback provided
            SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class FacebookLikeShimmer2 extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  FacebookLikeShimmer2({
    this.width = 200.0,
    this.height = 20.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // You can adjust the cross axis count as per your requirement
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(12),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}
