import '../../core/utils/typedef.dart';
import '../entities/document.dart';

abstract class DocumentRepository {
  ResultFuture<List<Document>> getDocuments();
  ResultFuture<Document> getDocument(String id);
  ResultFuture<Document> uploadDocument(String title, String content, String? fileType);
  ResultFuture<Document> updateDocument(Document document);
  ResultVoid deleteDocument(String id);
  ResultFuture<List<Document>> searchDocuments(String query);
}
