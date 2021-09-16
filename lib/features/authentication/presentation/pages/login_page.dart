import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AxessHeader(
              //   hasLogo: true,
              //   hasBackButton: true,
              // ),
              _buildLoginPage()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 20),
          _LoginFields(),
          // _ActionButtons(),
        ],
      ),
    );
  }
}

class _LoginFields extends StatefulWidget {
  const _LoginFields({Key? key}) : super(key: key);

  @override
  __LoginFieldsState createState() => __LoginFieldsState();
}

class __LoginFieldsState extends State<_LoginFields> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Login',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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
            onChanged: (value) {},
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
              onChanged: (value) {},
            ),
            Positioned(
              right: 0.0,
              top: 25,
              child: GestureDetector(
                onTap: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                child: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// class _ActionButtons extends StatelessWidget {
//   Widget _showDefaultButton(BuildContext context) {
//     // if (loginBloc == null) {
//     //   return CustomRaisedButton(
//     //     onTap: null,
//     //     height: 51,
//     //     text: 'Log in',
//     //     textColor: Constants.WHITE,
//     //     color: Constants.MAIN_GREEN,
//     //     disabledColor: Constants.PLACEHOLDER_GREY_TEXT,
//     //   );
//     // }

//     return AxessPageButton(
//       text: 'Log in',
//       bgColor: Constants.GOLDEN,
//       onTapFunc: () {
//         Navigator.push(
//           context,
//           FadeOutInRoute(
//             enterPage: MyPreferencesPage(),
//             settings: RouteSettings(name: ""),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Center(
//           child: TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 FadeOutInRoute(
//                   enterPage: SignUpPage(),
//                   settings: RouteSettings(name: ""),
//                 ),
//               );
//             },
//             child: Text(
//               'Create account',
//               style: TextStyle(
//                 color: Constants.TEXT_BUTTON_DARK_BLUE,
//                 fontWeight: FontWeight.w400,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//         Center(
//           child: TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 FadeOutInRoute(
//                   enterPage: ForgotPasswordPage(),
//                   settings: RouteSettings(name: ""),
//                 ),
//               );
//             },
//             child: Text(
//               'Forgot Password?',
//               style: TextStyle(
//                 color: Constants.TEXT_BUTTON_DARK_BLUE,
//                 fontWeight: FontWeight.w400,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//         Container(height: 20),
//         Row(
//           children: [
//             Expanded(
//               child: StreamBuilder(
//                 initialData: false,
//                 // stream: loginBloc.submitValid,
//                 builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
//                   if (snapshot.data != null) {
//                     if (snapshot.data == true) {
//                       // return Container(child: _showDefaultButton(loginBloc, context));
//                       return Container(
//                         child: _showDefaultButton(null, context),
//                       );
//                     }
//                     return Container(
//                       child: _showDefaultButton(null, context),
//                     );
//                   }
//                   return Container(
//                     child: _showDefaultButton(null, context),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
