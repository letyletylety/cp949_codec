library cp949_codec;

import 'dart:convert';
import 'dart:typed_data';

import 'cp949/cp949table.dart';

/// An instance of the default implementation of the Latin1Codec.
const CP949Codec cp949 = CP949Codec();

/// characters below RuneSelf are represented as themselves in a single byte.
const runeSelf = 0x80;

/// codec for cp949 encoding/decoding
class CP949Codec extends Encoding {
  final bool _allowInvalid;

  /// Instantiates a new CP949Codec.
  /// If allowInvalid is true, the decode method and the converter returned by decoder
  /// will default to allowing invalid values. Invalid values are decoded into
  /// the Unicode Replacement character (U+FFFD).
  /// Calls to the decode method can override this default.
  const CP949Codec({bool allowInvalid = false}) : _allowInvalid = allowInvalid;

  /// cp949 is not official [IANA charset](https://www.iana.org/assignments/character-sets/character-sets.xhtml).
  /// cp949 is just extended version of euc-kr.
  /// euc-kr is official charset.
  /// So, I write down euc-kr here.
  /// but, this class has full encoding/decoding support for cp949 charset.
  @override
  String get name => "euc-kr";

  /// cp949 charset needs only 2byte to represent a letter,
  Uint8List encode(String source) => encoder.convert(source);

  String decode(List<int> bytes, {bool? allowInvalid}) {
    Uint8List bytes8 = Uint8List.fromList(bytes);

    if (allowInvalid ?? _allowInvalid) {
      return const CP949Decoder(allowInvalid: true).convert(bytes8);
    } else {
      return const CP949Decoder(allowInvalid: false).convert(bytes8);
    }
  }

  /// CP949 (EUC-KR) byte 배열을 유니코드 기반으로 잘못 해석하여 깨져 보이는 String 을 받아 변환해 제대로 리턴합니다.
  /// 다트에서 읽을 수 없는 cp949로 인코딩된 깨진 문자를 유니코드로 복원합니다.
  String decodeString(String brokenString) => decoder.convert(
        Uint8List.fromList(brokenString.codeUnits),
      );

  /// CP949 (EUC-KR) byte 배열을 유니코드 기반으로 잘못 해석하여 깨져 보이는 String 을 리턴합니다.
  /// 이 리턴값은 다트에서는 읽을 수 없습니다.
  String encodeToString(String codeUnits) =>
      String.fromCharCodes(encoder.convert(codeUnits).buffer.asUint8List());

  CP949Encoder get encoder => const CP949Encoder();

  /// Returns the decoder of this, converting from List<int> to String.
  /// It may be stateful and should not be reused.
  CP949Decoder get decoder => _allowInvalid
      ? const CP949Decoder(allowInvalid: true)
      : const CP949Decoder(allowInvalid: false);
}

/// This class converts cp949 bytes (lists of unsigned 16-bit integers) to a string.
/// dart string = 16bit code
class CP949Decoder extends Converter<Uint8List, String> {
  const CP949Decoder({required bool allowInvalid});

  @override
  String convert(Uint8List bytes, [int start = 0, int? end]) {
    final int bytesLength = bytes.length;
    end = RangeError.checkValidRange(start, end, bytesLength);

    if (Endian.host != Endian.little) {
      throw FormatException("host endian is not little");
    }

    BytesBuilder builder = BytesBuilder();

    int? unicode;

    for (int i = start; i < bytesLength;) {
      // When 1 byte becomes 1 cp949 code
      if (0x00 <= bytes[i] && bytes[i] <= 0x7F) {
        unicode = cp949ToUnicodeCodeMap[bytes[i]];

        if (unicode == null) {
          throw FormatException(
              'out of unicode table : ${bytes[i]} is Invalid code unit of CP949. It has to be (>=0x00 <=0x7F) || (>=0x8141 <=0xFDFE).');
        }

        // little endian
        builder.addByte(unicode);
        builder.addByte(0);
        i = i + 1;
      } else {
        // When 2 bytes become 1 cp949 code
        int cp949Code;
        if (i + 1 == bytesLength) {
          cp949Code = bytes[i] << 8;
        } else {
          cp949Code = (bytes[i] << 8) + bytes[i + 1];
        }

        // valid range
        if (0x8141 <= cp949Code && cp949Code <= 0xFDFE) {
          unicode = cp949ToUnicodeCodeMap[cp949Code];

          if (unicode == null) {
            throw FormatException(
                'out of unicode table : ${bytes[i]} is Invalid code unit of CP949. It has to be (>=0x00 <=0x7F) || (>=0x8141 <=0xFDFE).');
          }

          // little endian
          builder.addByte(unicode);
          builder.addByte(unicode >> 8);
        } else {
          throw FormatException(
              '${bytes[i]} is Invalid code unit of CP949. It has to be (>=0x00 <=0x7F) || (>=0x8141 <=0xFDFE).');
        }
        i = i + 2;
      }
    }
    // print(builder.toBytes());
    // print(builder.toBytes().buffer.asUint16List());
    // print("아름다운".codeUnits);

    // dart string use only 16bit charCodes
    return String.fromCharCodes(builder.toBytes().buffer.asUint16List());
  }
}

/// This class converts cp949 bytes (lists of unsigned 16-bit integers) to a string.
/// Dart does not support non-unicode encoding.
/// Thus, the return value has to be raw byte array of CP949.
class CP949Encoder extends Converter<String, Uint8List> {
  const CP949Encoder();

  /// Dart does not support non-unicode encoding.
  /// Thus, the return value has to be raw byte array of CP949.
  @override
  Uint8List convert(String string, [int start = 0, int? end]) {
    int stringLength = string.codeUnits.length;
    end = RangeError.checkValidRange(start, end, stringLength);

    if (start == end) return Uint8List(0);

    // 2byte
    BytesBuilder cp949CodeUnits = BytesBuilder();

    // int i = 0;

    for (int unicode in string.codeUnits) {
      final cp949Code = unicodeToCp949CodeMap[unicode];

      if (cp949Code == null) {
        throw FormatException("the code map for $unicode is null");
      }

      final firstByte = cp949Code >> 8;
      final secondByte = cp949Code - (firstByte << 8);

      // 2 byte
      if (firstByte != 0) {
        cp949CodeUnits.addByte(firstByte);
      }
      cp949CodeUnits.addByte(secondByte);
      // cp949codeUnits[i] = secondByte;
      // i = i + 1;
    }

    return cp949CodeUnits.toBytes();
  }
}
