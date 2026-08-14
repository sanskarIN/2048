import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

bool isAllowedExternalUri(Uri uri) {
  if (uri.scheme == 'https') {
    return uri.host.isNotEmpty;
  }
  if (uri.scheme == 'mailto') {
    return uri.path.isNotEmpty;
  }
  return false;
}

Future<void> openExternal(BuildContext context, String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null || !isAllowedExternalUri(uri)) {
    _showCopyFallback(
      context,
      value,
      message: 'This link cannot be opened safely.',
    );
    return;
  }

  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException {
    opened = false;
  }

  if (!opened && context.mounted) {
    _showCopyFallback(
      context,
      value,
      message: 'Could not open this link on your device.',
    );
  }
}

void _showCopyFallback(
  BuildContext context,
  String value, {
  required String message,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Copy',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
        },
      ),
    ),
  );
}
