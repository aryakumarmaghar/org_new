import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:partypeoplebusiness/views/organization/dashboard/organisation_dashboard.dart';

import '../../../../constants/const_strings.dart';
import 'subscription_model.dart';

class SubscriptionController extends GetxController {
  //TODO: Implement SubscriptionController
  int count = -1.obs;
  Subscriptions? subscriptions;
  var isLoading = false.obs;
  RxInt quantitySelect = 1.obs;
  RxInt discountPercentage = 1.obs;
  RxInt subscriptionAmount = 499.obs;
  RxInt totalAmount = 499.obs;
  RxInt subsOrderId = 0.obs;

  ///Call this function if payment was successfull
  oderIdPlaced(String partyID, String startDate, String endDate) async {
    http.Response response = await http.post(
        Uri.parse(API.createOrder),
        body: {
          'party_id': partyID,
          'amount': '499',
          'papular_status': '1',
          'pr_start_date': startDate,
          'pr_end_date': endDate
        },
        headers: {
          "x-access-token": '${GetStorage().read('token')}'
        });

    print(jsonDecode(response.body));

    Get.snackbar('Success', '${jsonDecode(response.body)['message']}');
    Get.offAll(OrganisationDashboard());
  }

  Future<String> subscriptionPurchase({required String partyId , required String startDate , required String endDate , required String userType , required String amount}) async{
    String value ='0';
    try {
      final response = await http.post(Uri.parse(
          API.orgUserSubscriptionPurchase),
          headers: <String, String>{
            'x-access-token': '${GetStorage().read('token')}',
          },
          body: { 'party_id':partyId,
          'plan_start_date':startDate,
          'plan_end_date':endDate,
            'user_type':userType,
            'amount':amount
          }
      );
      if (response.statusCode == 200) {

        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if (jsonResponse['status'] == 1 ) {
         var id  = jsonResponse['subscription_purchase_id'];
         subsOrderId.value = int.parse(id.toString());
          log(' subs id : $subsOrderId');
          update();
          value = '1';
        }
        else if (jsonResponse['status'] == 0 &&
            jsonResponse['message'].contains('')) {
          Get.snackbar('Error', '${jsonResponse['message']}');
          update();
          value = '0';
        }
        else {
          update();
          log('${jsonResponse['message']}');
          value ='0';
        }
      }
      else{
        log('subscription_purchase api response is not 200');
        value = '0';
      }
    }
    catch(e)
    {
      log("$e");
    }
    return value ;
  }

  Future<String> updateSubsPaymentStatus({required String subsId,required String paymentStatus,}) async{
    String res='';
    try {
      log('$subsId  $paymentStatus ');
      final response = await http.post(Uri.parse(
          API.userSubscriptionPlanStatusUpdate),
          headers: <String, String>{
            'x-access-token': '${GetStorage().read('token')}',
          },
          body: { 'subscription_purchase_id':subsId.toString(),
            'payment_status':paymentStatus.toString(),
            //  'payment_response':paymentResponse?.toString(),
            // 'payment_id' :paymentId?.toString()
          }
      );
      log('STATUS CODE :: ${response.statusCode}');
      if (response.statusCode == 200) {

        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);

        if (jsonResponse['status'] == 1 && jsonResponse['message'].contains(
            'Your transaction successfully.')) {
          log('${jsonResponse['message']}');
          update();
          Get.snackbar("",'${jsonResponse['message']}' );
          res = '1';
        }
        else {
          update();
          log('${jsonResponse['message']}');
          res = '0';
        }
      }
      else{
        log('update subscription api response is not 200');
        res = '0';
      }
    }
    catch(e)
    {
      log("dfgmhmgmgh $e");
    }
    return res;
  }

}
