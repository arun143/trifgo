import 'package:sixam_mart/common/models/transaction_model.dart';
import 'package:sixam_mart/features/premium/domain/models/fund_bonus_model.dart';

abstract class PremiumServiceInterface{
  Future<TransactionModel?> getWalletTransactionList(String offset, String sortingType);
  Future<dynamic> addFundToWallet(double amount, String paymentMethod);
  Future<List<FundBonusModel>?> getWalletBonusList();
  Future<void> setWalletAccessToken(String token);
  String getWalletAccessToken();
}