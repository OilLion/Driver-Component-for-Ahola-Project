import 'package:grpc/grpc.dart';
import 'package:frontend/generated/user_manager.pbgrpc.dart';
import 'package:frontend/generated/status_updater.pbgrpc.dart';
import 'generated/route_manager.pbgrpc.dart';

class UserManagerService {

  String baseUrl = "10.0.2.2";

  UserManagerService._internal();
  static final UserManagerService _instance = UserManagerService._internal();

  factory UserManagerService() => _instance;

  ///static UserManagerService instance that we will call when we want to make requests
  static UserManagerService get instance => _instance;
  ///We will pass a channel to it to intialize it
  late UserManagerClient _userManagerClient;

  ///this will be used to create a channel once we create this class.
  ///Call UserManagerService().init() before making any call.
  Future<void> init() async {
    _createChannel();
  }

  ///provide public access to the UserManagerClient instance
  UserManagerClient get userManagerClient {
    return _userManagerClient;
  }

  ///here we create a channel and use it to initialize the UserManagerClient that was generated
  _createChannel() {
    final channel = ClientChannel(
      baseUrl,
      port: 4269,

      ///use credentials: ChannelCredentials.insecure() if you want to connect without Tls
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),

      ///use this if you are connecting with Tls
      //options: const ChannelOptions(),
    );
    _userManagerClient = UserManagerClient(channel);
  }
}

class RouteManagerService {

  String baseUrl = "10.0.2.2";

  RouteManagerService._internal();
  static final RouteManagerService _instance = RouteManagerService._internal();

  factory RouteManagerService() => _instance;

  ///static RouteManagerService instance that we will call when we want to make requests
  static RouteManagerService get instance => _instance;
  ///We will pass a channel to it to intialize it
  late RouteManagerClient _routeClient;

  ///this will be used to create a channel once we create this class.
  ///Call RouteManagerService().init() before making any call.
  Future<void> init() async {
    _createChannel();
  }

  ///provide public access to the RouteManagerClient instance
  RouteManagerClient get routeClient {
    return _routeClient;
  }

  ///here we create a channel and use it to initialize the RouteManagerClient that was generated
  _createChannel() {
    final channel = ClientChannel(
      baseUrl,
      port: 4269,

      ///use credentials: ChannelCredentials.insecure() if you want to connect without Tls
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),

      ///use this if you are connecting with Tls
      //options: const ChannelOptions(),
    );
    _routeClient = RouteManagerClient(channel);
  }
}

class StatusUpdaterService {

  String baseUrl = "10.0.2.2";

  StatusUpdaterService._internal();
  static final StatusUpdaterService _instance = StatusUpdaterService._internal();

  factory StatusUpdaterService() => _instance;

  ///static StatusUpdaterService instance that we will call when we want to make requests
  static StatusUpdaterService get instance => _instance;
  ///We will pass a channel to it to intialize it
  late DriverUpdaterClient _statusUpdaterClient;

  ///this will be used to create a channel once we create this class.
  ///Call StatusUpdaterService().init() before making any call.
  Future<void> init() async {
    _createChannel();
  }

  ///provide public access to the StatusUpdaterClient instance
  DriverUpdaterClient get statusUpdaterClient {
    return _statusUpdaterClient;
  }

  ///here we create a channel and use it to initialize the StatusUpdaterClient that was generated
  _createChannel() {
    final channel = ClientChannel(
      baseUrl,
      port: 4269,

      ///use credentials: ChannelCredentials.insecure() if you want to connect without Tls
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),

      ///use this if you are connecting with Tls
      //options: const ChannelOptions(),
    );
    _statusUpdaterClient = DriverUpdaterClient(channel);
  }
}
