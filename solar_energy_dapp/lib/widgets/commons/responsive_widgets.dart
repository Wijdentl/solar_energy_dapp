import 'package:flutter/material.dart';

class RowOrColumn extends StatelessWidget {
  final List<Widget> children;

  final MainAxisAlignment rowMainAxisAlignment;
  final MainAxisSize rowMainAxisSize;
  final CrossAxisAlignment rowCrossAxisAlignment;

  final MainAxisAlignment columnMainAxisAlignment;
  final MainAxisSize columnMainAxisSize;
  final CrossAxisAlignment columnCrossAxisAlignment;

  final bool showRow;

  final bool intrinsicRow;

  const RowOrColumn(
      {Key? key,
        this.intrinsicRow = false,
        this.rowMainAxisAlignment = MainAxisAlignment.start,
        this.rowMainAxisSize = MainAxisSize.max,
        this.rowCrossAxisAlignment = CrossAxisAlignment.center,
        this.columnMainAxisAlignment = MainAxisAlignment.start,
        this.columnMainAxisSize = MainAxisSize.max,
        this.columnCrossAxisAlignment = CrossAxisAlignment.center,
        this.showRow = true,
        this.children = const <Widget>[]})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return showRow
        ? IntrinsicHeightIf(
      intrinsic: intrinsicRow,
      child: Row(
        mainAxisAlignment: rowMainAxisAlignment,
        crossAxisAlignment: rowCrossAxisAlignment,
        mainAxisSize: rowMainAxisSize,
        children: children,
      ),
    )
        : Column(
      crossAxisAlignment: columnCrossAxisAlignment,
      mainAxisAlignment: columnMainAxisAlignment,
      mainAxisSize: columnMainAxisSize,
      children: children,
    );
  }
}

class IntrinsicHeightIf extends StatelessWidget {
  final bool intrinsic;
  final Widget child;

  const IntrinsicHeightIf(
      {Key? key, this.intrinsic = false, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return intrinsic
        ? IntrinsicHeight(
      child: child,
    )
        : child;
  }
}

class ExpandedIf extends StatelessWidget {
  final bool expanded;
  final Widget child;
  final int flex;

  const ExpandedIf(
      {Key? key, this.expanded = true, required this.child, this.flex = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return expanded
        ? Expanded(
      flex: flex,
      child: child,
    )
        : child;
  }
}

class PaddingSwitch extends StatelessWidget {
  final bool switchIf;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets switchedPadding;

  const PaddingSwitch(
      {this.switchIf = false,
        required this.child,
        this.padding = EdgeInsets.zero,
        this.switchedPadding = EdgeInsets.zero,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: switchIf ? switchedPadding : padding,
      child: child,
    );
  }
}