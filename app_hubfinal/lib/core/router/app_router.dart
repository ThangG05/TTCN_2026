import 'package:app_hubfinal/modules/auth/pages/forgot/forgot_otp_page.dart';
import 'package:app_hubfinal/modules/auth/pages/forgot/forgot_password_page.dart';
import 'package:app_hubfinal/modules/auth/pages/forgot/reset_password_page.dart';
import 'package:app_hubfinal/modules/auth/pages/signup/otp_page.dart';
import 'package:flutter/material.dart';
import '../../modules/auth/pages/signin/login_page.dart';
import '../../modules/auth/pages/signup/register_page.dart';
import '../../modules/auth/pages/forgot/welcome_back_page.dart';
import '../../modules/auth/pages/welcome_page.dart';
import '../../modules/auth/pages/onboarding_page.dart';
import '../../modules/home/home_page.dart';
import '../../modules/user/pages/edit_profile_page.dart';
class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const WelcomePage(),
    '/onboarding': (context) => const OnboardingPage(),
    '/email': (context) => RegisterPage(),
    '/signin': (_) => const LoginPage(),
    '/welcome-back': (_) => const WelcomeBackPage(),
    '/home': (_) => const HomePage(),
    '/forgot-password' : (_) => const ForgotPasswordPage(),
    '/reset-password' : (_) => const ResetPasswordPage(),
    '/edit-profile': (_) => const EditProfilePage(),
  };
}