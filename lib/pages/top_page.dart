import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zundatalk/pages/login_page.dart';
import 'package:zundatalk/pages/signup_page.dart';
import 'package:zundatalk/pages/talk_page.dart';
import 'package:zundatalk/widgets/app_button.dart';
import 'package:zundatalk/widgets/app_logo.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TalkPage(),
          ),
        );
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
              padding: const EdgeInsets.all(16),
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 24),
                  const Text('ズンダトークへようこそなのだ！', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('まずはログインしてくださいなのだ！', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        width: 100,
                        onPressed: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        text: 'ただいま！',
                      ),
                      const SizedBox(width: 16),
                      AppButton(
                        width: 100,
                        onPressed: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        text: '初めまして！',
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