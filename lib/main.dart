
import 'package:material_ui/material_ui.dart';

import 'models/services/banco_local_service.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';

import 'views/login_view.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
//import 'views/editor_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    final banco = BancoLocalService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Documentos',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginView(),

        '/cadastro': (context) => const CadastroView(),

        '/home': (context) {
          final nomeUsuario =
              ModalRoute.of(context)?.settings.arguments
                  as String? ?? 'Usuário';

          return HomeView(
            nomeUsuario: nomeUsuario,
            documentosVM: DocumentosViewModel(banco),
            authVM: AuthViewModel(banco),
          );
        },

        '/editor': (context) =>
            const Scaffold(
              body: Center(
                child: Text(
                  'Utilize o EditorDocumentoDialog na Home.',
                ),
              ),
            ),
      },
    );
  }
}
