import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/constans/variables.dart';
import 'package:fertilizer_calculator/core/helpers/navigation.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/new_password_page.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/password_recovery_page.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_back_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_input_code.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationCode extends StatefulWidget {
  final String email;

  const VerificationCode({Key? key, required this.email}) : super(key: key);

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  bool _isLoading = false;
  String _otp = "";
  late String email;

  int _timerSeconds = 180; // 3 menit
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
        _startCountdown();
      } else {
        setState(() {
          _canResendOtp = true; // Aktifkan tombol setelah timer habis
        });
      }
    });
  }

  Future<void> verifyOtp() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit code.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    const String apiUrl =
        Variables.baseUrl + "/verify-otp"; // Ganti dengan URL API

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": widget.email,
          "otp": _otp,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Jika OTP valid, pindah ke halaman password baru
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'OTP Verified')),
        );
        NavigatorHelper.slideTo(
            context, NewPasswordPage(email: email, otp: _otp));
      } else {
        // Jika OTP salah
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? 'Invalid OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> resendOtp() async {
    _startCountdown();
    setState(() {
      _isLoading = true;
      _canResendOtp = false;
      _timerSeconds = 120; // Reset waktu
    });

    const String apiUrl = Variables.baseUrl + "/forgot-pw";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": widget.email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'OTP Sent')),
        );
        _startCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['error'] ?? 'Failed to resend OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending OTP. Try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          top: 60,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton(
                context: context,
                destination: const PasswordRecoveryPage(),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Verification OTP",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: screenWidth * 0.06,
                    ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Input the OTP Code",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: screenWidth * 0.04,
                    ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "We've sent the code to your email ${widget.email}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: screenWidth * 0.04,
                    ),
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomPinCode(
                onChanged: (value) {
                  setState(() {
                    _otp = value;
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Please wait another ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                  ),
                  Text(
                    "${_timerSeconds.toString()} ",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.Secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                  ),
                  Text(
                    "seconds, to resend the OTP code.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          Column(
            children: [
              ElevatedButton(
                onPressed: _canResendOtp ? resendOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canResendOtp ? AppColors.primary : Colors.grey,
                  foregroundColor:
                      _canResendOtp ? Colors.white : Colors.black54,
                  minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Send Again",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              ElevatedButton(
                onPressed: verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
