import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'package:frontend/userData.dart';
import 'package:grpc/grpc.dart';
import 'generated/route_manager.pb.dart';
import 'package:frontend/menuScreen.dart';

import 'generated/status_updater.pb.dart';

class RouteDisplay extends StatelessWidget {
  const RouteDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Display'),
      ),
      body: const RouteDisplayStateful(),
    );
  }
}

class RouteDisplayStateful extends StatefulWidget{
  const RouteDisplayStateful({super.key});

  @override
  State<StatefulWidget> createState() => RouteDisplayStatefulState();
}

class RouteDisplayStatefulState extends State<RouteDisplayStateful> {
  List<String> test = ['eins', 'zwei', 'drei'];
  int currentStep = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              stepper(),
            ],
          ),
        ),
      ),
    );
  }

  List<Step> getSteps() {
    List<Step> steps = [];

    for (int i = 0;i < UserData.instance.activeRoute.events.length;i++) {
      steps.add(
        Step(
          state: currentStep >= i ? StepState.complete : StepState.indexed,
          isActive: currentStep >= i,
          title: Text(UserData.instance.activeRoute.events[i].location),
          content: Container(
            child: const Text('Content of Step'),
          )
        )
      );
    }
    return steps;
  }

  Stepper stepper() {
    return Stepper(
      controlsBuilder: (context, ControlsDetails details) {
        final isLastStep = currentStep == getSteps().length -2;
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(isLastStep ? 'Finish Delivery' : 'Next Step'),
              ),
            ),
          ],
        );
      },
      steps: getSteps(),
      currentStep: currentStep,
      onStepContinue: () {
        setState(() => currentStep += 1);
        updateStatus(currentStep).whenComplete(() {
          if(statusUpdateResponse) {
            Navigator.pop(context);
          }
        });
      },
      onStepCancel: currentStep == 0 ? null : () => setState(() => currentStep -= 1),
    );
  }

  bool statusUpdateResponse = false;

  Future<void> updateStatus(int currentStep) async {
    try {
      currentStep += 1;
      StatusUpdateRequest statusUpdateRequest = StatusUpdateRequest();
      statusUpdateRequest.uuid = UserData.instance.uuid;
      statusUpdateRequest.step = currentStep;

      var responseUpdateRequest = await
      StatusUpdaterService.instance.statusUpdaterClient.updateStatus(statusUpdateRequest);
      setState(() {
        statusUpdateResponse = responseUpdateRequest.done;
      });
    } on GrpcError catch (e) {
      /// handle GRPC Errors
      print(e);
    } catch (e) {
      /// handle Generic Errors
      print(e);
    }
  }
}