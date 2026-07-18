import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/registration_providers.dart';

class CreateMatchmakingPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<MatchmakingRoom> onCreated;

  const CreateMatchmakingPage({
    super.key,
    required this.onBack,
    required this.onCreated,
  });

  @override
  ConsumerState<CreateMatchmakingPage> createState() =>
      _CreateMatchmakingPageState();
}

class _CreateMatchmakingPageState extends ConsumerState<CreateMatchmakingPage> {
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _playAt = DateTime.now().add(const Duration(days: 1));
  String _level = 'Mọi trình độ';
  int _maxMembers = 4;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDate: _playAt,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_playAt),
    );
    if (time == null) return;
    setState(() {
      _playAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _create() async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return;
    final room = MatchmakingRoom(
      id: '',
      title: _titleController.text,
      sport: 'Cầu lông',
      venueName: _venueController.text,
      playAt: _playAt,
      skillLevel: _level,
      maxMembers: _maxMembers,
      memberCount: 1,
      createdBy: user.id,
      creatorName: user.fullName,
      description: _descriptionController.text.trim(),
      status: 'open',
    );
    final error = await ref
        .read(createMatchmakingProvider.notifier)
        .create(room);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final saved = ref.read(createMatchmakingProvider).valueOrNull;
    if (saved != null) widget.onCreated(saved);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(createMatchmakingProvider).isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Tạo phòng ghép'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Input(controller: _titleController, label: 'Tên phòng'),
          const SizedBox(height: 14),
          _Input(controller: _venueController, label: 'Địa điểm / tên sân'),
          const SizedBox(height: 14),
          ListTile(
            onTap: _chooseDateTime,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            leading: const Icon(Icons.schedule),
            title: const Text('Thời gian chơi'),
            subtitle: Text(
              '${_playAt.hour.toString().padLeft(2, '0')}:${_playAt.minute.toString().padLeft(2, '0')} - ${_playAt.day}/${_playAt.month}/${_playAt.year}',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _level,
            decoration: _decoration('Trình độ'),
            items: const [
              DropdownMenuItem(
                value: 'Mọi trình độ',
                child: Text('Mọi trình độ'),
              ),
              DropdownMenuItem(value: 'Mới chơi', child: Text('Mới chơi')),
              DropdownMenuItem(value: 'Trung bình', child: Text('Trung bình')),
              DropdownMenuItem(value: 'Nâng cao', child: Text('Nâng cao')),
            ],
            onChanged: (value) => setState(() => _level = value ?? _level),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: _maxMembers,
            decoration: _decoration('Số người tối đa'),
            items: [
              for (final value in [2, 4, 6, 8, 10, 12])
                DropdownMenuItem(value: value, child: Text('$value người')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _maxMembers = value);
            },
          ),
          const SizedBox(height: 14),
          _Input(
            controller: _descriptionController,
            label: 'Mô tả / ghi chú',
            maxLines: 4,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: loading ? null : _create,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.group_add_outlined),
            label: const Text('Tạo phòng'),
          ),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _Input({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: _decoration(label),
  );
}

InputDecoration _decoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
);
