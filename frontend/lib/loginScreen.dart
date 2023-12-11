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
      key: const Key('userNameField'),
      decoration: const InputDecoration(
          icon: Icon(Icons.account_box),
          hintText: 'YOUR USERNAME',
          labelText: 'USERNAME'
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
        key: const Key('passwordField'),
        obscureText: passwordVisible,
        decoration: InputDecoration(
            icon: const Icon(Icons.password),
            hintText: 'YOUR PASSWORD',
            labelText: 'PASSWORD',
            suffixIcon: IconButton(
              icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
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

  Center loginButton() {
    return Center(
      child: ElevatedButton(
        key: const Key('login'),
        onPressed: _handleLoginButton,
        child: const Text('LOG IN'),
      ),
    );
  }

  Center registrationButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _handleRegisterButton,
        child: const Text("REGISTER"),
      ),
    );
  }

  int loginResponse = -1;

  void _handleLoginButton() {
    final form = _formKey.currentState;
    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();
      sendLoginData().whenComplete(() {
        switch(loginResponse) {
          case 0:
            UserData.instance.currentStep = 0;
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
            break;
          case 1:
            _showAlertDialog('PASSWORD IS INCORRECT');
            break;
          case 2:
            _showAlertDialog('USERNAME DOESNT EXIST!');
            break;
          default:
            _showAlertDialog('UNKNOWN ERROR OCCURED!');
        }
      });
    }
  }

  Future<void> sendLoginData() async {
    try {
      Login loginRequest = Login();
      loginRequest.username = UserData.instance.username;
      loginRequest.password = UserData.instance.password;

      var responseLogin = await
      UserManagerService.instance.userManagerClient.loginUser(loginRequest);
      setState(() {
        loginResponse = responseLogin.result.value;
        UserData.instance.uuid = responseLogin.uuid;
        UserData.instance.duration = responseLogin.duration.toInt();
      });
    } on GrpcError catch (e) {
      /// handle GRPC Errors
      print(e);
    } catch (e) {
      /// handle Generic Errors
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
