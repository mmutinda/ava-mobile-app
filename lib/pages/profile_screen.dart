import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/pages/login/login.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../common/functions.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic> user = {};
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  Future<void> _loadUserData() async {
    final data = await getuserdata();
    setState(() {
      user = jsonDecode(data);
    });
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

  void _logout(BuildContext context) async {
    ProgressDialog pr = ProgressDialog(context, isDismissible: true);
    pr.style(message: "Logging you out...");
    await pr.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await pr.hide();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Login()),
      (_) => false,
    );
  }

  void _resetPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController oldPasswordController =
            TextEditingController();
        final TextEditingController newPasswordController =
            TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Center(
            child: const Text(
              "Reset Password",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Update your password by entering the current password and a new one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Old Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (oldPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty) {
                  toasty(context, "Fill the Details",
                      gravity: ToastGravity.TOP,
                      bgColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }
                // Add logic to validate and update the password here
                Navigator.pop(context);
                reset(oldPasswordController.text, newPasswordController.text);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text("Update Password"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 80, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${user["data"]?["name"] ?? ''}",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("${user["data"]?["email"] ?? ""}")],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${user["data"]?['username'] ?? ""}",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.lock,
                    color: const Color.fromARGB(255, 0, 48, 204)),
                title: Text('Change Password',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () => _resetPassword(context),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.logout,
                    color: const Color.fromARGB(255, 255, 11, 11)),
                title: Text('Logout',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void reset(OldpasswordController, passwordController) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CustomLoader(),
        );
      },
    );

    final dataToStore = {
      'old_password': OldpasswordController,
      'password': passwordController,
    };

    print(dataToStore);

    try {
      final url = "${Api.api_url}apichangePassword";
      var response =
          await httppostwithtoken(url, user['token'], dataToStore, context);
      if (response['success']) {
        Navigator.pop(context);

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: "${response['msg']}",
          ),
        );
        Login().launch(context,
            pageRouteAnimation: PageRouteAnimation.Fade, isNewTask: true);
      } else {
        Navigator.pop(context);
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "${response['msg']}",
          ),
        );
      }
    } catch (e) {
      print(e);
      Navigator.pop(context);
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "${e}",
        ),
      );
    }
  }
}
