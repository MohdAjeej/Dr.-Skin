import 'dart:io';

import 'package:O2ISkinSense/Otherspages/cropimage.dart';
import 'package:O2ISkinSense/Otherspages/DiagnoseAnimationPage.dart';
import 'package:O2ISkinSense/Otherspages/NotificationPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//this is camera page
class TakeOrUploadScreen extends StatefulWidget {
  @override
  _TakeOrUploadScreenState createState() => _TakeOrUploadScreenState();
}

class _TakeOrUploadScreenState extends State<TakeOrUploadScreen> {
  XFile? _image;

  // Method to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      // Navigate directly to crop page with the selected image
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImagePage(image: File(pickedImage.path)),
        ),
      ).then((croppedFile) {
        // This callback runs when we return from the crop page
        if (croppedFile != null) {
          setState(() {
            _image = XFile(croppedFile.path);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Column(
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.notifications_active),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    child: Text(
                      "You can either take a picture or upload one to proceed.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // Image display and buttons container
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.blue.shade800,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_image != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: GestureDetector(
                                onTap: () {
                                  // Allow re-cropping if image is already selected
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CropImagePage(
                                          image: File(_image!.path)),
                                    ),
                                  ).then((croppedFile) {
                                    if (croppedFile != null) {
                                      setState(() {
                                        _image = XFile(croppedFile.path);
                                      });
                                    }
                                  });
                                },
                                child: Image.file(
                                  File(_image!.path),
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No image selected.',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black54),
                              ),
                            ),

                          // Take/Upload buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _pickImage(ImageSource.camera),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Take Picture',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue.withOpacity(0.7),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _pickImage(ImageSource.gallery),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Upload Picture',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue.withOpacity(0.7),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),

                          // Diagnose button (only enabled when image is selected)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: ElevatedButton(
                                onPressed: _image != null
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DiagnosePage(
                                              image: File(_image!.path),
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    'Diagnose',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _image != null
                                      ? const Color.fromARGB(255, 122, 196, 125)
                                      : Colors.grey,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "How This Works",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Our AI-powered system will automatically analyze the image to detect potential skin issues like acne, rashes, or dryness. "
                      "Based on the analysis, personalized solutions will be provided to help you manage and improve your skin health. If needed, you can also explore a list of qualified dermatologists for a more detailed consultation.",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54), // Reduced font size to 14
                      textAlign: TextAlign.start,
                    ),
                  ),

                  // Carousel for "Top Rated" section
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Top Rated",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  // Carousel Section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      child: PageView(
                        children: [
                          Image.asset('assets/19834-bg.png', fit: BoxFit.cover),
                          Image.asset('assets/414.jpg', fit: BoxFit.cover),
                          Image.asset('assets/19834.png', fit: BoxFit.cover),
                          // Add more images as needed
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
