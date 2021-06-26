import 'package:cp949_codec/cp949_codec.dart';

void main() {
  /// cp949.decode();
  List<int> beautiful = [0xBE, 0xC6, 0xB8, 0xA7, 0xB4, 0xD9, 0xBF, 0xEE];

  print(cp949.decode(beautiful)); // 아름다운

  /// cp949.encode();
  final helloworld = "세계야, 안녕";
  print(cp949.encode(
      helloworld)); // [188, 188, 176, 232, 190, 223, 44, 32, 190, 200, 179, 231]

  /// cp949.decodeString
  final brokenString = "ÇÁ·Î±×·¡¹Ö¾ð¾î·Ð";
  final decodedString = cp949.decodeString(brokenString);
  print(decodedString); // 프로그래밍 언어론

  /// cp949.encodeToString
  final encodedString = cp949.encodeToString('컨텐츠');
  print(encodedString); // ÄÁÅÙÃ÷
}
