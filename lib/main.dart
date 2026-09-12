// import 'package:flutter/material.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:O2ISkinSense/Signup/onboarding_view.dart';

// import 'package:O2ISkinSense/Signup/LoginPage.dart';
// import 'package:O2ISkinSense/BottomPages/BottomNav.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final prefs = await SharedPreferences.getInstance();
//   final onboarding = prefs.getBool("onboarding") ?? false;
//   final jwtToken = prefs.getString("jwtToken");

//   runApp(MyApp(onboarding: onboarding, jwtToken: jwtToken));
// }

// class MyApp extends StatelessWidget {
//   final bool onboarding;
//   final String? jwtToken;

//   const MyApp({super.key, this.onboarding = false, this.jwtToken});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'O2I SkinSense',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: onboarding
//           ? (jwtToken != null && jwtToken!.isNotEmpty
//               ? MyHomePage() // Navigate to the home page if token exists
//               : LoginPage()) // Otherwise, navigate to the login page
//           : const OnboardingView(),
//       builder: (context, child) {
//         return ZegoUIKitPrebuiltCallMiniOverlayPage(
//           contextQuery: () => context, // Pass current context
//           // child: child!,
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Signup/onboarding_view.dart';
import 'package:O2ISkinSense/Signup/LoginPage.dart';
import 'package:O2ISkinSense/BottomPages/BottomNav.dart';
import 'package:O2ISkinSense/Doctor/DoctorBottomNav.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding") ?? false;
  final jwtToken = prefs.getString("jwtToken");
  final userRole = prefs.getString("roles") ?? "ROLE_NORMAL";

  runApp(MyApp(
    onboarding: onboarding, 
    jwtToken: jwtToken,
    userRole: userRole,
  ));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  final String? jwtToken;
  final String userRole;

  const MyApp({
    super.key, 
    this.onboarding = false, 
    this.jwtToken,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onboarding
          ? (jwtToken != null ? _getHomePageForRole() : LoginPage())
          : const OnboardingView(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            Positioned.fill(
              child: ZegoUIKitPrebuiltCallMiniOverlayPage(
                contextQuery: () =>
                    Navigator.of(context, rootNavigator: true).context,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getHomePageForRole() {
    print("Determining home page for role: $userRole");
    if (userRole == "ROLE_DOCTOR") {
      return DoctorBottomNav();
    } else {
      return MyHomePage();
    }
  }
}
