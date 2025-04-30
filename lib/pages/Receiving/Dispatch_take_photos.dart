import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/imageView.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Dispatch_take_photos extends StatefulWidget {
  final id;
  final title;
  final sku;
  const Dispatch_take_photos({
    super.key,
    this.id,
    this.title,
    required this.sku,
  });

  @override
  State<Dispatch_take_photos> createState() => _Dispatch_take_photosState();
}

class _Dispatch_take_photosState extends State<Dispatch_take_photos>
    with SingleTickerProviderStateMixin {
  List<File> selectedImages = [];
  final picker = ImagePicker();
  var user = {};
  String loadingText = '';
  bool isLoading = false;
  late Completer<void> _completer;
  List materials = [];
  @override
  void initState() {
    _completer = Completer<void>();

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchmaterials().then(
        (value) {
          if (materials.isEmpty) {
            setState(() {
              loadingText = 'No Images Found';
            });
          }
        },
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    if (!_completer.isCompleted) {
      _completer.complete(); // Completes the future
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildImageCard(String? imageUrl, int? imageId, int Number) {
      return Container(
        width: MediaQuery.of(context).size.width / 1.5,
        height: 200,
        child: Stack(
          children: [
            // Wrap the image widget with GestureDetector
            GestureDetector(
              onTap: () {
                // Show the image in a pop-up style
              },
              child: GridTile(
                child: ImageFullScreenWrapperWidget(
                  imageUrl: imageUrl!,
                  dark: true,
                ),
                footer: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    "Image $Number",
                    style: TextStyle(
                        color: textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                AwesomeDialog(
                  context: context,
                  // dialogType: DialogType.warning,
                  animType: AnimType.rightSlide,
                  title: 'Confirm To delete image No $Number',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () async {
                    // print(image['id']);
                    final ProgressDialog progressDialog =
                        ProgressDialog(context);
                    progressDialog.style(
                      message: 'Deleting...',
                      // child: CustomLoader(),
                      progressWidget: CircularProgressIndicator(),
                    );
                    await progressDialog.show();
                    try {
                      String url = Api.api_url + "apiDeleteImages";
                      var payload = {"progress_image_id": imageId};
                      print(payload);
                      print(url);
                      var response = await httppostwithtoken(
                          url, user["token"], payload, context);
                      log(jsonEncode(response));
                      if (response['success']) {
                        fetchmaterials().then(
                          (value) {
                            if (materials.isEmpty) {
                              setState(() {
                                loadingText = 'No Images Found';
                              });
                            }
                          },
                        );
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                            message: "${response['msg']}",
                          ),
                        );
                      } else {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: "${response['msg']}",
                          ),
                        );
                      }
                      return response;
                    } catch (e) {
                      print("error : $e");
                    } finally {
                      await progressDialog.hide();
                      fetchmaterials();
                    }
                  },
                  btnOkText: 'Confirm',
                  btnCancelText: 'Cancel',
                  btnOkColor: mycolor,
                  btnCancelColor: Colors.red[900],
                )..show();
              },
              child: Container(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: mycolor,
                  radius: 16,
                  child: Icon(
                    Icons.delete,
                    color: textWhite,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.title == 'CHASSIS' ? widget.sku : widget.title}",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: SizedBox(
              child: isLoading
                  ? Center(child: SizedBox.shrink())
                  : loadingText.isNotEmpty
                      ? ErrorMessageWidget(
                          errorMessage: loadingText,
                          onRetry: () {
                            fetchmaterials().then(
                              (value) {
                                if (materials.isEmpty) {
                                  setState(() {
                                    loadingText = 'No Images Found';
                                  });
                                }
                              },
                            );
                          },
                        )
                      : SingleChildScrollView(
                          child: GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 4,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              physics: const NeverScrollableScrollPhysics(),
                              children:
                                  List.generate(materials.length, (index) {
                                var req = materials[index];
                                print(req['image']);
                                var image = req['image'];
                                var imageId = req['id'];
                                var imageUrl =
                                    "${"Api.progress_image"}${image}";
                                var No = index + 1;
                                return _buildImageCard(
                                  imageUrl,
                                  imageId,
                                  No,
                                );
                                // return Text("data");
                              })),
                        ),
            ),
          ),
          // if (selectedImages.length == 0)
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            label: Text('Capture Image'),
            onPressed: () async {
              // await getImages();
              await captureImage();
            },
          ),
        ]),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> captureImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });

      // Automatically upload the captured image
      String imagePath = pickedFile.path;

      try {
        final response = await uploadImages(widget.id, [File(imagePath)]);
        if (response["status"] == Api.codeOK) {
          toasty(context, '${response["message"]}',
              bgColor: Colors.green, textColor: Colors.white);
          setState(() {
            selectedImages.removeWhere((image) => image.path == imagePath);
          });
          fetchmaterials().then(
            (value) {
              if (materials.isEmpty) {
                setState(() {
                  loadingText = 'No Images Found';
                });
              }
            },
          );
        } else {
          toasty(context, '${response["message"]}',
              bgColor: Colors.red, textColor: Colors.white);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(response["message"] ?? "Upload failed")),
          // );
        }
      } catch (e) {
        toasty(context, '${e.toString()}',
            bgColor: Colors.red, textColor: Colors.white);
      }
    } else {
      toasty(
        context,
        'No image captured',
      );
    }
  }

  Future uploadImages(vehicleId, images) async {
    String url = Api.api_url + "uploadReceivingImages";
    print(url);
    var response = await uploadImagesWithToken2(
        vehicleId.toString(), url, images, user["token"]);
    print("+++++");
    // print(response);
    log(jsonEncode(response));
    print("+++++");
    return response;
  }

  Future fetchmaterials() async {
    setState(() {
      isLoading = materials.isEmpty ? true : false;
      loadingText = '';
    });
    // String url =   "${Api.api_url}${Api.endpoint_load_assembly_material_list}/$id";
    String url = "${Api.api_url}apiFetchImagesReceiving/${widget.id}";
    print(url);
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    pr.style(
      message: 'Loading materials....',
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
          width: 20,
          height: 20,
          child: Center(child: CircularProgressIndicator())),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );

    // pr.show();
    var response = await httpget(url, user["token"], context);
    print(response["job_cards"]);
    if (response != null) {
      pr.hide();
      setState(() {
        isLoading = false;
        materials = response["job_cards"];
        // images = response["job_cards"]['progress_images'];
      });
    } else {
      pr.hide().whenComplete(() {
        setState(() {
          isLoading = false;
          loadingText = response["msg"];
        });
      });
    }
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();
      }
    });
  }
}
