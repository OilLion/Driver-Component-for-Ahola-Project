import 'package:grpc/grpc.dart';
import 'package:frontend/generated/user_manager.pbgrpc.dart';

import 'generated/route_manager.pbgrpc.dart';

class UserManagerService {

  ///here enter your host without the http part (e.g enter google.com now http://google.com)
  String baseUrl = "10.0.2.2";

  UserManagerService._internal();
  static final UserManagerService _instance = UserManagerService._internal();

  factory UserManagerService() => _instance;

  ///static HelloService instance that we will call when we want to make requests
  static UserManagerService get instance => _instance;
  ///HelloClient is the  class that was generated for us when we ran the generation command
  ///We will pass a channel to it to intialize it
  late UserManagerClient _userManagerClient;

  ///this will be used to create a channel once we create this class.
  ///Call HelloService().init() before making any call.
  Future<void> init() async {
    _createChannel();
  }

  ///provide public access to the HelloClient instance
  UserManagerClient get userManagerClient {
    return _userManagerClient;
  }

  ///here we create a channel and use it to initialize the HelloClient that was generated
  ///
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

  ///here enter your host without the http part (e.g enter google.com now http://google.com)
  String baseUrl = "10.0.2.2";

  RouteManagerService._internal();
  static final RouteManagerService _instance = RouteManagerService._internal();

  factory RouteManagerService() => _instance;

  ///static HelloService instance that we will call when we want to make requests
  static RouteManagerService get instance => _instance;
  ///HelloClient is the  class that was generated for us when we ran the generation command
  ///We will pass a channel to it to intialize it
  late RouteManagerClient _routeClient;

  ///this will be used to create a channel once we create this class.
  ///Call HelloService().init() before making any call.
  Future<void> init() async {
    _createChannel();
  }

  ///provide public access to the HelloClient instance
  RouteManagerClient get routeClient {
    return _routeClient;
  }

  ///here we create a channel and use it to initialize the HelloClient that was generated
  ///
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













/*import 'package:frontend/generated/user_manager.pbgrpc.dart';
import 'package:grpc/grpc.dart';


void main() async {
  final channel = ClientChannel(
    'localhost',
    port: 4269,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );

  final stub = UserManagerClient(channel);

  var response = await stub.loginUser(Login());
  print('Response received: ${response}');

  await channel.shutdown();
}*/