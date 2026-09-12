// import 'dart:io';
// import 'package:flutter/material.dart';

// class DiagnosePageAfterAPi extends StatelessWidget {
//   final File image;
//   final Map<String, dynamic> result;

//   DiagnosePageAfterAPi({required this.image, required this.result});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Diagnosis Result'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Image.file(image, height: 200),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Diagnosis Result:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             result['error'] != null
//                 ? Text(
//                     result['error'],
//                     style: TextStyle(fontSize: 16, color: Colors.red),
//                   )
//                 : Text(
//                     result['predictions'] != null
//                         ? result['predictions'][0]['class']
//                         : 'No result available',
//                     style: TextStyle(fontSize: 16),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
