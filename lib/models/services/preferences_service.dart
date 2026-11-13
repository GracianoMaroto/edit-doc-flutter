
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static Future<String> obterTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tema') ?? 'Não definido';
  }

  static Future<bool> obterNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificacoes') ?? false;
  }

  static Future<void> salvarTema(String tema) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema', tema);
  }

  static Future<void> salvarNotificacoes(bool ativadas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificacoes', ativadas);
  }
}
