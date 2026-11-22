import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../usuario.dart';

class PreferencesService {
  static const _chaveTema = 'tema';
  static const _chaveNotificacoes = 'notificacoes';
  static const _chaveUsuarios = 'usuarios';
  static const _chaveLogado = 'usuario_logado';
  static const _chaveSessaoNome = 'usuario_nome';
  static const _chaveSessaoEmail = 'usuario_email';

  static const temaClaro = 'Claro';
  static const temaEscuro = 'Escuro';

  static Future<String> obterTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveTema) ?? temaClaro;
  }

  static Future<void> salvarTema(String tema) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveTema, tema);
  }

  static Future<bool> obterNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveNotificacoes) ?? false;
  }

  static Future<void> salvarNotificacoes(bool ativadas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveNotificacoes, ativadas);
  }

  static Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveLogado) ?? false;
  }

  static Future<Usuario?> obterSessao() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_chaveLogado) ?? false)) {
      return null;
    }

    final nome = prefs.getString(_chaveSessaoNome);
    final email = prefs.getString(_chaveSessaoEmail);
    if (nome == null || email == null) {
      return null;
    }

    return Usuario(nome: nome, email: email, senha: '');
  }

  static Future<void> salvarSessao(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveLogado, true);
    await prefs.setString(_chaveSessaoNome, usuario.nome);
    await prefs.setString(_chaveSessaoEmail, usuario.email);
  }

  static Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveLogado, false);
    await prefs.remove(_chaveSessaoNome);
    await prefs.remove(_chaveSessaoEmail);
  }

  static Future<List<Usuario>> obterTodosUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_chaveUsuarios);
    if (json == null || json.isEmpty) {
      return [];
    }

    final lista = jsonDecode(json) as List<dynamic>;
    return lista
        .map((item) => Usuario.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> inserirUsuario(Usuario usuario) async {
    final usuarios = await obterTodosUsuarios();
    final proximoId = usuarios.isEmpty
        ? 1
        : usuarios
                .map((usuario) => usuario.id ?? 0)
                .reduce((atual, proximo) => atual > proximo ? atual : proximo) +
            1;

    usuarios.add(
      Usuario(
        id: proximoId,
        nome: usuario.nome,
        email: usuario.email,
        senha: usuario.senha,
      ),
    );

    await _salvarUsuarios(usuarios);
  }

  static Future<void> _salvarUsuarios(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(usuarios.map((usuario) => usuario.toMap()).toList());
    await prefs.setString(_chaveUsuarios, json);
  }
}
