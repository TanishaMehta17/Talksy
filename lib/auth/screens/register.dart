import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:talksy/auth/screens/login.dart';
import 'package:talksy/auth/services/authService.dart';
import 'package:talksy/common/colors.dart';
import 'package:talksy/common/typography.dart';
import 'package:talksy/utils/customTextFormField.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

bool _passwordVisible = false;
bool _confirmPasswordVisible = false;
final AuthService authService = AuthService();
final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();

class _SignUpScreenState extends State<SignUpScreen> {
  Future<bool> Signup() async {
    bool result = await authService.register(
      context: context,
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmpas: confirmPasswordController.text,
    );
    if (result) {
      Navigator.pushNamed(context, LoginScreen.routeName);
    }
    return result;
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
                    'Welcome to Talksy!',
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
                    'Sign up to continue',
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
                          controller: nameController,
                          labelText: "Name",
                          hintText: "Enter your name",
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 15),
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
                        CustomTextField(
                          controller: confirmPasswordController,
                          labelText: "Confirm Password",
                          hintText: "Re-enter your password",
                          obscureText: !_confirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: neonPurple,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible =
                                    !_confirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Signup();
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
                              'Get Started',
                              style: SCRTypography.subHeading
                                  .copyWith(color: white),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: SCRTypography.subHeading.copyWith(
                                  color: white70, fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: SCRTypography.subHeading.copyWith(
                                    color: neonPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                          context, LoginScreen.routeName);
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
