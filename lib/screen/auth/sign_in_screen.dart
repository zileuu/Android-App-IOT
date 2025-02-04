import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pizza_app/screen/auth/forgot_password.dart';
import 'package:pizza_app/utils/app_borders.dart';
import 'package:pizza_app/utils/app_icon.dart';

import '../../controller/auth_controller.dart';
import '../sale_app/pizza-home-screen.dart';
import 'components/no_account_text.dart';
import 'components/social_card.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Sign In"),centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign in with your email and password  \nor continue with social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  SignInForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ Obx(() => authController.isLoading.value
                        ? CircularProgressIndicator() // ✅ Show loader while signing in
                        : SocialCard(
                      icon: SvgPicture.string(AppIcons.googleIcon),
                      press: () => authController.signInWithGoogle(), // ✅ Google Sign-In
                    ),
                    ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: SocialCard(
                      //     icon: SvgPicture.string(AppIcons.facebookIcon),
                      //     press: () {},
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const NoAccountText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // ✅ Form Key for validation

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // ✅ Assign form key
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email cannot be empty!";
              } else if (!GetUtils.isEmail(value)) {
                return "Enter a valid email!";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Enter your email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffix: SvgPicture.string(AppIcons.mailIcon),
              border: AppBorders.authOutlineInputBorder,
              enabledBorder: AppBorders.authOutlineInputBorder,
              focusedBorder: AppBorders.authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF00BF6D)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password cannot be empty!";
                } else if (value.length < 6) {
                  return "Password must be at least 6 characters!";
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Enter your password",
                labelText: "Password",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffix: SvgPicture.string(AppIcons.lockIcon),
                border: AppBorders.authOutlineInputBorder,
                enabledBorder: AppBorders.authOutlineInputBorder,
                focusedBorder: AppBorders.authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFF00BF6D)),
                ),
              ),
            ),
          ),
          // const SizedBox(height: 16),
          GestureDetector(
            onTap: () {Get.to(()=>ForgotPasswordScreen());},
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Forget Password?",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 8),
          Obx(() => authController.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                authController.signIn(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF00BF6D),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: const Text("Sign In"),
          )),
        ],
      ),
    );
  }
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}





