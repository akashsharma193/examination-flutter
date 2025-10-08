import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class ForceUpdateWrapper extends StatelessWidget {
  final Widget child;

  const ForceUpdateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      showIgnore: false,
      showLater: false,
      shouldPopScope: () => false,
      dialogStyle: UpgradeDialogStyle.cupertino,
      showReleaseNotes: false,
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
        messages: CustomUpgraderMessages(),
      ),
      child: child,
    );
  }
}

class CustomUpgraderMessages extends UpgraderMessages {
  @override
  String get title => 'Update Required';

  @override
  String get body =>
      'A new version of the app is available. Please update to continue using the app.';

  @override
  String get buttonTitleUpdate => 'Update Now';

  @override
  String get buttonTitleIgnore => 'Skip';

  @override
  String get buttonTitleLater => 'Later';

  @override
  String get prompt => 'Would you like to update the app now?';
}
