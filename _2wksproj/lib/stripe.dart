
Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent?['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Aparte',
        ),
      );
     .then((value) {});
      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
}
displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Hotel Booked Successful', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
          ),
        ),
      );
     showDialog(context: context, builder: (_)=> AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
          Icon(Icons.check_circle, color: Colors.green, size: 50.0,),
          SizedBox(height: 10.0,),
          Text('Payment Successful', style: TextStyle(fontSize: 18.0),),
        ],
          )
        ],
      ),
     ));
      paymentIntent = null;
    }) .on Error((
      error, StackTrace
    )
    {
      print("Error is:--->$error $StackTrace");
    });
    } on StripeException catch (e) {
      print('Stripe error: $e');
      showDialog(context: context, builder: (_)=> AlertDialog(
        content: 
            Text('Payment Cancelled', style: TextStyle(fontSize: 18.0),),)
      );
    } catch (e) {
      print('$e');
    }
    }
         
         
      createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        
        headers: {
          'Authorization': 'Bearer $secretkey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');

    }
      }
      calculateAmount(String amount) {
    final calculateAmount = (int.parse(amount)) * 100;
    return calculateAmount.toString();}