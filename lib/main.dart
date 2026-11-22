import 'package:material_ui/material_ui.dart';

import 'models/documento.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/editor_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authVM = AuthViewModel();
  await authVM.carregarSessao();

  runApp(
    MeuAplicativo(
      authVM: authVM,
      documentosVM: DocumentosViewModel(),
    ),
  );
}

class MeuAplicativo extends StatefulWidget {
  final AuthViewModel authVM;
  final DocumentosViewModel documentosVM;

  const MeuAplicativo({
    super.key,
    required this.authVM,
    required this.documentosVM,
  });

  @override
  State<MeuAplicativo> createState() => _MeuAplicativoState();
}

class _MeuAplicativoState extends State<MeuAplicativo> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  AuthViewModel get authVM => widget.authVM;
  DocumentosViewModel get documentosVM => widget.documentosVM;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authVM,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Sistema de Documentos',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: authVM.themeMode,
          initialRoute: authVM.estaLogado ? '/home' : '/',
          routes: {
            '/': (context) => LoginView(authVM: authVM),
            '/cadastro': (context) => CadastroView(authVM: authVM),
            '/home': (context) => HomeView(
                  nomeUsuario: authVM.nomeUsuario,
                  documentosVM: documentosVM,
                  authVM: authVM,
                ),
            '/editor': (context) {
              final documento =
                  ModalRoute.of(context)?.settings.arguments as Documento?;
              return EditorView(documento: documento);
            },
          },
        );
      },
    );
  }
}
