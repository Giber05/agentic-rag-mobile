import '../../core/utils/typedef.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ConversationRepository {
  ResultFuture<List<Conversation>> getConversations();
  ResultFuture<Conversation> getConversation(String id);
  ResultFuture<Conversation> createConversation(String title);
  ResultFuture<Conversation> updateConversation(Conversation conversation);
  ResultVoid deleteConversation(String id);

  ResultFuture<List<Message>> getMessages(String conversationId);
  ResultFuture<Message> sendMessage(String conversationId, String content);
  ResultFuture<Message> getMessage(String messageId);
  ResultVoid deleteMessage(String messageId);
}
