import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';

/// Handles local device notifications for low-stock inventory items.
///
/// Notification logic mirrors the backend [needs_restock] calculation:
///   - Out of stock  : quantity == 0
///   - Segera habis  : days_until_empty (qty / PHRR) <= lead_time_days
class InventoryNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId      = 'inventory_low_stock';
  static const _channelName    = 'Stok Hampir Habis';
  static const _notifId        = 1001;
  static const _financeNotifId = 1002;

  // ── Initialise once ────────────────────────────────────────────────────────

  static Future<void> _init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Explicitly request iOS permission so the system dialog appears
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: false);

    _initialized = true;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches low-stock items for [pantiId], fires a local notification if any
  /// exist, and returns the full list so callers can update badge counts.
  ///
  /// Each item shown in the notification body includes:
  ///   • For "segera habis": days until empty and lead-time context.
  ///   • For "habis"       : explicit "Stok habis!" label.
  static Future<List<LowStockItemModel>> checkAndNotify(int pantiId) async {
    await _init();

    final items = await InventoryApi().fetchLowStockItems(pantiId);

    if (items.isEmpty) {
      await _plugin.cancel(_notifId);
      return items;
    }

    final outOfStock  = items.where((i) => i.isOutOfStock).toList();
    final almostEmpty = items.where((i) => !i.isOutOfStock).toList();

    final bodyLines = <String>[];

    for (final item in outOfStock.take(3)) {
      bodyLines.add('• ${item.name}: Stok habis!');
    }

    for (final item in almostEmpty.take(3)) {
      final d  = item.daysUntilEmpty;
      final lt = item.leadTimeDays;
      if (d != null) {
        // e.g. "• Beras: ~2.5 hari tersisa, perlu tunggu 3 hari"
        bodyLines.add(
          '• ${item.name}: ~${d.toStringAsFixed(1)} hari tersisa'
          ', perlu tunggu $lt hari',
        );
      } else {
        bodyLines.add('• ${item.name}: Segera habis');
      }
    }

    if (items.length > 6) {
      bodyLines.add('...dan ${items.length - 6} produk lainnya');
    }

    final title = items.length == 1
        ? '⚠️ 1 produk perlu restock'
        : '⚠️ ${items.length} produk perlu restock';
    final body = bodyLines.join('\n');

    await _plugin.show(
      _notifId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Notifikasi produk inventaris yang perlu direstok',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );

    return items;
  }

  /// Sends a warning notification when [saldo] is zero or negative.
  /// Cancels any existing finance notification when saldo is positive.
  static Future<void> checkFinanceAndNotify(double saldo) async {
    await _init();

    if (saldo > 0) {
      await _plugin.cancel(_financeNotifId);
      return;
    }

    final title = saldo == 0 ? '⚠️ Saldo keuangan habis' : '⚠️ Saldo keuangan minus';
    final body  = saldo == 0
        ? 'Saldo panti saat ini Rp 0. Segera tambahkan pemasukan.'
        : 'Saldo panti saat ini minus (Rp ${saldo.toInt()}). Pengeluaran melebihi pemasukan.';

    await _plugin.show(
      _financeNotifId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'finance_warning',
          'Peringatan Keuangan',
          channelDescription: 'Notifikasi peringatan saldo keuangan panti',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }
}
