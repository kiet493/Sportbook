import 'package:flutter/material.dart';

import 'booking_counter_button.dart';

/// Card with two counter rows: duration (hours) and players.
class BookingCountersCard extends StatelessWidget {
  final int duration;
  final int players;
  final int maxPlayers;
  final String priceLabel;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<int> onPlayersChanged;

  static const int _minDuration = 1;
  static const int _maxDuration = 4;
  static const int _minPlayers = 2;

  const BookingCountersCard({
    super.key,
    required this.duration,
    required this.players,
    required this.maxPlayers,
    required this.priceLabel,
    required this.onDurationChanged,
    required this.onPlayersChanged,
  });

  void _decrement(int current, int min, ValueChanged<int> setter) {
    if (current > min) setter(current - 1);
  }

  void _increment(int current, int max, ValueChanged<int> setter) {
    if (current < max) setter(current + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thời lượng",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$duration giờ × $priceLabel",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  BookingCounterButton(
                    icon: Icons.remove,
                    onTap: duration > _minDuration
                        ? () => _decrement(duration, _minDuration, onDurationChanged)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "$duration",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BookingCounterButton(
                    icon: Icons.add,
                    isPrimary: true,
                    onTap: duration < _maxDuration
                        ? () => _increment(duration, _maxDuration, onDurationChanged)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Số người chơi",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Tối đa $maxPlayers người",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  BookingCounterButton(
                    icon: Icons.remove,
                    onTap: players > _minPlayers
                        ? () => _decrement(players, _minPlayers, onPlayersChanged)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "$players",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BookingCounterButton(
                    icon: Icons.add,
                    isPrimary: true,
                    onTap: players < maxPlayers
                        ? () => _increment(players, maxPlayers, onPlayersChanged)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
