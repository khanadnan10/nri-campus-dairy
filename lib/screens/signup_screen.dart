import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nri_campus_dairy/resources/auth_methods.dart';
import 'package:nri_campus_dairy/responsive/mobile_screen_layout.dart';
import 'package:nri_campus_dairy/responsive/responsive_layout.dart';
import 'package:nri_campus_dairy/responsive/web_screen_layout.dart';
import 'package:nri_campus_dairy/screens/login_screen.dart';
import 'package:nri_campus_dairy/utils/colors.dart';
import 'package:nri_campus_dairy/utils/utils.dart';
import 'package:nri_campus_dairy/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {
    // set loading to true

    // signup user using our authmethodds

    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!);
    // if string returned is sucess, user has been created

    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      if (context.mounted) {
        showSnackBar(context, res);
      }
    }
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar

    setState(() {
      _image = im;
    });
  }

  bool hidePass = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Flexible(
              //   flex: 2,
              //   child: Container(),
              // ),
              // const Text(
              //   'NRI \nCampus Diary',
              //   style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              // ),
              // SvgPicture.asset(
              //   'assets/ic_instagram.svg',
              //   color: primaryColor,
              //   height: 64,
              // ),
              const SizedBox(
                height: 64,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                          backgroundColor: Colors.red,
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person_2_rounded,
                            size: 55.0,
                            color: Colors.white,
                          ),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: Container(
                      decoration: BoxDecoration(
                          color: mobileBackgroundColor,
                          borderRadius: BorderRadius.circular(50.0),
                          border: Border.all(style: BorderStyle.none)),
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 25.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                hintText: 'Username',
                prefixIcon: const Icon(
                  Icons.person,
                ),
                textInputType: TextInputType.text,
                textEditingController: _usernameController,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                hintText: 'Email',
                prefixIcon: const Icon(
                  Icons.email,
                ),
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                hintText: 'Password',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePass = !hidePass;
                      });
                    },
                    icon: hidePass
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off)),
                prefixIcon: const Icon(
                  Icons.password,
                ),
                textInputType: TextInputType.text,
                textEditingController: _passwordController,
                isPass: hidePass,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                hintText: 'Bio',
                prefixIcon: const Icon(
                  Icons.pending,
                ),
                textInputType: TextInputType.text,
                textEditingController: _bioController,
              ),
              const SizedBox(
                height: 24,
              ),
              InkWell(
                onTap: () {
                  if (_image == null) {
                    FocusScope.of(context).unfocus();
                    showSnackBar(context,
                        'Choose a profile picture to complete your signup. 📸');
                  } else if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _usernameController.text.isEmpty ||
                      _bioController.text.isEmpty) {
                    FocusScope.of(context).unfocus();

                    showSnackBar(context,
                        '🛑 Hold on! Looks like you missed some fields.');
                  } else {
                    signUpUser();
                  }
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: _isLoading ? secondaryColor : blueColor,
                  ),
                  child: !_isLoading
                      ? const Text(
                          'Sign up',
                        )
                      : const CircularProgressIndicator(
                          color: primaryColor,
                        ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                "🚨 All fields are mandatory.\n Please fill them out. Thank you!",
                style: TextStyle(color: secondaryColor, fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        ' Login.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
