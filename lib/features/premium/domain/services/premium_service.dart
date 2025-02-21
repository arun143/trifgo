import 'package:get/get.dart';
import 'package:sixam_mart/common/models/transaction_model.dart';
import 'package:sixam_mart/features/premium/domain/models/fund_bonus_model.dart';
import 'package:sixam_mart/features/premium/domain/repositories/premium_repository_interface.dart';
import 'package:sixam_mart/features/premium/domain/services/premium_service_interface.dart';

class PremiumService implements PremiumServiceInterface {
  final PremiumRepositoryInterface premiumRepositoryInterface;
 PremiumService({required this.premiumRepositoryInterface});

  @override
  Future<TransactionModel?> getWalletTransactionList(String offset, String sortingType) async {
    return await premiumRepositoryInterface.getList(offset: int.parse(offset), sortingType: sortingType);
  }

  @override
  Future<Response> addFundToWallet(double amount, String paymentMethod) async {
    return await premiumRepositoryInterface.addFundToWallet(amount, paymentMethod);
  }

  @override
  Future<List<FundBonusModel>?> getWalletBonusList() async {
    return await premiumRepositoryInterface.getList(isBonusList: true);
  }

  @override
  Future<void> setWalletAccessToken(String token) {
    return premiumRepositoryInterface.setWalletAccessToken(token);
  }

  @override
  String getWalletAccessToken() {
    return premiumRepositoryInterface.getWalletAccessToken();
  }

}