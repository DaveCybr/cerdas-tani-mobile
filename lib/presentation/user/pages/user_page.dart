import 'package:fertilizer_calculator/presentation/user/pages/widgets/logout_button.dart';
import 'package:fertilizer_calculator/presentation/user/pages/widgets/profile_header.dart';
import 'package:fertilizer_calculator/presentation/user/pages/widgets/profile_setting.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "My Profile",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ProfileHeader(),
            SizedBox(height: 20),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 20),
            LogoutButton(),
          ],
        ),
      ),
    );
  }
}
