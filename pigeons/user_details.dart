import 'package:pigeon/pigeon.dart';

class UserDetails {
  String? name;
  String? email;
}

@HostApi()
abstract class UserApi {
  UserDetails getUserDetails();
}
