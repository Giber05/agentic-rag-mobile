import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:mobile_app/core/network/api_client.dart';


@module
abstract class NetworkModule {

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  Logger get logger => Logger();

  @lazySingleton
  DioApiClient getDioApiClient() => DioApiClient();

}