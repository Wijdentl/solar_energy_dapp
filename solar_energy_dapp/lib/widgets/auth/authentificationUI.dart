import 'package:flutter/material.dart';
import 'dart:math';
import 'authentification_service.dart';
import 'User.dart';
import '../../SolarEnergyUI.dart';

class AuthentificationUI extends StatefulWidget {
  @override
  _AuthentificationUIState createState() => _AuthentificationUIState();
}

class _AuthentificationUIState extends State<AuthentificationUI> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isRegisterMode = false;
  bool _isPasswordVisible = false;

  // AuthenticationService instance
  final AuthentificationService authService = AuthentificationService();

  String get _username => _usernameController.text.trim();
  String get _password => _passwordController.text.trim();
  String get _confirmPassword => _confirmPasswordController.text.trim();
  String get _phone => _phoneController.text.trim();

  bool _isUsernameValid() => _username.length >= 3;
  bool _isPasswordValid() => _password.length >= 8;
  bool _isConfirmPasswordValid() => _password == _confirmPassword;
  bool _isPhoneValid() => _phone.length >= 8;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _authenticate() async {
    if (_isRegisterMode) {
      if (!_isUsernameValid() ||
          !_isPasswordValid() ||
          !_isConfirmPasswordValid() ||
          !_isPhoneValid()) {
        return;
      }
      await authService.addUser(
          User("", name: _username, password: _password, phone: _phone));
      setState(() {
        _isRegisterMode = false;
      });
    } else {
      final isAuthenticated = await authService.signIn(_username, _password);
      if (isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SolarEnergyUI()),
        );
      }
    }
  }

  void _toggleVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.orange.shade100,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(
          children: [
            // Left Side: Form Fields
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isRegisterMode ? "Register" : "Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Username TextField
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.person,
                      validator: _isUsernameValid,
                      errorMessage: "Username must be at least 3 characters",
                    ),
                    SizedBox(height: 15),

                    // Password TextField
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: _toggleVisibility,
                      ),
                      validator: _isPasswordValid,
                      errorMessage: "Password must be at least 8 characters",
                    ),
                    SizedBox(height: 15),

                    // Confirm Password TextField (only for register mode)
                    if (_isRegisterMode)
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock,
                        obscureText: !_isPasswordVisible,
                        validator: _isConfirmPasswordValid,
                        errorMessage: "Passwords do not match",
                      ),
                    SizedBox(height: 15),

                    // Phone TextField (only for register mode)
                    if (_isRegisterMode)
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        validator: _isPhoneValid,
                        errorMessage: "Phone number must be at least 8 digits",
                      ),

                    SizedBox(height: 25),

                    // Action Button
                    ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade500,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        _isRegisterMode ? "Register" : "Login",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),

                    // Switch between Register/Login
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegisterMode = !_isRegisterMode;
                        });
                      },
                      child: Text(
                        _isRegisterMode
                            ? "Already have an account? Login"
                            : "Don't have an account? Register",
                        style: TextStyle(color: Colors.orange.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Side: Abstract Design
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade200, Colors.orange.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    painter: SolarAbstractPainter(),
                    child: Container(
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for TextField widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required bool Function() validator,
    required String errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: (_) => setState(() {}), // Trigger validation on input
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.orange.shade600),
            prefixIcon: Icon(icon, color: Colors.orange.shade600),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
            ),
          ),
        ),
        if (controller.text.isNotEmpty && !validator())
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class SolarAbstractPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background gradient
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.orange.shade300.withOpacity(0.3),
          Colors.orange.shade500.withOpacity(0.6),
        ],
        center: Alignment.center,
        radius: 0.7,
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    canvas.drawCircle(center, size.width / 2, backgroundPaint);

    // Abstract sun rays
    final rayPaint = Paint()
      ..color = Colors.orange.shade100.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw multiple rays radiating from the center
    final rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 360 / rayCount) * (pi / 180);
      final start = center;
      final end = Offset(center.dx + cos(angle) * size.width * 0.7,
          center.dy + sin(angle) * size.width * 0.7);

      // Curved rays
      final controlPoint1 = Offset(center.dx + cos(angle) * size.width * 0.3,
          center.dy + sin(angle) * size.width * 0.3);
      final controlPoint2 = Offset(center.dx + cos(angle) * size.width * 0.5,
          center.dy + sin(angle) * size.width * 0.5);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
            controlPoint2.dy, end.dx, end.dy);

      canvas.drawPath(path, rayPaint);
    }

    // Central highlight
    final centerHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width * 0.2, centerHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
