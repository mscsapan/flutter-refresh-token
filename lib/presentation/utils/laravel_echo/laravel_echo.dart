// import 'package:laravel_echo/laravel_echo.dart';
// import 'package:pusher_client/pusher_client.dart';
//
// import '../../data/data_provider/remote_urls.dart';
//
// class LaravelEcho {
//   static LaravelEcho? _singleton;
//   static late Echo _echo;
//   final String token;
//
//   LaravelEcho._({
//     required this.token,
//   }) {
//     _echo = createLaravelEcho(token);
//   }
//
//   factory LaravelEcho.init({
//     required String token,
//   }) {
//     //debugPrint('auth-tokennnn $token');
//     if (_singleton == null || token != _singleton?.token) {
//       _singleton = LaravelEcho._(token: token);
//     }
//
//     return _singleton!;
//   }
//
//   static Echo get instance => _echo;
//
//   static String get socketId => _echo.socketId() ?? "11111.11111111";
// }
//
// class PusherConfig {
//   static const appId = "1832155";
//   static const key = "6c34a623a0eeab8c1b40";
//   static const secret = "d1b7f71791133903fdfb";
//   static const cluster = "mt1";
//   static const hostEndPoint = RemoteUrls.baseUrl;
//   static const hostAuthEndPoint = "${hostEndPoint}broadcasting/auth";
//   static const port = 443;
// }
//
// PusherClient createPusherClient(String token) {
//   PusherOptions options = PusherOptions(
//     wsPort: PusherConfig.port,
//     encrypted: true,
//     host: PusherConfig.hostEndPoint,
//     cluster: PusherConfig.cluster,
//     auth: PusherAuth(
//       PusherConfig.hostAuthEndPoint,
//       headers: {
//         'Authorization': "Bearer $token",
//         'Content-Type': "application/json",
//         'Accept': 'application/json'
//       },
//     ),
//   );
//
//   PusherClient pusherClient = PusherClient(
//     PusherConfig.key,
//     options,
//     autoConnect: false,
//     enableLogging: true,
//   );
//
//   pusherClient.onConnectionStateChange((state) {
//     print(
//         "previousState: ${state!.previousState}, currentState: ${state.currentState}");
//   });
//
//   pusherClient.onConnectionError((error) {
//     print("error: ${error!.message}");
//   });
//
//   return pusherClient;
// }
//
// Echo createLaravelEcho(String token) {
//   return Echo(
//     client: createPusherClient(token),
//     broadcaster: EchoBroadcasterType.Pusher,
//   );
// }
