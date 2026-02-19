class EasySupportCustomerSession {
  const EasySupportCustomerSession({
    this.customerId,
    this.chatId,
  });

  factory EasySupportCustomerSession.fromJson(Map<String, dynamic> json) {
    return EasySupportCustomerSession(
      customerId:
          json['customer_id'] as String? ?? json['customerId'] as String?,
      chatId: json['chat_id'] as String? ?? json['chatId'] as String?,
    );
  }

  final String? customerId;
  final String? chatId;

  bool get hasCustomerId => customerId != null && customerId!.trim().isNotEmpty;
  bool get hasChatId => chatId != null && chatId!.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (customerId != null) 'customer_id': customerId,
      if (chatId != null) 'chat_id': chatId,
    };
  }
}
