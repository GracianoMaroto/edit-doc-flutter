import 'package:material_ui/material_ui.dart';

import '../models/documento.dart';
import '../models/services/preferences_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';

class HomeView extends StatefulWidget {
  final String nomeUsuario;
  final DocumentosViewModel documentosVM;
  final AuthViewModel authVM;

  const HomeView({
    super.key,
    required this.nomeUsuario,
    required this.documentosVM,
    required this.authVM,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.documentosVM.carregarDocumentos();
    widget.authVM.carregarPreferencias();
  }

  Future<void> _abrirEditor({Documento? documento}) async {
    final resultado = await Navigator.pushNamed(
      context,
      '/editor',
      arguments: documento,
    );

    if (resultado is! Documento || !mounted) return;

    try {
      await widget.documentosVM.salvarDocumento(
        documento: documento,
        titulo: resultado.titulo,
        conteudo: resultado.conteudo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            documento == null
                ? 'Documento salvo com sucesso!'
                : 'Documento atualizado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar documento: $e')),
      );
    }
  }

  Future<void> _excluirDocumento(Documento documento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir documento'),
          content: Text(
            'Deseja excluir "${documento.titulo}"? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    try {
      await widget.documentosVM.excluirDocumento(documento.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documento excluído.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir documento: $e')),
      );
    }
  }

  Future<void> _mostrarModoLeitura(Documento documento) async {
    final desejaEditar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(documento.titulo),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                documento.conteudo,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Fechar'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
            ),
          ],
        );
      },
    );

    if (desejaEditar == true && mounted) {
      await _abrirEditor(documento: documento);
    }
  }

  Future<void> _mostrarPreferencias() async {
    await widget.authVM.carregarPreferencias();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AnimatedBuilder(
          animation: widget.authVM,
          builder: (context, child) {
            final temaEscuro =
                widget.authVM.tema == PreferencesService.temaEscuro;

            return AlertDialog(
              title: const Text('Minhas Preferências'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.palette),
                    title: const Text('Tema do aplicativo'),
                    subtitle: Text(widget.authVM.tema),
                    value: temaEscuro,
                    onChanged: (escuro) {
                      widget.authVM.salvarTema(
                        escuro
                            ? PreferencesService.temaEscuro
                            : PreferencesService.temaClaro,
                      );
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('Notificações'),
                    subtitle: Text(
                      widget.authVM.notificacoes ? 'Ativadas' : 'Desativadas',
                    ),
                    value: widget.authVM.notificacoes,
                    onChanged: widget.authVM.salvarNotificacoes,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarUsuarios() async {
    try {
      await widget.authVM.carregarUsuarios();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AnimatedBuilder(
            animation: widget.authVM,
            builder: (context, child) {
              final usuarios = widget.authVM.usuarios;

              return AlertDialog(
                title: const Text('Usuários cadastrados'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: usuarios.isEmpty
                      ? const Text('Nenhum usuário cadastrado.')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: usuarios.length,
                          itemBuilder: (context, index) {
                            final usuario = usuarios[index];

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(usuario.nome),
                              subtitle: Text(usuario.email),
                            );
                          },
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao consultar usuários: $e')),
      );
    }
  }

  Future<void> _sair() async {
    await widget.authVM.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Documentos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _sair,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.documentosVM,
        builder: (context, child) {
          final documentos = widget.documentosVM.documentos;
          final carregando = widget.documentosVM.carregandoDocumentos;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Olá, ${widget.authVM.nomeUsuario}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bem-vindo ao seu sistema de documentos.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 25),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _mostrarPreferencias,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          size: 40,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preferências do Usuário',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Alterar tema e notificações salvas.',
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _mostrarUsuarios,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storage,
                          size: 40,
                          color: Colors.green,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usuários no Banco Local',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Visualizar todos os usuários cadastrados.',
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Meus Documentos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _abrirEditor(),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo documento'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (carregando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (documentos.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Nenhum documento cadastrado. '
                      'Clique em Novo documento para começar.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...documentos.map((documento) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.description,
                              color: Colors.blue,
                              size: 35,
                            ),
                            title: Text(
                              documento.titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Editado em '
                              '${documento.atualizadoEm.day.toString().padLeft(2, '0')}/'
                              '${documento.atualizadoEm.month.toString().padLeft(2, '0')}/'
                              '${documento.atualizadoEm.year}',
                            ),
                            onTap: () => _mostrarModoLeitura(documento),
                          ),
                          const Divider(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    _mostrarModoLeitura(documento),
                                icon: const Icon(Icons.visibility),
                                label: const Text('Modo leitura'),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _abrirEditor(documento: documento),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                              ),
                              TextButton.icon(
                                onPressed: () => _excluirDocumento(documento),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Excluir'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            'Desenvolvedor: Graciano Marôto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
