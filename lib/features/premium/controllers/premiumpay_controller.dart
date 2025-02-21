import 'package:get/get.dart';
import 'package:sixam_mart/common/models/transaction_model.dart';
import 'package:sixam_mart/features/premium/domain/models/wallet_filter_body_model.dart';
import 'package:sixam_mart/features/premium/domain/models/fund_bonus_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;
import 'package:sixam_mart/features/premium/domain/services/premium_service_interface.dart';

class PremiumPayController extends GetxController implements GetxService {
  final PremiumServiceInterface premiumServiceInterface;
  PremiumPayController({required this.premiumServiceInterface});

  List<Transaction>? _transactionList;
  List<Transaction>? get transactionList => _transactionList;

  List<String> _offsetList = [];

  int _offset = 1;
  int get offset => _offset;

  int? _pageSize;
  int? get popularPageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  bool _amountEmpty = true;
  bool get amountEmpty => _amountEmpty;

  List<FundBonusModel>? _fundBonusList;
  List<FundBonusModel>? get fundBonusList => _fundBonusList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  String _type = 'all';
  String get type => _type;

  List<WalletFilterBodyModel> _walletFilterList = [];
  List<WalletFilterBodyModel> get walletFilterList => _walletFilterList;

  void setWalletFilerType(String type, {bool isUpdate = true}) {
    _type = type;
    if(isUpdate) {
      update();
    }
  }

  void insertFilterList(){
    _walletFilterList = [];
    for(int i=0; i < AppConstants.walletTransactionSortingList.length; i++){
      _walletFilterList.add(WalletFilterBodyModel.fromJson(AppConstants.walletTransactionSortingList[i]));
    }
  }

  void changeDigitalPaymentName(String name, {bool isUpdate = true}){
    _digitalPaymentName = name;
    if(isUpdate) {
      update();
    }
  }

  void isTextFieldEmpty(String value, {bool isUpdate = true}){
    _amountEmpty = value.isNotEmpty;
    if(isUpdate) {
      update();
    }
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<void> getWalletTransactionList(String offset, bool reload, String walletType) async {
    if(offset == '1' || reload) {
      _offsetList = [];
      _offset = 1;
      _transactionList = null;
      if(reload) {
        update();
      }

    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      TransactionModel? transactionModel = await premiumServiceInterface.getWalletTransactionList(offset, walletType);

      if (transactionModel != null) {
        if (offset == '1') {
          _transactionList = [];
        }
        _transactionList!.addAll(transactionModel.data!);
        _pageSize = transactionModel.totalSize;

        _isLoading = false;
        update();
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> addFundToWallet(double amount, String paymentMethod) async {
    _isLoading = true;
    update();
    Response response = await premiumServiceInterface.addFundToWallet(amount, paymentMethod);
    if (response.statusCode == 200) {
      String redirectUrl = response.body['redirect_link'];
      Get.back();
      if(GetPlatform.isWeb) {

        html.window.open(redirectUrl,"_self");
      } else{
        Get.toNamed(RouteHelper.getPaymentRoute('0', 0, '', 0, false, '', addFundUrl: redirectUrl, guestId: ''));
      }
    }
    _isLoading = false;
    update();
  }

  Future<void> getWalletBonusList({bool isUpdate = true}) async {
    _isLoading = true;
    if(isUpdate) {
      update();
    }

    List<FundBonusModel>? bonuses = await premiumServiceInterface.getWalletBonusList();
    if (bonuses != null) {
      _fundBonusList = [];
      _fundBonusList!.addAll(bonuses);

      _isLoading = false;
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void setWalletAccessToken(String accessToken){
    premiumServiceInterface.setWalletAccessToken(accessToken);
  }

  String getWalletAccessToken (){
    return premiumServiceInterface.getWalletAccessToken();
  }

}