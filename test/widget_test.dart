import 'package:edit_doc_flutter/main.dart';
import 'package:edit_doc_flutter/models/services/documento_storage_service.dart';
import 'package:edit_doc_flutter/models/services/preferences_service.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Aplicativo inicia na tela de login', (tester) async {
    final authVM = AuthViewModel();
    await authVM.carregarSessao();

    await tester.pumpWidget(
      MeuAplicativo(
        authVM: authVM,
        documentosVM: DocumentosViewModel(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
  });

  testWidgets('Cadastro, documentos, tema e persistência após reinício', (
    tester,
  ) async {
    final authVM = AuthViewModel();
    await authVM.carregarSessao();
    final documentosVM = DocumentosViewModel();

    await tester.pumpWidget(
      MeuAplicativo(authVM: authVM, documentosVM: documentosVM),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Não tem conta? Cadastre-se'));
    await tester.pumpAndSettle();

    var campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Graciano');
    await tester.enterText(campos.at(1), 'graciano@teste.com');
    await tester.enterText(campos.at(2), '123456');
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);

    campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'graciano@teste.com');
    await tester.enterText(campos.at(1), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Olá, Graciano!'), findsOneWidget);

    await tester.tap(find.text('Novo documento'));
    await tester.pumpAndSettle();

    campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Ata da reunião');
    await tester.enterText(campos.at(1), 'Discutimos o projeto DocEditor.');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Novo documento'), findsOneWidget);
    expect(find.text('Ata da reunião'), findsOneWidget);

    await tester.tap(find.text('Preferências do Usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(find.text(PreferencesService.temaEscuro), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    final authReinicio = AuthViewModel();
    await authReinicio.carregarSessao();
    final documentosReinicio = DocumentosViewModel();
    await documentosReinicio.carregarDocumentos();

    expect(authReinicio.estaLogado, isTrue);
    expect(authReinicio.nomeUsuario, 'Graciano');
    expect(authReinicio.tema, PreferencesService.temaEscuro);
    expect(documentosReinicio.documentos, hasLength(1));
    expect(documentosReinicio.documentos.first.titulo, 'Ata da reunião');
    expect(
      documentosReinicio.documentos.first.conteudo,
      'Discutimos o projeto DocEditor.',
    );

    await tester.pumpWidget(
      MeuAplicativo(
        authVM: authReinicio,
        documentosVM: documentosReinicio,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Olá, Graciano!'), findsOneWidget);
    expect(find.text('Ata da reunião'), findsOneWidget);
  });

  test('DocumentoStorageService executa CRUD em JSON', () async {
    final storage = DocumentoStorageService();

    await storage.inserir('Título 1', 'Conteúdo 1');
    await storage.inserir('Título 2', 'Conteúdo 2');
    var lista = await storage.obterTodos();
    expect(lista, hasLength(2));
    expect(lista.first.id, 1);

    await storage.atualizar(1, 'Título 1 editado', 'Novo conteúdo');
    lista = await storage.obterTodos();
    expect(lista.first.titulo, 'Título 1 editado');

    await storage.excluir(1);
    lista = await storage.obterTodos();
    expect(lista, hasLength(1));
    expect(lista.first.titulo, 'Título 2');
  });
}
