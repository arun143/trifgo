import 'package:get/get.dart';
import 'package:sixam_mart/features/subscription/controllers/subscription_controller.dart';
import 'package:sixam_mart/features/subscription/domain/services/subscription_service_interface.dart';

class SubscriptionControllerBinding extends Bindings {
  final SubscriptionServiceInterface subscriptionServiceInterface;
  SubscriptionControllerBinding({required this.subscriptionServiceInterface});

  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(SubscriptionController(subscriptionServiceInterface: subscriptionServiceInterface));
    //Get.lazyPut(()=>SubscriptionController(subscriptionServiceInterface: subscriptionServiceInterface));
  }




}