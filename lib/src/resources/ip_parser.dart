enum IpType {
  ipv4,
  ipv6;

  @override
  String toString() => name.toUpperCase();
}

class IpAddress {
  final IpType type;
  final List<int> bytes;

  const IpAddress._(this.type, this.bytes);

  static const int ipv4Length = 4;
  static const int ipv6Length = 16;

  factory IpAddress.fromBytes(IpType type, List<int> bytes) {
    if ((type == IpType.ipv4 && bytes.length != ipv4Length) ||
        (type == IpType.ipv6 && bytes.length != ipv6Length)) {
      throw ArgumentError('Invalid byte length for $type: ${bytes.length}');
    }
    return IpAddress._(type, List.unmodifiable(bytes));
  }

  String toReadableString() {
    if (type == IpType.ipv4) {
      return bytes.join('.');
    } else {
      final buffer = StringBuffer();
      for (var i = 0; i < 16; i += 2) {
        final part = (bytes[i] << 8) | bytes[i + 1];
        buffer.write(part.toRadixString(16));
        if (i < 14) buffer.write(':');
      }
      return buffer.toString();
    }
  }

  @override
  String toString() => toReadableString();

  @override
  bool operator ==(Object other) =>
      other is IpAddress &&
      other.type == type &&
      _listEquals(other.bytes, bytes);

  @override
  int get hashCode => Object.hashAll([type, ...bytes]);

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class IpParser {
  /// Tries to parse [input] as an IP address (IPv4 or IPv6).
  /// Returns null if invalid.
  static IpAddress? parse(String input) {
    final ipv4 = _parseIPv4(input);
    if (ipv4 != null) return ipv4;

    final ipv6 = _parseIPv6(input);
    if (ipv6 != null) return ipv6;

    return null;
  }

  static IpAddress? _parseIPv4(String input) {
    final parts = input.split('.');
    if (parts.length != 4) return null;

    final bytes = <int>[];
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return null;
      if (part != n.toString()) return null; // exclude '01', '001' (RFC 6943)
      bytes.add(n);
    }
    return IpAddress.fromBytes(IpType.ipv4, bytes);
  }

  static IpAddress? _parseIPv6(String input) {
    // Remove zone index if present
    final zoneIndexSplit = input.split('%');
    final address = zoneIndexSplit.first;

    // Handle "::" compression
    final segments = address.split('::');
    List<String> parts = [];

    if (segments.length > 2) return null;

    if (segments.length == 2) {
      final left = segments[0].isNotEmpty ? segments[0].split(':') : <String>[];
      final right =
          segments[1].isNotEmpty ? segments[1].split(':') : <String>[];
      final missing = 8 - (left.length + right.length);
      if (missing < 0) return null;
      parts = [...left, ...List.filled(missing, '0'), ...right];
    } else {
      parts = address.split(':');
      if (parts.length != 8) return null;
    }

    final bytes = <int>[];
    for (final part in parts) {
      if (part.length > 4 || part.isEmpty) return null;
      final n = int.tryParse(part, radix: 16);
      if (n == null || n < 0 || n > 0xFFFF) return null;
      bytes.add((n >> 8) & 0xFF);
      bytes.add(n & 0xFF);
    }

    return IpAddress.fromBytes(IpType.ipv6, bytes);
  }
}

void main() {
  final inputs = [
    '192.168.0.1',
    '2001:db8::1',
    '::1',
    '::ffff:192.168.1.1',
    'invalid::ip',
    '::',
    '',
  ];

  for (final ip in inputs) {
    final parsed = IpParser.parse(ip);
    print('$ip => ${parsed?.toReadableString() ?? 'Invalid'}');
    print('$ip => ${parsed?.type ?? 'Invalid'}');

    print(parsed != null ? parsed.bytes[0].toRadixString(2) : 'Invalid');
  }
}
