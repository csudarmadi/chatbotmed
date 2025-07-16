import 'history_service.dart';
import 'reminder_service.dart';
import 'obat_service.dart';

class TestHelper {
  static Future<void> fullReset() async {
    await HistoryService.clearHistory();
    await ReminderService.cancelAllReminders();
    await ObatService.clearAll();
  }
}
