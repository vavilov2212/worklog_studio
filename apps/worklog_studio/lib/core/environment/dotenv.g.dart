// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dotenv.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _DotEnv {
  static const String apiHost = 'https://api.example.com/';

  static const List<int> _enviedkeyjwtSecret = <int>[
    2662471724,
    2038020809,
    1729256870,
    1156002978,
    2084569611,
    2607575215,
    1934240824,
    3624992464,
    2356994600,
    3523953940,
  ];

  static const List<int> _envieddatajwtSecret = <int>[
    2662471782,
    2038020766,
    1729256946,
    1156003069,
    2084569688,
    2607575274,
    1934240891,
    3624992386,
    2356994669,
    3523953984,
  ];

  static final String jwtSecret = String.fromCharCodes(
    List<int>.generate(
      _envieddatajwtSecret.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatajwtSecret[i] ^ _enviedkeyjwtSecret[i]),
  );

  static const List<int> _enviedkeysecureKey = <int>[
    903130211,
    2272552834,
    355195940,
    1846265784,
    564508746,
    2293799549,
    3910431781,
    2790643515,
    3601467616,
    1932133448,
  ];

  static const List<int> _envieddatasecureKey = <int>[
    903130160,
    2272552903,
    355196007,
    1846265837,
    564508696,
    2293799480,
    3910431866,
    2790643568,
    3601467557,
    1932133393,
  ];

  static final String secureKey = String.fromCharCodes(
    List<int>.generate(
      _envieddatasecureKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatasecureKey[i] ^ _enviedkeysecureKey[i]),
  );
}
