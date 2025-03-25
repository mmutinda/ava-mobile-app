import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class CustomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: SizedBox(
          child: LoadingAnimationWidget.flickr(
            leftDotColor: mycolor,
            rightDotColor: Colors.red,
            size: 50,
          ),
        ),
      ),
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
