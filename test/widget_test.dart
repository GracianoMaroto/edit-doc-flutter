
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:edit_doc_flutter/main.dart';

void main() {
  testWidgets('Aplicativo inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuAplicativo());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Tela de Login'), findsOneWidget);
  });
}
