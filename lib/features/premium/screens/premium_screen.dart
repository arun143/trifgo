import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/menu/widgets/portion_widget.dart';
import 'package:sixam_mart/features/premium/widgets/add_premium_dialogue_widget.dart';
import 'package:sixam_mart/features/premium/widgets/add_premium_dialogue_widget1.dart';
import 'package:sixam_mart/features/profile/domain/models/userinfo_model.dart';
import 'package:sixam_mart/features/profile/domain/models/userinfo_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/support/widgets/support_button_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/support/widgets/web_help_support_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PremiumScreen extends StatefulWidget {

  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {

  void _loadData() async {

    if(!ResponsiveHelper.isDesktop(context)) {
      await Get.toNamed(RouteHelper.getPremiumRoute());
      if(AuthHelper.isLoggedIn()) {
        await Get.toNamed(RouteHelper.getPremiumRoute());
      }
    }

  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadData();
  }
  @override

  Widget build(BuildContext context) {

    DateTime dateToday = DateTime.now();
    String date = dateToday.toString().substring(0, 10);
    String? pdateNullable = Get.find<ProfileController>().userInfoModel?.premiumexpiry;
    DateTime? parsedPdate = (pdateNullable != null && pdateNullable.isNotEmpty)
        ? DateTime.tryParse(pdateNullable)
        : null;
    DateTime parsedDate = DateTime.parse(date);
    int? userpremium = Get.find<ProfileController>().userInfoModel?.premium;
    double? premium = Get.find<SplashController>().configModel?.premium1Rate;


    final ScrollController cardScrollController = ScrollController();

    return Scaffold(
      appBar: CustomAppBar(title: ''
          'Premium'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body:   SingleChildScrollView(
        padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: Center(child: FooterView(

          child: ResponsiveHelper.isDesktop(context) ? const SizedBox(
            width: double.infinity, height: 650,
            child: WebSupportScreen(),
          ) : SizedBox(width: Dimensions.webMaxWidth, child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),


            Image.asset(Images.premium, height: 120),
            const SizedBox(height: 30),

            if(parsedPdate == null ) const Text(
              '',
            )
            else
              if (parsedPdate!.isBefore(parsedDate))
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Text(
                    'Expired on ${Get.find<ProfileController>().userInfoModel?.premiumexpiry ?? ''}',
                    //'${ProfileController.userInfoModel?.phone ?? ''}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Text(
                    'Expires on ${Get.find<ProfileController>().userInfoModel?.premiumexpiry ?? ''}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                  ),
                ),




            const SizedBox(height: 10),




            if (Get.find<ProfileController>().userInfoModel?.premiumexpiry == null || parsedPdate!.isBefore(parsedDate))


              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Color(0xFFB68341), width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1)],
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  //color: Theme.of(context).shadowColor,
                ),



                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:

                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                                ? Get.find<SplashController>().configModel!.premiumRate!.toDouble() : 0.0),
                            style: robotoBold.copyWith(fontSize: 50), textDirection: TextDirection.ltr,
                          ),
                          Text(
                            ' for ${Get.find<SplashController>().configModel?.premium_validity ?? ''} ${Get.find<SplashController>().configModel?.premium_validity_type ?? ''}',
                            //'Expired on'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                          ),
                        ]),

                  ),const SizedBox(height: 10),
                  SafeArea(
                    child: CustomButton(
                      buttonText: 'Buy Now'.tr,
                      width: 300,height: 45,
                      fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
                      isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                      radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                      color: Color(0xFFB68341),
                      onPressed: () {
                        Get.dialog(
                          Dialog(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent, child: SizedBox(
                            width: 500, child: SingleChildScrollView(controller: cardScrollController, child: AddPremiumDialogueWidget(cardScrollController: cardScrollController)),
                          )),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' BENEFITS',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black,),
                        ),
                      ]),
                  Divider(
                    color: Color(0xFFB68341),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start, // Align left
                      children: [
                        Text(
                          '🛵  Free delivery up to ${Get.find<SplashController>().configModel?.premium_field1 ?? ''} Klm',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                        ),
                        Divider(
                          color: Color(0xFFB68341),
                        ),

                        Text(
                          '📦 Oders Unlimted',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                        ),
                        Divider(
                          color: Color(0xFFB68341),
                        ),

                        Text(
                          '💵 Min order value ${Get.find<SplashController>().configModel?.premium_field3 ?? ''}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                        ),
                      ],
                    ),

                  ),

                  const SizedBox(height: 10),



                ]),
              ),
            const SizedBox(height: 10),
            if (Get.find<ProfileController>().userInfoModel?.premiumexpiry == null || parsedPdate!.isBefore(parsedDate))
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Color(0xFFB68341), width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1)],
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  //color: Theme.of(context).shadowColor,
                ),



                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  const SizedBox(height: Dimensions.paddingSizeSmall),



                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:

                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                                ? Get.find<SplashController>().configModel!.premium1Rate!.toDouble() : 0.0),
                            style: robotoBold.copyWith(fontSize: 50), textDirection: TextDirection.ltr,
                          ),
                          Text(
                            ' for ${Get.find<SplashController>().configModel?.premium1_validity ?? ''} ${Get.find<SplashController>().configModel?.premium_validity_type ?? ''}',
                            //'Expired on'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                          ),
                        ]),

                  ),const SizedBox(height: 10),
                  SafeArea(
                    child: CustomButton(
                      buttonText: 'Buy Now'.tr,
                      width: 300,height: 45,
                      fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
                      isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                      radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                      color: Color(0xFFB68341),
                      onPressed: () {
                        Get.dialog(
                          Dialog(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent, child: SizedBox(
                            width: 500, child: SingleChildScrollView(controller: cardScrollController, child: AddPremiumDialogueWidget1(cardScrollController: cardScrollController)),
                          )),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' BENEFITS',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black,),
                        ),
                      ]),

                  Divider(
                    color: Color(0xFFB68341),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:


                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align left
                        children: [
                          Text(
                            '🛵  50% delivery fee off up to ${Get.find<SplashController>().configModel?.premium1_field1 ?? ''} Klm',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),
                          Divider(
                            color: Color(0xFFB68341),
                          ),
                          Text(
                            '📦 Oders Unlimited',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),
                          Divider(
                            color: Color(0xFFB68341),
                          ),

                          Text(
                            '💵 Min order value ${Get.find<SplashController>().configModel?.premium1_field3 ?? ''}',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),

                        ]),

                  ),

                  const SizedBox(height: 10),

                ]),
              ),



            if (parsedPdate != null &&
                (parsedPdate.isAfter(parsedDate) || parsedPdate.isAtSameMomentAs(parsedDate)) &&
                userpremium == premium)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Color(0xFFB68341), width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1)],
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  //color: Theme.of(context).shadowColor,
                ),



                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  const SizedBox(height: 10),

                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' BENEFITS',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black,),
                        ),
                      ]),

                  Divider(
                    color: Color(0xFFB68341),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:


                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align left
                        children: [
                          Text(
                            '🛵  50% Delivery fee off up to ${Get.find<ProfileController>().userInfoModel?.premiumklm ?? ''} Klm',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),
                          Divider(
                            color: Color(0xFFB68341),
                          ),
                          Text(
                            '📦 Oders upto Unlimted',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),
                          Divider(
                            color: Color(0xFFB68341),
                          ),

                          Text(
                            '💵 Min order value ${Get.find<ProfileController>().userInfoModel?.premiumminvalue ?? ''}',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),

                        ]),

                  ),

                  const SizedBox(height: 10),

                ]),
              ),

            if (parsedPdate != null &&
                (parsedPdate.isAfter(parsedDate) || parsedPdate.isAtSameMomentAs(parsedDate)) &&
                userpremium != premium)


              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Color(0xFFB68341), width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1)],
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  //color: Theme.of(context).shadowColor,
                ),



                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  const SizedBox(height: 10),

                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' BENEFITS',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black,),
                        ),
                      ]),

                  Divider(
                    color: Color(0xFFB68341),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                    //child:


                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align left
                        children: [
                          Text(
                            '🛵  Free delivery up to ${Get.find<ProfileController>().userInfoModel?.premiumklm ?? ''} Klm',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),
                          Divider(
                            color: Color(0xFFB68341),
                          ),
                          Text(
                            '📦 Completed: ${Get.find<ProfileController>().userInfoModel?.premiumuserorders ?? ''}',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),
                          Divider(
                            color: Color(0xFFB68341),
                          ),

                          Text(
                            '💵 Min order value ${Get.find<ProfileController>().userInfoModel?.premiumminvalue ?? ''}',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                          ),

                        ]),

                  ),

                  const SizedBox(height: 10),

                ]),
              ),




            const SizedBox(height: 10),
            Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PortionWidget(icon: Images.chatIcon, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                  PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                  PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                  PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),

                ]),



          ])),
        )),

      ),
    );
  }

}
