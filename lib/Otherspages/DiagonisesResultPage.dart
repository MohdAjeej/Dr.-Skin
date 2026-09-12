import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'dart:convert';
import 'package:O2ISkinSense/Otherspages/DoctorPageforSelectedDisease.dart';
import 'package:O2ISkinSense/Otherspages/DoctorProfilePage.dart';
// import 'package:O2ISkinSense/Otherspages/DoctorPageforSelectedDisease.dart';

class DiseaseResultPage extends StatefulWidget {
  final Map<String, dynamic> result;

  DiseaseResultPage({required this.result});

  @override
  _DiseaseResultPageState createState() => _DiseaseResultPageState();
}

class _DiseaseResultPageState extends State<DiseaseResultPage> {
  Map<String, dynamic>? _diseaseData;
  Map<String, dynamic>? _additionalDiseaseData;
  List<dynamic>? _doctorData;
  List<String>? _imageUrls;
  bool _isImageLoading = false;
  bool _isLoading = false;
  bool _isAdditionalLoading = false;
  bool _isDoctorLoading = false;
  bool _isTreatmentExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchImageUrls(String diseaseName) async {
    setState(() {
      _isImageLoading = true;
    });

    final url = Uri.parse(
        '${ApiService.baseUrl}/api/diseases/get-by-disease-name?diseaseName=$diseaseName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _imageUrls = List<String>.from(json.decode(response.body));
        _isImageLoading = false;
      });
    } else {
      setState(() {
        _isImageLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load images')),
      );
    }
  }

  Future<void> _fetchDiseaseData(String diseaseName) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        '${ApiService.baseUrl}/api/treatments/disease?diseaseName=$diseaseName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _diseaseData = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data')),
      );
    }
  }

  Future<void> _fetchAdditionalDiseaseData(String diseaseName) async {
    setState(() {
      _isAdditionalLoading = true;
    });

    final url = Uri.parse(
        '${ApiService.baseUrl}/api/diseases/get-disease-by-diseaseName?diseaseName=$diseaseName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _additionalDiseaseData = json.decode(response.body);
        _isAdditionalLoading = false;
      });
    } else {
      setState(() {
        _isAdditionalLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load additional data')),
      );
    }
  }

  // Add this helper method to get disease name
  String get diseaseName {
    return widget.result['predictions'] != null
        ? widget.result['predictions'][0]['class']
        : 'No result available';
  }

// Modify _fetchData method
  Future<void> _fetchData() async {
    if (diseaseName.toLowerCase() == 'no') {
      await _fetchDoctorData('general');
    } else {
      await _fetchDiseaseData(diseaseName);
      await _fetchAdditionalDiseaseData(diseaseName);
      await _fetchDoctorData(diseaseName);
      await _fetchImageUrls(diseaseName);
    }
  }

// Update _fetchDoctorData to handle 'no' case
  Future<void> _fetchDoctorData(String diseaseName) async {
    setState(() {
      _isDoctorLoading = true;
    });

    final Uri url;
    if (diseaseName.toLowerCase() == 'no') {
      url = Uri.parse('${ApiService.baseUrl}/api/doctors/get-all-doctors');
    } else {
      url = Uri.parse(
        '${ApiService.baseUrl}/api/doctors/get-all-doctor-by-search?special=$diseaseName',
      );
    }

    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _doctorData = json.decode(response.body);
        _isDoctorLoading = false;
      });
    } else {
      setState(() {
        _isDoctorLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load doctor data')),
      );
    }
  }

// Add this new widget for unidentified case
  Widget _buildUnidentifiedContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]),
            child: Text(
              "The analysis couldn't identify a specific skin condition. "
              "Please consult a dermatologist for proper diagnosis.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade800,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
          _buildDoctorSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Diagnosis Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.notifications, color: Colors.black),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading || _isAdditionalLoading || _isDoctorLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
        ),
      );
    }

    if (diseaseName.toLowerCase() == 'no') {
      return _buildUnidentifiedContent();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiagnosisHeader(),
          SizedBox(height: 20),
          _buildImageSection(),
          SizedBox(height: 20),
          _buildHorizontalSections(),
          SizedBox(height: 20),
          _buildPrevalenceSection(),
          SizedBox(height: 20),
          _buildTreatmentDuration(),
          SizedBox(height: 20),
          _buildSuggestionsSection(),
          SizedBox(height: 20),
          _buildTreatmentDetails(),
          SizedBox(height: 20),
          _buildAyurvedicRemediesSection(),
          SizedBox(height: 20),
          _buildDoctorSection(),
        ],
      ),
    );
  }

// Update _buildDiagnosisHeader to handle 'no' case
  Widget _buildDiagnosisHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        diseaseName.toLowerCase() == 'no'
            ? "Analysis Result Inconclusive"
            : "Based on the analysis, your condition appears to be\n${diseaseName}",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: diseaseName.toLowerCase() == 'no'
              ? Colors.red.shade800
              : Colors.blue.shade900,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHorizontalSections() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildInfoCard2(
              'Description', [_additionalDiseaseData?['description']]),
          SizedBox(width: 15),
          _buildInfoCard2('Causes', _additionalDiseaseData?['causes']),
          SizedBox(width: 15),
          _buildInfoCard2('Symptoms', _additionalDiseaseData?['symptoms']),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<dynamic>? content) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Text(
            content?.join('\n') ?? '',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard2(String title, List<dynamic>? content) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        // height: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            Divider(color: Colors.grey.shade300, height: 25),
            Text(
              content?.join('\n') ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletCard2(String title, List<dynamic>? items) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            Divider(color: Colors.grey.shade300, height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                      ?.map((item) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ',
                                    style:
                                        TextStyle(color: Colors.blue.shade800)),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList() ??
                  [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyurvedicRemediesSection() {
    final ayurvedicRemedies = _diseaseData?['ayurvedicHomeRemedies'];
    if (ayurvedicRemedies == null) {
      return SizedBox
          .shrink(); // Return an empty widget if no data is available
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ayurvedic Home Remedies",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Text(
            ayurvedicRemedies['description'] ?? '',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          SizedBox(height: 20),
          ...(ayurvedicRemedies['remedies'] as List<dynamic>?)?.map((remedy) {
                return _buildRemedyCard(remedy);
              }).toList() ??
              [],
          SizedBox(height: 20),
          Text(
            "Precautions:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          SizedBox(height: 10),
          ...(ayurvedicRemedies['precautions'] as List<dynamic>?)
                  ?.map((precaution) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: Colors.blue.shade800)),
                      Expanded(
                        child: Text(
                          precaution,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList() ??
              [],
        ],
      ),
    );
  }

  Widget _buildRemedyCard(Map<String, dynamic> remedy) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            remedy['name'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("Usage: ${remedy['usage']['application']}"),
          SizedBox(height: 5),
          Text("Duration: ${remedy['usage']['duration']}"),
          SizedBox(height: 5),
          Text("Notes: ${remedy['usage']['notes']}"),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Related Images",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageUrls?.length ?? 0,
              itemBuilder: (context, index) {
                final imageUrl = _imageUrls?[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Image.network(
                    '${ApiService.baseUrl}$imageUrl',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletCard(String title, List<dynamic>? items) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                    ?.map((item) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ',
                                  style:
                                      TextStyle(color: Colors.blue.shade800)),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList() ??
                [],
          ),
        ],
      ),
    );
  }

  Widget _buildPrevalenceSection() {
    final percentage =
        _additionalDiseaseData?['globalPercentage']?.toDouble() ?? 0.0;
    final text = _additionalDiseaseData?['globalText'] ?? '';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Global Prevalence",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Row(
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.blue.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
                strokeWidth: 10,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentDuration() {
    final duration = _additionalDiseaseData?['generallyTake']['months'] ?? 0;
    final text = _additionalDiseaseData?['generallyTake']['text'] ?? '';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Treatment Duration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "$duration Months",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return _buildBulletCard(
        'Suggestions', _additionalDiseaseData?['suggestions']);
  }

  Widget _buildTreatmentDetails() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Treatment Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isTreatmentExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue.shade800,
                ),
                onPressed: () => setState(
                    () => _isTreatmentExpanded = !_isTreatmentExpanded),
              ),
            ],
          ),
          if (_isTreatmentExpanded) ...[
            ..._diseaseData?['products']
                .map<Widget>((product) => _buildProductCard(product))
                .toList(),
            SizedBox(height: 20),
            _buildInfoCard('Post Treatment Care', [
              _diseaseData?['postTreatment']['conditionMonitoring']['action'],
              _diseaseData?['postTreatment']['followUp']['improvement']
            ]),
            SizedBox(height: 20),
            _buildInfoCard(
                'Precautions', [_diseaseData?['precautions']['application']]),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product['name'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("Brands: ${product['brandExample'].join(', ')}"),
          SizedBox(height: 10),
          Text("Usage: ${product['usage']['application']}"),
          SizedBox(height: 5),
          Text("Duration: ${product['usage']['duration']}"),
          SizedBox(height: 5),
          Text("Notes: ${product['usage']['notes']}"),
        ],
      ),
    );
  }

  Widget _buildDoctorSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommended Specialists",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _doctorData?.length ?? 0,
              itemBuilder: (context, index) {
                final doctor = _doctorData?[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorProfileDisplayPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: doctor['imageLink'] != null
                                  ? NetworkImage(
                                      '${ApiService.baseUrl}${doctor['imageLink']}',
                                    )
                                  : null,
                              child: doctor['imageLink'] == null
                                  ? Icon(Icons.person,
                                      size: 40, color: Colors.grey)
                                  : null,
                            ),
                          ),
                        ),

                        // CircleAvatar(
                        //   radius: 40,
                        //   backgroundImage:
                        //       NetworkImage(doctor?['imageLink'] ?? ''),
                        // ),
                        SizedBox(height: 10),
                        Text(
                          doctor?['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          doctor?['specialization'] ?? '',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              5,
                              (i) => Icon(
                                    Icons.star,
                                    color:
                                        i < (doctor?['ratings']?.floor() ?? 0)
                                            ? Colors.amber
                                            : Colors.grey.shade400,
                                    size: 18,
                                  )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
