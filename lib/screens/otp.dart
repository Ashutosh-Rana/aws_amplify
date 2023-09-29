import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class OTPScreen extends StatefulWidget {
  final String username;

  const OTPScreen({super.key, required this.username});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // String otp = '';
  final _formKey = GlobalKey<FormState>();
    TextEditingController otp_controller = TextEditingController();

  Future<void> confirmUser({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      // Check if further confirmations are needed or if
      // the sign up is complete.
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming user: ${e.message}')));
      safePrint('Error confirming user: ${e.message}');
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
        Navigator.pushNamed(context, "/welcome");
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
      // appBar: AppBar(title: Icon(Icons.logout)),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*.2,),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                key: ValueKey('otp'),
                controller: otp_controller,
                // obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "OTP",
                    hintText: "Enter OTP",
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.length == 0) {
                    return 'OTP cannot be empty';
                  } else {
                    return null;
                  }
                },
                // onSaved: (value) {
                //   setState(() {
                //     otp = value!;
                //   });
                // },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    confirmUser(
                        username: widget.username, confirmationCode: otp_controller.text.toString());
                  }
                },
                child: Text("Home"))
          ],
        ),
      ),
    );
  }
}
