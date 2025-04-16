import 'package:flutter/material.dart';

class DesktopLoginPage extends StatefulWidget {
  const DesktopLoginPage({super.key});

  @override
  State<DesktopLoginPage> createState() => Login();
}

class Login extends State<DesktopLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void signIn(String email, password) {

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.1;
    final logoWidth = screenWidth * 0.5;
    final formFieldWidth = screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Container(
                width: logoWidth,
                child: Image.asset('assets/Image/logo.png'),
              ),
              SizedBox(height: screenHeight * 0.04),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: SizedBox(
                        width: formFieldWidth,
                        child: TextFormField(
                          validator: (value) {
                            if (!value.toString().contains('@gmail.com')) {
                              return 'Enter a valid Gmail';
                            } else {
                              return null;
                            }
                          },
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email',
                            hintText: 'abc@gmail.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: SizedBox(
                        width: formFieldWidth,
                        child: TextFormField(
                          obscureText: true,
                          validator: (value) {
                            if (value!.length <= 6) {
                              return 'Password should be greater than 6';
                            } else {
                              return null;
                            }
                          },
                          controller: _passwordController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.045),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signIn(
                              _emailController.text, _passwordController.text);
                        }
                      },
                      child: Text('Login'),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text('Not Having an Account?'),
                    TextButton(
                      onPressed: () {},
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}