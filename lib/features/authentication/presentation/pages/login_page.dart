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
  Future<UserCredential>? autenticado;
  bool _isPasswordVisible = false;
  String _email = "";
  String _password = "";

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

  void signIn() {
    auth
        .signInWithEmailAndPassword(
          email: _email,
          password: _password,
        )
        .then(
          (value) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          ),
        );
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
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      _email = value;
                    },
                  ),
                ),
                Stack(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Senha",
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _isPasswordVisible ? false : true,
                      onChanged: (value) {
                        _password = value;
                      },
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
                    if (_email.isNotEmpty && _password.isNotEmpty) signIn();
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ), // _ActionButtons(),
        ],
      ),
    );
  }
}
