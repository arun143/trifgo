import 'package:get/get.dart';

class PremiumController extends GetxController implements GetxService {





  bool _showPremiumSuggestion = true;
  bool get showPremiumSuggestion => _showPremiumSuggestion;


  void hideSuggestedPremium(){
    _showPremiumSuggestion = !_showPremiumSuggestion;
  }
}