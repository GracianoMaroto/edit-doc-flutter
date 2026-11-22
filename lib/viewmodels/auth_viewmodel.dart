import 'package:material_ui/material_ui.dart';

import '../models/usuario.dart';
import '../models/services/preferences_service.dart';

class AuthViewModel extends ChangeNotifier {
  String tema = PreferencesService.temaClaro;
  bool notificacoes = false;
  Usuario? usuarioLogado;
  List<Usuario> usuarios = [];

  bool get estaLogado => usuarioLogado != null;

  String get nomeUsuario => usuarioLogado?.nome ?? 'Usuário';

  ThemeMode get themeMode =>
      tema == PreferencesService.temaEscuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> carregarPreferencias() async {
    tema = await PreferencesService.obterTema();
    notificacoes = await PreferencesService.obterNotificacoes();
    notifyListeners();
  }

  Future<void> carregarSessao() async {
    usuarioLogado = await PreferencesService.obterSessao();
    await carregarPreferencias();
  }

  Future<void> carregarUsuarios() async {
    usuarios = await PreferencesService.obterTodosUsuarios();
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

  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final existentes = await PreferencesService.obterTodosUsuarios();

    final jaExiste = existentes.any(
      (usuario) => usuario.email.toLowerCase() == emailNormalizado,
    );
    if (jaExiste) {
      return 'Este e-mail já está cadastrado.';
    }

    await PreferencesService.inserirUsuario(
      Usuario(
        nome: nome.trim(),
        email: emailNormalizado,
        senha: senha,
      ),
    );

    return null;
  }

  Future<String?> login({
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final existentes = await PreferencesService.obterTodosUsuarios();

    for (final usuario in existentes) {
      if (usuario.email.toLowerCase() == emailNormalizado &&
          usuario.senha == senha) {
        await PreferencesService.salvarSessao(usuario);
        usuarioLogado = usuario;
        notifyListeners();
        return null;
      }
    }

    return 'E-mail ou senha inválidos.';
  }

  Future<void> logout() async {
    await PreferencesService.limparSessao();
    usuarioLogado = null;
    notifyListeners();
  }
}
