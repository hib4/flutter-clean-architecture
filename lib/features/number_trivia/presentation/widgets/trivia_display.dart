import 'package:flutter/material.dart';

import '../../domain/entities/number_trivia.dart';

class TriviaDisplay extends StatelessWidget {
  const TriviaDisplay({Key? key, required this.numberTrivia}) : super(key: key);

  final NumberTrivia numberTrivia;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: [
          Text(
            numberTrivia.number.toString(),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  numberTrivia.text,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}