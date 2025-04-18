import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileForgotPasswordPage extends StatefulWidget {
  const MobileForgotPasswordPage({super.key});

  @override
  State<MobileForgotPasswordPage> createState() =>
      _MobileForgotPasswordPageState();
}

class _MobileForgotPasswordPageState extends State<MobileForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  // Hover state variables
  bool _isEmailHovered = false;
  bool _isResetButtonHovered = false;

  // Blue highlight color
  final Color _highlightColor = Color(0xFF2196F3);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void resetPassword() {
    if (_formKey.currentState!.validate()) {
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

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.1),
            Center(
              child: Image.asset(
                'assets/Image/logo.png',
                width: screenWidth * 0.5,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Reset Password',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Enter your email and we\'ll send you instructions to reset your password',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 20),
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
                  MouseRegion(
                    onEnter: (_) => setState(() => _isEmailHovered = true),
                    onExit: (_) => setState(() => _isEmailHovered = false),
                    child: TextFormField(
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
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Color(0xFF141414),
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
                            color: Colors.redAccent.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                _isEmailHovered
                                    ? _highlightColor
                                    : Color(0xFF1A1A1A),
                            width: _isEmailHovered ? 1.5 : 1,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Reset Password button
                  MouseRegion(
                    onEnter:
                        (_) => setState(() => _isResetButtonHovered = true),
                    onExit:
                        (_) => setState(() => _isResetButtonHovered = false),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A1A1A),
                          disabledBackgroundColor: Color(
                            0xFF1A1A1A,
                          ).withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  _isResetButtonHovered
                                      ? _highlightColor
                                      : Color(0xFF333333),
                              width: _isResetButtonHovered ? 1.5 : 1,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
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
                  if (_isEmailSent) ...[
                    // Success message and icon
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 80,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Email Sent Successfully!',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'We\'ve sent password reset instructions to:\n${_emailController.text}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[400],
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Please check your inbox and follow the instructions to reset your password.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 30),
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
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1A1A1A),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          _isResetButtonHovered
                                              ? _highlightColor
                                              : Color(0xFF333333),
                                      width: _isResetButtonHovered ? 1.5 : 1,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
