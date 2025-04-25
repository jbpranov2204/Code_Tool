import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WebForgotPasswordPage extends StatefulWidget {
  const WebForgotPasswordPage({super.key});

  @override
  State<WebForgotPasswordPage> createState() => _WebForgotPasswordPageState();
}

class _WebForgotPasswordPageState extends State<WebForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  // Hover state variables
  bool _isEmailHovered = false;
  bool _isResetButtonHovered = false;

  // Blue highlight color
  final Color _highlightColor = const Color(0xFF2196F3);

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
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network delay for password reset request
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _isEmailSent = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: Row(
        children: [
          // Left side with gradient background
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/bg.jpg',
                  ), // Add your asset image here
                  fit: BoxFit.cover,
                ),
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
                      const SizedBox(height: 30),
                      Text(
                        'Reset Password',
                        style: GoogleFonts.poppins(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: screenWidth * 0.3,
                        child: Text(
                          'Enter your email and we\'ll send you instructions to reset your password',
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

          // Right side with forgot password form
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              color: const Color(0xFF0A0A0A),
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
                            // Back button
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Forgot Password',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isEmailSent
                                  ? 'Password reset instructions sent to your email'
                                  : 'Please enter your email to receive reset instructions',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color:
                                    _isEmailSent
                                        ? Colors.green[400]
                                        : Colors.grey[500],
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 40),

                            if (!_isEmailSent) ...[
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
                              const SizedBox(height: 8),
                              MouseRegion(
                                onEnter:
                                    (_) =>
                                        setState(() => _isEmailHovered = true),
                                onExit:
                                    (_) =>
                                        setState(() => _isEmailHovered = false),
                                child: TextFormField(
                                  controller: _emailController,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        !value.contains('@')) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'abc@gmail.com',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[700],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.grey[600],
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF141414),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _highlightColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.redAccent.withOpacity(
                                          0.5,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            _isEmailHovered
                                                ? _highlightColor
                                                : const Color(0xFF1A1A1A),
                                        width: _isEmailHovered ? 1.5 : 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Reset Password button
                              MouseRegion(
                                onEnter:
                                    (_) => setState(
                                      () => _isResetButtonHovered = true,
                                    ),
                                onExit:
                                    (_) => setState(
                                      () => _isResetButtonHovered = false,
                                    ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A1A1A),
                                      disabledBackgroundColor: const Color(
                                        0xFF1A1A1A,
                                      ).withOpacity(0.6),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color:
                                              _isResetButtonHovered
                                                  ? _highlightColor
                                                  : const Color(0xFF333333),
                                          width:
                                              _isResetButtonHovered ? 1.5 : 1,
                                        ),
                                      ),
                                    ),
                                    child:
                                        _isLoading
                                            ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : Text(
                                              'Reset Password',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Success message and icon
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 80,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Email Sent Successfully!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'We\'ve sent password reset instructions to:\n${_emailController.text}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Please check your inbox and follow the instructions to reset your password.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    // Return to login button
                                    MouseRegion(
                                      onEnter:
                                          (_) => setState(
                                            () => _isResetButtonHovered = true,
                                          ),
                                      onExit:
                                          (_) => setState(
                                            () => _isResetButtonHovered = false,
                                          ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1A1A1A,
                                            ),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: BorderSide(
                                                color:
                                                    _isResetButtonHovered
                                                        ? _highlightColor
                                                        : const Color(
                                                          0xFF333333,
                                                        ),
                                                width:
                                                    _isResetButtonHovered
                                                        ? 1.5
                                                        : 1,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Return to Login',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: screenHeight * 0.04),

                            // Back to login link
                            if (!_isEmailSent)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Remember your password?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Back to Login',
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
