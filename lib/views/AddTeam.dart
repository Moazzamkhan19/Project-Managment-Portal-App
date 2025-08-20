import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_managment_fb/InternetServices/InternetServices.dart';
import 'dart:convert';
import 'package:project_managment_fb/database/database.dart';
import 'package:project_managment_fb/views/home_page.dart';
import 'package:uuid/uuid.dart';
import '../models/team_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // make sure this import is at the top
import 'package:project_managment_fb/controllers/Team_controller.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class AddTeamPage extends StatefulWidget {
  @override
  _AddTeamPageState createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();
  /*File? _image;
  final TeamController _teamController = TeamController();*/
  final TeamController _teamController = Get.put(TeamController());


  /* final ImagePicker _picker = ImagePicker();*/
  Future<bool> _saveTeam() async {
    if (_formKey.currentState!.validate()) {
      try {
        String base64Image = '';
        /* if (_image != null) {
          base64Image = await CompressAndConvert(_image!);
        }*/
        if (_teamController.pickImage.value != null) {
          base64Image =
          await CompressAndConvert(_teamController.pickImage.value!);
        }

        final team = Team(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          designation: _designationController.text,
          image: base64Image,
          id: '',
        );

        final teamMap = team.toMap()
          ..addAll({'addedAt': FieldValue.serverTimestamp()});

        final docRef = await FirebaseFirestore.instance
            .collection('teams')
            .add(teamMap);

        await docRef.update({'id': docRef.id});

        return true;
      } catch (e) {
        print('Save team failed: $e');
        return false;
      }
    }
    return false;
  }
  Future<bool> _saveTeamDB() async {
    if (_formKey.currentState!.validate()) {
      try {
        String base64Image = '';
        if (_teamController.pickImage.value!=null) {
          base64Image = await CompressAndConvert(_teamController.pickImage.value!);
        }
        var uuid = Uuid();
        String generatedId = uuid.v4();

        final team = Team(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          designation: _designationController.text,
          image: base64Image,
          id: generatedId.isNotEmpty ? generatedId : uuid.v4(),
        );

        await _teamController.addTeamDB(team);
        return true;
      }
      catch(e)
    {
      print(e);
      return false;
    }
    }
    return false;
  }
  Future<String> CompressAndConvert(File imageFile)async {
    try
    {
      final bytes = await imageFile.readAsBytes();
      final originalimg = img.decodeImage(bytes);
      if(originalimg==null) throw Exception('Failed to decode image');
      final resizedimg = img.copyResize(originalimg,width: 200);
      final compressedBytes = img.encodeJpg(resizedimg,quality: 40);
      final base64String  = base64Encode(compressedBytes);
      return base64String;
    }
    catch(e)
    {
      return "";
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),

        title: Text("Add Team Member"),
        backgroundColor: Colors.purple[100],centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _teamController.pickImage,
                  child: Obx(() {
                    return _teamController.pickImage.value == null
                        ? CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.add_a_photo, size: 30),
                    )
                        : CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_teamController.pickImage.value!),
                    );
                  }),
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _teamController.pickImagemethod,
                      icon: Icon(Icons.photo_library),
                      label: Text("Pick from Gallery"),
                    ),
                    SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: _teamController.takePicture,
                      icon: Icon(Icons.camera_alt),
                      label: Text("Take a Picture"),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name"),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter email';
                    if (!_teamController.isValidEmailFormat(value))
                      return 'Invalid email format';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter phone';
                    if (!_teamController.isValidPhoneNumber(value))
                      return 'Invalid phone number';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _designationController,
                  decoration: InputDecoration(labelText: "Designation"),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter designation' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async
                  {
                    final connection = await InternetServices.checkInternetAccess();
                    if (connection == true)
                      {
                        final isSuccess = await _saveTeam();
                        if (isSuccess && mounted) {
                          print("Navigating...");
                         /* Navigator.pushReplacementNamed(context, '/home');*/
                          Get.toNamed('/home');

                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Succesfully saved to Firebase 🔥',),
                                backgroundColor: Colors.grey[500],
                              ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save'),
                              backgroundColor: Colors.grey[500],
                            ),
                          );
                        }
                      }
                    else
                      {
                        final Success = await _saveTeamDB();
                        if(Success && mounted)
                          {
                            /*Navigator.pushReplacementNamed(context, '/home');*/
                            Get.toNamed('/home');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Succesfully saved to SQL-LITE'),
                                backgroundColor: Colors.grey[500],
                              ),
                            );
                          }
                        else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                      }

                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

