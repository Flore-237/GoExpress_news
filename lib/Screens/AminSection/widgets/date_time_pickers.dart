import 'package:flutter/material.dart';

Future<void> showDatePickerDialog({
  required BuildContext context,
  required TextEditingController controller,
}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3D56F0),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
  }
}

Future<void> showTimePickerDialog({
  required BuildContext context,
  required TextEditingController controller,
}) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3D56F0),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    controller.text = picked.format(context);
  }
}