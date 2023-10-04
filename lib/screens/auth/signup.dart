import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_demo/screens/auth/otp.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email_controller = TextEditingController();
  TextEditingController pass_controller = TextEditingController();
  TextEditingController username_controller = TextEditingController();
  // String email = '';
  // String password = '';
  // String username = '';
  bool isPassValid = false;

  bool validateEmailPass() {
    final bool isEmailValid =
        EmailValidator.validate(email_controller.text.trim());
    if (isEmailValid && isPassValid) {
      return true;
    } else {
      return false;
    }
  }

  /// Signs a user up with a username, password, and email. The required
  /// attributes may be different depending on your app's configuration.
  Future<void> signUpUser({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
  }) async {
    try {
      final userAttributes = {
        AuthUserAttributeKey.email: email,
        if (phoneNumber != null) AuthUserAttributeKey.phoneNumber: phoneNumber,
        // additional attributes as needed
      };
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing up: ${e.message}')));
      safePrint('Error signing up user: ${e.message}');
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignUpStep.done:
        safePrint('Sign up is complete');
        
        break;
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
        appBar: AppBar(title: Text("Registration")),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    key: ValueKey('username'),
                    controller: username_controller,
                    decoration: InputDecoration(
                        labelText: "Username",
                        hintText: "Enter Username",
                        border: OutlineInputBorder()),
                    // onSaved: (value) {
                    //   setState(() {
                    //     username = value!;
                    //   });
                    // },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter valid username';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    key: ValueKey('email'),
                    controller: email_controller,
                    decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter Email ID",
                        border: OutlineInputBorder()),
                    // onSaved: (value) {
                    //   setState(() {
                    //     email = value!.trim();
                    //   });
                    // },
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please Enter valid Email';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    obscureText: true,
                    controller: pass_controller,
                    decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter Password",
                        border: OutlineInputBorder()),
                    // onSaved: (value) {
                    //   setState(() {
                    //     password = value!;
                    //   });
                    // },
                    validator: (value) {
                      if (value!.length < 8) {
                        return 'Please Enter Password of min length 8';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                FlutterPwValidator(
                  controller: pass_controller,
                  minLength: 8,
                  uppercaseCharCount: 2,
                  numericCharCount: 3,
                  specialCharCount: 1,
                  normalCharCount: 3,
                  width: 400,
                  height: 150,
                  onSuccess: () {
                    setState(() {
                      isPassValid = true;
                    });
                  },
                  onFail: () {
                    setState(() {
                      isPassValid = false;
                    });
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          validateEmailPass()) {
                        signUpUser(
                            username: username_controller.text.toString(),
                            password: pass_controller.text.toString(),
                            email: email_controller.text.toString());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OTPScreen(username: username_controller.text.toString()),
                          ),
                        );
                      }
                    },
                    child: Text("Sign Up"))
              ],
            ),
          ),
        ));
  }
}
