import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:photoapp/photo_list_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // 入力内容のvalidationのため
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // 入力内容取得のため
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _onSignIn() async {
    try {
      if (_formKey.currentState?.validate() != true) {
        return;
      }

      final String email = _emailController.text;
      final String password = _passwordController.text;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PhotoListScreen(),
        ),
      );
    } catch (e) {
      await showDialog(
          context: context,
          builder: (context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(e.toString()),
        );
      }
    );
  }
  }

  Future<void> _onSignUp() async {
    try {
      if (_formKey.currentState?.validate() != true) {
        return;
      }

      final String email = _emailController.text;
      final String password = _passwordController.text;
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PhotoListScreen(),
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text(e.toString()),
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, //validation用
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Photo App',
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value?.isEmpty == true) {
                      return 'メースアドレスを入力してください';
                    }
                    return null;
                  }
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'パスワード'),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (String? value) {
                    if (value?.isEmpty == true) {
                      return 'パスワードを入力してください';
                    }
                    return null;
                  }
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onSignIn(),
                    child: Text('ログイン'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onSignUp(),
                    child: Text('新規登録'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}