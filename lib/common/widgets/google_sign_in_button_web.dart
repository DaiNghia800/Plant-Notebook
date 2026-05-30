import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget buildGoogleSignInButton({
  required VoidCallback onPressed,
  required Widget child,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SizedBox(
        height: 52,
        width: constraints.maxWidth,
        child: web.renderButton(
          configuration: web.GSIButtonConfiguration(
            type: web.GSIButtonType.standard,
            shape: web.GSIButtonShape.pill,
            theme: web.GSIButtonTheme.outline,
            text: web.GSIButtonText.signinWith,
            size: web.GSIButtonSize.large,
            minimumWidth: constraints.maxWidth,
          ),
        ),
      );
    },
  );
}
