import 'package:flutter/material.dart';
import '../widgets/auth/auth_wrapper.dart';

abstract class DialogUtil {
  static openLoginPopup(BuildContext context, {bool dismissible = true, bool isRegister = false}) {
    showDialog(
        context: context,
        barrierDismissible: dismissible,
        builder: (context) => WillPopScope(
              onWillPop: () async => dismissible,
              child: Dialog(
                insetPadding: const EdgeInsets.all(10),
                backgroundColor: Colors.transparent,
                child: AuthWrapper(isRegister: isRegister,)
              ),
            ));
  }
  
}

