# cp949_codec

null-safety cp949 decoding/encoding

## Usage

[cp949](https://github.com/jjangga0214/dart-cp949) 플러그인의 설명을 참조하세요.
- cp949.decode()
- cp949.encode()
- cp949.decodeString()
- cp949.encodeToString()

## 기존 cp949 플러그인의 메소드

기존 [cp949](https://github.com/jjangga0214/dart-cp949) 플러그인의 사용법을 그대로 사용할 수 있습니다.

## 기존 플러그인에서 개선점

다트의 int는 8바이트 자료형입니다.
cp949는 2바이트만 있으면 되기 때문에, BytesBuilder를 이용해서 메모리 소모를 줄였습니다.

단, host endian이 Little Endian인 경우에만 제대로 동작합니다.

## 기존 다트의 문법

dart:convert 에 있는 latin1, utf8 등에 쓰이는
Encoding 프로토콜을 사용합니다.

Encoder와 Decoder는 Converter를 사용합니다.

# PR은 언제든지 환영합니다!