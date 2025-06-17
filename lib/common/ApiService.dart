import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ApiService {
  static Future<void> postData({
    required BuildContext context,
    required String url,
    required Map<String, dynamic> data,
    required String token,
    required VoidCallback onSuccess,
    required void Function(String) onError,
  }) async {
    final progressDialog = ProgressDialog(context);
    progressDialog.style(
      message: 'Submitting ..',
      child: CustomLoader(),
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
        width: 20,
        height: 20,
        child: Center(child: CircularProgressIndicator()),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );
    progressDialog.show();

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);
      print(responseBody);

      if (response.statusCode == 200 || responseBody['success'] == true) {
        onSuccess();
      } else {
        String errorMessage = responseBody['msg'] ??
            responseBody['message'] ??
            "An error occurred";

        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          final errorDetails =
              errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
          errorMessage += '\n$errorDetails';
        }

        onError(errorMessage);
      }
    } on TimeoutException {
      onError('Request timed out. Please try again.');
    } on SocketException {
      onError('No Internet connection.');
    } catch (e) {
      print("Unexpected Error: $e");
      onError('Failed: ${e.toString()}');
    } finally {
      progressDialog.hide();
    }
  }
}
class ApiHelper {
  static Future<void> fetchMultipleData({
    required BuildContext context,
    required List<Future<dynamic>> requests,
    required void Function(List<dynamic> results) onSuccess,
    required void Function(String error) onError,
    required void Function(bool)
        setLoading, // pass (bool isLoading) => setState(() => isLoading = isLoading)
  }) async {
    setLoading(true);
    try {
      final results = await Future.wait(requests);

      if (results.isEmpty ||
          results.any((r) => r == null || r["data"] == null)) {
        throw Exception("Failed to fetch data: Missing required information.");
      }

      onSuccess(results);
    } catch (e) {
      onError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
