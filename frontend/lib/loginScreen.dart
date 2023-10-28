import 'package:flutter/material.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  userData userdata = userData();

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
                TextFormField(  // Username
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

                ),
                TextFormField(  // Password
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
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleLoginButton,
                    child: const Text('Log In'),
                  ),
                ),
                TextButton(
                    onPressed: _handleRegisterButton,
                    child: Text("Register")
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLoginButton() {
    final form = _formKey.currentState;
    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();
      //TODO send userData to Backend to check if exists
    }
  }

  void _handleRegisterButton() {
    final form = _formKey.currentState;
    if(!form!.validate()){
      _autoValidate = AutovalidateMode.always;
    }
    else{
      form.save();
      //TODO send userData to Backend and register user if not exists or change to register page
    }
  }
}

class userData{
  String username = "";
  String password = "";
}