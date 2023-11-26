import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'package:frontend/generated/user_manager.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:frontend/userData.dart';


class RegistrationScreen extends StatelessWidget{
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: const RegistrationScreenStateful(),
    );
  }
}

class RegistrationScreenStateful extends StatefulWidget{
  const RegistrationScreenStateful({super.key});

  @override
  State<StatefulWidget> createState() => RegistrationScreenStatefulState();
}

class RegistrationScreenStatefulState extends State<RegistrationScreenStateful>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool passwordVisible = true;
  List<String> list = <String>['Truck', 'Van'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidate,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                userNameField(),
                userPasswordField(),
                vehicleList(),
                registrationButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField userNameField() {
    return (TextFormField(  // Username
      decoration: const InputDecoration(
          icon: Icon(Icons.account_box),
          hintText: 'Your Username',
          labelText: 'Username'
      ),
      onSaved: (value) => UserData.instance.username = value!,
      validator: (value){
        return null;
      },
      keyboardType: TextInputType.name,
    ));
  }

  TextFormField userPasswordField() {
    return (TextFormField(  // Password
        obscureText: passwordVisible,
        decoration: InputDecoration(
            icon: const Icon(Icons.password),
            hintText: 'Your Password',
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
            )
        ),
        onSaved: (value) => UserData.instance.password = value!,
        validator: (value) {
          return null;
        },
        keyboardType: TextInputType.visiblePassword
    ));
  }

  DropdownButtonFormField<String> vehicleList() {
    String dropdownValue = list.first;

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      onSaved: (value) => UserData.instance.vehicle = value!,
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  TextButton registrationButton() {
    return (TextButton(
        onPressed: _handleRegisterButton,
        child: const Text("Register")
    ));
  }

  int registrationResponse = -1;

  void _handleRegisterButton() {
    final form = _formKey.currentState;

    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();

      sendRegisterData().whenComplete(() {
        if(registrationResponse == 0) {
          Navigator.pop(context);
        } else if (registrationResponse == 1){
          _showAlertDialog('Username already exists!');
        } else {
          _showAlertDialog('Unknown Error occured!');
        }
      });
    }
  }

  Future<void> sendRegisterData() async {
    try {
      Registration registration = Registration();
      registration.username = UserData.instance.username;
      registration.password = UserData.instance.password;
      registration.vehicle = UserData.instance.vehicle;

      if(registration.username != "" && registration.password != ""){ //Check if username and password not empty
        var responseRegistration = await UserManagerService.instance.userManagerClient.registerUser(registration);
        setState(() {
          registrationResponse = responseRegistration.result.value;
        });
      } else{
        registrationResponse = -1;
      }
    } on GrpcError catch (e) {
      /// handle GRPC Errors
      print(e);
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