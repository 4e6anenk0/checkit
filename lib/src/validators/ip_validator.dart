import 'package:checkit/src/resources/ip_parser.dart';
import 'package:checkit/src/resources/ip_resource.dart';

import 'validator.dart';

abstract class IpValidator {
  static Validator<String> ip({String? error}) => (value, context) {
        final ip = context.resources.getOrCreate(
          value,
          () => IpResource.fromString(value),
          temp: !context.usePermanentCache,
        );

        if (ip != null) {
          return (true, null);
        }
        return (false, error ?? context.errors.ipErrors.ip(value));
      };

  static Validator<String> v4({String? error}) => (value, context) {
        final ip = context.resources.tryGet<IpResource>(
          value,
          temp: !context.usePermanentCache,
        );
        if (ip == null) return (false, 'ip resource not found in context');
        if (ip.isIpv4) {
          return (true, null);
        }
        return (false, error ?? context.errors.ipErrors.v4());
      };

  static Validator<String> v6({String? error}) => (value, context) {
        final ip = context.resources.tryGet<IpResource>(
          value,
          temp: !context.usePermanentCache,
        );
        if (ip == null) return (false, 'ip resource not found in context');
        if (ip.isIpv6) {
          return (true, null);
        }
        return (false, error ?? context.errors.ipErrors.v6());
      };

  static Validator<String> loopback({String? error}) => (value, context) {
        final ip = context.resources.tryGet<IpResource>(
          value,
          temp: !context.usePermanentCache,
        );
        if (ip == null) return (false, 'ip resource not found in context');
        if (ip.isLoopback) {
          return (true, null);
        }
        return (false, error ?? context.errors.ipErrors.loopback());
      };

  static Validator<String> localhost({String? error}) => (value, context) {
        final ip = context.resources.tryGet<IpResource>(
          value,
          temp: !context.usePermanentCache,
        );
        if (ip == null) return (false, 'ip resource not found in context');
        if (ip.isLocalhost) {
          return (true, null);
        }
        return (false, error ?? context.errors.ipErrors.localhost());
      };

  static Validator<String> linkLocal({String? error}) => (value, context) {
        final ip = context.resources.tryGet<IpResource>(
          value,
          temp: !context.usePermanentCache,
        );
        if (ip == null) return (false, 'ip resource not found in context');
        if (ip.isLinkLocal) {
          return (true, null);
        }
        return (false, error ?? context.errors.ipErrors.linkLocal());
      };

  static Validator<String> range(
    String startIp,
    String endIp, {
    String? error,
  }) =>
      (value, context) {
        final ip = context.resources.tryGet<IpResource>(
          value,
          temp: !context.usePermanentCache,
        );
        if (ip == null) return (false, 'ip resource not found in context');
        if (ip.inRange(startIp, endIp)) {
          return (true, null);
        }
        return (false, error ?? context.errors.ipErrors.range(startIp, endIp));
      };

  static Validator<String> inSubnet(String cidr, {String? error}) => (
        value,
        context,
      ) {
        final ip = context.resources.tryGet<IpResource>(
          value,
          temp: !context.usePermanentCache,
        );
        if (ip == null) return (false, 'ip resource not found in context');
        try {
          final subnet = IpSubnet.fromCidr(cidr);
          if (ip.inSubnet(subnet)) {
            return (true, null);
          }
          return (false, error ?? context.errors.ipErrors.inSubnet(cidr));
        } catch (e) {
          return (false, 'cant parse subnet');
        }
      };
}
