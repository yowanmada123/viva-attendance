import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseDropdownSearch<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getLabel;
  final T? selectedValue;
  final void Function(T?)? onChanged;
  final String label;
  final bool isDisabled;
  final double? width;
  final void Function(String)? onSearchChanged;
  final TextEditingController? controller;

  const BaseDropdownSearch({
    super.key,
    required this.items,
    required this.getLabel,
    required this.selectedValue,
    required this.onChanged,
    required this.label,
    this.isDisabled = false,
    this.width,
    this.onSearchChanged,
    this.controller,
  });

  @override
  State<BaseDropdownSearch<T>> createState() => _BaseDropdownSearchState<T>();
}

class _BaseDropdownSearchState<T> extends State<BaseDropdownSearch<T>> {
  late final TextEditingController controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    controller.addListener(() {
      final text = controller.text;

      if (widget.onSearchChanged != null) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();

        _debounce = Timer(const Duration(milliseconds: 500), () {
          widget.onSearchChanged!(text);
        });
      }
    });
  }

  @override
  void dispose() {
    // controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: DropdownMenu<T>(
        controller: controller,
        initialSelection: widget.selectedValue,
        width: widget.width ?? MediaQuery.of(context).size.width - 30.w,
        menuHeight: 300.w,
        requestFocusOnTap: true,
        enableFilter: true,
        label: Text(widget.label),
        inputDecorationTheme: InputDecorationTheme(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        hintText: "Find ${widget.label}",
        enabled: !widget.isDisabled,
        onSelected: widget.isDisabled ? null : widget.onChanged,
        dropdownMenuEntries: widget.items.map((item) {
          return DropdownMenuEntry<T>(
            value: item,
            label: widget.getLabel(item),
          );
        }).toList(),
      ),
    );
  }
}