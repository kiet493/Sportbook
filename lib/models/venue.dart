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
  Venue({required this.id, String? firestoreId, required this.name, required this.sport, required this.distance, required this.rating, required this.reviews, required this.hours, required this.price, required this.priceNum, required this.available, required this.image, required this.images, required this.address, required this.description}) : firestoreId = firestoreId ?? id.toString();
}

class BookingInfo {
  final String id;
  final Venue venue;
  final String date;
  final String time;
  final String status;
  final String amount;
  final String court;
  final List<String> addOns;
  const BookingInfo({required this.id, required this.venue, required this.date, required this.time, required this.status, required this.amount, required this.court, this.addOns = const []});
}

class SportsCategory {
  final String name;
  final IconData icon;
  final Color color, bg;
  const SportsCategory({required this.name, required this.icon, required this.color, required this.bg});
}

class BannerInfo {
  final int id;
  final String title, sub, cta, image;
  final Color color;
  const BannerInfo({required this.id, required this.title, required this.sub, required this.cta, required this.image, required this.color});
}

class TimeSlot {
  final String time;
  final bool available;
  const TimeSlot({required this.time, required this.available});
}

class ReviewInfo {
  final String name, avatar, date, comment;
  final int rating;
  const ReviewInfo({required this.name, required this.avatar, required this.rating, required this.date, required this.comment});
}

class PaymentMethod {
  final String id, label, icon;
  final Color color;
  const PaymentMethod({required this.id, required this.label, required this.color, required this.icon});
}
