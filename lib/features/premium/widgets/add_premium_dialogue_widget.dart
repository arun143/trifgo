import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/premium/controllers/premiumpay_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';

class AddPremiumDialogueWidget extends StatefulWidget {
  final ScrollController cardScrollController;
  const AddPremiumDialogueWidget({super.key, required this.cardScrollController});

  @override
  State<AddPremiumDialogueWidget> createState() => _AddPremiumDialogueWidgetState();
}

class _AddPremiumDialogueWidgetState extends State<AddPremiumDialogueWidget> {
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        widget.cardScrollController.jumpTo(50);
      }
    });

    Get.find<PremiumPayController>().isTextFieldEmpty('', isUpdate: false);
    Get.find<PremiumPayController>().changeDigitalPaymentName('', isUpdate: false);

    if(Get.find<SplashController>().configModel!.activePaymentMethodList!.length == 1){
      Get.find<PremiumPayController>().changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList!.first.getWay!, isUpdate: false);
    }

  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [

      Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: (){
            Get.back();
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor.withOpacity(0.5),
            ),
            padding: const EdgeInsets.all(3),
            child: const Icon(Icons.clear),
          ),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      GetBuilder<PremiumPayController>(builder: (premiumPayController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
          ),
          width: context.width * 0.9,
          constraints: BoxConstraints(minHeight: context.height * 0.34, maxHeight: context.height * 0.7),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            const SizedBox(height: Dimensions.paddingSizeLarge),


            Text(
              PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                  ? Get.find<SplashController>().configModel!.premiumRate!.toDouble() : 0.0),
              style: robotoBold.copyWith(fontSize: 50), textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Flexible(
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: 'faster_and_secure_way_to_pay_bill'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                  ),
                ]),
              ),
            ),

            Flexible(
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    ListView.builder(
                      itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        bool isSelected = Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == premiumPayController.digitalPaymentName;
                        return InkWell(
                          onTap: (){
                            premiumPayController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                            child: Row(children: [
                              Container(
                                height: 20, width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: isSelected ? Colors.green : Theme.of(context).cardColor,
                                  border: Border.all(color: Theme.of(context).disabledColor),
                                ),
                                child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              CustomImage(
                                height: 20, fit: BoxFit.contain,
                                image: '${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl}',
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Text(
                                Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                  ]),
                ),
              ),
            ),

            CustomButton(
              buttonText: 'Pay Now'.tr,
              isLoading: premiumPayController.isLoading,
              onPressed: () => _onAddFundButtonClicked(premiumPayController),
            ),

          ]),
        );
      }),
    ]);
  }

  void _checkFormatters(String value) {
    String test = value;
    if(value.contains('-')) {
      test = value.replaceAll('-', '');
    } else if(value.contains(' ')) {
      test = value.replaceAll(' ', '');
    } else if(value.contains(',')) {
      test = value.replaceAll(',', '');
    } else {
      test = value;
    }
    setState(() {
      inputAmountController.text = test;
      inputAmountController.selection = TextSelection.fromPosition(
        TextPosition(offset: test.length),
      );
    });
  }

  void _onAddFundButtonClicked(PremiumPayController premiumPayController) {
     if(premiumPayController.digitalPaymentName == ''){
      showCustomSnackBar('please_select_payment_method'.tr);
    }else{
      double amount =  Get.find<SplashController>().configModel!.premiumRate!.toDouble();
      premiumPayController.addFundToWallet(amount, premiumPayController.digitalPaymentName!);
    }
  }
}
