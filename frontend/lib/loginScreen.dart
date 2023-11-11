import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'package:frontend/generated/user_manager.pbgrpc.dart';
import 'package:frontend/menuScreen.dart';
import 'package:grpc/grpc.dart';
import 'package:frontend/userData.dart';
import 'package:frontend/registrationScreen.dart';


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

  Center loginButton() {
    return (Center(
      child: ElevatedButton(
        onPressed: _handleLoginButton,
        child: const Text('Log In'),
      ),
    ));
  }

  TextButton registrationButton() {
    return (TextButton(
        onPressed: _handleRegisterButton,
        child: const Text("Register")
    ));
  }


  int loginResponse = -1;

  void _handleLoginButton() {
    final form = _formKey.currentState;

    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();

      ///Just for admin exception
      if(userdata.username == 'admin'){
        loginResponse = 0;
      }

      sendLoginData().whenComplete(() {
        if(loginResponse == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const menuScreen()));
        } else if (loginResponse == 1) {
          _showAlertDialog('Password is incorrect!');
        } else if (loginResponse == 2) {
          _showAlertDialog('Username doesnt exist!');
        } else {
          _showAlertDialog('Unknown Error occured!');
        }
      });
    }
  }

  Future<void> sendLoginData() async {

    try {
      Login loginRequest = Login();
      loginRequest.username = userdata.username;
      loginRequest.password = userdata.password;

      var responseLogin = await UserManagerService.instance.helloClient.loginUser(loginRequest);
      ///do something with your response here
      setState(() {
        loginResponse = responseLogin.result.value;
        //print(loginResponse);
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

  void _handleRegisterButton(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationScreen()));
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
