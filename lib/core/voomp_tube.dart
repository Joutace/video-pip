import 'dart:convert';

const String _salt = '#123\$ABCD';

Map<String, dynamic> decodeVsl(String data) {
  final myDecipher = _decipher(_salt, data);
  return jsonDecode(myDecipher);
}

List<int> _textToChars(String text) => text.codeUnits;

int _applySaltToChar(int code, List<int> saltChars) =>
    saltChars.reduce((a, b) => a ^ b) ^ code;

String _decipher(String salt, String encoded) {
  final saltChars = _textToChars(salt);
  final hexChars = RegExp(r'.{1,2}')
      .allMatches(encoded)
      .map((match) => match.group(0))
      .toList();
  final decodedChars = hexChars
      .map((hex) => int.parse(hex!, radix: 16))
      .map((code) => _applySaltToChar(code, saltChars))
      .map((charCode) => String.fromCharCode(charCode))
      .join('');
  return decodedChars;
}

//Just for test
// var source =
//     '481146415f1109115b47474340091c1c4444441d4a5c46474651561d505c5e1c445247505b0c450e0244047c547a7e7e615007111f11475b565e56110911435f5247555c415e111f11505241414a7c5d110955525f40564e';

// void main() {
//   var result = decodeVsl(source);
//   // ignore: avoid_print
//   print(result);
// }
