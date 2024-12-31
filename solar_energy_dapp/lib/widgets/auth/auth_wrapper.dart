import 'package:flutter/material.dart';
import 'package:solar_energy_dapp/constants/colors.dart';
import 'package:solar_energy_dapp/utils/responsive_util.dart';
import 'package:solar_energy_dapp/widgets/auth/auth_curve.dart';

import 'package:solar_energy_dapp/widgets/commons/responsive_widgets.dart';

class AuthWrapper extends StatefulWidget {
  final bool isRegister;

  const AuthWrapper({Key? key, this.isRegister = false}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late bool _isRegisterPage;

  @override
  void initState() {
    super.initState();
    _isRegisterPage = widget.isRegister;
  }

  void _switchPage({bool isRegisterPage = false}) {
    setState(() => _isRegisterPage = isRegisterPage);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (responsiveUtil) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          color: Colors.white,
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: RawMaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () => Navigator.of(context).pop(),
                  constraints: BoxConstraints.tight(const Size(22, 22)),
                  fillColor: responsiveUtil.value<Color>(
                      mobile: Colors.white,
                      desktop: themeColorDarkest,
                      tablet: themeColorDarkest),
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: responsiveUtil.value<Color>(
                        mobile: themeColorDarkest,
                        desktop: Colors.white,
                        tablet: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
