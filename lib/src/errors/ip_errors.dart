abstract class IpCheckitErrorsBase {
  const IpCheckitErrorsBase();
  ip(String address);
  v4();
  v6();
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
}
