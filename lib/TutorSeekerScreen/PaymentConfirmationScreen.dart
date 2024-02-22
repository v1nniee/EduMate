import 'package:edumateapp/Payment/GenrateReceipt.dart';
import 'package:edumateapp/Payment/StripePaymentHandle.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final String tutorSeekerName;
  final String tutorName;
  final String subject;
  final String paymentAmount;
  final DateTime paymentDate;
  final DateTime startclassDate;
  final DateTime endclassDate;

  PaymentConfirmationScreen({
    Key? key,
    required this.tutorSeekerName,
    required this.tutorName,
    required this.subject,
    required this.paymentAmount,
    required this.paymentDate,
    required this.startclassDate,
    required this.endclassDate,
  }) : super(key: key);

  final GenerateReceipt _GenerateReceipt = GenerateReceipt();

  @override
  Widget build(BuildContext context) {
    print("hi im here");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Receipt',
          ),
          ListTile(
            onTap: () async {
              await _GenerateReceipt.generateReceipt(
                  tutorSeekerName,
                  tutorName,
                  subject,
                  paymentAmount,
                  startclassDate,
                  endclassDate,
                  paymentDate,
                  context

                  // Pass the BuildContext here
                  );
            },
            title: const Text('Generate Receipt'),
            trailing: const Icon(Icons.chevron_right_rounded),
          )
        ],
      ),
    );
  }
}
