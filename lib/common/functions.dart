import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
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
