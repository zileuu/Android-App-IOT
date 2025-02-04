import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../utils/app_borders.dart';
import '../../utils/app_icon.dart';
import '../sale_app/pizza-home-screen.dart';
import 'components/social_card.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Register Account"),
        centerTitle: true,
         automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // const SizedBox(height: 16),
                  // const Text(
                  //   "Register Account",
                  //   style: TextStyle(
                  //     color: Colors.black,
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  const Text(
                    "Complete your details or continue \nwith social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const SignUpForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => authController.isLoading.value
                          ? CircularProgressIndicator() // ✅ Show loader while signing in
                          : SocialCard(
                        icon: SvgPicture.string(AppIcons.googleIcon),
                        press: () => authController.signInWithGoogle(), // ✅ Google Sign-In
                      ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    "By continuing your confirm that you agree \nwith our Term and Condition",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF757575),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // ✅ Form Key for validation


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // ✅ Assign form key
      child: Column(
        children: [
          TextFormField(
            controller: firstNameController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "First name cannot be empty!";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Enter your first name",
              labelText: "First Name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: AppBorders.authOutlineInputBorder,
            ),
          ),
          const SizedBox(height: 16),

          /// 🔹 **Last Name Field**
          TextFormField(
            controller: lastNameController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Last name cannot be empty!";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Enter your last name",
              labelText: "Last Name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: AppBorders.authOutlineInputBorder,
            ),
          ),
          const SizedBox(height: 16),
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
              suffix: SvgPicture.string(AppIcons.mailIcon),
              border: AppBorders.authOutlineInputBorder,
              enabledBorder: AppBorders.authOutlineInputBorder,
              focusedBorder: AppBorders.authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFE9901)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
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
                suffix: SvgPicture.string(AppIcons.lockIcon),
                border: AppBorders.authOutlineInputBorder,
                enabledBorder: AppBorders.authOutlineInputBorder,
                focusedBorder: AppBorders.authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFFFE9901)),
                ),
              ),
            ),
          ),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please confirm your password!";
              } else if (value != passwordController.text.trim()) {
                return "Passwords do not match!";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Re-enter your password",
              labelText: "Confirm Password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffix: SvgPicture.string(AppIcons.lockIcon),
              border: AppBorders.authOutlineInputBorder,
              enabledBorder: AppBorders.authOutlineInputBorder,
              focusedBorder: AppBorders.authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFE9901)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Obx(() => authController.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                authController.signUp(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                  firstNameController.text.trim(),
                  lastNameController.text.trim(),

                );
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFE9901),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: const Text("Continue"),
          )),
        ],
      ),
    );
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
