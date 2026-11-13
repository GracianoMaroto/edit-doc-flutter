
import '../documento.dart';
import '../usuario.dart';

class BancoLocalService {
  // Integre aqui a implementação do seu banco local.

  Future<List<Documento>> obterTodosDocumentos() async {
    // Chamar a consulta já existente do BancoDocumentosLocal.
    throw UnimplementedError(
      'Integre a consulta do banco de documentos.',
    );
  }

  Future<void> inserirDocumento(
    String titulo,
    String conteudo,
  ) async {
    // Chamar BancoDocumentosLocal.inserirDocumento.
    throw UnimplementedError(
      'Integre a inserção do banco de documentos.',
    );
  }

  Future<void> atualizarDocumento(
    int id,
    String titulo,
    String conteudo,
  ) async {
    // Chamar BancoDocumentosLocal.atualizarDocumento.
    throw UnimplementedError(
      'Integre a atualização do banco de documentos.',
    );
  }

  Future<List<Usuario>> obterTodosUsuarios() async {
    // Chamar BancoDadosLocal.obterTodosUsuarios.
    throw UnimplementedError(
      'Integre a consulta do banco de usuários.',
    );
  }
}
