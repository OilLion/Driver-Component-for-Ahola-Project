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

  SizedBox routeList() {
    return
      SizedBox(
        height: 500,
        child: ListView.builder(
          itemCount: _routes.length,
          itemBuilder: (context, index) {
            return Container(
              alignment: Alignment.center,
              //color: Colors.deepPurple[200],
              child: Text(_routes[index].routeId as String),
            );
        }),
      );
  }

  int getRouteResponse = -1;

  void _handleGetRouteButton() {
    getRoutes().whenComplete(() {
      if(getRouteResponse == 0) {
        print("Get Routes was successful");
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