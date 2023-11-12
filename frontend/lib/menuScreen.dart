import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'package:frontend/generated/route_manager.pb.dart';
import 'package:frontend/generated/route_manager.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'userData.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Screen'),
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
  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<RouteReply> _routes = [];

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

  SizedBox getRouteButton() {
    return SizedBox(
      height: 30,
      width: 120,
      child: TextButton(
          onPressed: _handleGetRouteButton,
          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blue),
              foregroundColor: MaterialStatePropertyAll(Colors.white)),
          child: const Text("Get Routes")
      ),
    );
  }

  Column routeList() {
    return
      Column(
        children: [
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          Stepper(
                            controlsBuilder: (context, controller) {
                              return const Row(children: []);
                            },
                            steps: <Step>[
                              Step(
                                title: Text(_routes[index].events.first.location),
                                content: SizedBox(
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
                              ),
                              Step(
                                title: Text(_routes[index].events.last.location),
                                content: Text(_routes[index].events.last.location),
                              ),
                            ],
                          ),
                          TextButton(
                              onPressed: ()=>_handleAccept(index),
                              child: const Text("Accept this Route"))
                        ],
                      ),

                    )
                  ],
                );
              }),
        ],
      );
  }

  void _handleAccept(int index) {
    print(index);
  }

  int getRouteResponse = -1;

  void _handleGetRouteButton() {
    getRoutes().whenComplete(() {
      if(getRouteResponse == 0) {
        print("Get Routes was successful");
        // print(_routes.length);
      } else if (getRouteResponse == 1) {
        _showAlertDialog('User is not authenticated!');
      } else if (getRouteResponse == 2) {
        _showAlertDialog('MalformedLogintoken!');
      } else {
        _showAlertDialog('Unknown Error occured!');
      }
    });
  }

  Future<void> getRoutes() async {
    try {
      GetRoutesRequest getRequest = GetRoutesRequest();
      getRequest.uuid = UserData.instance.uuid;

      var responseGetRequest = await RouteManagerService.instance.helloClient2.getRoutes(getRequest);
      ///do something with your response here
      setState(() {
        getRouteResponse = responseGetRequest.result.value;
        _routes = responseGetRequest.routes;
        print(responseGetRequest.routes.length);
      });
    } on GrpcError catch (e) {
      ///handle all grpc errors here
      ///errors such us UNIMPLEMENTED,UNIMPLEMENTED etc...
      print(e);
    } catch (e) {
      ///handle all generic errors here
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
              child: const Text('Ok'),
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