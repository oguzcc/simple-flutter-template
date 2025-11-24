part of '../tile.dart';

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    required this.title,
    required this.onTap,
    this.color,
    this.prefixIcon,
    this.suffixIcon,
  });
  final String title;

  final Color? color;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      title:
          Text(title, style: context.text.bodyMedium?.copyWith(color: color)),
      leading: Icon(prefixIcon, color: color),
      trailing: Icon(suffixIcon, color: color),
      onTap: onTap,
    );
  }
}
