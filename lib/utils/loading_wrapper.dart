// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';

import '../theme/app_them_data.dart';

class LoadingWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingWrapper({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (!isLoading) ...[
          const SizedBox.shrink(),
        ] else ...[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black87),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppThemData.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppThemData.primary300)

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}