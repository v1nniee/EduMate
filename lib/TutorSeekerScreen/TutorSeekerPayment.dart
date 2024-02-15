import 'package:edumateapp/Payment/StripePaymentHandle.dart';
import 'package:edumateapp/TutorSeekerScreen/CardFormScreen.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/widgets/PageHeader.dart';



class TutorSeekerPayment extends StatelessWidget {
  const TutorSeekerPayment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create an instance of StripePaymentHandle
    final stripePaymentHandle = StripePaymentHandle();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Payment',
          ),
          ListTile(
            onTap: () async {
              // Call the stripeMakePayment method when the ListTile is tapped
              await stripePaymentHandle.stripeMakePayment();
            },
            title: const Text('Pay with Card'),
            trailing: const Icon(Icons.chevron_right_rounded),
          )
        ],
      ),
    );
  }
}
