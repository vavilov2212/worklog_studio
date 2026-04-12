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
    1745781289,
    892202835,
    981990449,
    4140666213,
    1527903612,
    485362405,
    2859977609,
    585034419,
    1881882016,
    3204821194,
  ];

  static const List<int> _envieddatajwtSecret = <int>[
    1745781347,
    892202756,
    981990501,
    4140666170,
    1527903535,
    485362336,
    2859977674,
    585034465,
    1881882085,
    3204821150,
  ];

  static final String jwtSecret = String.fromCharCodes(
    List<int>.generate(
      _envieddatajwtSecret.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatajwtSecret[i] ^ _enviedkeyjwtSecret[i]),
  );

  static const List<int> _enviedkeysecureKey = <int>[
    787373770,
    1760564420,
    3363680058,
    608636348,
    3230118396,
    2527934524,
    647508836,
    2230250277,
    402430712,
    1556867555,
  ];

  static const List<int> _envieddatasecureKey = <int>[
    787373721,
    1760564353,
    3363680121,
    608636393,
    3230118318,
    2527934585,
    647508795,
    2230250350,
    402430653,
    1556867514,
  ];

  static final String secureKey = String.fromCharCodes(
    List<int>.generate(
      _envieddatasecureKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatasecureKey[i] ^ _enviedkeysecureKey[i]),
  );
}
