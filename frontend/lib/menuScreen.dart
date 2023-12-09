import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'package:frontend/generated/route_manager.pb.dart';
import 'package:frontend/generated/route_manager.pbgrpc.dart';
import 'package:frontend/routeDisplay.dart';
import 'package:grpc/grpc.dart';
import 'userData.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('menuScreen'),
      appBar: AppBar(
        title: const Text('MAIN MENU'),
      ),
      body: const MenuScreenStateful(),
    );
  }
}

class MenuScreenStateful extends StatefulWidget{
  const MenuScreenStateful({super.key});


  @override
  State<StatefulWidget> createState() => MenuScreenStatefulState();
}

class MenuScreenStatefulState extends State<MenuScreenStateful>{
  List<RouteReply> _routes = [];
  //bool alreadyAssigned = false;

  @override void initState() {
    super.initState();
    _checkIfAlreadyAssigned();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              getRouteButton(),
              routeList(),
            ],
          ),
        ),
      ),
    );
  }

  Center getRouteButton() {
    return Center(
      child: ElevatedButton(
        key: const Key('getRoutesButton'),
        onPressed: _handleGetRouteButton,
        child: const Text("GET ROUTES"),
      ),
    );
  }

  ListView routeList() {
    return
      ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: _routes.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  color: Colors.grey,
                  child: Card(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,  //height of individual Routes
                          child: ListView.builder(
                            itemCount: _routes[index].events.length,
                            itemBuilder: (context, indexEvents) {
                              return Container(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    Text(_routes[index].events[indexEvents].location,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                            key: Key(_routes[index].routeId.toString()),
                            onPressed: ()=>_handleAccept(index),
                            child: const Text("ACCEPT THIS ROUTE"))
                      ],
                    ),
                  ),
                )
              ],
            );
          });
  }

  void _checkIfAlreadyAssigned() {
    checkAssignedRoute().whenComplete(() {
      if(UserData.instance.alreadyAssigned) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RouteDisplay()));
      }
    });
  }

  int acceptRouteResponse = -1;

  void _handleAccept(int index) {
    acceptRoute(index).whenComplete(() {
      switch(acceptRouteResponse) {
        case 0:
          UserData.instance.activeRoute = _routes[index];
          UserData.instance.alreadyAssigned = true;
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RouteDisplay()))
              .then((value) {
                _handleGetRouteButton();
          });
          break;
        case 3:
          _showAlertDialog('UNKNOWN ROUTE');
          break;
        case 4:
          _showAlertDialog('ROUTE ALREADY ASSIGNED!');
          break;
        case 5:
          _showAlertDialog('DRIVER ALREADY ASSIGNED!');
          break;
        case 6:
          _showAlertDialog('UNAUTHENTICATED USER!');
          break;
        case 8:
          _showAlertDialog('MALFORMED LOGIN TOKEN');
          break;
        default:
          _showAlertDialog('UNKNOWN ERROR OCCURED!');
      }
    });
  }

  Future<void> acceptRoute(int index) async {
    try {
      SelectRouteRequest selectRequest = SelectRouteRequest();
      selectRequest.routeId = _routes[index].routeId;
      selectRequest.uuid = UserData.instance.uuid;

      var responseSelectRequest = await
      RouteManagerService.instance.routeClient.selectRoute(selectRequest);
      setState(() {
        acceptRouteResponse = responseSelectRequest.result.value;
      });
    } on GrpcError catch (e) {
      /// handle GRPC Errors
      print(e);
    } catch (e) {
      /// handle Generic Errors
      print(e);
    }
  }

  int getRouteResponse = -1;

  void _handleGetRouteButton() {
    getRoutes().whenComplete(() {
      switch(getRouteResponse) {
        case 0:
          //print("Get Routes was successful");
          break;
        case 3:
          _showAlertDialog('UNKNOWN ROUTE');
          break;
        case 6:
          _showAlertDialog('UNAUTHENTICATED USER!');
          break;
        case 8:
          _showAlertDialog('MALFORMED LOGIN TOKEN');
          break;
        default:
          _showAlertDialog('UNKNOWN ERROR OCCURED!');
      }
    });
  }

  Future<void> getRoutes() async {
    try {
      GetRoutesRequest getRequest = GetRoutesRequest();
      getRequest.uuid = UserData.instance.uuid;

      var responseGetRequest = await
      RouteManagerService.instance.routeClient.getRoutes(getRequest);
      setState(() {
        getRouteResponse = responseGetRequest.result.value;
        _routes = responseGetRequest.routes;
      });
    } on GrpcError catch (e) {
      /// handle GRPC Errors
      print(e);
    } catch (e) {
      /// handle Generic Errors
      print(e);
    }
  }

  int checkAssignedRouteresponse = -1;
  int currentStep = -1;

  Future<void> checkAssignedRoute() async {
    try {
      GetAssignedRouteRequest getRequest = GetAssignedRouteRequest();
      getRequest.uuid = UserData.instance.uuid;

      var responseGetRequest = await
      RouteManagerService.instance.routeClient.getAssignedRoute(getRequest);
      setState(() {
        UserData.instance.activeRoute = responseGetRequest.route;
        UserData.instance.currentStep = responseGetRequest.currentStep - 1;
        UserData.instance.alreadyAssigned = true;
      });
    } on GrpcError catch (e) {
      /// handle GRPC Errors
      if (e.code == 3){
        UserData.instance.alreadyAssigned = false;
      } else {
        print(e);
      }
    } catch (e) {
      /// handle Generic Errors
      print(e);
    }
  }

  void _showAlertDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}