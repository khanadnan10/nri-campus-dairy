import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nri_campus_dairy/resources/auth_methods.dart';
import 'package:nri_campus_dairy/screens/signup_screen.dart';
import 'package:nri_campus_dairy/utils/colors.dart';
import 'package:nri_campus_dairy/utils/utils.dart';
import 'package:nri_campus_dairy/widgets/text_field_input.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({Key? key}) : super(key: key);

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final TextEditingController _passcodeController = TextEditingController();
  bool hidePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void checkPasscode() async {
    setState(() {
      _isLoading = true;
    });

    String isCorrectPasscode = await AuthMethods()
        .signupCheck(passCode: int.parse(_passcodeController.text));

    if (isCorrectPasscode == 'success') {
      print('✅ Authorized user ------------------------');
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignupScreen(),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, 'Congratulation 🎉');
      }
    } else {
      print('❌ Unauthorized user ------------------------');
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(context, isCorrectPasscode);
      }
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Icon(
                    CupertinoIcons.lock_circle_fill,
                    size: 30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Enter Passcode',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'You can sign up as soon as you provide the invite code',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldInput(
                    hintText: 'Passcode',
                    isPass: hidePass,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePass = !hidePass;
                        });
                      },
                      icon: hidePass
                          ? const Icon(Icons.visibility)
                          : const Icon(
                              Icons.visibility_off,
                            ),
                    ),
                    maxLength: 4,
                    textInputType: TextInputType.number,
                    textEditingController: _passcodeController,
                  ),
                ],
              ),
              InkWell(
                onTap: checkPasscode,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: blueColor,
                  ),
                  child: !_isLoading
                      ? const Text(
                          'Log in',
                        )
                      : const CircularProgressIndicator(
                          color: primaryColor,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
