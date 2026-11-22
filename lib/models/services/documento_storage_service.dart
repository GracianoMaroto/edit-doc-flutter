import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../documento.dart';

class DocumentoStorageService {
  static const _chaveDocumentos = 'documentos';

  Future<List<Documento>> obterTodos() async {
    return _carregarLista();
  }

  Future<void> inserir(String titulo, String conteudo) async {
    final documentos = await _carregarLista();
    final proximoId = documentos.isEmpty
        ? 1
        : documentos
                .map((documento) => documento.id)
                .reduce((atual, proximo) => atual > proximo ? atual : proximo) +
            1;

    documentos.add(
      Documento(
        id: proximoId,
        titulo: titulo,
        conteudo: conteudo,
        atualizadoEm: DateTime.now(),
      ),
    );

    await _salvarLista(documentos);
  }

  Future<void> atualizar(int id, String titulo, String conteudo) async {
    final documentos = await _carregarLista();
    final indice = documentos.indexWhere((documento) => documento.id == id);
    if (indice < 0) {
      throw StateError('Documento não encontrado.');
    }

    documentos[indice] = Documento(
      id: id,
      titulo: titulo,
      conteudo: conteudo,
      atualizadoEm: DateTime.now(),
    );

    await _salvarLista(documentos);
  }

  Future<void> excluir(int id) async {
    final documentos = await _carregarLista();
    documentos.removeWhere((documento) => documento.id == id);
    await _salvarLista(documentos);
  }

  Future<List<Documento>> _carregarLista() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_chaveDocumentos);
    if (json == null || json.isEmpty) {
      return [];
    }

    final lista = jsonDecode(json) as List<dynamic>;
    return lista
        .map(
          (item) => Documento.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> _salvarLista(List<Documento> documentos) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
      documentos.map((documento) => documento.toMap()).toList(),
    );
    await prefs.setString(_chaveDocumentos, json);
  }
}
