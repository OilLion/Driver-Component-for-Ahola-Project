import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'package:frontend/generated/user_manager.pbgrpc.dart';
import 'package:frontend/menuScreen.dart';
import 'package:grpc/grpc.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  UserData userdata = UserData();

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
                loginButton(),
                textButton()
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

  Center loginButton() {
    return (Center(
      child: ElevatedButton(
        onPressed: _handleLoginButton,
        child: const Text('Log In'),
      ),
    ));
  }

  TextButton textButton() {
    return (TextButton(
        onPressed: _handleRegisterButton,
        child: const Text("Register")
    ));
  }

  void _handleLoginButton() {
    final form = _formKey.currentState;
    bool successfulLogin = false;

    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();

      //TODO Remove if statement
      if(userdata.username == 'admin'){
        successfulLogin = true;
      }
      
      //TODO send userData to Backend to check if exists
      sendLoginData();

      if(successfulLogin) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const menuScreen()));
      } else {
        _showAlertDialog('Login Credentials are not correct!');
      }
    }
  }

  int hello = 3;
  Future<void> sendLoginData() async {
    try {
      Login loginRequest = Login();
      loginRequest.username = userdata.username;
      loginRequest.password = userdata.password;

      var helloResponse = await UserManagerService.instance.helloClient.loginUser(loginRequest);
      ///do something with your response here
      setState(() {
        hello = helloResponse.result.value;
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



  void _handleRegisterButton() {
    final form = _formKey.currentState;
    bool successfulRegister = false;

    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();

      //TODO Remove if statement
      if(userdata.username == 'admin'){
        successfulRegister = true;
      }

      //TODO send userData to Backend and register user if not exists or change to register page



      if(successfulRegister) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const menuScreen()));
      } else {
        _showAlertDialog("Username already exists!");
      }
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

class UserData{
  String username = "";
  String password = "";
}