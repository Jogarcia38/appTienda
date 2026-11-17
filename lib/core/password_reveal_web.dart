import 'dart:html' as html;

void hideNativePasswordReveal() {
  if (html.document.getElementById('hide-password-reveal') != null) return;

  final style = html.StyleElement()
    ..id = 'hide-password-reveal'
    ..text = '''
      input::-ms-reveal,
      input::-ms-clear {
        display: none !important;
        width: 0 !important;
        height: 0 !important;
      }
    ''';
  html.document.head?.append(style);
}
