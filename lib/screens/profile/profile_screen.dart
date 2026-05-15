import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/data/services/firebase_messaging_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fcmToken;
  String? _userId;
  String? _userEmail;
  bool _isLoadingToken = true;
  bool _isSendingTest = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');
    final token = await FirebaseMessagingService.getToken();
    if (userId != null && token != null) {
      await FirebaseMessagingService.registerToken(userId);
    }

    setState(() {
      _userId = userId;
      _userEmail = userEmail;
      _fcmToken = token;
      _isLoadingToken = false;
    });
  }

  Future<void> _sendTestNotification() async {
    if (_userId == null) return;

    setState(() => _isSendingTest = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/user/send-test-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _userId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Thông báo thử nghiệm đã gửi!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Gửi thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Lỗi: $e')));
    } finally {
      setState(() => _isSendingTest = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    // Remove FCM token from server
    if (userId != null) {
      await FirebaseMessagingService.removeFcmTokenFromServer(userId);
    }

    // Clear local data
    await prefs.remove('userId');
    await prefs.remove('userEmail');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, loginViewRoute);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin tài khoản',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(label: 'Email', value: _userEmail ?? 'Chưa có'),
          const SizedBox(height: 12),
          _buildInfoCard(
            label: 'User ID',
            value: _userId ?? 'Chưa có',
            copyable: true,
          ),
          const SizedBox(height: 20),
          const Text(
            'Thông báo (Firebase)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _isLoadingToken
              ? const CircularProgressIndicator()
              : _buildInfoCard(
                  label: 'FCM Token',
                  value: _fcmToken != null
                      ? '${_fcmToken!.substring(0, 20)}...'
                      : 'Chưa có token',
                  copyable: true,
                ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSendingTest ? null : _sendTestNotification,
            icon: const Icon(Icons.send),
            label: _isSendingTest
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gửi thông báo thử'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (copyable)
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('✅ Đã copy')));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
