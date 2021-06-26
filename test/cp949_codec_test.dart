import 'dart:typed_data';

// ignore: import_of_legacy_lib' as another;
import 'package:cp949_codec/cp949_codec.dart';
import 'package:test/test.dart';

void main() {
  List<int> beautiful = [0xBE, 0xC6, 0xB8, 0xA7, 0xB4, 0xD9, 0xBF, 0xEE];
  // String unicodeBeauty = "아름다운";

  group('common sense', () {
    test('check host endian', () {
      print(Endian.host == Endian.little);
    });

    test('beauty!', () {
      // print(beautiful);

      Uint8List u8l = Uint8List.fromList(beautiful);
      expect(u8l, equals(beautiful));

      Uint8ClampedList u8cl = Uint8ClampedList.fromList(beautiful);
      expect(u8cl, equals(beautiful));

      Uint16List u16l = Uint16List.fromList(beautiful);
      expect(u16l, equals(beautiful));
    });

    test('123123', () {
      BytesBuilder bytes = BytesBuilder();

      bytes.addByte(0);
      bytes.addByte(0xff);

      Uint8List u8 = bytes.toBytes().buffer.asUint8List();

      ByteData bin = ByteData.sublistView(u8);

      int value = bin.getUint16(0, Endian.little);
      print(value);
    });
  });

  group('this one', () {
    test('decode() converts cp949 byte code units to native String.', () {
      expect(cp949.decode(beautiful), equals("아름다운"));
    });

    test(
        'decodeString() converts broken String of cp949 byte code units to native String.',
        () {
      expect(cp949.decodeString("ÄÁÅÙÃ÷"), equals("컨텐츠"));
    });

    test('encode() converts dart native String to cp949 byte code units.', () {
      expect(cp949.encode("아름다운"), equals(beautiful));
    });

    test(
        'encodeToString() converts dart native String to broken String of cp949 byte code units.',
        () {
      expect(cp949.encodeToString("컨텐츠"), equals("ÄÁÅÙÃ÷"));
    });

    test('Verify encode() and decode() are inverse functions.', () {
      const content = "123 abc !.,/? 春夏秋冬 아름다운 한글..";

      // print(content.codeUnits);

      final Uint8List cp949CodeUnits = cp949.encode(content);

      // print(cp949CodeUnits);

      final String decodedContent = cp949.decode(cp949CodeUnits);

      expect(decodedContent, equals(content));
    });

    test('Verify encodeToString() and decodeString() are inverse functions.',
        () {
      const content = "123 abc !.,/? 春夏秋冬 아름다운 한글..";
      final brokenString = cp949.encodeToString(content);
      final decodedContent = cp949.decodeString(brokenString);

      expect(decodedContent, equals(content));
    });
  });

  /// [https://github.com/golang/text/blob/master/encoding/korean/all_test.go]
  group('golang', () {
    final helloworld = "세계야, 안녕";
    final cp949hw = [
      0xbc,
      0xbc,
      0xb0,
      0xe8,
      0xbe,
      0xdf,
      0x2c,
      0x20,
      0xbe,
      0xc8,
      0xb3,
      0xe7
    ];

    test('helloworld', () {
      var encoded = cp949.encode(helloworld);
      print(encoded);

      expect(encoded, cp949hw);
    });

    test('non repertoire', () {});
  });

  group('single word', () {
    var ga = [0xb0, 0xa1];

    var whi = [0xc0, 0xa7];

    var gakk = [0x81, 0x4a];

    /// korean test
    var unknown = [0xc7, 0xd1, 0xb1, 0xdb, 0xc5, 0xd7, 0xbd, 0xba, 0xc6, 0xae];

    var gaegkk = [0x81, 0x81];

    test('whi', () {
      Uint8List encoded = cp949.encode('위');
      expect(encoded, equals(whi));
    });

    test('gakk', () {
      Uint8List encoded = cp949.encode('갘');
      expect(encoded, equals(gakk));
    });

    test('description123123', () {
      String d = cp949.decode(unknown);
      expect(d, equals('한글테스트'));
    });

    test('2', () {
      var d = cp949.decode(gaegkk);
      expect(d, equals('걖'));
    });

    test('ga', () {
      var d = cp949.decode(ga);
      expect(d, equals('가'));
    });
  });

  // group('jamo', () {
  //   var a = [0xb0, 0x40];
  //
  //   var b = [0xd0, 0xff];
  //   var c = [0xfe, 0xfe];
  //
  //   test('1', () {
  //     var d = cp949.decode(a);
  //     print(d);
  //   });
  //
  //   test('2', () {
  //     var d = cp949.decode(b);
  //     print(d);
  //   });
  //
  //   test('3', () {
  //     var d = cp949.decode(c);
  //     print(d);
  //   });
  // });

  // group('that one', () {
  //   test('decode() converts cp949 byte code units to native String.', () {
  //     expect(another.decode([0xBE, 0xC6, 0xB8, 0xA7, 0xB4, 0xD9, 0xBF, 0xEE]),
  //         equals("아름다운"));
  //   });
  //
  //   test(
  //       'decodeString() converts broken String of cp949 byte code units to native String.',
  //       () {
  //     expect(another.decodeString("ÄÁÅÙÃ÷"), equals("컨텐츠"));
  //   });
  //
  //   test('encode() converts dart native String to cp949 byte code units.', () {
  //     expect(another.encode("아름다운"),
  //         equals([0xBE, 0xC6, 0xB8, 0xA7, 0xB4, 0xD9, 0xbf, 0xee]));
  //   });
  //
  //   test(
  //       'encodeToString() converts dart native String to broken String of cp949 byte code units.',
  //       () {
  //     expect(another.encodeToString("컨텐츠"), equals("ÄÁÅÙÃ÷"));
  //   });
  //
  //   test('Verify encode() and decode() are inverse functions.', () {
  //     const content = "123 abc !.,/? 春夏秋冬 아름다운 한글..";
  //     final cp949CodeUnits = another.encode(content);
  //     final decodedContent = another.decode(cp949CodeUnits);
  //
  //     expect(decodedContent, equals(content));
  //   });
  //
  //   test('Verify encodeToString() and decodeString() are inverse functions.',
  //       () {
  //     const content = "123 abc !.,/? 春夏秋冬 아름다운 한글..";
  //     final brokenString = another.encodeToString(content);
  //     final decodedContent = another.decodeString(brokenString);
  //
  //     expect(decodedContent, equals(content));
  //   });
  // });
}
