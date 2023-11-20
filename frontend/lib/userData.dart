import 'generated/route_manager.pb.dart';

class UserData{
  String username = "";
  String password = "";
  String vehicle = "";
  List<int> uuid = [];
  int duration = 0;
  RouteReply activeRoute = RouteReply();

  UserData._();
  static final instance = UserData._();
}