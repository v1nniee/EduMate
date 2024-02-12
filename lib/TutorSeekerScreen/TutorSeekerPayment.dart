import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';


class TutorSeekerPayment extends StatelessWidget {
  const TutorSeekerPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: const Column(
        children: [
          PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Payment',
          ),
        ],
      ),
      
    );
  }
}
