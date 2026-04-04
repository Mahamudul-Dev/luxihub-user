import 'package:flutter/material.dart';

import '../../../../core/config/assets.dart';
import '../../../../core/config/utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text_input_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(Utils.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: Utils.defaultPadding,
          children: [
            // image
            Image.asset(Assets.appLogo, width: 200),
        
            Text('Continue with', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary
            ),),
        
            // social login buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Utils.defaultPadding,
              children: [
                // google
                IconButton(onPressed: (){}, icon: Image.asset(Assets.google_logo, height: 40, width: 40)),
        
                // facebook
                IconButton(onPressed: (){}, icon: Image.asset(Assets.facebook_logo, height: 40, width: 40)
                ),
        
                // x
                IconButton(onPressed: (){}, icon: Image.asset(Assets.x_logo, height: 40, width: 40)
                ),
              ],
            ),
        
            TextInputField(
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            TextInputField(
              label: 'Password',
              obscureText: true,
              showPasswordToggle: true,
            ),  

            ElevatedButton(onPressed: (){}, child: Text('Login')),

            // Don't have an account? Sign up 
            Text('Don\'t have an account?'),
            TextButton(onPressed: (){}, child: Text('Sign up', style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16
            ),))
          ],
        ),
      )
    );
  }
}