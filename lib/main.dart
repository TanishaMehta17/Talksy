import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:talksy/auth/screens/login.dart';
import 'package:talksy/auth/services/authService.dart';
import 'package:talksy/screens/homeScreen.dart';
import 'package:talksy/providers/userProvider.dart';
import 'package:talksy/routes.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await Permission.storage.request();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  //await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    print(Provider.of<UserProvider>(context).user.id);
    bool isUserLoggedIn =
        Provider.of<UserProvider>(context).user.token.isNotEmpty;
    print(isUserLoggedIn);

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),

     
      home: isUserLoggedIn
          ? HomeScreen()
          :  LoginScreen(),
      onGenerateRoute: (settings) => generateRoute(settings),
    );
  }
}
