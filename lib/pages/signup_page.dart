import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zundatalk/pages/talk_page.dart';
import 'package:zundatalk/widgets/app_logo.dart';
import 'package:zundatalk/widgets/app_text_form_field.dart';

import '../widgets/app_button.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  'はじめましてなのだ！',
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
                      const SizedBox(height: 24),
                      AppTextFormField(
                        controller: _confirmPasswordController,
                        labelText: 'もういちどぱすわーど',
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'ぱすわーどが違うのだ！';
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
                    // バリデーションエラーがある場合、処理を中断
                    if (!_formKey.currentState!.validate()) return;

                    final result = await _signup(
                      context,
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    // この時点で画面が破棄されている場合、処理を中断
                    if (result == null || !mounted) return;

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => TalkPage(),
                      ),
                    );
                  },
                  text: '新規登録するのだ！',
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('お久しぶりなのだ?'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text('ろぐいんするのだ！'),
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

  Future<dynamic> _signup(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      setState(() {
        _isLoading = true;
      });
      return await Supabase.instance.client.auth.signUp(email: email, password: password);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
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