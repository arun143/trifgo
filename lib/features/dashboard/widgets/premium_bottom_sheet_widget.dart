import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';

class PremiumBottomSheetWidget extends StatelessWidget {
  final bool fromDialog;
  const PremiumBottomSheetWidget({super.key, this.fromDialog = false});

  @override
  Widget build(BuildContext context) {
    if(Get.find<AddressController>().addressList == null){
      Get.find<AddressController>().getAddressList();
    }
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius : BorderRadius.only(
            topLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
            topRight : Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
            bottomLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
            bottomRight: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
          ),
      ),
      child: GetBuilder<AddressController>(
        builder: (addressController) {
          AddressModel? selectedAddress = AddressHelper.getUserAddressFromSharedPref();
          return Column(mainAxisSize: MainAxisSize.min, children: [

            fromDialog ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
                    Get.back();
                    },
                  icon: const Icon(Icons.clear),
                )
              ]
            ) : const SizedBox(),

            fromDialog ? const SizedBox() : Center(
              child: Container(
                margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                height: 3, width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                ),
              ),
            ),


            Flexible(
              child: SingleChildScrollView(

                padding: EdgeInsets.symmetric(horizontal: fromDialog ? 50 : Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child:Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1)],
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                //color: Theme.of(context).shadowColor,
                  ),



                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Image.asset(Images.premium, height: 120),
                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:

                  child: Row(children: [
                      Text(
                        '${Get.find<SplashController>().configModel?.premium_validity ?? ''}-${Get.find<SplashController>().configModel?.premium_validity_type ?? ''} Membership',
                        //'Expired on'.tr,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                      ),
                    const Expanded(child: SizedBox()),
                      Text(
                      '${PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                      ? Get.find<SplashController>().configModel!.premiumRate!.toDouble() : 0.0)}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),),


                  ]),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:

                    child: Row(children: [
                      Text(
                        '${Get.find<SplashController>().configModel?.premium_field1 ?? ''}',
                        //'Expired on'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                      ),

                    ]),
                  ),const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:

                    child: Row(children: [
                      Text(
                        '${Get.find<SplashController>().configModel?.premium_field2 ?? ''}',
                        //'Expired on'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                      ),

                    ]),
                  ),const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:

                    child: Row(children: [
                      Text(
                        '${Get.find<SplashController>().configModel?.premium_field3 ?? ''}',
                        //'Expired on'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                      ),

                    ]),
                  ),
                  const SizedBox(height: 10),

                  InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getPremiumRoute()),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                      child: Text(
                        'View details'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor, ),
                      ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                ]),
                ),
              ),
            ),
          ]);
        }
      ),
    );
  }
}
