import '../resources/ip_resource.dart';
import 'validator.dart';

abstract class SubnetValidator {
  static Validator<String> subnet(String cidr, {String? error}) => (
    value,
    context,
  ) {
    final subnet = context.resources.getOrCreate(
      'subnetResource',
      () => SubnetResource.fromString(cidr),
    );

    if (subnet != null) {
      return (true, null);
    }
    return (false, error ?? context.errors.ipErrors.subnet(cidr));
  };

  static Validator<String> contains(String ip, {String? error}) => (
    value,
    context,
  ) {
    final subnet = context.resources.tryGet<SubnetResource>('subnetResource');
    if (subnet == null) return (false, 'subnet resource not found in context');

    if (subnet.contains(ip)) {
      return (true, null);
    }
    return (false, error ?? context.errors.ipErrors.contains(ip));
  };
}
