// import 'dart:convert';
// import 'package:O2ISkinSense/Ztherspages/BookedDetailsPage.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class PaymentPage extends StatefulWidget {
//   final int userId;
//   final int doctorId;
//   final String slotTime;

//   const PaymentPage(
//       {Key? key,
//       required this.userId,
//       required this.doctorId,
//       required this.slotTime})
//       : super(key: key);

//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   late Razorpay _razorpay;
//   final String apiUrl = "http://142.93.221.34:7078/api/appointments/book";
//   final String razorpayKey = "rzp_test_ylWSg3ZmhzAKID";
//   double charges = 0;
//   String razorpayOrderId = "";
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   Future<void> bookAppointment() async {
//     setState(() => isLoading = true);

//     var url = Uri.parse(
//         "$apiUrl?userId=${widget.userId}&doctorId=${widget.doctorId}&slotTime=${Uri.encodeComponent(widget.slotTime)}");

//     try {
//       var response = await http.post(url);
//       print("sdfgdfhfg ${response.body}");
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);

//         if (data.containsKey("charges") &&
//             data.containsKey("razorpayOrderId")) {
//           setState(() {
//             charges = data["charges"];
//             razorpayOrderId = data["razorpayOrderId"];
//           });

//           startPayment();
//         } else {
//           _showError("Invalid response from server.");
//         }
//       } else {
//         _showError("Failed to book appointment. Try again.");
//       }
//     } catch (e) {
//       _showError("Error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void startPayment() {
//     if (charges <= 0 || razorpayOrderId.isEmpty) {
//       _showError("Invalid payment details. Try again.");
//       return;
//     }

//     var options = {
//       'key': razorpayKey,
//       'amount': (charges * 100).toInt(),
//       'order_id': razorpayOrderId,
//       'name': 'Doctor Appointment',
//       'description': 'Consultation Charges',
//       'prefill': {'contact': '9999999999', 'email': 'test@example.com'},
//       'theme': {'color': '#F37254'}
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       _showError("Payment failed: $e");
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     print(
//         "Payment Success Response: ${response.paymentId}, ${response.orderId}, ${response.signature}");

//     // API URL
//     String apiUrl = "http://142.93.221.34:7078/api/allorders/paymentCallback";

//     // API Call
//     try {
//       final res = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/x-www-form-urlencoded",
//         },
//         body: {
//           "razorpay_order_id": response.orderId,
//         },
//       );

//       if (res.statusCode == 200) {
//         print("fghnfjhgjkmhgkhjk success");
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Appointment booked successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Navigate to booked details page
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => BookedDetailsPage(
//               paymentId: response.paymentId ?? "N/A",
//               orderId: response.orderId ?? "N/A",
//               slotTime: widget.slotTime,
//               amount: charges,
//             ),
//           ),
//         );
//       } else {
//         print("fghnfjhgjkmhgkhjk fail");
//         // Show error if API fails
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Payment confirmed, but booking failed!"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error calling API: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("An error occurred! Please try again."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//   // void _handlePaymentSuccess(PaymentSuccessResponse response) {
//   //   print(
//   //       "Payment Success Response: ${response.paymentId}, ${response.orderId}, ${response.signature}");

//   //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //     content: Text("Payment Successful!"),
//   //     backgroundColor: Colors.green,
//   //   ));
//   // }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     _showError("Payment Failed! Reason: ${response.message}");
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("External Wallet Used: ${response.walletName}");
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//       backgroundColor: Colors.red,
//     ));
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Payment")),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator()
//             : ElevatedButton(
//                 onPressed: bookAppointment,
//                 child: Text("Book & Pay"),
//               ),
//       ),
//     );
//   }
// }
