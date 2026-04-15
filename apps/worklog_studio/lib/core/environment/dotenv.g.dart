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
    3765458098,
    4158841344,
    4184436198,
    416399909,
    467166557,
    4196399869,
    1820334300,
    1192725856,
    3161771978,
    3475049242,
  ];

  static const List<int> _envieddatajwtSecret = <int>[
    3765458168,
    4158841431,
    4184436146,
    416399994,
    467166478,
    4196399800,
    1820334239,
    1192725810,
    3161771919,
    3475049294,
  ];

  static final String jwtSecret = String.fromCharCodes(
    List<int>.generate(
      _envieddatajwtSecret.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatajwtSecret[i] ^ _enviedkeyjwtSecret[i]),
  );

  static const List<int> _enviedkeysecureKey = <int>[
    2785799942,
    3676267394,
    3994246775,
    1146108260,
    1711299634,
    286031940,
    2037245853,
    1304527837,
    1679331498,
    3838217314,
  ];

  static const List<int> _envieddatasecureKey = <int>[
    2785800021,
    3676267463,
    3994246708,
    1146108209,
    1711299680,
    286031873,
    2037245890,
    1304527766,
    1679331567,
    3838217275,
  ];

  static final String secureKey = String.fromCharCodes(
    List<int>.generate(
      _envieddatasecureKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatasecureKey[i] ^ _enviedkeysecureKey[i]),
  );
}
