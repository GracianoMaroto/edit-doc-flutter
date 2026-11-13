
import 'package:material_ui/material_ui.dart';
import '../models/documento.dart';
import '../models/services/banco_local_service.dart';

class DocumentosViewModel extends ChangeNotifier {
  final BancoLocalService _banco;

  DocumentosViewModel(this._banco);

  List<Documento> _documentos = [];
  bool _carregandoDocumentos = false;

  List<Documento> get documentos => _documentos;

  bool get carregandoDocumentos => _carregandoDocumentos;

  Future<void> carregarDocumentos() async {
    _carregandoDocumentos = true;
    notifyListeners();

    try {
      _documentos = await _banco.obterTodosDocumentos();
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
      await _banco.inserirDocumento(titulo, conteudo);
    } else {
      await _banco.atualizarDocumento(
        documento.id,
        titulo,
        conteudo,
      );
    }

    await carregarDocumentos();
  }
}
