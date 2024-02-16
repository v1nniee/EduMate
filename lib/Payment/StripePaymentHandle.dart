import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StripePaymentHandle {
  Map<String, dynamic>? paymentIntent;
  bool paymentSuccessful = false;

  Future<bool> stripeMakePayment(String amount) async {
    
    try {
      paymentIntent = await createPaymentIntent(amount, 'MYR');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  billingDetails: const BillingDetails(
                      name: 'YOUR NAME',
                      email: 'YOUREMAIL@gmail.com',
                      phone: 'YOUR NUMBER',
                      address: Address(
                          city: 'YOUR CITY',
                          country: 'YOUR COUNTRY',
                          line1: 'YOUR ADDRESS 1',
                          line2: 'YOUR ADDRESS 2',
                          postalCode: 'YOUR PINCODE',
                          state: 'YOUR STATE')),
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Ikay'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      paymentSuccessful = await displayPaymentSheet();
      
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
    return paymentSuccessful;
  }

  Future<bool> displayPaymentSheet() async {
  bool paymentSuccessful = false; // Local variable to track the payment status

  try {
    // Display the payment sheet.
    await Stripe.instance.presentPaymentSheet();
    Fluttertoast.showToast(msg: 'Payment successfully completed');
    paymentSuccessful = true; // Set to true on successful payment
  } on StripeException catch (e) {
    // Handle the specific Stripe exception
    Fluttertoast.showToast(
        msg: 'Error from Stripe: ${e.error.localizedMessage}');
  } catch (e) {
    // Handle other exceptions
    Fluttertoast.showToast(msg: 'Unforeseen error: $e');
  }

  return paymentSuccessful; // Return the status of the payment
}


//create Payment
  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

//calculate Amount
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

}
