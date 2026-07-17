import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/back_chevron_button.dart';
import '../../models/court_booking.dart';
import '../../providers/booking_providers.dart';
import '../../providers/registration_providers.dart';
import '../../services/Firebase/booking_firestore_service.dart';

class ManageVenuesPage extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const ManageVenuesPage({super.key, this.onBack});

  @override
  ConsumerState<ManageVenuesPage> createState() => _ManageVenuesPageState();
}

class _ManageVenuesPageState extends ConsumerState<ManageVenuesPage> {
  String? _selectedVenueId;

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(managedVenuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackChevronButton(onPressed: widget.onBack),
        title: const Text(
          'Quản lý sân',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Thêm cụm sân',
            onPressed: () => _showVenueSheet(context),
            icon: const Icon(Icons.add_business, color: AppColors.primary),
          ),
        ],
      ),
      body: venuesAsync.when(
        data: (venues) {
          if (venues.isEmpty) {
            return _EmptyVenues(onCreate: () => _showVenueSheet(context));
          }
          final selected = venues.any((venue) => venue.id == _selectedVenueId)
              ? _selectedVenueId
              : venues.first.id;
          _selectedVenueId = selected;
          final venue = venues.firstWhere((item) => item.id == selected);

          return Column(
            children: [
              SizedBox(
                height: 68,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: venues.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = venues[index];
                    final active = item.id == selected;
                    return ChoiceChip(
                      selected: active,
                      label: Text(item.name),
                      onSelected: (_) =>
                          setState(() => _selectedVenueId = item.id),
                    );
                  },
                ),
              ),
              Expanded(child: _VenueEditor(venue: venue)),
            ],
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Không tải được danh sách sân: $error'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(managedVenuesProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showVenueSheet(
    BuildContext context, [
    ManagedVenue? venue,
  ]) async {
    final ownerId = ref.read(sessionProvider)?.user.id ?? '';
    final result = await showModalBottomSheet<ManagedVenue>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _VenueFormSheet(venue: venue, currentOwnerId: ownerId),
    );
    if (result == null || !context.mounted) return;
    await _runAdminMutation(
      context,
      () => ref.read(bookingFirestoreServiceProvider).upsertVenue(result),
      success: venue == null ? 'Đã tạo cụm sân' : 'Đã cập nhật cụm sân',
    );
  }
}

class _VenueEditor extends ConsumerWidget {
  final ManagedVenue venue;

  const _VenueEditor({required this.venue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courtsAsync = ref.watch(venueCourtsProvider(venue.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(managedVenuesProvider);
        ref.invalidate(venueCourtsProvider(venue.id));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _VenueSummaryCard(venue: venue),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh sách sân con',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCourtSheet(
                  context,
                  ref,
                  venue,
                  suggestedSortOrder:
                      (courtsAsync.valueOrNull?.length ?? 0) + 1,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm sân'),
              ),
            ],
          ),
          courtsAsync.when(
            data: (courts) => courts.isEmpty
                ? _EmptyCourts(venue: venue)
                : Column(
                    children: courts
                        .map((court) => _CourtTile(venue: venue, court: court))
                        .toList(),
                  ),
            error: (error, _) => Text('Không tải được sân con: $error'),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCourtSheet(
    BuildContext context,
    WidgetRef ref,
    ManagedVenue venue, {
    int suggestedSortOrder = 1,
  }) async {
    final result = await showModalBottomSheet<SportCourt>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CourtFormSheet(
        venue: venue,
        suggestedSortOrder: suggestedSortOrder,
      ),
    );
    if (result == null || !context.mounted) return;
    await _runAdminMutation(
      context,
      () => ref.read(bookingFirestoreServiceProvider).upsertCourt(result),
      success: 'Đã tạo sân',
    );
  }
}

class _VenueSummaryCard extends ConsumerWidget {
  final ManagedVenue venue;

  const _VenueSummaryCard({required this.venue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Switch(
                value: venue.active,
                onChanged: (value) => _runAdminMutation(
                  context,
                  () => ref
                      .read(bookingFirestoreServiceProvider)
                      .upsertVenue(venue.copyWith(active: value)),
                  success: value ? 'Đã mở cụm sân' : 'Đã khóa cụm sân',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            venue.address,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(icon: Icons.schedule, label: venue.hours),
              _InfoPill(
                icon: Icons.payments_outlined,
                label: '${formatVnd(venue.pricePerHour)}đ/giờ',
              ),
              _InfoPill(icon: Icons.sports, label: venue.sports.join(', ')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditVenue(context, ref, venue),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Sửa'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDeleteVenue(context, ref, venue),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Xóa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditVenue(
    BuildContext context,
    WidgetRef ref,
    ManagedVenue venue,
  ) async {
    final ownerId = ref.read(sessionProvider)?.user.id ?? '';
    final result = await showModalBottomSheet<ManagedVenue>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _VenueFormSheet(venue: venue, currentOwnerId: ownerId),
    );
    if (result == null || !context.mounted) return;
    await _runAdminMutation(
      context,
      () => ref.read(bookingFirestoreServiceProvider).upsertVenue(result),
      success: 'Đã cập nhật cụm sân',
    );
  }

  Future<void> _confirmDeleteVenue(
    BuildContext context,
    WidgetRef ref,
    ManagedVenue venue,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa cụm sân?'),
        content: Text(
          'Thao tác này sẽ xóa "${venue.name}", toàn bộ sân con và lịch mở sân. '
          'Cụm sân có booking sắp tới sẽ không thể xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _runAdminMutation(
      context,
      () => ref.read(bookingFirestoreServiceProvider).deleteVenue(venue.id),
      success: 'Đã xóa cụm sân',
    );
  }
}

class _CourtTile extends ConsumerWidget {
  final ManagedVenue venue;
  final SportCourt court;

  const _CourtTile({required this.venue, required this.court});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: court.active
                ? AppColors.successSoft
                : AppColors.dangerSoft,
            child: Icon(
              court.active ? Icons.check : Icons.lock_outline,
              color: court.active ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${court.sport} • ${formatVnd(court.pricePerHour)}đ/giờ • sức chứa ${court.capacity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: court.active ? 'Khóa sân' : 'Mở sân',
            onPressed: () => _runAdminMutation(
              context,
              () => ref
                  .read(bookingFirestoreServiceProvider)
                  .upsertCourt(court.copyWith(active: !court.active)),
              success: court.active ? 'Đã khóa sân' : 'Đã mở sân',
            ),
            icon: Icon(court.active ? Icons.lock_open : Icons.lock_outline),
          ),
          IconButton(
            tooltip: 'Sửa sân',
            onPressed: () => _showCourtSheet(context, ref, venue, court),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xóa sân',
            onPressed: () => _confirmDeleteCourt(context, ref, court),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  Future<void> _showCourtSheet(
    BuildContext context,
    WidgetRef ref,
    ManagedVenue venue,
    SportCourt court,
  ) async {
    final result = await showModalBottomSheet<SportCourt>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CourtFormSheet(
        venue: venue,
        court: court,
        suggestedSortOrder: court.sortOrder,
      ),
    );
    if (result == null || !context.mounted) return;
    await _runAdminMutation(
      context,
      () => ref.read(bookingFirestoreServiceProvider).upsertCourt(result),
      success: 'Đã cập nhật sân',
    );
  }

  Future<void> _confirmDeleteCourt(
    BuildContext context,
    WidgetRef ref,
    SportCourt court,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa sân?'),
        content: Text(
          'Bạn có chắc muốn xóa "${court.name}" và lịch mở sân liên quan? '
          'Sân có booking sắp tới sẽ không thể xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _runAdminMutation(
      context,
      () => ref.read(bookingFirestoreServiceProvider).deleteCourt(court.id),
      success: 'Đã xóa sân',
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

Future<void> _runAdminMutation(
  BuildContext context,
  Future<void> Function() action, {
  required String success,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(success)));
  } catch (error) {
    if (!context.mounted) return;
    final message = switch (error) {
      ActiveVenueBookingsException exception =>
        'Không thể xóa "${exception.venueName}" vì còn booking sắp tới. Hãy khóa cụm sân thay vì xóa.',
      ActiveCourtBookingsException exception =>
        'Không thể xóa "${exception.courtName}" vì còn booking sắp tới. Hãy khóa sân thay vì xóa.',
      VenueDataException exception => exception.message,
      _ => 'Không thể lưu dữ liệu Firebase: $error',
    };
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _VenueFormSheet extends StatefulWidget {
  final ManagedVenue? venue;
  final String currentOwnerId;

  const _VenueFormSheet({this.venue, required this.currentOwnerId});

  @override
  State<_VenueFormSheet> createState() => _VenueFormSheetState();
}

class _VenueFormSheetState extends State<_VenueFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sports;
  late final TextEditingController _address;
  late final TextEditingController _hours;
  late final TextEditingController _price;
  late final TextEditingController _image;
  late final TextEditingController _description;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final venue = widget.venue ?? ManagedVenue.empty();
    _name = TextEditingController(text: venue.name);
    _sports = TextEditingController(text: venue.sports.join(', '));
    _address = TextEditingController(text: venue.address);
    _hours = TextEditingController(text: venue.hours);
    _price = TextEditingController(text: venue.pricePerHour.toString());
    _image = TextEditingController(
      text: venue.image.isNotEmpty
          ? venue.image
          : (venue.images.firstOrNull ?? ''),
    );
    _description = TextEditingController(text: venue.description);
    _active = venue.active;
  }

  @override
  void dispose() {
    _name.dispose();
    _sports.dispose();
    _address.dispose();
    _hours.dispose();
    _price.dispose();
    _image.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.venue == null ? 'Thêm cụm sân' : 'Sửa cụm sân',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _TextInput(controller: _name, label: 'Tên cụm sân'),
              _TextInput(
                controller: _sports,
                label: 'Môn thể thao, cách nhau bằng dấu phẩy',
              ),
              _TextInput(controller: _address, label: 'Địa chỉ'),
              _TextInput(
                controller: _hours,
                label: 'Giờ mở cửa (HH:mm - HH:mm)',
                validate: _validateHours,
              ),
              _TextInput(
                controller: _price,
                label: 'Giá tham chiếu mỗi giờ',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              _TextInput(
                controller: _image,
                label: 'Ảnh URL',
                isRequired: false,
                validate: _validateUrl,
              ),
              _TextInput(
                controller: _description,
                label: 'Mô tả',
                maxLines: 3,
                isRequired: false,
              ),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: const Text('Đang hoạt động'),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Lưu cụm sân'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.venue ?? ManagedVenue.empty();
    final image = _image.text.trim();
    Navigator.pop(
      context,
      old.copyWith(
        name: _name.text.trim(),
        sports: _splitCsv(_sports.text),
        address: _address.text.trim(),
        hours: _hours.text.trim(),
        pricePerHour: int.parse(_price.text.trim()),
        active: _active,
        image: image,
        images: image.isEmpty ? const [] : [image],
        description: _description.text.trim(),
        ownerId: old.ownerId.isNotEmpty
            ? old.ownerId
            : widget.currentOwnerId,
      ),
    );
  }
}

class _CourtFormSheet extends StatefulWidget {
  final ManagedVenue venue;
  final SportCourt? court;
  final int suggestedSortOrder;

  const _CourtFormSheet({
    required this.venue,
    this.court,
    required this.suggestedSortOrder,
  });

  @override
  State<_CourtFormSheet> createState() => _CourtFormSheetState();
}

class _CourtFormSheetState extends State<_CourtFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sport;
  late final TextEditingController _location;
  late final TextEditingController _capacity;
  late final TextEditingController _price;
  late final TextEditingController _amenities;
  late final TextEditingController _sortOrder;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final court = widget.court;
    _name = TextEditingController(text: court?.name ?? '');
    _sport = TextEditingController(
      text:
          court?.sport ??
          (widget.venue.sports.isNotEmpty ? widget.venue.sports.first : ''),
    );
    _location = TextEditingController(
      text: court?.location ?? widget.venue.address,
    );
    _capacity = TextEditingController(text: (court?.capacity ?? 4).toString());
    _price = TextEditingController(
      text: (court?.pricePerHour ?? widget.venue.pricePerHour).toString(),
    );
    _amenities = TextEditingController(text: court?.amenities.join(', ') ?? '');
    _sortOrder = TextEditingController(
      text: (court?.sortOrder ?? widget.suggestedSortOrder).toString(),
    );
    _active = court?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _sport.dispose();
    _location.dispose();
    _capacity.dispose();
    _price.dispose();
    _amenities.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.court == null ? 'Thêm sân con' : 'Sửa sân con',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _ReadOnlyInfo(label: 'Mã cụm sân', value: widget.venue.id),
              _TextInput(controller: _name, label: 'Tên sân'),
              _TextInput(controller: _sport, label: 'Môn thể thao'),
              _TextInput(controller: _location, label: 'Vị trí'),
              _TextInput(
                controller: _capacity,
                label: 'Sức chứa',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              _TextInput(
                controller: _price,
                label: 'Giá mỗi giờ',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              _TextInput(
                controller: _amenities,
                label: 'Tiện ích, cách nhau bằng dấu phẩy',
                isRequired: false,
              ),
              _TextInput(
                controller: _sortOrder,
                label: 'Thứ tự hiển thị',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: Text(
                  _active ? 'Trạng thái: hoạt động' : 'Trạng thái: tạm khóa',
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Lưu sân'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final old =
        widget.court ??
        SportCourt(
          id: '',
          venueId: widget.venue.id,
          name: '',
          sport: '',
          location: widget.venue.address,
          capacity: 4,
          images: widget.venue.images,
          pricePerHour: widget.venue.pricePerHour,
          amenities: const [],
          active: true,
          sortOrder: 1,
        );
    Navigator.pop(
      context,
      old.copyWith(
        venueId: widget.venue.id,
        name: _name.text.trim(),
        sport: _sport.text.trim(),
        location: _location.text.trim(),
        capacity: int.parse(_capacity.text.trim()),
        pricePerHour: int.parse(_price.text.trim()),
        amenities: _splitCsv(_amenities.text),
        active: _active,
        sortOrder: int.parse(_sortOrder.text.trim()),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final int? minNumber;
  final bool isRequired;
  final String? Function(String value)? validate;

  const _TextInput({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.minNumber,
    this.isRequired = true,
    this.validate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) {
            return isRequired ? 'Bắt buộc nhập' : null;
          }
          if (keyboardType == TextInputType.number) {
            final parsed = int.tryParse(text);
            if (parsed == null) return 'Vui lòng nhập số hợp lệ';
            if (minNumber != null && parsed < minNumber!) {
              return 'Giá trị phải lớn hơn hoặc bằng $minNumber';
            }
          }
          return validate?.call(text);
        },
      ),
    );
  }
}

class _ReadOnlyInfo extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? 'Sẽ được tạo sau khi lưu' : value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

List<String> _splitCsv(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String? _validateHours(String value) {
  final valid = RegExp(
    r'^(?:[01]\d|2[0-3]):[0-5]\d\s*-\s*(?:[01]\d|2[0-3]):[0-5]\d$',
  ).hasMatch(value);
  return valid ? null : 'Nhập theo định dạng HH:mm - HH:mm';
}

String? _validateUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !uri.hasScheme ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    return 'URL phải bắt đầu bằng http:// hoặc https://';
  }
  return null;
}

class _EmptyVenues extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyVenues({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stadium_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Chưa có cụm sân nào',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Thêm cụm sân'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCourts extends ConsumerWidget {
  final ManagedVenue venue;

  const _EmptyCourts({required this.venue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text('Cụm sân này chưa có sân con.'),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => _runAdminMutation(
              context,
              () => ref
                  .read(bookingFirestoreServiceProvider)
                  .ensureVenueWithDefaultCourts(venue),
              success: 'Đã tạo 4 sân mặc định',
            ),
            child: const Text('Tạo 4 sân mặc định'),
          ),
        ],
      ),
    );
  }
}
