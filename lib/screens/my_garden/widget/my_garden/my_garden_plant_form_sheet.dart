import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
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
    final bool isEditing = widget.initialValue != null && widget.initialValue!.id != null;

    return Container(
      decoration: const BoxDecoration(
        color: neutral,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Sửa hồ sơ cây' : 'Thêm cây mới',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 1. Image Picker Banner
              GestureDetector(
                onTap: _showPickImageOptions,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _plantImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              _plantImage!.startsWith('http')
                                  ? Image.network(_plantImage!, fit: BoxFit.cover)
                                  : Image.file(File(_plantImage!), fit: BoxFit.cover),
                              Container(
                                color: Colors.black.withOpacity(0.3),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt, color: primaryColor, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Thay đổi ảnh',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _plantImage = null;
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white.withOpacity(0.9),
                                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: neutral,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 32,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Thêm hình ảnh cho cây',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Chụp ảnh hoặc chọn từ thư viện',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Category selection (Position)
              _buildCategorySelector(isEditing),
              const SizedBox(height: 20),

              // 3. Plant Name Input
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Tên cây',
                  hintText: 'Ví dụ: Sen đá ban công, Trầu bà...',
                  prefixIcon: const Icon(Icons.eco_rounded, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên cho cây';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. Start Date
              InkWell(
                onTap: _pickStartDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: neutral,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngày bắt đầu trồng',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Status Selector
              _buildStatusSelector(),
              const SizedBox(height: 24),

              // 6. Reminder Settings
              _buildReminderSettingsCard(),
              const SizedBox(height: 28),

              // 7. Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded),
                  label: Text(
                    isEditing ? 'Lưu thay đổi' : 'Thêm vào vườn',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vị trí đặt cây',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: widget.plantOptions
              .where((option) => GardenCategory.categoryToText(option.name) != "Tất cả")
              .map((option) {
                final bool isSelected = _categoryId == option.id;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          GardenCategory.categoryToText(option.name),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? primaryColor : Colors.grey[300]!,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _categoryId = option.id;
                            _category = option.name;
                          });
                        }
                      },
                    ),
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tình trạng sức khỏe',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatusChip(
              status: GardenPlantStatus.healthy,
              label: 'Khỏe mạnh',
              icon: Icons.check_circle_rounded,
              activeColor: Colors.green,
              backgroundColor: Colors.green[50]!,
            ),
            const SizedBox(width: 8),
            _buildStatusChip(
              status: GardenPlantStatus.thirsty,
              label: 'Đang khát',
              icon: Icons.opacity_rounded,
              activeColor: Colors.blue,
              backgroundColor: Colors.blue[50]!,
            ),
            const SizedBox(width: 8),
            _buildStatusChip(
              status: GardenPlantStatus.sick,
              label: 'Đang bệnh',
              icon: Icons.medical_services_rounded,
              activeColor: Colors.orange,
              backgroundColor: Colors.orange[50]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required GardenPlantStatus status,
    required String label,
    required IconData icon,
    required Color activeColor,
    required Color backgroundColor,
  }) {
    final bool isSelected = _status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _status = status;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? backgroundColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey[500],
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: neutral,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tự động nhắc nhở',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Switch(
                value: _pushEnabled,
                activeColor: primaryColor,
                onChanged: (value) {
                  setState(() {
                    _pushEnabled = value;
                  });
                },
              ),
            ],
          ),
          if (_pushEnabled) ...[
            const Divider(height: 24),
            _buildCycleInput(
              controller: _wateringController,
              label: 'Chu kỳ tưới nước',
              icon: Icons.opacity_rounded,
              iconColor: Colors.blue,
              quickDays: [1, 3, 5, 7],
            ),
            const SizedBox(height: 20),
            _buildCycleInput(
              controller: _fertilizingController,
              label: 'Chu kỳ bón phân',
              icon: Icons.grass_rounded,
              iconColor: Colors.brown,
              quickDays: [7, 14, 30, 60],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCycleInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required List<int> quickDays,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: 'ngày',
            hintText: 'Nhập số ngày...',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: neutral,
          ),
          validator: _validateCycle,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickDays.map((days) {
              final String valStr = days.toString();
              final bool isSelected = controller.text == valStr;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('$days ngày'),
                  selected: isSelected,
                  selectedColor: primaryColor.withOpacity(0.15),
                  backgroundColor: Colors.grey[100],
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected ? primaryColor : Colors.black87,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? primaryColor : Colors.transparent,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        controller.text = valStr;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String? _validateCycle(String? value) {
    final int? parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Vui lòng nhập số ngày hợp lệ';
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn ảnh cho cây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
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
