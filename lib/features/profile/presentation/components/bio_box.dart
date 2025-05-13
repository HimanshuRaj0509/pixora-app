import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      //padding insie
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        //color
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Text(text.isNotEmpty ? text : "Empy bio.."),
    );
  }
}
