import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_demo/models/ModelProvider.dart';
import 'package:amplify_demo/providers/message_provider.dart';
import 'package:amplify_demo/providers/user_provider.dart';
import 'package:amplify_demo/screens/auth/login.dart';
import 'package:amplify_demo/screens/auth/signup.dart';
import 'package:amplify_demo/screens/home.dart';
import 'package:amplify_demo/screens/image_upload/img_upload.dart';
import 'package:amplify_demo/screens/messages/message_screen.dart';
import 'package:amplify_demo/screens/welcome/welcome_screen.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  final storage = AmplifyStorageS3();
  try {
    // final auth = AmplifyAuthCognito();
    // await Amplify.addPlugin(auth);

    // // call Amplify.configure to use the initialized categories in your app
    // await Amplify.configure(amplifyconfig);
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugins([api, auth, storage]);
    await Amplify.configure(amplifyconfig);
    safePrint("Amplify configured successfully");
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  // void initState() {
  //   super.initState();
  //   _configureAmplify();
  // }

  // Future<void> _configureAmplify() async {
  //   try {
  //     final auth = AmplifyAuthCognito();
  //     await Amplify.addPlugin(auth);

  //     // call Amplify.configure to use the initialized categories in your app
  //     await Amplify.configure(amplifyconfig);
  //   } on Exception catch (e) {
  //     safePrint('An error occurred configuring Amplify: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      debugShowCheckedModeBanner: false,
      routes: {
        "/login": (context) => Login(),
        "/signup": (context) => SignUp(),
        "/home": (context) => HomeScreen(),
        "/welcome": (context) => WelcomeScreen(),
        "/message": (context) => MessagesScreen(),
        "/upload_img":(context) => UploadScreen()
      },
    );
  }
}
