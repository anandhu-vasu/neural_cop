import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:neural_cop/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiController {
  final SharedPreferences prefs;
  final String baseUrl;

  ApiController._init(this.prefs, this.baseUrl);

  static Future<ApiController> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hostname = prefs.getString("hostname");

    hostname ??= await promptHostname();

    final baseUrl = "$hostname/api";

    return ApiController._init(prefs, baseUrl);
  }

  Future<bool> login(String username, String password) async {
    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        var endpoint = "/login";

        var response = await http.post(Uri.parse(baseUrl + endpoint),
            body: {'username': username, 'password': password});
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['status'] == 1) {
            prefs.setBool('login', true);
            prefs.setInt('uid', data['id']);
            prefs.setString('role', data['role']);
            return true;
          }
        }
      } catch (e) {}
    }
    return false;
  }

  Future<Map<String, dynamic>?> userProfile(int uid) async {
    try {
      var endpoint = "/security_profile/{$uid}";
      var response = await http.get(Uri.parse(baseUrl + endpoint));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(response.body));
        return data;
      }
    } catch (e) {}
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchThreats() async {
    try {
      var endpoint =
          prefs.getString('role') == 'user' ? '/security_home' : '/police_home';
      var response = await http.get(Uri.parse(baseUrl + endpoint));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        int threatCount = prefs.getInt('threat_count') ?? 0;
        if (data.length > threatCount) {
          if (threatCount != 0) {
            int diff = data.length - threatCount;
            AwesomeNotifications().createNotification(
                content: NotificationContent(
                    id: data.length,
                    channelKey: 'threats',
                    title: 'Threat Alert',
                    body: '$diff threats detected!',
                    actionType: ActionType.Default));
          }
        }
        prefs.setInt('threat_count', data.length);

        return data;
      }
    } catch (e) {}
    return [];
  }

  Future<void> removeThreat(int id) async {
    try {
      var endpoint = "/false_positive/{$id}";
      var response = await http.get(Uri.parse(baseUrl + endpoint));

      if (response.statusCode == 200) {
        showSnackBar("Threat removed.");
      }
    } catch (e) {}
  }

  Future<void> forwardThreat(int id) async {
    try {
      var endpoint = "/forward/{$id}";
      var response = await http.get(Uri.parse(baseUrl + endpoint));

      if (response.statusCode == 200) {
        showSnackBar("Threat forwarded to Police.");
      }
    } catch (e) {}
  }
}
