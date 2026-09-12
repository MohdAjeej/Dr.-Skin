// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:typicons_flutter/typicons_flutter.dart';

// class ResultPage extends StatelessWidget {
//   final File image;
//   final Map<String, dynamic> result;

//   const ResultPage({Key? key, required this.image, required this.result})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // GlobalPercentage to be shown as a percentage value
//     double globalPercentage = 1.3;

//     return Scaffold(
//       // appBar: AppBar(
//       //   backgroundColor: Colors.blue.withOpacity(0.7),
//       //   // leading: IconButton(
//       //   //   icon: const Icon(Icons.arrow_back),
//       //   //   onPressed: () => Navigator.pop(context),
//       //   // ),
//       //   leading: IconButton(
//       //     icon: Icon(
//       //       Typicons.chevron_left,
//       //       color: Colors.white,
//       //     ), // Change back icon using Typicons
//       //     onPressed: () {
//       //       Navigator.pop(context); // Return to previous screen
//       //     },
//       //   ),
//       //   title: Row(
//       //     children: [
//       //       // CircleAvatar(
//       //       //   backgroundImage: AssetImage("assets/414.jpg"),
//       //       // ),
//       //       // const SizedBox(width: 10),
//       //       Text(
//       //         "Diagnosis Result",
//       //         style: TextStyle(
//       //           color: Colors.white,
//       //         ),
//       //       ), // Replace with dynamic name
//       //     ],
//       //   ),
//       //   actions: <Widget>[
//       //     IconButton(
//       //       icon: const Icon(
//       //         Icons.notifications,
//       //         color: Colors.white,
//       //       ),
//       //       onPressed: () {},
//       //     ),
//       //   ],
//       // ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           // Wrap the entire body content in a SingleChildScrollView
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                 color: Colors.white,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       alignment: Alignment.centerLeft,
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.6,
//                         child: Text(
//                           "Diagnosis Result",
//                           style: TextStyle(
//                             color: Colors.black54,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       splashRadius: 20,
//                       icon: const Icon(Icons.notifications_active),
//                       onPressed: () {
//                         // Placeholder for notification functionality
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 15),
//               // SizedBox(height: 10),

//               Container(
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.only(left: 10, bottom: 10),
//                 child: result['error'] != null
//                     ? Text(
//                         result['error'],
//                         style: TextStyle(fontSize: 16, color: Colors.red),
//                       )
//                     : Text(
//                         result['predictions'] != null
//                             ? result['predictions'][0]['class']
//                             : 'No result available',
//                         style: TextStyle(fontSize: 16),
//                       ),

//                 //  Text(
//                 //   "Based on the image, your condition seems to be Mild Psoriasis.",
//                 //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 // ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 width: MediaQuery.of(context).size.width * 1,
//                 color: Colors.black,
//                 child: Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.file(
//                       image,
//                       height: 250,
//                       width: 250,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               SingleChildScrollView(
//                 scrollDirection: Axis
//                     .horizontal, // Make horizontal scrolling possible for this row
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       _buildSection(
//                           "Mild Psoriasis",
//                           "A chronic autoimmune condition characterized by small patches of red skin with silvery scales, usually affecting less than 3% of the body surface area.",
//                           context),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       _buildSection(
//                           "Causes",
//                           "• Genetic predisposition\n• Immune system dysfunction\n• Environmental triggers such as stress or infections",
//                           context),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       _buildSection(
//                           "Symptoms",
//                           "• Small red patches with silvery scales\n• Mild itching or discomfort\n• Occasional irritation in affected areas",
//                           context),
//                     ],
//                   ),
//                 ),
//               ),
//               // const SizedBox(height: 20),
//               const SizedBox(height: 20),
//               _buildPrevalencePercentage(globalPercentage, context),
//               const SizedBox(height: 20),
//               _buildTreatmentDuration(context),
//               const SizedBox(height: 20),
//               _buildSection2(
//                 "Suggestions",
//                 "• Use topical treatments such as corticosteroids or moisturizers.\n• Avoid triggers like stress and infections.\n• Monitor symptoms regularly and consult a dermatologist for tailored treatment.",
//               ),
//               const SizedBox(height: 20),
//               TreatmentDetails(),
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.only(left: 20),
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Specialists",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Colors.blue[800],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18),
//                 ),
//               ),

//               const SizedBox(height: 10),
//               // Specialists list with random doctor names and photo
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal, // Make the scroll horizontal
//                 child: Row(
//                   children: [
//                     for (int index = 0;
//                         index < 5;
//                         index++) // Loop to generate the items
//                       Container(
//                         margin: const EdgeInsets.only(right: 14),
//                         // height: 180, // Adjusted height to accommodate the button
//                         width: 140,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.blue.shade200,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.asset(
//                                   'assets/person.jpg',
//                                   width: 60,
//                                   height: 60,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               'Dr. Rajesh $index',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               '\$${(index + 1) * 50}', // Placeholder for price
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: List.generate(5, (starIndex) {
//                                 return Icon(
//                                   Icons.star,
//                                   color: starIndex < 4
//                                       ? Colors.yellow
//                                       : Colors.grey,
//                                   size: 14,
//                                 );
//                               }),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               '${(index + 1) * 2} years experience', // Placeholder for experience
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             TextButton(
//                               onPressed: () {
//                                 // Add consult button functionality here
//                               },
//                               style: TextButton.styleFrom(
//                                 backgroundColor: Colors.orange,
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 6, horizontal: 20),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Consult',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.only(left: 20),
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Buy Products",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Colors.blue[800],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal, // Make the scroll horizontal
//                 child: Row(
//                   children: [
//                     for (int index = 0;
//                         index < 5;
//                         index++) // Loop to generate the products
//                       Container(
//                         margin: const EdgeInsets.only(right: 14),
//                         // Adjusted height to accommodate the button
//                         width: 140,

//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.shade300,
//                               offset: Offset(0, 4),
//                               blurRadius: 8,
//                             ),
//                           ],
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.blue.shade200,
//                               Colors.green.shade200
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),

//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.asset(
//                                   'assets/person.jpg', // Replace with product image
//                                   width: 60,
//                                   height: 60,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(right: 8.0, left: 8.0),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     'Product ${index + 1}',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   Text(
//                                     '\$${(index + 1) * 30}', // Placeholder for product price
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 5),

//                             //

//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(right: 8.0, left: 8.0),
//                               child: Text(
//                                 'Description for Product ${index + 1}', // Placeholder for product description
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             TextButton(
//                               onPressed: () {
//                                 // Add buy now button functionality here
//                               },
//                               style: TextButton.styleFrom(
//                                 backgroundColor: Colors.orange,
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 6, horizontal: 20),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Buy Now',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSection(String title, String content, BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.8, // 80% of the screen width
//       height: MediaQuery.of(context).size.width * 0.5,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         // border: Border.all(width: 0.1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 6,
//             spreadRadius: 2,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             content,
//             style: const TextStyle(fontSize: 16, height: 1.5),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection2(String title, String content) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 6,
//             spreadRadius: 2,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             content,
//             style: const TextStyle(fontSize: 16, height: 1.5),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPrevalencePercentage(double percentage, BuildContext context) {
//     return Container(
//       // Set container width to 80% of the screen width
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 6,
//             spreadRadius: 2,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.8,
//             child: const Text(
//               "Global Prevalence",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               CircularPercentIndicator(
//                 radius: 60.0,
//                 lineWidth: 40.0,
//                 percent: percentage / 100, // converting percentage to fraction
//                 center: Text(
//                   '${percentage.toStringAsFixed(1)}%',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 progressColor: const Color.fromARGB(255, 65, 164, 68),
//                 backgroundColor: Color.fromARGB(255, 195, 232, 248),
//               ),
//               const SizedBox(width: 20),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.45,
//                 child: Text(
//                   "Approximately 1.3% of the global population experiences mild psoriasis (65% of 2%).",
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTreatmentDuration(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 6,
//             spreadRadius: 2,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.3,
//                 child: const Text(
//                   "Treatment Duration (Months)",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "2 months",
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 5),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const Text(
//                 "Treatment Description",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 width: 200,
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.4,
//                   child: const Text(
//                     "Mild can improve with consistent treatment, but it may take several weeks to months for symptoms to fully improve. The duration depends on the individual and their response to treatment.",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TreatmentDetails extends StatefulWidget {
//   @override
//   _TreatmentDetailsState createState() => _TreatmentDetailsState();
// }

// class _TreatmentDetailsState extends State<TreatmentDetails> {
//   bool _isExpanded = false; // Flag to track whether content is expanded

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 6,
//             spreadRadius: 2,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Treatment: Topical Corticosteroids",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildProductSection(
//               "Hydrocortisone Cream (1%)",
//               ["Cortaid", "Hydrocortisone Cream", "Cortizone-10"],
//               "Apply a thin layer of Hydrocortisone Cream on the affected areas 1-2 times a day (morning and evening).",
//               "Use consistently for 2-4 weeks.",
//               "Do not use for more than 4 weeks without consulting a doctor."),
//           const SizedBox(height: 20),
//           _buildProductSection(
//               "Betamethasone Cream (0.05%)",
//               ["Betnovate", "Betamethasone Cream", "Celestone"],
//               "Apply a thin layer of Betamethasone Cream on the affected areas 1-2 times a day.",
//               "Use consistently for 2-4 weeks.",
//               "Avoid long-term use. Consult a doctor if no improvement after 4 weeks."),
//           const SizedBox(height: 20),

//           // Show additional details if expanded
//           if (_isExpanded) ...[
//             _buildPostTreatmentSection(),
//             const SizedBox(height: 20),
//             _buildPrecautionsSection(),
//             const SizedBox(height: 20),
//             _buildSkinCareTipsSection(),
//           ],

//           // View more button
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _isExpanded = !_isExpanded; // Toggle the expanded state
//               });
//             },
//             child: Text(
//               _isExpanded ? "View Less" : "View More",
//               style: TextStyle(
//                 color: Colors.blueAccent,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductSection(String name, List<String> brandExamples,
//       String application, String duration, String notes) {
//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             name,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text("Brands: ${brandExamples.join(', ')}"),
//           const SizedBox(height: 10),
//           Text("Application: $application"),
//           const SizedBox(height: 10),
//           Text("Duration: $duration"),
//           const SizedBox(height: 10),
//           Text("Notes: $notes"),
//         ],
//       ),
//     );
//   }

//   Widget _buildPostTreatmentSection() {
//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Post Treatment Care",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "Condition Monitoring: After 2-4 weeks of consistent application, take a photo of the affected areas to track progress.",
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "Follow-Up: If symptoms improve, reduce the frequency of application (use every alternate day) under medical advice. If condition does not improve or worsens, consult a dermatologist for alternative treatment.",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPrecautionsSection() {
//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Text(
//         "Precautions: Apply only on the affected areas, do not use on the face or genitals unless prescribed by a doctor.",
//         style: TextStyle(fontSize: 16),
//       ),
//     );
//   }

//   Widget _buildSkinCareTipsSection() {
//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Skin Care Tips",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "• Keep the skin moisturized to prevent dryness. Use fragrance-free, gentle moisturizers.\n"
//             "• Take warm baths instead of hot ones. Hot water can irritate the skin.\n"
//             "• Avoid scrubbing the skin harshly. Pat the skin dry with a towel after bathing.\n"
//             "• Use mild, soap-free cleansers to avoid irritating the skin.\n"
//             "• Apply sunscreen with at least SPF 30 if going out in the sun.",
//             style: TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Dietary Recommendations:",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "What to Eat: \n• Eat foods rich in omega-3 fatty acids like fish (salmon, mackerel) and flaxseeds to help reduce inflammation.\n"
//             "• Include fruits and vegetables rich in antioxidants, such as berries, spinach, and carrots, to support skin health.\n"
//             "• Consume foods rich in vitamin D (like fortified milk, egg yolks, and mushrooms), as vitamin D can help manage psoriasis symptoms.\n"
//             "• Include whole grains and lean proteins in your diet for balanced nutrition.",
//             style: TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "What to Avoid: \n• Avoid processed foods, sugary snacks, and refined carbohydrates as they may trigger inflammation.\n"
//             "• Limit alcohol intake, as alcohol can worsen psoriasis symptoms for some people.\n"
//             "• Avoid smoking, as it can increase the risk of psoriasis flare-ups.\n"
//             "• Stay away from dairy products if they seem to irritate your skin (some individuals find that dairy can trigger flare-ups).",
//             style: TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Lifestyle Recommendations:\n"
//             "• Manage stress through relaxation techniques like yoga, meditation, or deep breathing exercises.\n"
//             "• Get enough sleep (7-8 hours a night) to support immune function and skin healing.\n"
//             "• Exercise regularly to maintain a healthy weight, as obesity can worsen psoriasis.\n"
//             "• Stay hydrated by drinking plenty of water throughout the day.",
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
