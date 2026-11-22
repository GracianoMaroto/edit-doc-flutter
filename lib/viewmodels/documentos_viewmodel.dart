import 'package:material_ui/material_ui.dart';

import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

class DocumentosViewModel extends ChangeNotifier {
  final DocumentoStorageService _storage;

  DocumentosViewModel([DocumentoStorageService? storage])
      : _storage = storage ?? DocumentoStorageService();

  List<Documento> _documentos = [];
  bool _carregandoDocumentos = false;

  List<Documento> get documentos => _documentos;

  bool get carregandoDocumentos => _carregandoDocumentos;

  Future<void> carregarDocumentos() async {
    _carregandoDocumentos = true;
    notifyListeners();

    try {
      _documentos = await _storage.obterTodos();
    } finally {
      _carregandoDocumentos = false;
      notifyListeners();
    }
  }

  Future<void> salvarDocumento({
    Documento? documento,
    required String titulo,
    required String conteudo,
  }) async {
    if (documento == null) {
      await _storage.inserir(titulo, conteudo);
    } else {
      await _storage.atualizar(documento.id, titulo, conteudo);
    }

    await carregarDocumentos();
  }

  Future<void> excluirDocumento(int id) async {
    await _storage.excluir(id);
    await carregarDocumentos();
  }
}
