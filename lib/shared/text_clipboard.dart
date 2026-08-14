import 'package:flutter/services.dart';

abstract interface class TextClipboard {
  Future<void> writeText(String text);

  Future<String?> readText();
}

class SystemTextClipboard implements TextClipboard {
  const SystemTextClipboard();

  @override
  Future<void> writeText(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Future<String?> readText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
