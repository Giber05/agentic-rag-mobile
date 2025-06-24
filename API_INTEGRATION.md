# API Integration Layer Documentation

## Overview

The API Integration Layer connects the Flutter frontend with the FastAPI backend, providing a robust communication layer for the RAG (Retrieval-Augmented Generation) pipeline. This layer handles HTTP requests, WebSocket connections, error handling, caching, and real-time updates.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  Repository     │    │   API Client    │
│   (BLoC/Cubit)  │◄──►│  Implementation │◄──►│   (Dio HTTP)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Domain        │    │   Network       │
                       │   Entities      │    │   Layer         │
                       └─────────────────┘    └─────────────────┘
```

## Core Components

### 1. API Client (`lib/core/network/api_client.dart`)

**Purpose**: Central HTTP client using Dio for all API communications.

**Features**:

- Singleton pattern for consistent configuration
- Automatic request/response logging
- Error handling and retry logic
- Authentication token management
- Request/response interceptors
- Timeout configuration

**Configuration**:

```dart
BaseOptions(
  baseUrl: 'http://localhost:8000',  // From .env
  connectTimeout: 30 seconds,
  receiveTimeout: 30 seconds,
  sendTimeout: 30 seconds,
)
```

**Key Methods**:

- `get<T>()` - GET requests with type safety
- `post<T>()` - POST requests with automatic serialization
- `put<T>()` - PUT requests for updates
- `delete<T>()` - DELETE requests
- `stream()` - WebSocket/SSE streaming

### 2. Network Exceptions (`lib/core/network/network_exceptions.dart`)

**Purpose**: Structured error handling for different network scenarios.

**Exception Types**:

- `CONNECTION_TIMEOUT` - Network connectivity issues
- `SEND_TIMEOUT` - Request sending timeout
- `RECEIVE_TIMEOUT` - Response receiving timeout
- `BAD_REQUEST` - 400 status codes
- `UNAUTHORIZED` - 401 authentication errors
- `FORBIDDEN` - 403 permission errors
- `NOT_FOUND` - 404 resource not found
- `SERVER_ERROR` - 500+ server errors
- `NETWORK_ERROR` - General connectivity issues
- `UNKNOWN_ERROR` - Unexpected errors

### 3. API Interceptors (`lib/core/network/api_interceptors.dart`)

**Logging Interceptor**:

- Logs all requests with emoji indicators
- Tracks request/response timing
- Formats JSON data for readability
- Configurable log levels

**Authentication Interceptor**:

- Automatically adds Bearer tokens
- Handles token refresh logic
- Manages authentication state

**Error Interceptor**:

- Converts Dio exceptions to NetworkExceptions
- Provides user-friendly error messages
- Handles retry logic for transient errors

### 4. Result Type (`lib/core/utils/result.dart`)

**Purpose**: Type-safe error handling without exceptions.

**Usage**:

```dart
// Success case
final result = Result.success("Hello World");

// Failure case
final result = Result.failure(NetworkExceptions(...));

// Pattern matching
final message = result.fold(
  (data) => "Success: $data",
  (error) => "Error: ${error.message}",
);

// Extension methods
if (result.isSuccess) {
  print(result.data);
}
```

### 5. API Models (`lib/data/models/api_models.dart`)

**Base API Response**:

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
}
```

**RAG Request Model**:

```dart
class RagRequest {
  final String query;
  final String? conversationId;
  final Map<String, dynamic>? context;
}
```

**RAG Response Model**:

```dart
class RagResponse {
  final String answer;
  final List<String> sources;
  final Map<String, dynamic> agentData;
  final double confidence;
}
```

## Repository Implementation

### RAG Repository (`lib/data/repositories/rag_repository_impl.dart`)

**Core Operations**:

1. **Query Processing**:

   ```dart
   Future<Result<String>> processQuery({
     required String query,
     String? conversationId,
     Map<String, dynamic>? context,
   })
   ```

2. **Streaming Updates**:

   ```dart
   Stream<Map<String, dynamic>> processQueryStream({
     required String query,
     String? conversationId,
     Map<String, dynamic>? context,
   })
   ```

3. **Conversation Management**:

   ```dart
   Future<Result<List<Conversation>>> getConversations()
   Future<Result<Conversation>> createConversation({String? title})
   Future<Result<List<Message>>> getMessages(String conversationId)
   ```

4. **Document Operations**:
   ```dart
   Future<Result<List<Document>>> getDocuments()
   Future<Result<Document>> uploadDocument(File file)
   ```

## API Endpoints

### Health Check

- `GET /health` - Basic health check
- `GET /api/v1/status` - Detailed status with dependencies

### RAG Pipeline

- `POST /api/v1/rag/query` - Process single query
- `GET /api/v1/rag/stream` - WebSocket streaming endpoint

### Conversations

- `GET /api/v1/conversations` - List conversations
- `POST /api/v1/conversations` - Create conversation
- `GET /api/v1/conversations/{id}` - Get conversation details
- `GET /api/v1/conversations/{id}/messages` - Get messages

### Documents

- `GET /api/v1/documents` - List documents
- `POST /api/v1/documents/upload` - Upload document
- `DELETE /api/v1/documents/{id}` - Delete document

## State Management Integration

### App State Cubit Updates

**Initialization**:

```dart
Future<void> initializeApp() async {
  // Check API health
  final healthResult = await _ragRepository.getHealth();

  // Load conversations
  final conversationsResult = await _ragRepository.getConversations();

  // Update UI state
  emit(state.copyWith(conversations: conversations));
}
```

**Query Processing**:

```dart
Future<void> processQuery(String query) async {
  // Add user message locally
  final userMessage = Message(...);
  emit(state.copyWith(messages: [...state.messages, userMessage]));

  // Process via API with streaming
  final stream = _ragRepository.processQueryStream(query: query);
  await for (final update in stream) {
    // Update agent progress
    if (update.containsKey('agent')) {
      emit(state.copyWith(currentAgent: agent, progress: progress));
    }

    // Handle final answer
    if (update.containsKey('answer')) {
      final assistantMessage = Message(...);
      emit(state.copyWith(messages: [...messages, assistantMessage]));
    }
  }
}
```

## Error Handling Strategy

### 1. Network Layer

- Automatic retry for transient errors
- Exponential backoff for rate limiting
- Circuit breaker for repeated failures

### 2. Repository Layer

- Graceful degradation to offline mode
- Fallback to cached data when available
- User-friendly error messages

### 3. UI Layer

- Loading states during API calls
- Error snackbars for user feedback
- Retry buttons for failed operations

## Configuration

### Environment Variables (`.env`)

```env
API_BASE_URL=http://localhost:8000
API_TIMEOUT=30000
ENABLE_LOGGING=true
CACHE_DURATION=300
```

### Dependency Injection

```dart
// Core networking
getIt.registerLazySingleton<ApiClient>(() => ApiClient.instance);

// Repositories
getIt.registerLazySingleton<RagRepository>(() => RagRepositoryImpl(getIt()));

// State management
getIt.registerLazySingleton(() => AppStateCubit(getIt()));
```

## Testing Strategy

### Unit Tests

- Repository method testing with mock API client
- Error handling scenarios
- Data serialization/deserialization

### Integration Tests

- End-to-end API communication
- WebSocket streaming functionality
- Authentication flows

### Widget Tests

- UI state updates during API calls
- Error state handling
- Loading state management

## Performance Optimizations

### 1. Caching

- Response caching for frequently accessed data
- Offline data persistence
- Smart cache invalidation

### 2. Request Optimization

- Request deduplication
- Batch operations where possible
- Compression for large payloads

### 3. Streaming

- Real-time updates via WebSocket
- Progressive loading for large datasets
- Efficient memory management

## Security Considerations

### 1. Authentication

- JWT token management
- Automatic token refresh
- Secure token storage

### 2. Data Protection

- HTTPS enforcement
- Request/response encryption
- Sensitive data masking in logs

### 3. Input Validation

- Client-side validation
- Sanitization of user inputs
- Protection against injection attacks

## Monitoring and Debugging

### 1. Logging

- Structured logging with context
- Request/response tracing
- Performance metrics

### 2. Error Tracking

- Automatic error reporting
- User session tracking
- API performance monitoring

### 3. Development Tools

- Network inspector integration
- Debug mode enhancements
- Mock data for testing

## Future Enhancements

### 1. Offline Support

- Local database synchronization
- Conflict resolution strategies
- Background sync capabilities

### 2. Advanced Features

- Request queuing for poor connectivity
- Adaptive timeout based on network conditions
- Smart retry policies

### 3. Performance

- GraphQL integration for efficient queries
- Response compression
- CDN integration for static assets

## Troubleshooting

### Common Issues

1. **Connection Timeout**

   - Check network connectivity
   - Verify API server status
   - Increase timeout values if needed

2. **Authentication Errors**

   - Verify API keys in `.env`
   - Check token expiration
   - Ensure proper header formatting

3. **Serialization Errors**

   - Validate JSON structure
   - Check entity `fromJson` methods
   - Verify API response format

4. **WebSocket Issues**
   - Check WebSocket endpoint availability
   - Verify connection upgrade headers
   - Monitor connection lifecycle

### Debug Commands

```bash
# Check API connectivity
curl http://localhost:8000/health

# Test authentication
curl -H "Authorization: Bearer <token>" http://localhost:8000/api/v1/status

# Monitor network traffic
flutter run --verbose

# Enable debug logging
flutter run --dart-define=ENABLE_DEBUG_LOGGING=true
```

---

This API integration layer provides a robust foundation for the RAG application, with comprehensive error handling, real-time capabilities, and excellent developer experience.
