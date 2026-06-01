import 'google_sign_in_button_stub.dart'
    if (dart.library.html) 'google_sign_in_button_web.dart'
    as platform_button;
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return platform_button.buildGoogleSignInButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
