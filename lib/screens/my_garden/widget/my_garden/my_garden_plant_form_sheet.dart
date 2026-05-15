import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/models/reminder.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:provider/provider.dart';

class MyGardenPlantFormSheet extends StatefulWidget {
  const MyGardenPlantFormSheet({
    super.key,
    required this.initialValue,
    required this.plantOptions,
  });

  final GardenPlantProfile? initialValue;
  final List<GardenCategory> plantOptions;

  @override
  State<MyGardenPlantFormSheet> createState() => _MyGardenPlantFormSheetState();
}

class _MyGardenPlantFormSheetState extends State<MyGardenPlantFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _nicknameController;
  late final TextEditingController _wateringController;
  late final TextEditingController _fertilizingController;

  late DateTime _startDate;
  late String? _gardenPlantId;
  late String _plantId;
  late String _plantName;
  late String? _plantImage;
  late String _categoryId;
  late GardenPlantStatus _status;
  late Category _category;
  bool _pushEnabled = true;

  @override
  void initState() {
    super.initState();
    final GardenPlantProfile? initial = widget.initialValue;
    if (initial != null) {
      _gardenPlantId = initial.id;
      _plantId = initial.plantId;
      _plantName = initial.name;
      _plantImage = initial.imageUrl;
      _categoryId = initial.category.id;
      _category = initial.category.name;
      _status = initial.status;
      _startDate = initial.startDate;
      _pushEnabled = initial.reminderSetting.pushNotificationEnabled;
      _nicknameController = TextEditingController(text: _plantName);
      _wateringController = TextEditingController(
        text: initial.reminderSetting.wateringCycleDays.toString(),
      );
      _fertilizingController = TextEditingController(
        text: initial.reminderSetting.fertilizingCycleDays.toString(),
      );
      return;
    }

    final GardenCategory? firstOption = widget.plantOptions.isNotEmpty
        ? widget.plantOptions.first
        : null;
    _plantId = '';
    _gardenPlantId = null;
    _plantName = '';
    _plantImage = null;
    _categoryId = firstOption?.id ?? '';
    _category = firstOption?.name ?? Category.indoor;
    _status = GardenPlantStatus.healthy;
    _startDate = DateTime.now();
    _nicknameController = TextEditingController(text: _plantName);
    _wateringController = TextEditingController(text: '');
    _fertilizingController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _wateringController.dispose();
    _fertilizingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isEditing = widget.initialValue != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Sửa hồ sơ cây' : 'Thêm cây mới',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildPlantSelector(isEditing),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Tên cây',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nhập tên cho cây';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text('Ngày bắt đầu trồng'),
                subtitle: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showPickImageOptions,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh'),
              ),
              if (_plantImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _plantImage!.startsWith('http')
                      ? Image.network(
                          // Nếu là link online
                          _plantImage!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          // Nếu là file trong máy
                          File(_plantImage!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Trạng thái hiện tại',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<GardenPlantStatus>(
                value: _status,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: GardenPlantStatus.thirsty,
                    child: Text('Đang khát'),
                  ),
                  DropdownMenuItem(
                    value: GardenPlantStatus.healthy,
                    child: Text('Khỏe mạnh'),
                  ),
                  DropdownMenuItem(
                    value: GardenPlantStatus.sick,
                    child: Text('Đang bênh'),
                  ),
                ],
                onChanged: (status) {
                  if (status == null) {
                    return;
                  }
                  setState(() {
                    _status = status;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Cài đặt nhắc nhở',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wateringController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chu kỳ tưới nước (ngày/lần)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateCycle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fertilizingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chù kỳ bón phân (ngày/lần)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateCycle,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _pushEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('Bật cảnh báo'),
                onChanged: (value) {
                  setState(() {
                    _pushEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitForm,
                  child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm vào vườn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantSelector(bool isEditing) {
    return DropdownButtonFormField<String>(
      initialValue: _categoryId,
      value: _categoryId,
      decoration: const InputDecoration(
        labelText: 'Loai cay',
        border: OutlineInputBorder(),
      ),
      items: widget.plantOptions
          .where(
            (option) => GardenCategory.categoryToText(option.name) != "Tất cả",
          )
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.id,
              child: Text(GardenCategory.categoryToText(option.name)),
            ),
          )
          .toList(growable: false),
      onChanged: (id) {
        if (id == null) {
          return;
        }
        final GardenCategory selected = widget.plantOptions.firstWhere(
          (option) => option.id == id,
        );
        setState(() {
          _categoryId = selected.id;
          _category = selected.name;
        });
      },
    );
  }

  String? _validateCycle(String? value) {
    final int? parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Nhap so ngay hop le';
    }
    return null;
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      initialDate: _startDate,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _startDate = picked;
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (photo == null) return;

      setState(() {
        _plantImage = photo.path;
      });
    } catch (e) {
      debugPrint("Lỗi chụp ảnh: $e");
    }
  }

  void _showPickImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Chụp ảnh mới'),
            onTap: () {
              Navigator.pop(context);
              _pickPhoto(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn từ thư viện'),
            onTap: () {
              Navigator.pop(context);
              _pickPhoto(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  GardenPlantProfile _buildPlantProfile() {
    return GardenPlantProfile(
      id: _gardenPlantId,
      plantId: _plantId,
      name: _nicknameController.text.trim(),
      latinName: '',
      imageUrl: _plantImage ?? '',
      status: _status,
      category: GardenCategory(id: _categoryId, name: _category),
      startDate: _startDate,
      reminderSetting: GardenReminder(
        wateringCycleDays: int.tryParse(_wateringController.text.trim()) ?? 0,
        fertilizingCycleDays:
            int.tryParse(_fertilizingController.text.trim()) ?? 0,
        pushNotificationEnabled: _pushEnabled,
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final GardenPlantProfile profile = _buildPlantProfile();
    final MyGardenController controller = Provider.of<MyGardenController>(
      context,
      listen: false,
    );

    try {
      final GardenPlantProfile? createdProfile = await controller
          .upsertPlantProfile(profile);

      if (createdProfile == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Lỗi khi thêm cây')));
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(createdProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
