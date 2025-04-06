import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../utils/functions/API/food_analyzer.dart';
import '../utils/functions/camera_permissions.dart';
import '../widgets/snack_bar.dart';

class DonationScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const DonationScreen({super.key, required this.latitude, required this.longitude});

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  List<XFile> _foodImages = [];
  List<String> _uploadedImageUrls = [];
  String? _quantity;
  String? _name;
  String? _items;
  String? _vehicleSize;
  bool isEnable = false;
  double? _qualityScore;
  bool _isSubmitting = false;
  bool _analyzing = false;

  Future<void> _pickImages({required bool fromCamera}) async {
    final ImagePicker picker = ImagePicker();
    List<XFile> selectedImages = [];

    if (fromCamera) {
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) selectedImages = [image];
    } else {
      final images = await picker.pickMultiImage();
      if (images.isNotEmpty) selectedImages = images;
    }

    setState(() {
      _foodImages = selectedImages;
      _qualityScore = null;
      _uploadedImageUrls = [];
      isEnable = false;
      _analyzing = true;
    });

    for (final image in _foodImages) {
      final url = await _uploadImageToImgBB(image);
      if (url != null) _uploadedImageUrls.add(url);
    }

    if (_uploadedImageUrls.isNotEmpty) {
      final result = await FoodAnalyzerService.analyzeFood(_uploadedImageUrls);
      setState(() {
        final assessments = result?["assessment"] as List<dynamic>?;
        if (assessments != null && assessments.isNotEmpty) {
          bool allAboveThreshold = true;
          for (var item in assessments) {
            final score = double.tryParse(item["qualityScore"].toString()) ?? 0.0;
            if (score < 5.0) {
              allAboveThreshold = false;
              break;
            }
          }
          isEnable = allAboveThreshold;
          _analyzing = false;
        }});
    } else {
      setState(() => _analyzing = false);
    }
  }


  Future<void> _submitToFirebase() async {
    try {
      if (_uploadedImageUrls.isEmpty) {
        showCustomSnackBar(context, 'Please upload at least one image.', false);
        return;
      }

      await FirebaseFirestore.instance.collection('donations').add({
        'foodImages': _uploadedImageUrls, // Save list of URLs
        'quantity': _quantity,
        'name': _name,
        'items': _items,
        'vehicleSize': _vehicleSize,
        'latitude': widget.latitude,
        'longitude': widget.longitude,
        'status': 'Pending',
        'assignedTo': '',
        'timestamp': Timestamp.now(),
      });

      showCustomSnackBar(context, 'Donation successfully submitted!', true);

      // Optional: Clear form after submission
      setState(() {
        _foodImages.clear();
        _uploadedImageUrls.clear();
        _qualityScore = null;
        isEnable = false;
        _quantity = '';
        _name = '';
        _items = '';
        _vehicleSize = '';
      });
    } catch (e) {
      showCustomSnackBar(context, 'Error: ${e.toString()}', false);
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

  void _continueStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    }
  }


  void _submitForm() async {
    if (_formKey.currentState!.validate() && _foodImages != null && isEnable) {
      setState(() => _isSubmitting = true);
      await _submitToFirebase();
      setState(() => _isSubmitting = false);
      if (context.mounted) Navigator.pop(context);
    } else if (_foodImages == null) {
      showCustomSnackBar(context, 'Please upload a food image.', false);
    } else {
      showCustomSnackBar(context, 'Food quality too low to donate.', false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Donation')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep < 2 ? _continueStep : null,
        onStepCancel: () => setState(() => _currentStep = (_currentStep - 1).clamp(0, 2)),
        controlsBuilder: (context, details) {
          return _currentStep < 2
              ? Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: const Text('Next'),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            ],
          )
              : const SizedBox.shrink();
        },
        steps: [
          Step(
            title: const Text('Food Details'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceSheet(),
                    child: _foodImages.isNotEmpty
                        ? SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _foodImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                                child: Image.file(
                                  File(_foodImages[index].path),
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _foodImages.removeAt(index);
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    )
                        : Container(
                      height: 300,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 2, // You can adjust thickness
                        ),
                        borderRadius: BorderRadius.circular(8), // Optional: for rounded corners
                      ),
                      child: const Icon(CupertinoIcons.camera, size: 50),
                    )

                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name for the food'),
                    keyboardType: TextInputType.name,
                    onChanged: (value) => _name = value,
                    validator: (value) => value!.isEmpty ? 'Please enter the name' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Approx Quantity (kg)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _quantity = value,
                    validator: (value) => value!.isEmpty ? 'Please enter the quantity' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Number of Items'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _items = value,
                    validator: (value) => value!.isEmpty ? 'Please enter the number of items' : null,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Vehicle Requirement'),
            content: DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Select Vehicle Size'),
              items: const [
                DropdownMenuItem(value: 'Small', child: Text('Small (Bike/Scooter)')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium (Car)')),
                DropdownMenuItem(value: 'Large', child: Text('Large (Truck)')),
              ],
              onChanged: (value) => _vehicleSize = value,
              validator: (value) => value == null ? 'Please select a vehicle size' : null,
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Confirm Submission'),
            content: Column(
              children: [
                const Text(
                  'Please review your donation details before submitting.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                if (isEnable == false && _analyzing == false)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "The food didn't pass the AI freshness test.\nPlease recheck before submission.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                if(_analyzing || _isSubmitting)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.amber,),
                    ),
                  ),
                if(!_analyzing && !_isSubmitting)
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(CupertinoIcons.checkmark_shield),
                    label: const Text('Submit Donation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      backgroundColor: isEnable == true ? Colors.amber : Colors.grey,

                    ),
                  ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
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
                  _pickImages(fromCamera: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  _pickImages(fromCamera: true);

                },
              ),
            ],
          ),
        );
      },
    );
  }

}
