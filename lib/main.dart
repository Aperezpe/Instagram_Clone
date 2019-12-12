import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/screens/loadingscreen.dart';
import 'package:provider/provider.dart';
import 'screens/loginscreen.dart';
import 'screens/mainscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = InstagramBloc();
    return ChangeNotifierProvider(builder: (_) => bloc,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: SetupWidget(),
    ),);
  }
}

class SetupWidget extends StatefulWidget {
  SetupWidget({Key key}) : super(key: key);

  @override
  _SetupWidgetState createState() => _SetupWidgetState();
}

class _SetupWidgetState extends State<SetupWidget> {
  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    
    
    if(bloc.isLoggedIn){
      if(bloc.isReady){
        return MainScreen();
      }else{
        //Aqui puedoo poner if(bloc.failed)
        return LoadingScreen();
      }
    }else{
      return LoginScreen();
    }
  }
}

