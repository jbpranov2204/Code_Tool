import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:code_tool/pages/desktop_page.dart'; // Import DesktopPage

class DesktopLoginPage extends StatefulWidget {
  const DesktopLoginPage({super.key});

  @override
  State<DesktopLoginPage> createState() => _LoginState();
}

class _LoginState extends State<DesktopLoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void signIn(String email, String password) {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      // Navigate to DesktopPage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DesktopPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Even darker black background
      body: Row(
        children: [
          // Left side with image or gradient
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF111111), // Very dark gray
                    Color(0xFF161616), // Dark gray
                    Color(0xFF1A1A1A), // Medium dark gray
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(5, 0),
                  ),
                ],
              ),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.25,
                        child: Image.asset('assets/Image/logo.png'),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.poppins(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: screenWidth * 0.3,
                        child: Text(
                          'Login to access your dashboard and continue your journey with us',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Right side with login form
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              color: Color(0xFF0A0A0A), // Darkest black background
              child: Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: screenWidth * 0.3,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Please enter your credentials to continue',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 40),
                            
                            // Email field
                            Text(
                              'Email Address',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[300],
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value == null || !value.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'abc@gmail.com',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[700]),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                                filled: true,
                                fillColor: Color(0xFF141414), // Slightly lighter black
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF333333), width: 1), // Very dark gray border
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 1), // Dark gray border
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            SizedBox(height: 24),
                            
                            // Password field
                            Text(
                              'Password',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[300],
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value!.length <= 6) {
                                  return 'Password should be greater than 6';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[700]),
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Color(0xFF141414), // Slightly lighter black
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF333333), width: 1), // Very dark gray border
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 1), // Dark gray border
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            
                            // Forgot password
                            Container(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading 
                                    ? null 
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          signIn(_emailController.text, _passwordController.text);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1A1A1A), // Dark gray button
                                  disabledBackgroundColor: Color(0xFF1A1A1A).withOpacity(0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Color(0xFF333333), width: 1),
                                  ),
                                ),
                                child: _isLoading 
                                    ? SizedBox(
                                        height: 20, 
                                        width: 20, 
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            
                            // Sign up section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Not Having an Account?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}