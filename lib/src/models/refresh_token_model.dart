import 'dart:convert';

class RefreshTokenModel {
  const RefreshTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userJson,
    required this.needFirstAccess,
  });

  final String? accessToken;
  final String? refreshToken;
  final String? userJson;
  final bool needFirstAccess;

  bool hasToken() => accessToken != null && accessToken!.isNotEmpty;

  bool hasUserJson() => userJson != null && userJson!.isNotEmpty;

  bool isTokenExpired() {
    if (!hasToken()) return true;
    try {
      final parts = accessToken!.split('.');
      if (parts.length != 3) return true;

      final payload = _decodeBase64(parts[1]);
      final Map<String, dynamic> json =
          jsonDecode(payload) as Map<String, dynamic>;
      final exp = json['exp'];

      if (exp is int) {
        final expiration = DateTime.fromMillisecondsSinceEpoch(
          exp * 1000,
          isUtc: true,
        );
        return DateTime.now().toUtc().isAfter(expiration);
      }

      return true;
    } catch (_) {
      return true;
    }
  }

  RefreshTokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? userJson,
    bool? needFirstAccess,
  }) {
    return RefreshTokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userJson: userJson ?? this.userJson,
      needFirstAccess: needFirstAccess ?? this.needFirstAccess,
    );
  }

  String _decodeBase64(String str) {
    final normalized = base64Url.normalize(str);
    final decodedBytes = base64Url.decode(normalized);
    return utf8.decode(decodedBytes);
  }
}

