import 'package:flutter/material.dart';
import '../core/constants.dart';
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Text(
              message!,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}
