import 'package:checkit/src/resources/ip_parser.dart';

import 'validator.dart';

abstract class IpValidator {
  static Validator<String> ip({String? error}) => (value, context) {
    final ip = context.resources.getOrCreate('ip', () => IpParser.parse(value));

    if (ip != null) {
      return (true, null);
    }
    return (false, error ?? context.errors.ipErrors.ip(value));
  };

  static Validator<String> v4({String? error}) => (value, context) {
    final ip = context.resources.tryGet<IpAddress>('ip');
    if (ip == null) return (false, 'ip address not found in context');
    if (ip.type == IpType.ipv4) {
      return (true, null);
    }
    return (false, error ?? context.errors.ipErrors.v4());
  };

  static Validator<String> v6({String? error}) => (value, context) {
    final ip = context.resources.tryGet<IpAddress>('ip');
    if (ip == null) return (false, 'ip address not found in context');
    if (ip.type == IpType.ipv6) {
      return (true, null);
    }
    return (false, error ?? context.errors.ipErrors.v6());
  };
}
