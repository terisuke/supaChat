import 'package:flutter/material.dart';
import 'package:zundatalk/pages/signup_page.dart';
import 'package:zundatalk/widgets/app_logo.dart';
import 'package:zundatalk/widgets/app_text_form_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_button.dart';
import 'talk_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

    @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(),
                const SizedBox(height: 24),
                const Text(
                  'おかえりなのだ！',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextFormField(
                        controller: _emailController,
                        labelText: 'めーる',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'めーるは必須なのだ！';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      AppTextFormField(
                        controller: _passwordController,
                        labelText: 'ぱすわーど',
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'ぱすわーどは必須なのだ！';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  height: 48,
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final result = await _login(
                      context,
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    if (result == null || !mounted) return;

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => TalkPage(),
                      ),
                    );
                  },
                  text: 'ぽちっとなのだ！',
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("はじめましてなのだ?"),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text('新規登録するのだ！'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      setState(() {
        _isLoading = true;
      });
      return await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}