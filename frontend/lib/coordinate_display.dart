import 'package:flutter/material.dart';

class CoordinateDisplay extends StatelessWidget {
  final List<List<int>> coordinates;

  const CoordinateDisplay({Key? key, required this.coordinates})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Matched Coordinates:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        coordinates.isNotEmpty
            ? Text(
                coordinates
                    .map((coord) => '(${coord[0]}, ${coord[1]})')
                    .join(', '),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              )
            : Text(
                'No matches found.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
      ],
    );
  }
}
