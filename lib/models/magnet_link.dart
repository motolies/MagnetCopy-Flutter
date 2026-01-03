class MagnetLink {
  final String uri;
  final DateTime addedAt;

  MagnetLink({
    required this.uri,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  String get displayName {
    final dnMatch = RegExp(r'dn=([^&]+)').firstMatch(uri);
    if (dnMatch != null) {
      return Uri.decodeComponent(dnMatch.group(1)!);
    }

    final xtMatch = RegExp(r'xt=urn:btih:([^&]+)').firstMatch(uri);
    if (xtMatch != null) {
      return xtMatch.group(1)!.substring(0, 8).toUpperCase();
    }

    return uri.length > 50 ? '${uri.substring(0, 50)}...' : uri;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MagnetLink && other.uri == uri;
  }

  @override
  int get hashCode => uri.hashCode;
}
