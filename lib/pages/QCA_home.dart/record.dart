import 'dart:convert';
import 'dart:io';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class RecordAnswer extends StatefulWidget {
  final gcaType;
  final stepId;
  final vehicle_id;
  final CategoryId;
  final query_group_name;

  const RecordAnswer(
      {super.key,
      this.gcaType,
      this.stepId,
      this.vehicle_id,
      this.CategoryId,
      this.query_group_name});

  @override
  State<RecordAnswer> createState() => _RecordAnswerState();
}

class _RecordAnswerState extends State<RecordAnswer> {
  String? selectedComponent;
  File? selectedImages;
  late TextEditingController inputController;
  final List<String> Paintdata = [
    'Factor 0.5',
    'Factor 1',
    'Factor 10',
    'Factor 50',
    // 'Factor 50',
  ];
  final List<String> Functiondata = [
    'Loose',
    'Dermaged',
    'Wrongly Assembled',
    'Lack Of Parts',
    'Functional Defects',
  ];
  final List<String> Functiondata2 = [
    'Factor 10',
    'Factor 50',
  ];
  final List<String> FunctionWeightingdata2 = [
    'Factor 0.5',
    'Factor 1',
    'Factor 10',
    'Factor 50',
  ];
  final List<String> LabelCv = [
    'Regulation-related parts',
    'Engineering information related parts',
  ];
  final List<String> LabelCvValue = [
    'zonea',
    'zoneb',
  ];
  final List<String> LabelLCv = [
    'Factor {{ zoneaf }}-Safety/Government Regulation',
    'Factor {{ zonebf }}-Non Safety/Government Regulation Labels',
  ];
  final List<String> LabelLCvValue = [
    'zonea',
    'zoneb',
  ];
  final List<String> Lamp = [
    'Deviate to upper from standard value - Factor {{ zoneaf }}',
    'Deviate to lower from standard value - Factor {{ zonebf }}',
  ];
  final List<String> LampValue = [
    'zonea',
    'zoneb',
  ];
  final List<String> OilFillingValue = [
    'zonea',
    'zoneb',
    'zonec',
    'zoned',
    'zonee',
    'zonef',
  ];
  final List<String> OilFilling = [
    'More than standard - Factor {{}}',
    'Extra Ordinary - Factor {{ zonebf }}',
    'Less than inspection standard - Factor {{ zonecf }}',
    'Extra Ordinary few - Factor {{ zoneef }}',
    'Leakage - Factor {{ zoneff }}',
  ];
  final List<String> data = [
    'Factor 0.5',
    'Factor 1',
    'Factor 10',
    'Factor 50',
  ];
  final List<String> data2 = [
    'Loose',
    'Factor 1',
    'Dermaged',
    'Wrongly Assembled',
    'Lack Of Parts',
    'Functional Defects',
  ];
  final List<String> data3 = [
    'Factor 10',
    'Factor 50',
  ];

  var user = {};
  var alldata = {};
  var components = {};
  String Factor = '';
  String category = '';
  String message = '';

  @override
  void initState() {
    // TODO: implement initState
    inputController = TextEditingController(text: widget.stepId);
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      // fetchComponent();
    });
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> captureImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    setState(() {
      if (pickedFile != null) {
        selectedImages = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image captured')),
        );
      }
    });
  }

  Future fetchComponent() async {
    setState(() {
      message = '';
    });

    try {
      String unitsurl = Api.api_url +
          "getcomponent/${widget.CategoryId}/${widget.vehicle_id}";
      print(unitsurl);
      var responsedata =
          await httpget(unitsurl, "${user['data']['token']}", context);

      if (responsedata["success"]) {
        responsedata["data"]['routes'].forEach((var route) {
          print(route['routing_part']);
          setState(() {
            data.add(route['routing_part']);
            data2.add(route['id'].toString());
            data3.add(route['route_number'].toString());
            // data2.add(route['id'].toString());
          });
        });
        // setState(() {
        //   alldata = responsedata["data"]['routes'];
        // });
      } else {
        setState(() {
          message = 'Network Problem';
        });
      }
    } catch (error) {
      // Handle errors
      print('Error fetching units: $error');
      setState(() {
        message = 'Network Problem';
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.query_group_name);
    return Container(
      width: double.infinity,
      child: data.isEmpty
          ? CustomLoader()
          : message.isNotEmpty
              ? ErrorMessageWidget(
                  errorMessage: message,
                  onRetry: () {
                    fetchComponent().then((value) {
                      setState(() {
                        message = '';
                      });
                    });
                  },
                )
              : SingleChildScrollView(
                  child: Container(
                    width: 500,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 192, 85, 3),
                          ),
                          child: Text(
                            "ENTER GCA VALUES",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 20),
                        //paint && Functional Weighting Standard
                        if (widget.query_group_name == 'Paint' ||
                            widget.query_group_name ==
                                'Functional Weighting Standard')
                          Column(
                            children: [
                              Column(
                                children: Paintdata.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;
                                          });
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Function
                        if (widget.query_group_name == 'Function')
                          Column(
                            children: [
                              header(title: 'Function'),
                              Column(
                                children: Functiondata.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            category = value!;
                                          });
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              header(title: 'Factor'),
                              Column(
                                children:
                                    FunctionWeightingdata2.map((component) {
                                  final componentName = component;
                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;
                                          });
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Label CV
                        if (widget.query_group_name == 'Label' &&
                            widget.gcaType == 'CV')
                          Column(
                            children: [
                              Column(
                                children: LabelCv.map((component) {
                                  final componentName = component;
                                  final componentNameId =
                                      LabelCvValue[data.indexOf(component)];
                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentNameId,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;
                                          });
                                          ;
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Label CV
                        if (widget.query_group_name == 'Label' &&
                            widget.gcaType == 'LCV')
                          Column(
                            children: [
                              Column(
                                children: LabelLCv.map((component) {
                                  final componentName = component;
                                  final componentNameId =
                                      LabelLCvValue[data.indexOf(component)];

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentNameId,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //lAMP
                        if (widget.query_group_name == 'Lamp')
                          Column(
                            children: [
                              Column(
                                children: Lamp.map((component) {
                                  final componentName = component;
                                  final componentNameId =
                                      LampValue[Lamp.indexOf(component)];
                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentNameId,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //oil filling
                        if (widget.query_group_name == 'Oil Filling')
                          Column(
                            children: [
                              header(title: "Filling Amount "),
                              Column(
                                children: OilFilling.map((component) {
                                  final componentName = component;
                                  final componentNameId =
                                      LampValue[data.indexOf(component)];
                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentNameId,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //zoneABC
                        if (widget.query_group_name == 'ZoneABC')
                          Column(
                            children: [
                              header(title: "Zones"),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //ABCD
                        if (widget.query_group_name == 'ABCD')
                          Column(
                            children: [
                              header(title: "Zones"),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Fluid-Level
                        if (widget.query_group_name == 'Fluid-Level')
                          Column(
                            children: [
                              header(title: "Fluid Level"),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Noise
                        if (widget.query_group_name == 'Noise')
                          Column(
                            children: [
                              header(title: "Noise"),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Safety
                        if (widget.query_group_name == 'Safety')
                          Column(
                            children: [
                              header(title: "Defect"),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              header(title: "Factor"),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //No-Zones
                        if (widget.query_group_name == 'No-Zones')
                          Column(
                            children: [
                              // header(title: "Noise"),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Exterior-Interior
                        if (widget.query_group_name == 'Exterior-Interior')
                          Column(
                            children: [
                              header(title: "Zone & Weight Factor "),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //ExteriorAB-Interior
                        if (widget.query_group_name == 'ExteriorAB-Interior')
                          Column(
                            children: [
                              header(title: "Zone & Weight Factor "),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //Weight Factor'
                        if (widget.query_group_name == 'ExteriorAB-Interior')
                          Column(
                            children: [
                              header(title: "Zone & Weight Factor "),
                              Column(
                                children: data.map((component) {
                                  final componentName = component;

                                  return Column(
                                    children: [
                                      RadioListTile(
                                        groupValue: Factor,
                                        value: componentName,
                                        title: Text(
                                          '$componentName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            Factor = value!;

                                            selectedComponent = Factor;
                                          });
                                          print(components);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Divider(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        //select SHOP
                        Column(
                          children: [
                            header(title: "Select Responsible  Shop"),
                            Column(
                              children: data.map((component) {
                                final componentName = component;

                                return Column(
                                  children: [
                                    RadioListTile(
                                      groupValue: Factor,
                                      value: componentName,
                                      title: Text(
                                        '$componentName',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          Factor = value!;

                                          selectedComponent = Factor;
                                        });
                                        print(components);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Divider(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        // defect Count
                        Column(
                          children: [
                            header(title: "Defect Count"),
                            Column(
                              children: data.map((component) {
                                final componentName = component;

                                return Column(
                                  children: [
                                    RadioListTile(
                                      groupValue: Factor,
                                      value: componentName,
                                      title: Text(
                                        '$componentName',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          Factor = value!;

                                          selectedComponent = Factor;
                                        });
                                        print(components);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Divider(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        // defect Description
                        Column(
                          children: [
                            header(title: "Defect Description"),
                            Column(
                              children: data.map((component) {
                                final componentName = component;

                                return Column(
                                  children: [
                                    RadioListTile(
                                      groupValue: Factor,
                                      value: componentName,
                                      title: Text(
                                        '$componentName',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          Factor = value!;

                                          selectedComponent = Factor;
                                        });
                                        print(components);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Divider(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        // UPC/FNA/Sheet Number
                        Column(
                          children: [
                            header(title: "UPC/FNA/Sheet Number"),
                            Column(
                              children: data.map((component) {
                                final componentName = component;

                                return Column(
                                  children: [
                                    RadioListTile(
                                      groupValue: Factor,
                                      value: componentName,
                                      title: Text(
                                        '$componentName',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          Factor = value!;

                                          selectedComponent = Factor;
                                        });
                                        print(components);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Divider(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        // Responsible Team Leader
                        Column(
                          children: [
                            header(title: "Defect Description"),
                            Column(
                              children: data.map((component) {
                                final componentName = component;

                                return Column(
                                  children: [
                                    RadioListTile(
                                      groupValue: Factor,
                                      value: componentName,
                                      title: Text(
                                        '$componentName',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          Factor = value!;

                                          selectedComponent = Factor;
                                        });
                                        print(components);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Divider(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        if (selectedImages == null)
                          ElevatedButton.icon(
                            icon: Icon(Icons.camera),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            label: Text('Capture Image'),
                            onPressed: () async {
                              await captureImage();
                            },
                          ),
                        // Text('${selectedImages}'),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: selectedImages != null
                              ? SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          selectedImages!,
                                          fit: BoxFit.contain,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            print("ok");
                                            setState(() {
                                              selectedImages = null;
                                            });
                                          },
                                          child: Container(
                                            // alignment: Alignment.topRight,

                                            child: CircleAvatar(
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                              : Container(), // or any other placeholder widget
                        ),
                        gap(),
                        AppButton(
                          text: " SAVE RECORD",
                          onTap: () async {
                            if (selectedComponent != null) {
                              // Navigator.pop(context);
                              showConfirmDialogCustom(
                                primaryColor: Colors.amber[900],
                                context,
                                title: "Do you want to Push this?",
                                // dialogType: DialogType.CONFIRMATION,
                                onAccept: (val) async {
                                  final ProgressDialog progressDialog =
                                      ProgressDialog(context);
                                  progressDialog.style(
                                    message: 'Pushing...',
                                    child: CustomLoader(),
                                    progressWidget: CircularProgressIndicator(),
                                  );
                                  await progressDialog.show();

                                  try {
                                    String url =
                                        Api.api_url + "moveunitfromstore";
                                    var payload = {
                                      "id": widget.vehicle_id,
                                      "route_id": widget.CategoryId,
                                      "component": components,
                                      "job_no": inputController.text,
                                    };
                                    print(payload);
                                    log(jsonEncode(payload));
                                    print(url);
                                    var response = await httppostwithtoken(
                                        url,
                                        user['data']['token'],
                                        payload,
                                        context);
                                    print(response);
                                    if (response['success']) {
                                      await progressDialog.hide();

                                      awesomeTopSnackbar(
                                        context,
                                        "${response['msg']}",
                                        iconWithDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(),
                                            color: Colors.white),
                                        icon: Icon(
                                          Icons.done,
                                          color: Colors.green[900],
                                        ),
                                      );
                                      Navigator.pop(context);
                                      // print(response);
                                      print(response);
                                    } else {
                                      await progressDialog.hide();

                                      awesomeTopSnackbar(
                                          context, "${response['msg']}",
                                          iconWithDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(),
                                              color: Colors.white),
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          backgroundColor: Colors.red[900]);
                                      // print(response);

                                      print(response);
                                    }
                                    return response;
                                  } catch (e) {
                                    await progressDialog.hide();
                                    print("error : $e");
                                  } finally {
                                    await progressDialog.hide();
                                  }

                                  Navigator.pop(context);
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please select a component.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class header extends StatelessWidget {
  final title;

  const header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: mycolor.withOpacity(0.09)),
      child: Text(
        "${title}",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
