import '../../models/venue.dart';

class VenueFilter {
  final String query, sport, sort;
  final int? maxPrice;
  final double? minRating;
  final bool onlyAvailable;
  const VenueFilter({this.query = '', this.sport = 'Tất cả', this.sort = 'Gần nhất', this.maxPrice, this.minRating, this.onlyAvailable = false});
}

List<Venue> filterVenues(List<Venue> venues, VenueFilter filter) {
  final query = filter.query.trim().toLowerCase();
  final result = venues.where((venue) {
    final matchesQuery = query.isEmpty || venue.name.toLowerCase().contains(query) || venue.address.toLowerCase().contains(query) || venue.sport.any((item) => item.toLowerCase().contains(query));
    final matchesSport = filter.sport == 'Tất cả' || venue.sport.any((item) => item.toLowerCase() == filter.sport.toLowerCase());
    return matchesQuery && matchesSport && (filter.maxPrice == null || venue.priceNum <= filter.maxPrice!) && (filter.minRating == null || venue.rating >= filter.minRating!) && (!filter.onlyAvailable || venue.available);
  }).toList();
  result.sort((a, b) {
    switch (filter.sort) {
      case 'Đánh giá cao': return b.rating.compareTo(a.rating);
      case 'Giá thấp nhất': return a.priceNum.compareTo(b.priceNum);
      case 'Giá cao nhất': return b.priceNum.compareTo(a.priceNum);
      case 'Phổ biến nhất': return b.reviews.compareTo(a.reviews);
      default: return _distance(a.distance).compareTo(_distance(b.distance));
    }
  });
  return result;
}

int _distance(String value) {
  final raw = RegExp(r'([0-9]+(?:[.,][0-9]+)?)').firstMatch(value)?.group(1) ?? '';
  return ((double.tryParse(raw.replaceAll(',', '.')) ?? 9999) * 1000).round();
}
