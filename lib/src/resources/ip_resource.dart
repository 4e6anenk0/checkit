import 'package:checkit/src/resources/ip_parser.dart';

class IpResource {
  final IpAddress ip;

  const IpResource._(this.ip);

  static IpResource? fromString(String address) {
    final ip = IpParser.parse(address);
    return ip != null ? IpResource._(ip) : null;
  }

  bool get isIpv6 => ip.type == IpType.ipv6;
  bool get isIpv4 => ip.type == IpType.ipv4;
  bool get isLoopback => ip.isLoopback();
  bool get isLinkLocal => ip.isLinkLocal();
  bool get isLocalhost => ip.isLocalhost();

  bool inSubnet(IpSubnet subnet) {
    return ip.inSubnet(subnet);
  }

  bool inRange(String startIp, String endIp) {
    final start = IpParser.parse(startIp);
    final end = IpParser.parse(endIp);

    if (start == null ||
        end == null ||
        start.type != ip.type ||
        end.type != ip.type) {
      return false;
    }

    return ip >= start && ip <= end;
  }

  @override
  String toString() => ip.toReadableString();
}

class SubnetResource {
  final IpSubnet subnet;

  const SubnetResource._(this.subnet);

  static SubnetResource? fromString(String cidr) {
    try {
      return SubnetResource._(IpSubnet.fromCidr(cidr));
    } catch (e) {
      return null;
    }
  }

  bool contains(String ip) {
    final parsedIp = IpParser.parse(ip);
    if (parsedIp != null) {
      return subnet.contains(parsedIp);
    }
    return false;
  }
}
