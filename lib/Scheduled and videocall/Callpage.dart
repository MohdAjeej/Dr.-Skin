// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// class CallScreen extends StatelessWidget {
//   final String callID;
//   final String userID;
//   final String userName;

//   const CallScreen({
//     super.key,
//     required this.callID,
//     required this.userID,
//     required this.userName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: ZegoUIKitPrebuiltCall(
//       appID:
//           326028385, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
//       appSign:
//           "47b35d93725aed8a436f18111d9ca7a94835e295ecd219856c7c9ad59a7b6f3c", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
//       userID: userID,
//       userName: userName,
//       callID: callID,
//       // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
//       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//     ));
//   }
// }
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;

  const CallScreen({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 1757124275, // Your ZEGOCLOUD appID
        appSign:
            "7c061a38a8174f60cbac4ee55dc3340c216d46ef6b63b157f8ee89de3cd65337", // Your ZEGOCLOUD appSign
        userID: userID,
        userName: userName,
        callID: callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          ..topMenuBarConfig.isVisible = true
          ..bottomMenuBarConfig.isVisible = true
          ..layout = ZegoLayout.pictureInPicture() // ✅ Enable PiP Mode
          ..topMenuBarConfig.buttons.add(
                ZegoMenuBarButtonName.minimizingButton, // ✅ Add minimize button
              ),
      ),
    );
  }
}
