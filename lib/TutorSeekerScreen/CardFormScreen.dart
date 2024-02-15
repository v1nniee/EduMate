import 'package:edumateapp/Payment/StripePaymentHandle.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/widgets/PageHeader.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CardFormScreen extends StatelessWidget {
  const CardFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create an instance of StripePaymentHandle
    final stripePaymentHandle = StripePaymentHandle();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: SingleChildScrollView( // Wrap with a SingleChildScrollView
        child: Column(
          children: [
            const PageHeader(
              backgroundColor: Color.fromARGB(255, 255, 255, 115),
              headerTitle: 'Pay with a Credit Card',
            ),
            Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Card Form',
                    ),
                    const SizedBox(height: 20),
                    CardFormField(
                      controller: CardFormEditController(),
                      style: CardFormStyle(
                        borderColor: const Color.fromARGB(255, 122, 121, 121),
                        placeholderColor: const Color.fromARGB(255, 122, 121, 121),
                        textColor: const Color.fromARGB(255, 122, 121, 121),
                        backgroundColor: Color.fromARGB(255, 235, 243, 206),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Pay"),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
