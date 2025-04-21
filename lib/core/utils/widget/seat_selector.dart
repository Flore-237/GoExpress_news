import 'package:flutter/material.dart';

class SeatSelector extends StatefulWidget {
  final List<String> availableSeats;
  final Function(String) onSeatSelected;

  const SeatSelector({
    Key? key,
    required this.availableSeats,
    required this.onSeatSelected
  }) : super(key: key);

  @override
  _SeatSelectorState createState() => _SeatSelectorState();
}

class _SeatSelectorState extends State<SeatSelector> {
  String? _selectedSeat;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
      ),
      itemCount: widget.availableSeats.length,
      itemBuilder: (context, index) {
        final seat = widget.availableSeats[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSeat = seat;
            });
            widget.onSeatSelected(seat);
          },
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _selectedSeat == seat ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(seat)),
          ),
        );
      },
    );
  }
}