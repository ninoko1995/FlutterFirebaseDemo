import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:photoapp/providers.dart';
import 'package:photoapp/credentials.dart';
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

  Future<void> _onSignIn(User? user) async {
    try {
      if (_formKey.currentState?.validate() != true) {
        return;
      }

      final String email = _emailController.text;
      final String password = _passwordController.text;
      final AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      if (user !=null && user.isAnonymous) {
        await user.linkWithCredential(credential);
        Navigator.of(context).pop();
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PhotoListScreen(),
            ),
          );
        }
      }

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

  Future<void> _onSignInWithGoogle(User? user) async {
    try{
      final googleLogin = GoogleSignIn(scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ]);

      GoogleSignInAccount? signinAccount = await googleLogin.signIn();
      if (signinAccount == null) return;

      GoogleSignInAuthentication auth = await signinAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      if (user !=null && user.isAnonymous) {
        await user.linkWithCredential(credential);
        Navigator.of(context).pop();
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PhotoListScreen(),
            ),
          );
        }
      }
    } catch(e) {
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

  Future<void> _onSignInWithTwitter(User? user) async {
    try{
      final twitterLogin = TwitterLogin(
        apiKey: apiKey,
        apiSecretKey: apiSecretKey,
        redirectURI: redirectURI,
      );
      final authResult = await twitterLogin.login();
      if (authResult.status != TwitterLoginStatus.loggedIn) {
        print("cannot fetch auth data from twitter");
        return;
      }

      AuthCredential credential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      if (user !=null && user.isAnonymous) {
        await user.linkWithCredential(credential);
        Navigator.of(context).pop();
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PhotoListScreen(),
            ),
          );
        }
      }
    } catch(e) {
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

  Future<void> _onSignInWithApple(User? user) async {
    try{
      print("=============================================================");
      print("start!");
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print("=============================================================");
      print(appleCredential);
      print(appleCredential.userIdentifier);
      print(appleCredential.givenName);
      print(appleCredential.familyName);
      print(appleCredential.authorizationCode);
      print(appleCredential.email);
      print(appleCredential.identityToken);
      print(appleCredential.state);
      

      OAuthProvider oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (user !=null && user.isAnonymous) {
        await user.linkWithCredential(credential);
        Navigator.of(context).pop();
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PhotoListScreen(),
            ),
          );
        }
      }
    } catch(e) {
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

  Future<void> _onSignInWithAnonymousUser(User? user) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try{
      if (user !=null && user.isAnonymous) {
        Navigator.of(context).pop();

      } else {
        await firebaseAuth.signInAnonymously();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PhotoListScreen(),
          ),
        );
      }
    } catch(e) {
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
    return Consumer(builder: (context, watch, child) {
      final asyncUser = watch(userProvider);
      return asyncUser.when(
        data: (User? user) {
          final isAnonymous = user != null && user.isAnonymous;
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
                        !isAnonymous ? 'Photo App' : ' アカウントをリンク',
                        style: !isAnonymous ? Theme.of(context).textTheme.headline4 : Theme.of(context).textTheme.headline5,
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
                          onPressed: () => _onSignIn(user),
                          child: Text(!isAnonymous ? 'ログイン' : 'メールアドレスを追加'),
                        ),
                      ),
                      if (!isAnonymous) SizedBox(height: 8),
                      if (!isAnonymous) SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _onSignUp(),
                          child: Text('新規登録'),
                        ),
                      ),
                      SizedBox(height: 8),
                      SignInButton(
                        Buttons.Google,
                        onPressed: () {
                          _onSignInWithGoogle(user);
                        },
                      ),
                      SignInButton(
                        Buttons.Twitter,
                        onPressed: () {
                          _onSignInWithTwitter(user);
                        },
                      ),
                      if (Platform.isIOS) SignInButton(
                          Buttons.Apple,
                          onPressed: () {
                            _onSignInWithApple(user);
                          },
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () => _onSignInWithAnonymousUser(user),
                            child: Text(!isAnonymous ? '登録せず利用' : 'キャンセル'),
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () {
          return Container();
        },
        error: (e, stackTrace) {
          return Container();
        },
      );
    });
  }
}