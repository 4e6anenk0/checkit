abstract class IpCheckitErrorsBase {
  const IpCheckitErrorsBase();
  ip(String address);
  v4();
  v6();
  loopback();
  localhost();
  linkLocal();
  range(String startIp, String endIp);
  inSubnet(String cidr);
  contains(String ip);
  subnet(String cidr);
}

class IpCheckitErrors extends IpCheckitErrorsBase {
  const IpCheckitErrors();

  @override
  String ip(String address) =>
      'The provided IP address "$address" is invalid. Please ensure it follows a standard IPv4 or IPv6 format.';

  @override
  String v4() =>
      'This is not a valid IPv4 address. An IPv4 address should consist of four numbers (0-255) separated by dots (e.g., 192.168.1.1).';

  @override
  String v6() =>
      'This is not a valid IPv6 address. An IPv6 address is a hexadecimal string separated by colons (e.g., 2001:0db8:85a3:0000:0000:8a2e:0370:7334).';

  @override
  inSubnet(String cidr) =>
      'The provided CIDR "$cidr" is invalid or the IP address is not within this subnet. Please ensure the CIDR is correctly formatted (e.g., 192.168.1.0/24) and the IP is part of it.';

  @override
  linkLocal() =>
      'This IP address is not a valid link-local address. Link-local addresses are typically used for local network communication without a router.';

  @override
  localhost() =>
      'This IP address is not a valid localhost address. Localhost refers to the current device, commonly 127.0.0.1 for IPv4 or ::1 for IPv6.';

  @override
  loopback() =>
      'This IP address is not a valid loopback address. Loopback addresses are used to test network software on the local machine.';

  @override
  range(String startIp, String endIp) =>
      'The provided IP range "$startIp - $endIp" is invalid. Please ensure both IP addresses are valid and the start IP is not greater than the end IP.';

  @override
  contains(String ip) =>
      'The provided subnet does not contain the IP address "$ip". Please ensure the IP address falls within the specified network range.';

  @override
  subnet(String cidr) =>
      'The provided CIDR "$cidr" is an invalid subnet. A valid CIDR should follow the format of an IP address followed by a slash and a prefix length (e.g., 192.168.1.0/24 or 2001:db8::/32).';
}
