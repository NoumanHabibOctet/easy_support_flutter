import 'package:shared_preferences/shared_preferences.dart';

import 'models/easy_support_customer_session.dart';

abstract class EasySupportCustomerLocalStorage {
  Future<EasySupportCustomerSession> readSession();

  Future<void> writeSession(EasySupportCustomerSession session);
}

class EasySupportSharedPrefsCustomerLocalStorage
    implements EasySupportCustomerLocalStorage {
  static const String _customerIdKey = 'easy_support_customer_id';
  static const String _chatIdKey = 'easy_support_chat_id';

  @override
  Future<EasySupportCustomerSession> readSession() async {
    final preferences = await SharedPreferences.getInstance();
    final customerId = _normalize(preferences.getString(_customerIdKey));
    final chatId = _normalize(preferences.getString(_chatIdKey));
    return EasySupportCustomerSession(
      customerId: customerId,
      chatId: chatId,
    );
  }

  @override
  Future<void> writeSession(EasySupportCustomerSession session) async {
    final preferences = await SharedPreferences.getInstance();

    if (session.hasCustomerId) {
      await preferences.setString(_customerIdKey, session.customerId!.trim());
    } else {
      await preferences.remove(_customerIdKey);
    }

    if (session.hasChatId) {
      await preferences.setString(_chatIdKey, session.chatId!.trim());
    } else {
      await preferences.remove(_chatIdKey);
    }
  }

  static String? _normalize(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
