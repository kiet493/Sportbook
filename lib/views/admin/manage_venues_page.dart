import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/back_chevron_button.dart';
import '../../models/court_booking.dart';
import '../../providers/booking_providers.dart';
import '../../providers/registration_providers.dart';

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
          'Quan ly san',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Them cum san',
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
        error: (error, _) =>
            Center(child: Text('Khong tai duoc danh sach san: $error')),
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
                  'Danh sach san con',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCourtSheet(context, ref, venue),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Them san'),
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
            error: (error, _) => Text('Khong tai duoc san con: $error'),
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
    ManagedVenue venue, [
    SportCourt? court,
  ]) async {
    final result = await showModalBottomSheet<SportCourt>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CourtFormSheet(venue: venue, court: court),
    );
    if (result == null || !context.mounted) return;
    await _runAdminMutation(
      context,
      () => ref.read(bookingFirestoreServiceProvider).upsertCourt(result),
      success: court == null ? 'Đã tạo sân' : 'Đã cập nhật sân',
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
                label: '${formatVnd(venue.pricePerHour)}d/h',
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
                label: const Text('Sua'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDeleteVenue(context, ref, venue),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Xoa'),
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
        title: const Text('Xoa cum san?'),
        content: Text('Ban co chac muon xoa "${venue.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoa'),
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
                  '${court.sport} • ${formatVnd(court.pricePerHour)}d/h • suc chua ${court.capacity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: court.active ? 'Khoa san' : 'Mo san',
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
            tooltip: 'Sua san',
            onPressed: () => _showCourtSheet(context, ref, venue, court),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xoa san',
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
      builder: (_) => _CourtFormSheet(venue: venue, court: court),
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
        content: Text('Bạn có chắc muốn xóa "${court.name}"?'),
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
    messenger.showSnackBar(
      SnackBar(content: Text('Không thể lưu dữ liệu Firebase: $error')),
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
  late final TextEditingController _images;
  late final TextEditingController _description;
  late final TextEditingController _coordinates;
  late final TextEditingController _ownerId;
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
    _image = TextEditingController(text: venue.image);
    _images = TextEditingController(text: venue.images.join(', '));
    _description = TextEditingController(text: venue.description);
    _coordinates = TextEditingController(text: venue.coordinates);
    _ownerId = TextEditingController(
      text: venue.ownerId.isNotEmpty ? venue.ownerId : widget.currentOwnerId,
    );
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
    _images.dispose();
    _description.dispose();
    _coordinates.dispose();
    _ownerId.dispose();
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
                widget.venue == null ? 'Them cum san' : 'Sua cum san',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _TextInput(controller: _name, label: 'Ten cum san'),
              _TextInput(controller: _ownerId, label: 'Owner ID'),
              _TextInput(
                controller: _sports,
                label: 'Mon the thao, cach nhau bang dau phay',
              ),
              _TextInput(controller: _address, label: 'Location'),
              _TextInput(controller: _coordinates, label: 'Coordinates'),
              _TextInput(controller: _hours, label: 'Gio mo cua'),
              _TextInput(
                controller: _price,
                label: 'Gia tham chieu moi gio',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              _TextInput(controller: _image, label: 'Anh dai dien URL'),
              _TextInput(
                controller: _images,
                label: 'Images URLs, cach nhau bang dau phay',
              ),
              _TextInput(
                controller: _description,
                label: 'Description',
                maxLines: 3,
              ),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: const Text('Dang hoat dong'),
              ),
              FilledButton(onPressed: _submit, child: const Text('Luu')),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.venue ?? ManagedVenue.empty();
    final imageList = _splitCsv(_images.text);
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
        images: imageList.contains(image) ? imageList : [image, ...imageList],
        description: _description.text.trim(),
        coordinates: _coordinates.text.trim(),
        ownerId: _ownerId.text.trim(),
      ),
    );
  }
}

class _CourtFormSheet extends StatefulWidget {
  final ManagedVenue venue;
  final SportCourt? court;

  const _CourtFormSheet({required this.venue, this.court});

  @override
  State<_CourtFormSheet> createState() => _CourtFormSheetState();
}

class _CourtFormSheetState extends State<_CourtFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sport;
  late final TextEditingController _location;
  late final TextEditingController _capacity;
  late final TextEditingController _images;
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
    _capacity = TextEditingController(text: (court?.capacity ?? 10).toString());
    _images = TextEditingController(
      text:
          (court?.images.isNotEmpty == true
                  ? court!.images
                  : widget.venue.images)
              .join(', '),
    );
    _price = TextEditingController(
      text: (court?.pricePerHour ?? widget.venue.pricePerHour).toString(),
    );
    _amenities = TextEditingController(text: court?.amenities.join(', ') ?? '');
    _sortOrder = TextEditingController(
      text: (court?.sortOrder ?? 1).toString(),
    );
    _active = court?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _sport.dispose();
    _location.dispose();
    _capacity.dispose();
    _images.dispose();
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
                widget.court == null ? 'Them san con' : 'Sua san con',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _ReadOnlyInfo(label: 'Complex ID', value: widget.venue.id),
              _TextInput(controller: _name, label: 'Name'),
              _TextInput(controller: _sport, label: 'Type'),
              _TextInput(controller: _location, label: 'Location'),
              _TextInput(
                controller: _capacity,
                label: 'Capacity',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              _TextInput(
                controller: _price,
                label: 'Price per hour',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              _TextInput(
                controller: _images,
                label: 'Images URLs, cach nhau bang dau phay',
              ),
              _TextInput(
                controller: _amenities,
                label: 'Amenities, cach nhau bang dau phay',
              ),
              _TextInput(
                controller: _sortOrder,
                label: 'Thu tu hien thi',
                keyboardType: TextInputType.number,
                minNumber: 1,
              ),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: Text(_active ? 'Status: active' : 'Status: inactive'),
              ),
              FilledButton(onPressed: _submit, child: const Text('Luu')),
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
          capacity: 10,
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
        images: _splitCsv(_images.text),
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

  const _TextInput({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.minNumber,
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
          if (text.isEmpty) return 'Bat buoc nhap';
          if (keyboardType == TextInputType.number) {
            final parsed = int.tryParse(text);
            if (parsed == null) return 'Vui long nhap so hop le';
            if (minNumber != null && parsed < minNumber!) {
              return 'Gia tri phai lon hon hoac bang $minNumber';
            }
          }
          return null;
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
            value.isEmpty ? 'Se duoc tao sau khi luu' : value,
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
              'Chua co cum san nao',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Them cum san'),
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
          const Text('Cum san nay chua co san con.'),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => ref
                .read(bookingFirestoreServiceProvider)
                .ensureVenueWithDefaultCourts(venue),
            child: const Text('Tao 4 san mac dinh'),
          ),
        ],
      ),
    );
  }
}
