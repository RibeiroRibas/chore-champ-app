import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';

class AuthSignUpLinkComponent extends StatelessWidget {
  const AuthSignUpLinkComponent({
    super.key,
    required this.onPressed,
    this.promptText = AppStrings.dontHaveAccount,
    this.linkText = AppStrings.createOne,
  });

  final VoidCallback onPressed;
  final String promptText;
  final String linkText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(promptText, style: Theme.of(context).textTheme.bodySmall),
        TextButton(
          onPressed: onPressed,
          child: Text(linkText),
        ),
      ],
    );
  }
}
