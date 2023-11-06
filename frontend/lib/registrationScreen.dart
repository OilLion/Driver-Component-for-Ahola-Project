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
  UserData userdata = UserData();
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
      onSaved: (value) => userdata.username = value!,
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
              icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
            )
        ),
        onSaved: (value) => userdata.password = value!,
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
      elevation: 16,
      //style: const TextStyle(color: Colors.deepPurple),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      onSaved: (value) => userdata.vehicle = value!,
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

  void _handleRegisterButton() {
    final form = _formKey.currentState;
    int registrationResponse = -1;

    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();
      print(userdata.vehicle); //TODO delete
      //Just for admin exception
      if(userdata.username == 'admin'){
        registrationResponse = 0;
      }

      //TODO send userData to Backend and register user if not exists or change to register page
      sendRegisterData();
      //change registrationResponse accordingly to output of sendRegisterData()

      if(registrationResponse == 0) {
        Navigator.pop(context);
      } else if (registrationResponse == 1){
        _showAlertDialog('Username already exists!');
      } else {
        _showAlertDialog('Unknown Error occured!');
      }
    }
  }

  Future<void> sendRegisterData() async {
    int hello = 3;
    try {
      Registration registration = Registration();
      registration.username = userdata.username;
      registration.password = userdata.password;
      //TODO registration.vehicle = userdata.vehicle;

      var registrationResponse = await UserManagerService.instance.helloClient.registerUser(registration);
      ///do something with your response here
      setState(() {
        hello = registrationResponse.result.value;
        print(hello);
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