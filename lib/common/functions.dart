import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/UIHelper.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:path/path.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

Future getuserdata() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var userdata = preferences.getString('userdata')!;
  return userdata;
}

Future httppost(
    String url, Map<String, dynamic> data, BuildContext context) async {
  try {
    var vardata = data;

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(vardata),
    );
    var jsonResponse = json.decode(response.body);

    if (response.statusCode == Api.codeOK) {
      return jsonResponse;
    } else {
      return jsonResponse;
    }
    // ignore: empty_catches
  } catch (e) {}
}

Future httppostwithtoken(String url, token, data, BuildContext context) async {
  try {
    var vardata = data;

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(vardata),
    );
    var jsonResponse = json.decode(response.body);

    if (response.statusCode == Api.codeOK) {
      return jsonResponse;
    } else {
      return jsonResponse;
    }
    // ignore: empty_catches
  } catch (e) {}
}

Future httppostimagewithtoken(
    String url, token, data, BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: data,
    );
    var jsonResponse = json.decode(response.body);

    if (response.statusCode == Api.codeOK) {
      return jsonResponse;
    } else {
      return jsonResponse;
    }
    // ignore: empty_catches
  } catch (e) {}
}

Future uploadImagesWithToken(
    String jobcard,
    String stage,
    String description,
    String url,
    List<File> images,
    String token,
    String user,
    String ins) async {
  var request = http.MultipartRequest('POST', Uri.parse(url));

  // Add your headers, including the authorization token
  request.headers.addAll({
    'Accept': 'application/json',
    'Content': 'application/json',
    'Authorization': 'Bearer $token',
  });
  request.fields['job_card_no'] = jobcard;
  request.fields['stage_id'] = stage;
  request.fields['description'] = description;
  request.fields['user_id'] = user;
  request.fields['ins'] = ins;

  await Future.forEach(
    images,
    (file) async => {
      request.files.add(
        http.MultipartFile(
          'images[]',
          (http.ByteStream(file.openRead())).cast(),
          await file.length(),
          filename: file.path.split('/').last,
        ),
      )
    },
  );
  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      return {"status": response.statusCode, "message": 'Upload success'};
    } else {
      return {
        "status": response.statusCode,
        "message": 'Upload failed : ${response.reasonPhrase}'
      };
    }
  } catch (error) {
    return 'Error uploading file: $error';
  }
}

Future uploadImagesWithToken2(
    String vehicleId, String url, List<File> images, String token) async {
  var request = http.MultipartRequest('POST', Uri.parse(url));

  // Add headers
  request.headers.addAll({
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  });

  request.fields['vehicle_id'] = vehicleId;

  // Correct way to add files
  for (File file in images) {
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();

    var multipartFile = http.MultipartFile(
      'images[]',
      stream,
      length,
      filename: file.path.split('/').last,
    );

    request.files.add(multipartFile);
  }

  try {
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    print("---> $responseBody");

    if (response.statusCode == 200) {
      return {"status": response.statusCode, "message": 'Upload success'};
    } else {
      return {
        "status": response.statusCode,
        "message": 'Upload failed : $responseBody'
      };
    }
  } catch (error) {
    return {"status": 500, "message": 'Error uploading file: $error'};
  }
}
// Future uploadImagesWithToken2(
//     String vehicle_id, String url, List<File> images, String token) async {
//   var request = http.MultipartRequest('POST', Uri.parse(url));
//   // Add your headers, including the authorization token
//   request.headers.addAll({
//     'Accept': 'application/json',
//     'Content': 'application/json',
//     'Authorization': 'Bearer $token',
//   });
//   request.fields['vehicle_id'] = vehicle_id;

//   await Future.forEach(
//     images,
//     (file) async => {
//       request.files.add(
//         http.MultipartFile(
//           'images[]',
//           (http.ByteStream(file.openRead())).cast(),
//           await file.length(),
//           filename: file.path.split('/').last,
//         ),
//       )
//     },
//   );
//   try {
//     var response = await request.send();
//     var responseBody = await response.stream.bytesToString();
//     print("--->${responseBody}");
//     if (response.statusCode == 200) {
//       return {"status": response.statusCode, "message": 'Upload success'};
//     } else {
//       return {
//         "status": response.statusCode,
//         "message": 'Upload failed : ${responseBody}'
//       };
//     }
//   } catch (error) {
//     return 'Error uploading file: $error';
//   }
// }

Future httpget(String url, token, BuildContext context) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    var jsonResponse = json.decode(response.body);

    if (response.statusCode == Api.codeOK) {
      return jsonResponse;
    } else {
      return jsonResponse;
    }
    // ignore: empty_catches
  } catch (e) {}
}

SnackBar snackBar(message, Color? color) {
  return SnackBar(
    duration: const Duration(seconds: 2),
    backgroundColor: color,
    content: Text(
      message,
      style: const TextStyle(fontSize: 18),
    ),
  );
}

//post function with token
// Replace with your UIHelper import

Future<void> submitMultipartForm({
  required BuildContext context,
  required String url,
  required final fields, // Explicit type for clarity
  required final files, // key: field name, value: File
  required token,
}) async {
  final uri = Uri.parse(url);
  final request = http.MultipartRequest('POST', uri);

  request.headers.addAll({
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  });

  // ✅ Add dynamic fields as String only
  fields.forEach((key, value) {
    request.fields[key] = value.toString();
  });

  // Add dynamic files
  for (final entry in files.entries) {
    final fieldName = entry.key;
    final file = entry.value;

    if (file != null && file.path.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath(fieldName, file.path));
    }
  }

  // Debug: print fields
  request.fields.forEach((key, value) {
    print('Field: $key = $value');
  });

  final progressDialog = ProgressDialog(context);
  progressDialog.style(
    message: 'Submitting...',
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
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var responseBody = jsonDecode(responseData);

    log(responseBody.toString());

    if (response.statusCode == 200 || responseBody['success'] == true) {
      UIHelper.showSuccessMessage(
        context: context,
        message: "Submitted successfully",
      );
    } else {
      String errorMessage =
          responseBody['msg'] ?? responseBody['message'] ?? "An error occurred";

      if (responseBody['errors'] != null) {
        final errors = responseBody['errors'];
        final errorDetails =
            errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
        errorMessage += '\n$errorDetails';
      }

      UIHelper.showErrorMessage(context: context, message: errorMessage);
    }
  } on SocketException {
    UIHelper.showErrorMessage(
      context: context,
      message: "No Internet connection.",
    );
  } on TimeoutException {
    UIHelper.showErrorMessage(
      context: context,
      message: "Request timed out. Please try again",
    );
  } catch (e) {
    print("Unexpected Error: $e");
    UIHelper.showErrorMessage(
      context: context,
      message: 'Failed: ${e.toString()}',
    );
  } finally {
    progressDialog.hide();
  }
}

//post function with token
// Replace with your UIHelper import

Future<void> submitForm({
  required BuildContext context,
  required String url,
  required final fields, // Explicit type for clarity
  // key: field name, value: File
  required token,
}) async {
  final uri = Uri.parse(url);
  final request = http.MultipartRequest('POST', uri);

  request.headers.addAll({
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  });

  // ✅ Add dynamic fields as String only
  fields.forEach((key, value) {
    request.fields[key] = value.toString();
  });

  // Debug: print fields
  request.fields.forEach((key, value) {
    print('Field: $key = $value');
  });

  final progressDialog = ProgressDialog(context);
  progressDialog.style(
    message: 'Submitting...',
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
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var responseBody = jsonDecode(responseData);

    log(responseBody.toString());

    if (response.statusCode == 200 || responseBody['success'] == true) {
      UIHelper.showSuccessMessage(
        context: context,
        message: "Submitted successfully",
      );
    } else {
      String errorMessage =
          responseBody['msg'] ?? responseBody['message'] ?? "An error occurred";

      if (responseBody['errors'] != null) {
        final errors = responseBody['errors'];
        final errorDetails =
            errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
        errorMessage += '\n$errorDetails';
      }

      UIHelper.showErrorMessage(context: context, message: errorMessage);
    }
  } on SocketException {
    UIHelper.showErrorMessage(
      context: context,
      message: "No Internet connection.",
    );
  } on TimeoutException {
    UIHelper.showErrorMessage(
      context: context,
      message: "Request timed out. Please try again",
    );
  } catch (e) {
    print("Unexpected Error: $e");
    UIHelper.showErrorMessage(
      context: context,
      message: 'Failed: ${e.toString()}',
    );
  } finally {
    progressDialog.hide();
  }
}
/// fetch data from api


class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse({
    required this.success,
    this.data,
    this.message = '',
  });
}

Future<ApiResponse<T>> fetchData<T>({
   required BuildContext context,
  required String url,
  required String token,
  required T Function(dynamic json) parser,
  Duration timeout = const Duration(seconds: 15),
  
}) async {
  try {
    if (token.isEmpty) {
      return ApiResponse(success: false, message: 'Invalid user session.');
    }

    debugPrint('Fetching data from: $url');

    final responseData = await httpget(url, token, context)
        .timeout(timeout);

    debugPrint('Response data: $responseData');

    if (responseData == null) {
      return ApiResponse(success: false, message: 'No response from server.');
    }

    if (responseData is! Map || !responseData.containsKey('success')) {
      return ApiResponse(success: false, message: 'Invalid response format.');
    }

    if (responseData["success"] == true) {
      if (!responseData.containsKey('data')) {
        return ApiResponse(success: true, data: null);
      }
      final dataJson = responseData["data"];
      final dataParsed = parser(dataJson);
      return ApiResponse(success: true, data: dataParsed);
    } else {
      final serverMessage = responseData["message"]?.toString() ?? 'Unknown error';
      if (serverMessage == 'Unauthenticated.') {
        return ApiResponse(success: false, message: 'Session expired. Please login again.');
      } else {
        return ApiResponse(success: false, message: serverMessage);
      }
    }
  } on TimeoutException {
    debugPrint('Request to $url timed out.');
    return ApiResponse(success: false, message: 'Request timed out. Please check your internet connection.');
  } on SocketException {
    debugPrint('Network error while fetching data.');
    return ApiResponse(success: false, message: 'Network error. Please check your internet connection.');
  } on FormatException {
    debugPrint('Invalid response format.');
    return ApiResponse(success: false, message: 'Invalid server response. Please contact support.');
  } catch (e, stackTrace) {
    debugPrint('Unexpected error: $e');
    debugPrintStack(stackTrace: stackTrace);
    return ApiResponse(success: false, message: 'Something went wrong. Please try again later.');
  }
}
