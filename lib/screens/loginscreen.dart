import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    return Scaffold(appBar: AppBar(title: Text("Login"),), body: Column(children: <Widget>[
      TextField(controller: usernameCtrl,),
      TextField(controller: passwordCtrl, obscureText: true,),
      RaisedButton(child: Text("Login"), onPressed: () async {
        //fetch token
        bloc.attemptLogin(usernameCtrl.text, passwordCtrl.text);
      },),
      Text(bloc.didLoginFail ? "Login failed" : "", style: TextStyle(color: Colors.redAccent),)
    ],),);
  }
}