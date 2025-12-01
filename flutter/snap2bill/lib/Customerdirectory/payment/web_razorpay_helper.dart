// File: web_razorpay_helper.dart
import 'dart:js';

void openRazorpayWeb(
    Map<String, dynamic> options, {
      Function(String)? onSuccess,
      Function(String)? onError,
    }) {
  final razorpayOptions = JsObject.jsify({
    'key': options['key'],
    'amount': options['amount'],
    'name': options['name'],
    'description': options['description'],
    'prefill': JsObject.jsify({
      'contact': options['prefill']['contact'],
      'email': options['prefill']['email'],
    }),
    'theme': JsObject.jsify({
      'color': options['theme']['color'],
    }),
    'handler': allowInterop((response) {
      final paymentId = response['razorpay_payment_id'];
      if (onSuccess != null) {
        onSuccess(paymentId);
      }
    }),
    'modal': JsObject.jsify({
      'ondismiss': allowInterop(() {
        if (onError != null) {
          onError("Payment cancelled");
        }
      }),
    }),
  });

  final razorpay = JsObject(context['Razorpay'], [razorpayOptions]);
  razorpay.callMethod('open');
}
