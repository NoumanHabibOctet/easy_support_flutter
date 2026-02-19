class EasySupportChatEmitPayload {
  const EasySupportChatEmitPayload({
    required this.body,
    required this.chatId,
    required this.customerId,
    this.author = '',
    this.unseenCount = 1,
  });

  factory EasySupportChatEmitPayload.fromJson(Map<String, dynamic> json) {
    return EasySupportChatEmitPayload(
      author: json['author'] as String? ?? '',
      body: json['body'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      unseenCount: json['unseen_count'] as int? ?? 1,
    );
  }

  final String author;
  final String body;
  final String chatId;
  final String customerId;
  final int unseenCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'author': author,
      'body': body,
      'chat_id': chatId,
      'customer_id': customerId,
      'unseen_count': unseenCount,
    };
  }
}
