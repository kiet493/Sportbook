import 'package:flutter/material.dart';

class Venue {
  final int id;
  final String firestoreId;
  final String name;
  final List<String> sport;
  final String distance;
  final double rating;
  final int reviews;
  final String hours;
  final String price;
  final int priceNum;
  final bool available;
  final String image;
  final List<String> images;
  final String address;
  final String description;

  Venue({
    required this.id,
    String? firestoreId,
    required this.name,
    required this.sport,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.hours,
    required this.price,
    required this.priceNum,
    required this.available,
    required this.image,
    required this.images,
    required this.address,
    required this.description,
  }) : firestoreId = firestoreId ?? id.toString();
}

class SportsCategory {
  final String name;
  final IconData icon;
  final Color color;
  final Color bg;

  SportsCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

class BannerInfo {
  final int id;
  final String title;
  final String sub;
  final String cta;
  final String image;
  final Color color;

  BannerInfo({
    required this.id,
    required this.title,
    required this.sub,
    required this.cta,
    required this.image,
    required this.color,
  });
}

class FacilityInfo {
  final IconData icon;
  final String label;

  FacilityInfo({
    required this.icon,
    required this.label,
  });
}

class TimeSlot {
  final String time;
  final bool available;

  TimeSlot({
    required this.time,
    required this.available,
  });
}

class ReviewInfo {
  final String name;
  final String avatar;
  final int rating;
  final String date;
  final String comment;

  ReviewInfo({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

class PaymentMethod {
  final String id;
  final String label;
  final Color color;
  final String icon;

  PaymentMethod({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });
}

class BookingInfo {
  final String id;
  final Venue venue;
  final String date;
  final String time;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final String amount;
  final String court;

  BookingInfo({
    required this.id,
    required this.venue,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
    required this.court,
  });
}

class OnboardingScreenInfo {
  final int id;
  final String image;
  final String tag;
  final String headline;
  final String sub;
  final List<OnboardingFeature> features;
  final String primaryBtn;
  final String secondaryBtn;
  final Color accent;

  OnboardingScreenInfo({
    required this.id,
    required this.image,
    required this.tag,
    required this.headline,
    required this.sub,
    required this.features,
    required this.primaryBtn,
    required this.secondaryBtn,
    required this.accent,
  });
}

class OnboardingFeature {
  final IconData icon;
  final String label;
  final Color color;

  OnboardingFeature({
    required this.icon,
    required this.label,
    required this.color,
  });
}

// ─── DATA MOCK ─────────────────────────────────────────────────────────────

final List<Venue> VENUES = [
  Venue(
    id: 1,
    name: "Galaxy Badminton Club",
    sport: ["Cầu lông"],
    distance: "0.8 km",
    rating: 4.8,
    reviews: 245,
    hours: "06:00 – 23:00",
    price: "120.000đ/h",
    priceNum: 120000,
    available: true,
    image: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&h=380&fit=crop&auto=format",
    images: [
      "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&h=500&fit=crop&auto=format",
    ],
    address: "99 Hoàng Văn Thụ, Phú Nhuận, TP.HCM",
    description: "Cụm sân cầu lông trong nhà với sàn gỗ, điều hòa và khu nghỉ chờ. Có cho thuê vợt và bán cầu tại chỗ.",
  ),
  Venue(
    id: 2,
    name: "Phu Nhuan Badminton Center",
    sport: ["Cầu lông"],
    distance: "1.5 km",
    rating: 4.9,
    reviews: 186,
    hours: "05:30 – 22:30",
    price: "150.000đ/h",
    priceNum: 150000,
    available: true,
    image: "https://images.unsplash.com/photo-1613918108466-292b78a8ef95?w=600&h=380&fit=crop&auto=format",
    images: [
      "https://images.unsplash.com/photo-1613918108466-292b78a8ef95?w=800&h=500&fit=crop&auto=format",
    ],
    address: "21 Nguyễn Văn Trỗi, Phú Nhuận, TP.HCM",
    description: "Trung tâm cầu lông gần sân bay, có thảm chuẩn, đèn LED và bãi xe rộng.",
  ),
  Venue(
    id: 3,
    name: "Q7 Badminton House",
    sport: ["Cầu lông"],
    distance: "2.4 km",
    rating: 4.7,
    reviews: 132,
    hours: "06:00 – 22:00",
    price: "130.000đ/h",
    priceNum: 130000,
    available: true,
    image: "https://images.unsplash.com/photo-1600679472829-3044539ce8ed?w=600&h=380&fit=crop&auto=format",
    images: [
      "https://images.unsplash.com/photo-1600679472829-3044539ce8ed?w=800&h=500&fit=crop&auto=format",
    ],
    address: "268 Nguyễn Văn Linh, Quận 7, TP.HCM",
    description: "Cụm sân cầu lông Quận 7, phù hợp đặt sân theo nhóm sau giờ làm.",
  ),
  Venue(
    id: 4,
    name: "Thu Duc Shuttle Hub",
    sport: ["Cầu lông"],
    distance: "3.2 km",
    rating: 4.6,
    reviews: 98,
    hours: "06:00 – 22:30",
    price: "140.000đ/h",
    priceNum: 140000,
    available: true,
    image: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&h=380&fit=crop&auto=format",
    images: [
      "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&h=500&fit=crop&auto=format",
    ],
    address: "12 Xuân Thủy, TP Thủ Đức, TP.HCM",
    description: "Sân cầu lông trong nhà cho sinh viên và nhân viên văn phòng, có khu nghỉ chờ và nước uống.",
  ),
];

final List<SportsCategory> BADMINTON_FEATURES = [
  SportsCategory(name: "Sân trong nhà", icon: Icons.home_work, color: Color(0xFF2563EB), bg: Color(0xFFDBEAFE)),
  SportsCategory(name: "Thảm chuẩn", icon: Icons.grid_view, color: Color(0xFF22C55E), bg: Color(0xFFDCFCE7)),
  SportsCategory(name: "Điều hòa", icon: Icons.ac_unit, color: Color(0xFF06B6D4), bg: Color(0xFFCFFAFE)),
  SportsCategory(name: "Đèn LED", icon: Icons.lightbulb, color: Color(0xFFF97316), bg: Color(0xFFFFEDD5)),
  SportsCategory(name: "Thuê vợt", icon: Icons.shopping_bag, color: Color(0xFFA855F7), bg: Color(0xFFF3E8FF)),
  SportsCategory(name: "Bãi xe", icon: Icons.local_parking, color: Color(0xFF64748B), bg: Color(0xFFE2E8F0)),
  SportsCategory(name: "Nước uống", icon: Icons.local_drink, color: Color(0xFFEF4444), bg: Color(0xFFFEE2E2)),
];

final List<String> BADMINTON_SPORT_FILTERS = ["Cầu lông"];

final List<BannerInfo> BANNERS = [
  BannerInfo(id: 1, title: "Đặt sân cầu lông", sub: "Lịch trống theo thời gian thực", cta: "Đặt ngay", image: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&h=400&fit=crop&auto=format", color: Color(0xFF2563EB)),
  BannerInfo(id: 2, title: "Khung giờ vàng", sub: "Giá tốt cho buổi sáng", cta: "Xem ngay", image: "https://images.unsplash.com/photo-1613918108466-292b78a8ef95?w=800&h=400&fit=crop&auto=format", color: Color(0xFFF97316)),
  BannerInfo(id: 3, title: "CLB mới mở", sub: "Sân trong nhà, đèn LED", cta: "Khám phá", image: "https://images.unsplash.com/photo-1600679472829-3044539ce8ed?w=800&h=400&fit=crop&auto=format", color: Color(0xFF22C55E)),
];

final List<String> QUICK_FILTERS = ["Tất cả", "Gần nhất", "Giá thấp", "Đánh giá cao", "Mở ngay"];

final List<FacilityInfo> FACILITIES = [
  FacilityInfo(icon: Icons.local_parking, label: "Bãi đỗ xe"),
  FacilityInfo(icon: Icons.opacity, label: "Phòng tắm"),
  FacilityInfo(icon: Icons.inventory, label: "Tủ đồ"),
  FacilityInfo(icon: Icons.lightbulb, label: "Đèn LED"),
  FacilityInfo(icon: Icons.wifi, label: "Wi-Fi"),
  FacilityInfo(icon: Icons.local_drink, label: "Nước uống"),
];

final List<TimeSlot> TIME_SLOTS = [
  TimeSlot(time: "06:00", available: true),
  TimeSlot(time: "07:00", available: true),
  TimeSlot(time: "08:00", available: false),
  TimeSlot(time: "09:00", available: false),
  TimeSlot(time: "10:00", available: true),
  TimeSlot(time: "11:00", available: true),
  TimeSlot(time: "14:00", available: true),
  TimeSlot(time: "15:00", available: false),
  TimeSlot(time: "16:00", available: true),
  TimeSlot(time: "17:00", available: true),
  TimeSlot(time: "18:00", available: false),
  TimeSlot(time: "19:00", available: true),
  TimeSlot(time: "20:00", available: true),
  TimeSlot(time: "21:00", available: false),
];

final List<ReviewInfo> FIELD_REVIEWS = [
  ReviewInfo(name: "Trần Văn Minh", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop", rating: 5, date: "2 ngày trước", comment: "Sân rất đẹp, cỏ chất lượng tốt. Nhân viên thân thiện. Sẽ quay lại!"),
  ReviewInfo(name: "Nguyễn Thu Hà", avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=60&h=60&fit=crop", rating: 4, date: "1 tuần trước", comment: "Vị trí thuận tiện, giá hợp lý. Hệ thống đèn chiếu sáng tốt cho buổi tối."),
  ReviewInfo(name: "Lê Hoàng Nam", avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop", rating: 5, date: "2 tuần trước", comment: "Tuyệt vời! Đặt qua app nhanh chóng, check-in dễ dàng bằng QR code."),
];

final List<PaymentMethod> PAYMENT_METHODS = [
  PaymentMethod(id: "momo", label: "MoMo", color: Color(0xFFAE2070), icon: "💜"),
  PaymentMethod(id: "vnpay", label: "VNPay", color: Color(0xFF0066CC), icon: "💙"),
  PaymentMethod(id: "card", label: "Thẻ ngân hàng", color: Color(0xFF2563EB), icon: "💳"),
  PaymentMethod(id: "cash", label: "Tiền mặt tại sân", color: Color(0xFF22C55E), icon: "💵"),
];

final List<BookingInfo> MOCK_BOOKINGS = [
  BookingInfo(id: "BK001", venue: VENUES[0], date: "Thứ 7, 12 Jul 2025", time: "19:00 – 20:00", status: "upcoming", amount: "120.000đ", court: "Sân cầu lông 1"),
  BookingInfo(id: "BK002", venue: VENUES[1], date: "Thứ 3, 8 Jul 2025", time: "08:00 – 09:00", status: "completed", amount: "150.000đ", court: "Sân VIP 1"),
  BookingInfo(id: "BK003", venue: VENUES[3], date: "Thứ 2, 7 Jul 2025", time: "17:00 – 18:00", status: "completed", amount: "140.000đ", court: "Sân 2"),
  BookingInfo(id: "BK004", venue: VENUES[2], date: "Chủ nhật, 6 Jul 2025", time: "06:00 – 07:00", status: "cancelled", amount: "130.000đ", court: "Sân Q7 A"),
];

final List<String> RECENT_SEARCHES = ["Cầu lông Phú Nhuận", "Sân cầu lông Quận 7", "Cầu lông Thủ Đức"];
final List<String> POPULAR_SEARCHES = ["Sân trong nhà", "Cầu lông giá rẻ", "Có điều hòa", "Thuê vợt", "Mở cửa tối"];

final List<OnboardingScreenInfo> OB_SCREENS = [
  OnboardingScreenInfo(
    id: 0,
    image: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&h=900&fit=crop&auto=format&q=80",
    tag: "SportBook",
    headline: "Book Your\nPerfect Game",
    sub: "Khám phá và đặt sân cầu lông trong vài chạm, xem lịch trống, giá sân và thông tin tiện ích rõ ràng.",
    features: [],
    primaryBtn: "Bắt đầu ngay",
    secondaryBtn: "Bỏ qua",
    accent: Color(0xFF2563EB),
  ),
  OnboardingScreenInfo(
    id: 1,
    image: "https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800&h=900&fit=crop&auto=format&q=80",
    tag: "Khám phá",
    headline: "Hàng nghìn\nSân Thể Thao",
    sub: "Tìm sân gần bạn với lịch trống thời gian thực, đánh giá, giá cả và hình ảnh thực tế.",
    features: [
      OnboardingFeature(icon: Icons.pin_drop, label: "Theo vị trí", color: Color(0xFF2563EB)),
      OnboardingFeature(icon: Icons.verified_user, label: "Đã xác thực", color: Color(0xFF22C55E)),
      OnboardingFeature(icon: Icons.wifi, label: "Lịch trống live", color: Color(0xFFF97316)),
      OnboardingFeature(icon: Icons.bookmark, label: "Yêu thích", color: Color(0xFFA855F7)),
    ],
    primaryBtn: "Tiếp theo",
    secondaryBtn: "Bỏ qua",
    accent: Color(0xFF22C55E),
  ),
  OnboardingScreenInfo(
    id: 2,
    image: "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=800&h=900&fit=crop&auto=format&q=80",
    tag: "Đặt lịch",
    headline: "Đặt Sân\nChỉ 30 Giây",
    sub: "Chọn ngày, giờ và sân yêu thích. Xác nhận tức thì, không cần gọi điện hay chờ đợi.",
    features: [
      OnboardingFeature(icon: Icons.flash_on, label: "Đặt ngay lập tức", color: Color(0xFFF59E0B)),
      OnboardingFeature(icon: Icons.credit_card, label: "Thanh toán bảo mật", color: Color(0xFF2563EB)),
      OnboardingFeature(icon: Icons.history, label: "Lịch sử đặt sân", color: Color(0xFF22C55E)),
      OnboardingFeature(icon: Icons.qr_code, label: "Xác nhận QR code", color: Color(0xFFF97316)),
    ],
    primaryBtn: "Tiếp theo",
    secondaryBtn: "Bỏ qua",
    accent: Color(0xFFF97316),
  ),
  OnboardingScreenInfo(
    id: 3,
    image: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&h=900&fit=crop&auto=format&q=80",
    tag: "Cộng đồng",
    headline: "Cùng Chơi\nNhiều Hơn",
    sub: "Tham gia giải đấu, kết nối với cầu thủ mới và không bao giờ bỏ lỡ trận đấu tiếp theo.",
    features: [
      OnboardingFeature(icon: Icons.sports_esports, label: "Sự kiện thể thao", color: Color(0xFFEF4444)),
      OnboardingFeature(icon: Icons.people_outline, label: "Cộng đồng", color: Color(0xFF2563EB)),
      OnboardingFeature(icon: Icons.local_offer, label: "Ưu đãi độc quyền", color: Color(0xFFF97316)),
      OnboardingFeature(icon: Icons.psychology, label: "Gợi ý cá nhân", color: Color(0xFFA855F7)),
    ],
    primaryBtn: "Bắt đầu chơi",
    secondaryBtn: "Đã có tài khoản",
    accent: Color(0xFF2563EB),
  ),
];
