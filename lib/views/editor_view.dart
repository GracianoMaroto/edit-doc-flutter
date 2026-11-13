
import 'package:material_ui/material_ui.dart';
import '../models/documento.dart';

class EditorDocumentoDialog extends StatefulWidget {
  final Documento? documento;

  const EditorDocumentoDialog({
    super.key,
    this.documento,
  });

  @override
  State<EditorDocumentoDialog> createState() =>
      _EditorDocumentoDialogState();
}

class _EditorDocumentoDialogState
    extends State<EditorDocumentoDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _conteudoController;

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
    final editando = widget.documento != null;

    return AlertDialog(
      title: Text(
        editando ? 'Editar documento' : 'Novo documento',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 15),
                TextFormField(
                  controller: _conteudoController,
                  maxLines: 6,
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _salvar,
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}
