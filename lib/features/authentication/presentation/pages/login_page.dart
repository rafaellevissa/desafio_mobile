import 'package:desafio/features/home/presentation/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  bool _validateEmail = false;
  bool _validatePassword = false;

  var snackBar;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    Future(() {
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    });
    super.initState();
  }

  void signIn() async {
    setState(() {
      _loading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.value.text, password: _password.value.text);
      if (auth.currentUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          _showMessage('No user found for that email.'),
        );
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          _showMessage('Wrong password provided for that user.'),
        );
        print('Wrong password provided for that user.');
      }
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: _buildLoginFields(context),
        ),
      ),
    );
  }

  Widget _buildLoginFields(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  child: TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      errorText:
                          _validateEmail ? 'Value Can\'t Be Empty' : null,
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Stack(
                  children: [
                    TextField(
                      controller: _password,
                      decoration: InputDecoration(
                        errorText:
                            _validatePassword ? 'Value Can\'t Be Empty' : null,
                        labelText: "Senha",
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _isPasswordVisible ? false : true,
                    ),
                    Positioned(
                      right: 0.0,
                      top: 25,
                      child: GestureDetector(
                        onTap: () {
                          setState(
                              () => _isPasswordVisible = !_isPasswordVisible);
                        },
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () {
                    setState(() {
                      _email.text.isEmpty
                          ? _validateEmail = true
                          : _validateEmail = false;
                      _password.text.isEmpty
                          ? _validatePassword = true
                          : _validatePassword = false;
                    });
                    if (_email.text.isNotEmpty &&
                        _password.text.isNotEmpty &&
                        !_loading) signIn();
                  },
                  child: !_loading
                      ? Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )
                      : CircularProgressIndicator(color: Colors.white),
                ),
              ],
            ),
          ), // _ActionButtons(),
        ],
      ),
    );
  }

  SnackBar _showMessage(String message) {
    return SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
  }
}
