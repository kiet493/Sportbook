import 'package:flutter/material.dart';

class Venue {
  final int id;
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
  });
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
    name: "SVĐ Arena Quận 7",
    sport: ["Bóng đá", "5v5"],
    distance: "1.2 km",
    rating: 4.9,
    reviews: 312,
    hours: "06:00 – 22:00",
    price: "180.000đ/h",
    priceNum: 180000,
    available: true,
    image: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=600&h=380&fit=crop&auto=format",
    images: [
      "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&h=500&fit=crop&auto=format",
      "https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800&h=500&fit=crop&auto=format",
      "https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&h=500&fit=crop&auto=format",
    ],
    address: "268 Nguyễn Văn Linh, Quận 7, TP.HCM",
    description: "Sân bóng đá 5v5 tiêu chuẩn quốc tế với mặt cỏ nhân tạo thế hệ mới. Hệ thống đèn LED chiếu sáng đảm bảo chất lượng thi đấu tốt nhất cả ngày lẫn đêm.",
  ),
  Venue(
    id: 2,
    name: "Tennis Club Thảo Điền",
    sport: ["Tennis"],
    distance: "2.8 km",
    rating: 4.8,
    reviews: 189,
    hours: "07:00 – 21:00",
    price: "250.000đ/h",
    priceNum: 250000,
    available: true,
    image: "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=600&h=380&fit=crop&auto=format",
    images: [
      "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=800&h=500&fit=crop&auto=format",
      "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800&h=500&fit=crop&auto=format",
    ],
    address: "12 Xuân Thủy, Quận 2, TP.HCM",
    description: "CLB tennis cao cấp với 6 sân tiêu chuẩn, mặt sân đa dạng gồm hard court và clay court. Phù hợp cho cả người mới và vận động viên chuyên nghiệp.",
  ),
  Venue(
    id: 3,
    name: "Aqua Sport Center",
    sport: ["Bơi lội"],
    distance: "3.4 km",
    rating: 4.9,
    reviews: 421,
    hours: "05:30 – 21:00",
    price: "90.000đ/h",
    priceNum: 90000,
    available: false,
    image: "https://images.unsplash.com/photo-1530549387789-4c1017266635?w=600&h=380&fit=crop&auto=format",
    images: [
      "https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800&h=500&fit=crop&auto=format",
      "https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=800&h=500&fit=crop&auto=format",
    ],
    address: "45 Đinh Tiên Hoàng, Bình Thạnh, TP.HCM",
    description: "Hồ bơi Olympic 50m với hệ thống lọc nước hiện đại. Có làn bơi riêng cho các cấp độ từ người mới đến chuyên nghiệp.",
  ),
  Venue(
    id: 4,
    name: "Galaxy Badminton Club",
    sport: ["Cầu lông"],
    distance: "0.8 km",
    rating: 4.7,
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
    description: "Sân cầu lông trong nhà với 12 sân chơi, sàn gỗ chuyên dụng và hệ thống điều hòa mát lạnh. Cho thuê vợt và bán cầu tại chỗ.",
  ),
];

final List<SportsCategory> SPORTS_CATEGORIES = [
  SportsCategory(name: "Bóng đá", icon: Icons.flash_on, color: Color(0xFF22C55E), bg: Color(0xFFDCFCE7)),
  SportsCategory(name: "Cầu lông", icon: Icons.air, color: Color(0xFF3B82F6), bg: Color(0xFFDBEAFE)),
  SportsCategory(name: "Pickleball", icon: Icons.offline_bolt, color: Color(0xFFF97316), bg: Color(0xFFFFEDD5)),
  SportsCategory(name: "Tennis", icon: Icons.emoji_events, color: Color(0xFFA855F7), bg: Color(0xFFF3E8FF)),
  SportsCategory(name: "Bóng rổ", icon: Icons.sports_basketball, color: Color(0xFFEF4444), bg: Color(0xFFFEE2E2)),
  SportsCategory(name: "Bóng chuyền", icon: Icons.sports_volleyball, color: Color(0xFF06B6D4), bg: Color(0xFFCFFAFE)),
  SportsCategory(name: "Gym", icon: Icons.fitness_center, color: Color(0xFF8B5CF6), bg: Color(0xFFEDE9FE)),
  SportsCategory(name: "Bơi lội", icon: Icons.pool, color: Color(0xFF0EA5E9), bg: Color(0xFFE0F2FE)),
];

final List<BannerInfo> BANNERS = [
  BannerInfo(id: 1, title: "Giải Cuối Tuần", sub: "500+ đội thi đấu", cta: "Đăng ký", image: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&h=400&fit=crop&auto=format", color: Color(0xFF2563EB)),
  BannerInfo(id: 2, title: "Ưu đãi Tennis", sub: "Giảm 30% tháng 7", cta: "Xem ngay", image: "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=800&h=400&fit=crop&auto=format", color: Color(0xFFF97316)),
  BannerInfo(id: 3, title: "Sân mới Q.9", sub: "Chuẩn quốc tế", cta: "Khám phá", image: "https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800&h=400&fit=crop&auto=format", color: Color(0xFF22C55E)),
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
  BookingInfo(id: "BK001", venue: VENUES[0], date: "Thứ 7, 12 Jul 2025", time: "19:00 – 20:00", status: "upcoming", amount: "180.000đ", court: "Sân A"),
  BookingInfo(id: "BK002", venue: VENUES[1], date: "Thứ 3, 8 Jul 2025", time: "08:00 – 09:00", status: "completed", amount: "250.000đ", court: "Sân 2"),
  BookingInfo(id: "BK003", venue: VENUES[3], date: "Thứ 2, 7 Jul 2025", time: "17:00 – 18:00", status: "completed", amount: "120.000đ", court: "Sân 5"),
  BookingInfo(id: "BK004", venue: VENUES[2], date: "Chủ nhật, 6 Jul 2025", time: "06:00 – 07:00", status: "cancelled", amount: "90.000đ", court: "Làn 3"),
];

final List<String> RECENT_SEARCHES = ["Sân bóng đá Quận 7", "Tennis gần đây", "Cầu lông Phú Nhuận"];
final List<String> POPULAR_SEARCHES = ["Bóng đá 5v5", "Tennis buổi sáng", "Gym 24h", "Cầu lông giá rẻ", "Pickleball mới"];

final List<OnboardingScreenInfo> OB_SCREENS = [
  OnboardingScreenInfo(
    id: 0,
    image: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&h=900&fit=crop&auto=format&q=80",
    tag: "SportBook",
    headline: "Book Your\nPerfect Game",
    sub: "Khám phá và đặt sân bóng đá, cầu lông, tennis, pickleball và hơn 8 môn thể thao chỉ trong vài chạm.",
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
