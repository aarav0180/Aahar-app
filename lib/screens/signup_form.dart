import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_solution/screens/agent_home.dart';
import 'package:google_solution/screens/ngo_home.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/Auth/auth.dart';
import '../utils/app_colors.dart';
import '../utils/functions/camera_permissions.dart';
import '../widgets/snack_bar.dart';

class NgoFormPage extends StatefulWidget {
  final String title;
  final String email;
  final String password;
  final bool isAgentForm;
  final void Function(Map<String, String>) onSubmit;

  const NgoFormPage({
    super.key,
    required this.title,
    required this.password,
    required this.email,
    required this.isAgentForm,
    required this.onSubmit,
  });

  @override
  State<NgoFormPage> createState() => _NgoFormPageState();
}

class _NgoFormPageState extends State<NgoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};
  XFile? _profileImage;
  String profileUrl = "";


  Future<void> _pickImage({required bool fromCamera}) async {
    final ImagePicker picker = ImagePicker();

    if (fromCamera) {
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) _profileImage = image;
    } else {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = image;

        });

    }

    final url = await _uploadImageToImgBB(image!);
    if(url != null){
      profileUrl = url;
    }
    }
  }

  Future<String?> _uploadImageToImgBB(XFile imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload?key=4d4101b9a1570ecccdfc197edcf972a2'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', File(imageFile.path).path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(await response.stream.bytesToString());
      return jsonResponse['data']['url']; // Return the uploaded image URL
    } else {
      //print("Failed to upload image");
      showCustomSnackBar(context, 'Failed to upload image', true);
      return null;
    }
  }

  void _handleNgoFormSubmit(Map<String, String> data) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    String role = widget.isAgentForm ? "NGO Agent" : "NGO";

    String email = data['email'] ?? '';
    String name = data['name'] ?? '';
    String phone = data['phone'] ?? '';
    String organizationEmail = data['organizationEmail'] ?? '';
    String profilePhoto = profileUrl;

    try {
      if (role == "NGO Agent") {
        // 🔍 Find the NGO with the given email
        QuerySnapshot ngoSnapshot = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'NGO')
            .where('email', isEqualTo: organizationEmail)
            .get();

        if (ngoSnapshot.docs.isEmpty) {
          showCustomSnackBar(context, 'No NGO found with this email.', false);
          return;
        }

        DocumentSnapshot ngoDoc = ngoSnapshot.docs.first;
        String ngoId = ngoDoc.id;

        // 🔹 Update agent’s data in 'users'
        await _firestore.collection('users').doc(data['uid']).update({
          'name': name,
          'phone': phone,
          'email': email,
          'profileImageUrl': profilePhoto,
          'role': 'NGO Agent',
          'assignedNGO': ngoId,
        });

        // 🔹 Add/update agent under NGO's `agents` field (map of agents)
        await _firestore.collection('users').doc(ngoId).update({
          'agents.${data['uid']}': {
            'uid': data['uid'],
            'name': name,
            'email': email,
            'phone': phone,
            'profileImageUrl': profilePhoto,
            'assignedNGO': ngoId,
          }
        });

        showCustomSnackBar(context, 'Agent updated under NGO', true);
        //Navigator.pop(context);

      } else {
        // 🔹 Update NGO's own fields
        await _firestore.collection('users').doc(data['uid']).update({
          'name': name,
          'phone': phone,
          'email': email,
          'profileImageUrl': profilePhoto,
          'role': 'NGO',
        });

        showCustomSnackBar(context, 'NGO details updated', true);
        //Navigator.pop(context);
      }
    } catch (e) {
      print("🔥 Error: $e");
      showCustomSnackBar(context, 'Error updating data: ${e.toString()}', false);
    }
  }


  void _showImageSourceSheet() async{
    await PermissionHelper.requestCameraPermission(context);
    await PermissionHelper.requestStoragePermission(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  _pickImage(fromCamera: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  _pickImage(fromCamera: true);

                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _formData['email'] = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Animate(
              effects: [FadeEffect(duration: 300.ms), MoveEffect(begin: const Offset(0, 20))],
              child: Text(
                widget.isAgentForm ? "👷 Agent Registration" : "🏢 NGO Registration",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if(!widget.isAgentForm)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Profile Photo",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            _showImageSourceSheet();
                          },
                          child: _profileImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_profileImage!.path),
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_a_photo, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  _buildTextField("name", "Full Name"),
                  const SizedBox(height: 16),
                  _buildTextField("employeeSize", "Employee Size", inputType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField("phone", "Phone Number", inputType: TextInputType.phone),
                  const SizedBox(height: 16),
                  if (widget.isAgentForm)
                    _buildTextField("organizationEmail", "Organization Email"),
                  const SizedBox(height: 32),
                  Animate(
                    effects: [FadeEffect(duration: 400.ms)],
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        print(_formData);
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          widget.onSubmit(_formData);

                          _handleNgoFormSubmit(_formData);

                          if(widget.isAgentForm) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AgentHomeScreen(mail: widget.email)));
                          }else if(!widget.isAgentForm){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NGOHomeScreen(mail: widget.email)));
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String key, String label, {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
      onSaved: (value) => _formData[key] = value ?? '',
    );
  }
}
