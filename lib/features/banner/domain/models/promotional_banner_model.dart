class PromotionalBanner {
  String? basicSectionNearbyFullUrl;
  String? bottomSectionBannerFullUrl;
  String? addBannerFullUrl;
  String? add1BannerFullUrl;

  PromotionalBanner({
    this.basicSectionNearbyFullUrl,
    this.bottomSectionBannerFullUrl,
    this.addBannerFullUrl,
    this.add1BannerFullUrl,
  });

  PromotionalBanner.fromJson(Map<String, dynamic> json) {
    basicSectionNearbyFullUrl = json['basic_section_nearby_full_url'];
    bottomSectionBannerFullUrl = json['bottom_section_banner_full_url'];
    addBannerFullUrl = json['add_section_banner_full_url'];
    add1BannerFullUrl = json['add1_section_banner_full_url'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['basic_section_nearby_full_url'] = basicSectionNearbyFullUrl;
    data['bottom_section_banner_full_url'] = bottomSectionBannerFullUrl;
    data['add_section_banner_full_url'] = addBannerFullUrl;
    data['add1_section_banner_full_url'] = add1BannerFullUrl;
    return data;
  }
}