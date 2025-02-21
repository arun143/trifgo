import 'dart:async';
import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/order/widgets/track_details_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({super.key, required this.orderID, this.contactNumber});



  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _takeAway = false;
  bool _parcel = false;
  bool _isRestaurant = false;
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;
  Set<Polyline> _polylines = {};
  String? setmystatus;

  void _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
    ));
  }

  // void _startApiCall(){
  //   _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
  //     Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
  //   });
  // }

  void _startApiCall() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      print("Timer triggered");

      var orderController = Get.find<OrderController>();
      await orderController.timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);

      if (orderController.trackModel != null && orderController.trackModel!.deliveryMan != null) {
        print("DeliveryManssz: ${orderController.trackModel!.deliveryMan}");
        setMarker(
            orderController.trackModel!.store,
            orderController.trackModel!.deliveryMan,
            orderController.trackModel!.deliveryAddress,
            _takeAway,
            _parcel,
            _isRestaurant
        );
      } else {
        print("Track model or delivery man is null");
      }
    });
  }


  @override
  void initState() {
    super.initState();

    _loadData();
    _startApiCall();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;

          if(track!.orderType != 'parcel') {
            if (track.store!.storeBusinessModel == 'commission') {
              showChatPermission = true;
            } else if (track.store!.storeSubscription != null && track.store!.storeBusinessModel == 'subscription') {
              showChatPermission = track.store!.storeSubscription!.chat == 1;
            } else {
              showChatPermission = false;
            }
          } else {
            showChatPermission = AuthHelper.isLoggedIn();
          }
        }

        return track != null ? SingleChildScrollView(
          physics: isHovered || !ResponsiveHelper.isDesktop(context) ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          child: FooterView(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, height: ResponsiveHelper.isDesktop(context) ? 700 : MediaQuery.of(context).size.height * 0.85, child: Stack(children: [

              MouseRegion(
                onEnter: (event) => onEntered(true),
                onExit: (event) => onEntered(false),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: LatLng(
                    double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
                  ), zoom: 20),
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  zoomControlsEnabled: false,
                  polylines: _polylines,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    _isLoading = false;
                    setMarker(
                      track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                          address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                      track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                        latitude: Get.find<LocationController>().position.latitude.toString(),
                        longitude: Get.find<LocationController>().position.longitude.toString(),
                        address: Get.find<LocationController>().address,
                      ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                    );

                  },

                  style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                ),
              ),

              _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

              Positioned(
                top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away'),
              ),

              Positioned(
                right: 15, bottom: track.orderType != 'take_away' && track.deliveryMan == null ? 150 : 220,
                child: InkWell(
                  onTap: () => _checkPermission(() async {
                    AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                    setMarker(
                      track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                          address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                      track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                        latitude: Get.find<LocationController>().position.latitude.toString(),
                        longitude: Get.find<LocationController>().position.longitude.toString(),
                        address: Get.find<LocationController>().address,
                      ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                      currentAddress: address, fromCurrentLocation: true,
                    );
                  }),
                  child: Container(
                    padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                    child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                  ),


                ),
              ),

              Positioned(
                bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackDetailsViewWidget(status: track.orderStatus, track: track, showChatPermission: showChatPermission, callback: () async{
                  _timer?.cancel();
                  await Get.toNamed(RouteHelper.getChatRoute(
                    notificationBody: NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                    user: User(id: track.deliveryMan!.id, fName: track.deliveryMan!.fName, lName: track.deliveryMan!.lName, imageFullUrl: track.deliveryMan!.imageFullUrl),
                  ));
                  _startApiCall();
                }),
              ),

            ]))),
          ),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void setMarker(
      Store? store,
      DeliveryMan? deliveryMan,
      AddressModel? addressModel,
      bool takeAway,
      bool parcel,
      bool isRestaurant,
      {AddressModel? currentAddress,
        bool fromCurrentLocation = false}
      )
  async {
    _takeAway = takeAway;
    _parcel = parcel;
    _isRestaurant = isRestaurant;
    try {

      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: (isRestaurant || parcel) ? 50 : 70,
        imagePath: parcel ? Images.userMarker : isRestaurant ? Images.restaurantMarker : Images.markerStore,
      );

      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 50, imagePath: Images.deliveryManMarker,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 50, imagePath: takeAway ? Images.myLocationMarker : Images.userMarker,
      );

      /// Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
          rotation = 0;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      if(fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: GetPlatform.isWeb ? 7 : 15)));
      }

       if(!fromCurrentLocation) {
         _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
         if(!ResponsiveHelper.isWeb()) {
           zoomToFit(_controller, bounds, centerBounds, padding: GetPlatform.isWeb ? 15 : 3);
         }
       }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if(currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if(currentAddress == null){
        addressModel != null ? _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'sender'.tr : 'Destination'.tr,
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        )) : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null ? _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'receiver'.tr : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: restaurantImageData,
      )) : const SizedBox();

      if (deliveryMan != null && addressModel != null) {
        double deliveryManLat = double.parse(deliveryMan.lat ?? '0');
        double deliveryManLng = double.parse(deliveryMan.lng ?? '0');

        String orderStatus = Get.find<OrderController>().trackModel?.orderStatus ?? 'Unknown';
        //print("Order Status: $orderStatus");
        //print("DeliveryMan Latitude: $deliveryManLat, Longitude: $deliveryManLng");

        bool markerExists = _markers.any((marker) => marker.markerId.value == 'delivery_boy');

        if (!markerExists) {
          BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 50,
            imagePath: Images.deliveryManMarker,  // Customize marker image as needed
          );

          _markers.add(Marker(
            markerId: const MarkerId('delivery_boy'),
            position: LatLng(deliveryManLat, deliveryManLng),
            infoWindow: InfoWindow(
              title: 'delivery_man'.tr,
              snippet: deliveryMan.location,
            ),
            rotation: rotation,
            icon: deliveryBoyImageData,
          ));
        } else {
          _markers.removeWhere((marker) => marker.markerId.value == 'delivery_boy');
          _markers.add(Marker(
            markerId: const MarkerId('delivery_boy'),
            position: LatLng(deliveryManLat, deliveryManLng),
            infoWindow: InfoWindow(
              title: 'delivery_man'.tr,
              snippet: deliveryMan.location,
            ),
            rotation: rotation,
            icon: deliveryBoyImageData,
          ));
        }

        if (orderStatus != 'picked_up' && store != null) {
          List<LatLng> polylineCoordinates = await _getRouteCoordinates(
            LatLng(deliveryManLat, deliveryManLng),
            LatLng(double.parse(store.latitude ?? '0'), double.parse(store.longitude ?? '0')),
          );
          _polylines.add(Polyline(
            polylineId: const PolylineId("handover_route"),
            points: polylineCoordinates,
            color: Colors.deepOrange,
            width: 5,
          ));
        } else
        if (orderStatus == 'picked_up' && addressModel != null) {
          List<LatLng> polylineCoordinates = await _getRouteCoordinates(
            LatLng(deliveryManLat, deliveryManLng),
            LatLng(double.parse(addressModel.latitude ?? '0'), double.parse(addressModel.longitude ?? '0')),
          );

          _polylines.add(Polyline(
            polylineId: const PolylineId("picked_up_route"),
            points: polylineCoordinates,
            color: Colors.purple,
            width: 5,
          ));
        } else {
          print("Invalid order status or missing data");
          return;
        }

        if (_controller != null) {
          _controller!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(deliveryManLat, deliveryManLng),
              zoom: 16, // Adjust zoom level as necessary
              tilt: 50, // Optional: Adjust tilt for a better view
            ),
          ));
        }
        // Trigger a UI update to reflect changes
        setState(() {});
      }


    }catch(_) {}
    setState(() {});
  }
  Future<List<LatLng>> _getRouteCoordinates(LatLng start, LatLng end) async {
    String url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${start.latitude},${start.longitude}"
        "&destination=${end.latitude},${end.longitude}"
        "&key=AIzaSyAlkUl7CfmjDtmo6J_SKx06zrOlwxCjm8I";

    var response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    List<LatLng> coordinates = [];

    if (values['routes'].isNotEmpty) {
      String encodedPolyline = values['routes'][0]['overview_polyline']['points'];
      coordinates = _decodePolyline(encodedPolyline);
    }

    return coordinates;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;


    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    }else {
      onTap();
    }
  }

}
