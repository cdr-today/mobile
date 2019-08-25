import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
// blocs
import 'package:cdr_today/blocs/main.dart';
import 'package:cdr_today/blocs/user.dart';
import 'package:cdr_today/blocs/edit.dart';
import 'package:cdr_today/blocs/verify.dart';
import 'package:cdr_today/blocs/article_list.dart';
// pages
import 'package:cdr_today/pages/login.dart';
import 'package:cdr_today/pages/verify.dart';
import 'package:cdr_today/pages/edit.dart';
import 'package:cdr_today/navigations/args.dart';
import 'package:cdr_today/navigations/tabbar.dart';

/* app */
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  VerifyBloc verifyBloc = VerifyBloc();
  
  @override
  Widget build(BuildContext context) {
    VerifyBloc verifyBloc = VerifyBloc();
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          builder: (context) => ThemeBloc()
        ),
        BlocProvider<UserBloc>(
          builder: (context) => UserBloc(verifyBloc)
        ),
        BlocProvider<VerifyBloc>(
          builder: (context) => verifyBloc
        ),
        BlocProvider<EditBloc>(
          builder: (context) => EditBloc()
        ),
        BlocProvider<ArticleListBloc>(
          builder: (context) => ArticleListBloc()
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeData>(
        builder: (context, theme) => app(context, theme)
      )
    );
  }
}

Widget app(BuildContext context, ThemeData theme) {
  final UserBloc _userBloc = BlocProvider.of<UserBloc>(context);
  
  return MaterialApp(
    theme: theme,
    initialRoute: '/',
    onGenerateRoute: router,
    home: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserUnInited) {
          return Login();
        } else if (state is UserInited) {
          return TabNavigator(index: 0);
        } else {
          _userBloc.dispatch(CheckUserEvent());
          return Center(
            child: CircularProgressIndicator()
          );
        }
      }
    )
  );
}

/* app router */
MaterialPageRoute router(settings) {
  String r = settings.name;
  
  if (r == '/init') {
    final RootArgs args = settings.arguments;
    return MaterialPageRoute(
      builder: (context) =>  TabNavigator(index: 0)
    );
  } else if (r == '/user/verify') {
    final MailArgs args = settings.arguments;
    return MaterialPageRoute(
      builder: (context) =>  Verify(mail: args.mail)
    );
  } else if (r == '/user/edit') {
    return MaterialPageRoute(
      builder: (context) =>  Edit()
    );
  }
  
  return MaterialPageRoute(
    builder: (context) =>  Text('hello')
  );
}
