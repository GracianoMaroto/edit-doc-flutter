
import 'package:material_ui/material_ui.dart';
import '../models/usuario.dart';
import '../models/services/preferences_service.dart';
import '../models/services/banco_local_service.dart';

class AuthViewModel extends ChangeNotifier {
  final BancoLocalService _banco;

  AuthViewModel(this._banco);

  String tema = 'Não definido';
  bool notificacoes = false;

  List<Usuario> usuarios = [];

  Future<void> carregarPreferencias() async {
    tema = await PreferencesService.obterTema();
    notificacoes = await PreferencesService.obterNotificacoes();

    notifyListeners();
  }

  Future<void> carregarUsuarios() async {
    usuarios = await _banco.obterTodosUsuarios();
    notifyListeners();
  }

  Future<void> salvarTema(String novoTema) async {
    await PreferencesService.salvarTema(novoTema);
    tema = novoTema;
    notifyListeners();
  }

  Future<void> salvarNotificacoes(bool ativadas) async {
    await PreferencesService.salvarNotificacoes(ativadas);
    notificacoes = ativadas;
    notifyListeners();
  }
}
