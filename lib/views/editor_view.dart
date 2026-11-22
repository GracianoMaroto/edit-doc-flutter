import 'package:material_ui/material_ui.dart';

import '../models/documento.dart';

class EditorView extends StatefulWidget {
  final Documento? documento;

  const EditorView({super.key, this.documento});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _conteudoController;

  bool get _editando => widget.documento != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.documento?.titulo ?? '',
    );
    _conteudoController = TextEditingController(
      text: widget.documento?.conteudo ?? '',
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final documento = Documento(
      id: widget.documento?.id ?? 0,
      titulo: _tituloController.text.trim(),
      conteudo: _conteudoController.text.trim(),
      atualizadoEm: DateTime.now(),
    );

    Navigator.pop(context, documento);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar documento' : 'Novo documento'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título do documento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conteudoController,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o conteúdo do documento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
