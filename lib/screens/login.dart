import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController pass_controller = TextEditingController();
  TextEditingController username_controller = TextEditingController();
  // bool login = false;

  Future<void> signInUser(String username, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      await _handleSignInResult(result);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: ${e.message}')));
      safePrint('Error signing in: ${e.message}');
    }
  }

  Future<void> _handleSignInResult(SignInResult result) async {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithSmsMfaCode:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignInStep.confirmSignInWithNewPassword:
        safePrint('Enter a new password to continue signing in');
        break;
      case AuthSignInStep.confirmSignInWithCustomChallenge:
        final parameters = result.nextStep.additionalInfo;
        final prompt = parameters['prompt']!;
        safePrint(prompt);
        break;
      // case AuthSignInStep.resetPassword:
      //   final resetResult = await Amplify.Auth.resetPassword(
      //     username: username_controller.text.toString(),
      //   );
      // await _handleResetPasswordResult(resetResult);
      // break;
      case AuthSignInStep.confirmSignUp:
        // Resend the sign up code to the registered device.
        final resendResult = await Amplify.Auth.resendSignUpCode(
          username: username_controller.text.toString(),
        );
        _handleCodeDelivery(resendResult.codeDeliveryDetails);
        break;
      case AuthSignInStep.done:
        safePrint('Sign in is complete');
        Navigator.pushNamed(context, "/welcome");
        break;
      default:
    }
  }

  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
    safePrint(
      'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
      'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 42.0, left: 8, right: 8, bottom: 8),
                child: TextFormField(
                  key: ValueKey('email'),
                  controller: username_controller,
                  decoration: InputDecoration(
                      labelText: "Username",
                      hintText: "Enter Username",
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter Username';
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (value) {
                  //   setState(() {
                  //     email = value!.trim();
                  //   });
                  // },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  key: ValueKey('password'),
                  controller: pass_controller,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter Password",
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value!.length < 8) {
                      return 'Please Enter Password of min length 8';
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (value) {
                  //   setState(() {
                  //     password = value!;
                  //   });
                  // },
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blue),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    signInUser(username_controller.text.toString(),
                        pass_controller.text.toString());
                  }
                },
                child: Text("Login"),
              ),
              SizedBox(
                height: 18,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.pushNamed(context, "/signup");
                },
                child: Text("SignUp"),
              )
            ],
          ),
        ));
  }
}
