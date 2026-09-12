import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Otherspages/DiagonisingResult.dart';
import 'package:O2ISkinSense/Otherspages/DiagonisesResultPage.dart';
import 'package:O2ISkinSense/BottomPages/BottomNav.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';
// Import your DiagnosePage

class DiagnosePage extends StatefulWidget {
  final File image;
  const DiagnosePage({Key? key, required this.image}) : super(key: key);

  @override
  _DiagnosePageState createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _isDiagnoseComplete = false;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startDiagnosis();
  }

  Future<void> _apiGetData() async {
    ApiService apiService = ApiService();
    _result = await apiService.diagnoseSkin(widget.image);
  }

  void _startDiagnosis() {
    Future.doWhile(() async {
      if (_progress < 0.95) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _progress = (_progress + 0.02).clamp(0.0, 0.95);
        });
        return true;
      } else {
        return false;
      }
    }).then((_) async {
      await _apiGetData();

      setState(() {
        _progress = 1.0;
        _isDiagnoseComplete = true;
        _animationController.stop();
      });

      savetodatabase();
    });
  }

  Future<void> savetodatabase() async {
    ApiService apiService = ApiService();
    String disease = _result?['predictions'] != null
        ? _result!['predictions'][0]['class']
        : 'No result available';
    await apiService.uploadDiseaseHistory(widget.image, disease);
  }

  void _navigateToResultPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseResultPage(
          result: _result!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Typicons.chevron_left),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                    child: Text(
                      "Diagnosis",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        widget.image,
                        height: 250,
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (!_isDiagnoseComplete)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _scanLineAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter:
                                  _ScanLinePainter(_scanLineAnimation.value),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _isDiagnoseComplete
                  ? Column(
                      children: [
                        Icon(Icons.check_circle,
                            size: 60, color: Colors.green.shade600),
                        const SizedBox(height: 10),
                        const Text(
                          "Diagnosis Complete!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _navigateToResultPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Get Result",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const SpinKitRipple(
                          color: Colors.blue,
                          size: 80,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Diagnosing...",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearPercentIndicator(
                  lineHeight: 30.0,
                  percent: _progress,
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Colors.blue.withOpacity(0.7),
                  barRadius: const Radius.circular(10),
                  center: Text(
                    "${(_progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double position;

  _ScanLinePainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 4.0;

    final y = position * size.height;

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
