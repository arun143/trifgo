import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/subscription/domain/models/check_product_limit_model.dart';
import 'package:sixam_mart/features/subscription/domain/models/subscription_transaction_model.dart';
import 'package:sixam_mart/features/subscription/domain/repositories/subscription_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';

class SubscriptionRepository implements SubscriptionRepositoryInterface {
  final ApiClient apiClient;
  SubscriptionRepository({required this.apiClient});

  @override
  Future<Response> renewBusinessPlan(Map<String, String> body, Map<String, String>? headers) async {
    return await apiClient.postData(AppConstants.gbusinessPlanUri, body, headers: headers, handleError: false);
  }

  @override
  Future<SubscriptionTransactionModel?> getSubscriptionTransactionList({required int offset, required int? restaurantId, required String? from, required String? to,  required String? searchText}) async {
    SubscriptionTransactionModel? subscriptionTransactionModel;
    Response response = await apiClient.getData('${AppConstants.GoldsubscriptionTransactionUri}?limit=10&offset=$offset&restaurant_id=$restaurantId&from=$from&to=$to&search=${searchText ?? ''}');
    if(response.statusCode == 200){
      subscriptionTransactionModel = SubscriptionTransactionModel.fromJson(response.body);
    }
    return subscriptionTransactionModel;
  }

  @override
  Future<Response> cancelSubscription(Map<String, String> body) async {
    return await apiClient.postData(AppConstants.cancelGoldSubscriptionUri, body);
  }

  @override
  Future<CheckProductLimitModel?> getProductLimit({required int storeId, required int packageId})async{
    CheckProductLimitModel? checkProductLimitModel;
    Response response = await apiClient.getData('${AppConstants.checkProductLimitsUri}?store_id=$storeId&package_id=$packageId');
    if(response.statusCode == 200){
      checkProductLimitModel = CheckProductLimitModel.fromJson(response.body);
    }
    return checkProductLimitModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }

   

}