import 'package:flutter/material.dart';
import '../models/venue.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingInfo booking;
  final VoidCallback onBack;

  const BookingDetailScreen({
    Key? key,
    required this.booking,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Timeline steps based on status
    final List<TimelineStep> timeline = [
      TimelineStep(
        label: "Đặt sân thành công",
        time: "10:23 AM",
        done: true,
      ),
      TimelineStep(
        label: "Thanh toán xác nhận",
        time: "10:24 AM",
        done: true,
      ),
      TimelineStep(
        label: "Sân đã xác nhận",
        time: "10:25 AM",
        done: booking.status != "cancelled",
      ),
      TimelineStep(
        label: "Hoàn thành",
        time: booking.status == "completed" ? "Đã hoàn thành" : "--",
        done: booking.status == "completed",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF0F172A)),
          onPressed: onBack,
        ),
        title: const Text(
          "Chi tiết đặt sân",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildStatusBadge(booking.status),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Venue card
            _buildVenueCard(),
            const SizedBox(height: 16),

            // Timeline status
            _buildTimelineCard(timeline),
            const SizedBox(height: 16),

            // Booking info fields
            _buildInfoCard(),
            const SizedBox(height: 16),

            // QR Code
            _buildQrCodeCard(),
            const SizedBox(height: 24),

            // Actions list
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 140,
            child: Image.network(
              booking.venue.image,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.venue.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF64748B),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.venue.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(List<TimelineStep> timeline) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Trạng thái đặt sân",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(timeline.length, (index) {
              final step = timeline[index];
              final isLast = index == timeline.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.done ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        ),
                        alignment: Alignment.center,
                        child: step.done
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF94A3B8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: step.done && timeline[index + 1].done
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: step.done ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Thông tin đặt sân",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Mã đặt sân", "#${booking.id}"),
          _buildInfoRow("Sân", booking.court),
          _buildInfoRow("Ngày", booking.date),
          _buildInfoRow("Giờ", booking.time),
          _buildInfoRow("Môn thể thao", booking.venue.sport[0]),
          _buildInfoRow("Số tiền", booking.amount, isBoldValue: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String val, {bool isBoldValue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "QR Check-in",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.qr_code,
              color: Color(0xFF0F172A),
              size: 100,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Xuất trình mã QR này khi đến sân để check-in",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (booking.status == "upcoming") ...[
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF2F2),
              foregroundColor: const Color(0xFFEF4444),
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.close, size: 16),
                SizedBox(width: 8),
                Text("Hủy đặt sân", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F172A),
            backgroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.refresh, size: 16),
              SizedBox(width: 8),
              Text("Đặt lại sân này", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F172A),
            backgroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.chat_bubble_outline, size: 16),
              SizedBox(width: 8),
              Text("Liên hệ ban quản lý", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case "upcoming":
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1D4ED8);
        label = "Sắp tới";
        break;
      case "completed":
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        label = "Hoàn thành";
        break;
      case "cancelled":
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        label = "Đã hủy";
        break;
      default:
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1D4ED8);
        label = "Sắp tới";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TimelineStep {
  final String label;
  final String time;
  final bool done;

  TimelineStep({
    required this.label,
    required this.time,
    required this.done,
  });
}
