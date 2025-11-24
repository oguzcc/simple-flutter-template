part of '../picker.dart';

const kPickerHeight = 200.0;

class _PickerCupertino extends StatefulWidget {
  const _PickerCupertino({
    required this.items,
    required this.initialIndex,
    required this.onSelectedItemChanged,
    this.subItems,
  });
  final List<String>? items;

  final List<String>? subItems;
  final int? initialIndex;
  final ValueSetter<dynamic> onSelectedItemChanged;

  @override
  State<_PickerCupertino> createState() => _PickerCupertinoState();
}

class _PickerCupertinoDate extends StatelessWidget {
  const _PickerCupertinoDate({
    required this.initialDateTime,
    required this.onDateChanged,
  });
  final DateTime? initialDateTime;

  final ValueSetter<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kPickerHeight,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: initialDateTime ?? DateTime.now().toUtc(),
        onDateTimeChanged: onDateChanged,
      ),
    );
  }
}

class _PickerCupertinoState extends State<_PickerCupertino> {
  late final FixedExtentScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kPickerHeight,
      child: CupertinoPicker(
        scrollController: _scrollController,
        itemExtent: 32,
        onSelectedItemChanged: widget.onSelectedItemChanged,
        children: List.generate(
          widget.items?.length ?? 0,
          (int index) => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.subItems != null) Text(widget.subItems![index]),
              const Gap.xxs(),
              Text(widget.items?[index] ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController =
        FixedExtentScrollController(initialItem: widget.initialIndex ?? 0);
  }
}

class _PickerCupertinoTime extends StatelessWidget {
  const _PickerCupertinoTime({
    required this.onTimeChanged,
    this.initialDateTime,
    this.minuteInterval,
  });
  final DateTime? initialDateTime;

  final int? minuteInterval;
  final ValueSetter<DateTime> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    final interval = minuteInterval ?? 20;
    return SizedBox(
      height: kPickerHeight,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        initialDateTime: initialDateTime ??
            (DateTime.now().minute % interval == 0
                ? DateTime.now()
                : DateTime.now().add(
                    Duration(
                      minutes: interval - DateTime.now().minute % interval,
                    ),
                  )),
        minuteInterval: interval,
        onDateTimeChanged: onTimeChanged,
      ),
    );
  }
}
