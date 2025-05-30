import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:talksy/auth/screens/register.dart';
import 'package:talksy/auth/services/authService.dart';
import 'package:talksy/common/colors.dart';
import 'package:talksy/common/typography.dart';
import 'package:talksy/screens/homeScreen.dart';
import 'package:talksy/utils/customTextFormField.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final AuthService authService = AuthService();
  final TextEditingController emailController =
      TextEditingController(text: 'tanay@gmail.com');
  final TextEditingController passwordController =
      TextEditingController(text: '123456');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signin(BuildContext context) {
    authService.login(
      context: context,
      email: emailController.text,
      password: passwordController.text,
      callback: (bool success) {
        if (success) {
          Navigator.pushNamed(
            context,
           HomeScreen.routeName,
            arguments: emailController.text,
          );
        } else {
          print("Password is Incorrect");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Glowing Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  const Color(0xFFB367FF), // neon purple glow
                  black, // from color.dart
                ],
              ),
            ),
          ),

          // Main Content
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(seconds: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/chat.jpg',
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Welcome Back!',
                    style: SCRTypography.heading.copyWith(
                      color: white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.purpleAccent.withOpacity(0.6),
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Login In to continue',
                    style: SCRTypography.subHeading.copyWith(color: white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: black.withOpacity(0.7),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: emailController,
                          labelText: "Email",
                          hintText: "Enter your email",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 15),
                        CustomTextField(
                          controller: passwordController,
                          labelText: "Password",
                          hintText: "Enter your password",
                          obscureText: !_passwordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: neonPurple,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              signin(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: neonPurple,
                              foregroundColor: white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                              shadowColor: neonPurple.withOpacity(0.5),
                            ),
                            child: Text(
                              'Login Now',
                              style: SCRTypography.subHeading
                                  .copyWith(color: white),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: SCRTypography.subHeading.copyWith(
                                  color: white70, fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: 'Register',
                                  style: SCRTypography.subHeading.copyWith(
                                    color: neonPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                          context, SignUpScreen.routeName);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
