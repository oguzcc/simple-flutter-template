part of '../button.dart';

class ButtonWithIconParam {
  ButtonWithIconParam({
    required this.title,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
  });
  final String title;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback onPressed;
}

class _ButtonWithIcon extends StatelessWidget {
  const _ButtonWithIcon(this.param);
  final ButtonWithIconParam param;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: param.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (param.leadingIcon != null) ...[param.leadingIcon!],
          const Spacer(),
          Text(param.title),
          const Spacer(),
          if (param.trailingIcon != null) ...[param.trailingIcon!],
        ],
      ),
    );
  }
}
