import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/community_models.dart';
import '../../models/court_booking.dart';
import '../../providers/booking_providers.dart';
import '../../providers/community_providers.dart';
import '../../providers/registration_providers.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<SportEvent> onCreated;

  const CreateEventPage({
    super.key,
    required this.onBack,
    required this.onCreated,
  });

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  static const _hourlyRate = 50000;
  static const _maxImages = 3;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController(text: '20');
  final List<TextEditingController> _imageControllers = List.generate(
    _maxImages,
    (_) => TextEditingController(),
  );
  ManagedVenue? _venue;
  SportCourt? _court;
  DateTime? _startDate;
  DateTime? _endDate;
  int _startMinutes = 18 * 60;
  int _endMinutes = 20 * 60;

  DateTime get _minimumDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 3));
  }

  int get _dayCount => _startDate == null || _endDate == null
      ? 0
      : _endDate!.difference(_startDate!).inDays + 1;

  int get _minutesPerDay => _endMinutes - _startMinutes;
  int get _totalMinutes => _dayCount * _minutesPerDay;
  int get _totalPrice => (_totalMinutes * _hourlyRate / 60).round();

  List<String> get _imageUrls => _imageControllers
      .map((c) => c.text.trim())
      .where((url) => url.isNotEmpty)
      .toList();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    for (final c in _imageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final venues = ref.watch(managedVenuesProvider);
    final courts = _venue == null
        ? const AsyncValue<List<SportCourt>>.data([])
        : ref.watch(venueCourtsProvider(_venue!.id));
    final submitting = ref.watch(createEventProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: submitting ? null : widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Tạo đơn sự kiện'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Notice(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên sự kiện',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            venues.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Không tải được cụm sân: $error'),
              data: (items) => DropdownButtonFormField<ManagedVenue>(
                key: ValueKey(_venue?.id),
                initialValue: items
                    .where((item) => item.id == _venue?.id)
                    .firstOrNull,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Cụm sân',
                  border: OutlineInputBorder(),
                ),
                items: items
                    .where((item) => item.active)
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: submitting
                    ? null
                    : (value) => setState(() {
                        _venue = value;
                        _court = null;
                      }),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn cụm sân.' : null,
              ),
            ),
            const SizedBox(height: 12),
            courts.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Không tải được sân: $error'),
              data: (items) {
                final activeCourts = items
                    .where((item) => item.active)
                    .toList();
                return DropdownButtonFormField<SportCourt>(
                  key: ValueKey('${_venue?.id}_${_court?.id}'),
                  initialValue: activeCourts
                      .where((item) => item.id == _court?.id)
                      .firstOrNull,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sân tổ chức',
                    border: OutlineInputBorder(),
                  ),
                  items: activeCourts
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            '${item.name} • ${item.sport}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: submitting
                      ? null
                      : (value) => setState(() => _court = value),
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn sân.' : null,
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Từ ngày',
                    value: _startDate,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateField(
                    label: 'Đến ngày',
                    value: _endDate,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày bắt đầu sớm nhất: ${_formatDate(_minimumDate)}.',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _timeDropdown(true)),
                const SizedBox(width: 10),
                Expanded(child: _timeDropdown(false)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Khung giờ áp dụng giống nhau cho tất cả các ngày.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số người tối đa',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final number = int.tryParse(value ?? '');
                return number == null || number < 2
                    ? 'Số người tối thiểu là 2.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            _ImageUrlPicker(
              controllers: _imageControllers,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),
            _OrderSummary(
              dayCount: _dayCount,
              minutesPerDay: _minutesPerDay,
              totalMinutes: _totalMinutes,
              totalPrice: _totalPrice,
              hourlyRate: _hourlyRate,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: submitting ? null : _submit,
              icon: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.receipt_long_outlined),
              label: const Text('Tạo đơn và thanh toán'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: const Color(0xFF9333EA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeDropdown(bool isStart) {
    final values = <int>[
      for (
        var minute = isStart ? 6 * 60 : 6 * 60 + 30;
        minute <= (isStart ? 22 * 60 + 30 : 23 * 60);
        minute += 30
      )
        minute,
    ];
    final value = isStart ? _startMinutes : _endMinutes;
    return DropdownButtonFormField<int>(
      key: ValueKey('${isStart ? 'start' : 'end'}_$value'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: isStart ? 'Giờ bắt đầu' : 'Giờ kết thúc',
        border: const OutlineInputBorder(),
      ),
      items: values
          .map(
            (minute) => DropdownMenuItem(
              value: minute,
              child: Text(formatMinutes(minute)),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected == null) return;
        setState(() {
          if (isStart) {
            _startMinutes = selected;
            if (_endMinutes <= selected) _endMinutes = selected + 30;
          } else {
            _endMinutes = selected;
          }
        });
      },
      validator: (_) => _endMinutes <= _startMinutes
          ? 'Giờ kết thúc phải sau giờ bắt đầu.'
          : null,
    );
  }

  Future<void> _pickDate(bool start) async {
    final initial = (start ? _startDate : _endDate) ?? _minimumDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(_minimumDate) ? _minimumDate : initial,
      firstDate: _minimumDate,
      lastDate: _minimumDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startDate = picked;
        if (_endDate == null || _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final venue = _venue;
    final court = _court;
    final startDate = _startDate;
    final endDate = _endDate;
    final user = ref.read(sessionProvider)?.user;
    if (venue == null ||
        court == null ||
        startDate == null ||
        endDate == null ||
        user == null) {
      _showError('Vui lòng chọn cụm sân, sân và đầy đủ ngày tổ chức.');
      return;
    }
    if (startDate.isBefore(_minimumDate)) {
      _showError('Sự kiện chỉ được đặt từ 3 ngày sau hôm nay.');
      return;
    }
    if (_dayCount < 1) {
      _showError('Ngày kết thúc phải bằng hoặc sau ngày bắt đầu.');
      return;
    }
    final slotsPerDay = _minutesPerDay ~/ 30;
    if (_dayCount * slotsPerDay > 450) {
      _showError(
        'Đơn có quá nhiều ô giờ. Hãy giảm số ngày hoặc thời lượng mỗi ngày.',
      );
      return;
    }
    final startAt = _atMinutes(startDate, _startMinutes);
    final endAt = _atMinutes(endDate, _endMinutes);
    final imageUrls = _imageUrls;
    final primaryImage = imageUrls.isNotEmpty
        ? imageUrls.first
        : (court.images.firstOrNull ?? venue.image);
    final event = SportEvent(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      sport: court.sport.isEmpty ? 'Thể thao' : court.sport,
      location: venue.name,
      imageUrl: primaryImage,
      images: imageUrls,
      startAt: startAt,
      endAt: endAt,
      capacity: int.parse(_capacityController.text),
      registeredCount: 0,
      active: false,
      createdBy: user.id,
      creatorName: user.fullName,
      venueId: venue.id,
      fieldId: court.id,
      courtName: court.name,
      dailyStartMinutes: _startMinutes,
      dailyEndMinutes: _endMinutes,
      deadline: startAt,
      minPlayers: 1,
      status: 'pending_payment',
      estimatedPrice: _totalPrice,
      hourlyRate: _hourlyRate,
      totalDurationMinutes: _totalMinutes,
      paymentStatus: 'unpaid',
    );
    final error = await ref.read(createEventProvider.notifier).create(event);
    if (!mounted) return;
    if (error != null) {
      _showError(error);
      return;
    }
    final saved = ref.read(createEventProvider).valueOrNull;
    if (saved != null) widget.onCreated(saved);
  }

  DateTime _atMinutes(DateTime date, int minutes) =>
      DateTime(date.year, date.month, date.day, minutes ~/ 60, minutes % 60);

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Không được để trống.' : null;

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _OrderSummary extends StatelessWidget {
  final int dayCount;
  final int minutesPerDay;
  final int totalMinutes;
  final int totalPrice;
  final int hourlyRate;

  const _OrderSummary({
    required this.dayCount,
    required this.minutesPerDay,
    required this.totalMinutes,
    required this.totalPrice,
    required this.hourlyRate,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFF3E8FF),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _row('Số ngày', '$dayCount ngày'),
          _row('Thời lượng mỗi ngày', _duration(minutesPerDay)),
          _row('Tổng thời lượng', _duration(totalMinutes), bold: true),
          _row('Đơn giá', '${formatVnd(hourlyRate)}đ/giờ'),
          const Divider(),
          _row('Tổng thanh toán', '${formatVnd(totalPrice)}đ', bold: true),
        ],
      ),
    ),
  );

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(fontWeight: bold ? FontWeight.w800 : null),
        ),
      ],
    ),
  );

  String _duration(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '$hours giờ' : '$hours giờ $remainder phút';
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3E8FF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: Color(0xFF7E22CE)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Đây là đơn đặt sân sự kiện. Phải đặt trước ít nhất 3 ngày; các ô giờ sẽ được giữ màu tím trong lúc thanh toán.',
          ),
        ),
      ],
    ),
  );
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(value == null ? 'Chọn ngày' : _formatDate(value!)),
    ),
  );
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Widget cho phép ng\u01b0\u1eddi d\u00f9ng nh\u1eadp t\u1ed1i \u0111a 3 URL \u1ea3nh v\u00e0 xem tr\u01b0\u1edbc.
class _ImageUrlPicker extends StatefulWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onChanged;

  const _ImageUrlPicker({
    required this.controllers,
    required this.onChanged,
  });

  @override
  State<_ImageUrlPicker> createState() => _ImageUrlPickerState();
}

class _ImageUrlPickerState extends State<_ImageUrlPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF7E22CE)),
              const SizedBox(width: 8),
              const Text(
                '\u1ea2nh s\u1ef1 ki\u1ec7n',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'T\u1ed1i \u0111a 3 \u1ea3nh',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7E22CE), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'D\u00e1n \u0111\u01b0\u1eddng d\u1eabn URL \u1ea3nh (jpg, png...) \u0111\u1ec3 hi\u1ec3n th\u1ecb trong s\u1ef1 ki\u1ec7n.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < widget.controllers.length; i++) ...[
            _ImageUrlRow(
              index: i,
              controller: widget.controllers[i],
              onChanged: () {
                setState(() {});
                widget.onChanged();
              },
            ),
            if (i < widget.controllers.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ImageUrlRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _ImageUrlRow({
    required this.index,
    required this.controller,
    required this.onChanged,
  });

  bool get _hasUrl => controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: '\u1ea2nh ${index + 1}${index == 0 ? ' (ch\u00ednh)' : ' (t\u00f9y ch\u1ecdn)'}',
            hintText: 'https://example.com/image.jpg',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.link, size: 18),
            suffixIcon: _hasUrl
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.clear();
                      onChanged();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        if (_hasUrl) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              controller.text.trim(),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined, color: Color(0xFFB91C1C), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'URL \u1ea3nh kh\u00f4ng h\u1ee3p l\u1ec7 ho\u1eb7c kh\u00f4ng t\u1ea3i \u0111\u01b0\u1ee3c.',
                      style: TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
                    ),
                  ],
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

