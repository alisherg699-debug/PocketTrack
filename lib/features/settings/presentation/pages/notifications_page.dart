import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool dailyReminder = true;
  bool weeklyReport = true;
  bool budgetAlert = true;
  bool newFeatures = false;
  int alertThreshold = 80; 
  int reminderHour = 20;
  int reminderMinute = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyReminder = prefs.getBool('daily_reminder') ?? true;
      weeklyReport = prefs.getBool('weekly_report') ?? true;
      budgetAlert = prefs.getBool('budget_alert') ?? true;
      newFeatures = prefs.getBool('new_features') ?? false;
      alertThreshold = prefs.getInt('alert_threshold') ?? 80;
      reminderHour = prefs.getInt('reminder_hour') ?? 20;
      reminderMinute = prefs.getInt('reminder_minute') ?? 0;
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
    
    if (dailyReminder) {
      _scheduleDaily();
    } else {
      NotificationService.cancelAllNotifications();
    }
  }

  void _scheduleDaily() {
    NotificationService.scheduleDailyNotification(
      id: 100,
      title: "Xarajatlarni kiritish vaqti keldi!",
      body: "Bugungi barcha sarf-xarajatlaringizni PocketTrack-ga yozib qo'ydingizmi?",
      hour: reminderHour,
      minute: reminderMinute,
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminderHour, minute: reminderMinute),
    );
    if (picked != null) {
      setState(() {
        reminderHour = picked.hour;
        reminderMinute = picked.minute;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', picked.hour);
      await prefs.setInt('reminder_minute', picked.minute);
      if (dailyReminder) _scheduleDaily();
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeLabel = "${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Bildirishnomalar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                "TIZIM BILDIRISHNOMALARI",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildNotificationItem(
                    title: "Kundalik eslatma",
                    description: "Har kuni $timeLabel da xarajatlarni kiritishni eslatish",
                    value: dailyReminder,
                    onTap: _selectTime,
                    onChanged: (val) {
                      setState(() => dailyReminder = val);
                      _updateSetting('daily_reminder', val);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    title: "Haftalik hisobot",
                    description: "O'tgan hafta xarajatlarining qisqacha tahlili",
                    value: weeklyReport,
                    onChanged: (val) {
                      setState(() => weeklyReport = val);
                      _updateSetting('weekly_report', val);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    title: "Byudjet ogohlantirishi",
                    description: "Oy limiti $alertThreshold% dan oshganda xabar berish",
                    value: budgetAlert,
                    onTap: () => _showThresholdDialog(),
                    onChanged: (val) {
                      setState(() => budgetAlert = val);
                      _updateSetting('budget_alert', val);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    title: "Yangi xususiyatlar",
                    description: "Ilovadagi yangilanishlar va takliflar haqida ma'lumot",
                    value: newFeatures,
                    onChanged: (val) {
                      setState(() => newFeatures = val);
                      _updateSetting('new_features', val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Switch.adaptive(
              value: value,
              activeColor: const Color(0xFF0D9488),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _showThresholdDialog() {
    final controller = TextEditingController(text: alertThreshold.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Limit foizini tanlang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Qaysi foizdan oshganda sizga xabar beraylik?", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              decoration: const InputDecoration(
                suffixText: "%",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Bekor qilish")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0 && val <= 100) {
                setState(() => alertThreshold = val);
                _updateSetting('alert_threshold', val);
                Navigator.pop(context);
              }
            },
            child: const Text("Saqlash", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
