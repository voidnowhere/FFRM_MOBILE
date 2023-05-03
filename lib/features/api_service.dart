import 'package:dio/dio.dart';
import 'package:ffrm/features/login/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' as get_x;
import 'custom_snackbar.dart';

class ApiService {
  static Dio? _instance;

  static void _logout(SharedPreferences prefs) {
    prefs.remove('accessToken');
    prefs.remove('refreshToken');
    CustomSnackbar.get('Your session is expired!', 17);
    get_x.Get.offAll(() => const LoginScreen());
  }

  static Dio getInstance() {
    if (_instance == null) {
      _instance = Dio();

      String baseUrl = dotenv.env['BASE_URL']!;
      _instance!.options.baseUrl = baseUrl;
      _instance!.options.connectTimeout = const Duration(seconds: 10);
      _instance!.options.headers['Content-Type'] = 'application/json';
      _instance!.options.headers['Accept'] = 'application/json';

      _instance!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) async {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            final String? accessToken = prefs.getString('accessToken');

            if (accessToken != null) {
              if (JwtDecoder.isExpired(accessToken)) {
                final String refreshToken = prefs.getString('refreshToken')!;
                if (JwtDecoder.isExpired(refreshToken)) {
                  _logout(prefs);
                } else {
                  try {
                    final response = await Dio().post(
                      '${baseUrl}api/token/refresh/',
                      data: {'refresh': refreshToken},
                    );
                    prefs.setString('accessToken', response.data['access']);
                    prefs.setString('refreshToken', response.data['refresh']);
                  } on DioError {
                    _logout(prefs);
                  }
                }
              }
              options.headers['Authorization'] =
                  'Bearer ${prefs.getString('accessToken')}';
            }

            return handler.next(options);
          },
          onResponse: (
            Response response,
            ResponseInterceptorHandler handler,
          ) {
            return handler.next(response);
          },
          onError: (
            DioError e,
            ErrorInterceptorHandler handler,
          ) {
            return handler.next(e);
          },
        ),
      );
    }
    return _instance ?? Dio();
  }
}
