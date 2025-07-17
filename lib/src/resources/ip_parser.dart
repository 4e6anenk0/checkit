enum IpType {
  ipv4,
  ipv6;

  @override
  String toString() => name.toUpperCase();
}

extension IpAddressExtensions on IpAddress {
  bool inSubnet(IpSubnet subnet) {
    return subnet.contains(this);
  }
}

class IpSubnet {
  final IpAddress network;
  final int prefixLength;

  IpSubnet._(this.network, this.prefixLength);

  BigInt countOfAddresses() {
    if (network.type == IpType.ipv4) {
      return BigInt.two.pow(32 - prefixLength);
    } else {
      return BigInt.two.pow(128 - prefixLength);
    }
  }

  IpAddress? getBroadcastAddress() {
    if (network.type != IpType.ipv4) {
      return null;
    }

    final totalBits = 32;
    final hostBits = totalBits - prefixLength;
    final base = network.toBigInt();

    final broadcastValue = base | ((BigInt.one << hostBits) - BigInt.one);
    return IpAddress.fromBigInt(network.type, broadcastValue);
  }

  factory IpSubnet.fromCidr(String cidr) {
    final parts = cidr.split('/');
    if (parts.length != 2) {
      throw Exception();
    }

    final ip = IpParser.parse(parts[0]);
    if (ip == null) {
      throw Exception();
    }

    final prefixLength = int.tryParse(parts[1]);
    final maxBits = ip.type == IpType.ipv4 ? 32 : 128;
    if (prefixLength == null || prefixLength < 0 || prefixLength > maxBits) {
      throw Exception();
    }

    final masked = _applyMask(ip, prefixLength);

    return IpSubnet._(masked, prefixLength);
  }

  static IpAddress _applyMask(IpAddress ip, int prefixLength) {
    final totalBits = ip.bytes.length * 8;
    final maskedBytes = List<int>.from(ip.bytes);
    for (int i = 0; i < totalBits; i++) {
      if (i >= prefixLength) {
        final byteIndex = i ~/ 8;
        final bitIndex = 7 - (i % 8);
        maskedBytes[byteIndex] &= ~(1 << bitIndex);
      }
    }
    return IpAddress.fromBytes(ip.type, maskedBytes);
  }

  bool contains(IpAddress other) {
    if (other.type != network.type) return false;
    final otherMasked = _applyMask(other, prefixLength);
    return network == otherMasked;
  }

  @override
  String toString() => '${network.toReadableString()}/$prefixLength';
}

class IpAddress {
  final IpType type;
  final List<int> bytes;

  const IpAddress._(this.type, this.bytes);

  static const int ipv4Length = 4;
  static const int ipv6Length = 16;

  factory IpAddress.fromBytes(IpType type, List<int> bytes) {
    final expectedLength = type == IpType.ipv4 ? ipv4Length : ipv6Length;
    if (bytes.length != expectedLength) {
      throw ArgumentError('Invalid IP byte length');
    }
    return IpAddress._(type, List.unmodifiable(bytes));
  }

  BigInt toBigInt() {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  factory IpAddress.fromBigInt(IpType type, BigInt value) {
    final length = type == IpType.ipv4 ? 4 : 16;
    final bytes = List<int>.filled(length, 0);
    var temp = value;
    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xFF)).toInt();
      temp = temp >> 8;
    }
    return IpAddress.fromBytes(type, bytes);
  }

  IpAddress operator +(int offset) =>
      IpAddress.fromBigInt(type, toBigInt() + BigInt.from(offset));
  IpAddress operator -(int offset) =>
      IpAddress.fromBigInt(type, toBigInt() - BigInt.from(offset));

  int compareTo(IpAddress other) {
    if (type != other.type) {
      throw ArgumentError('Cannot compare IPs of different types');
    }
    return toBigInt().compareTo(other.toBigInt());
  }

  bool operator <(IpAddress other) => compareTo(other) < 0;
  bool operator >(IpAddress other) => compareTo(other) > 0;
  bool operator <=(IpAddress other) => compareTo(other) <= 0;
  bool operator >=(IpAddress other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is IpAddress &&
      type == other.type &&
      bytes.length == other.bytes.length &&
      _listEquals(bytes, other.bytes);

  @override
  int get hashCode => Object.hashAll([type, ...bytes]);

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool isLoopback() {
    if (type == IpType.ipv4) {
      return bytes.length == 4 && bytes[0] == 127;
    }
    if (type == IpType.ipv6) {
      return bytes.length == 16 &&
          bytes.sublist(0, 15).every((b) => b == 0) &&
          bytes[15] == 1;
    }
    return false;
  }

  bool isLinkLocal() {
    if (type == IpType.ipv4 && bytes.length == 4) {
      // 169.254.0.0/16
      return bytes[0] == 169 && bytes[1] == 254;
    } else if (type == IpType.ipv6 && bytes.length == 16) {
      // fe80::/10
      return bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80;
    }
    return false;
  }

  bool isLocalhost() {
    if (type == IpType.ipv4) {
      return bytes[0] == 127 && bytes[1] == 0 && bytes[2] == 0 && bytes[3] == 1;
    }
    if (type == IpType.ipv6) {
      return bytes.length == 16 &&
          bytes.sublist(0, 15).every((b) => b == 0) &&
          bytes[15] == 1;
    }
    return false;
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
