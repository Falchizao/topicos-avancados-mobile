import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas_utfpr/pages/filtro_page.dart';
import 'package:gerenciador_tarefas_utfpr/pages/lista_tarefas_page.dart';

void main() {
  runApp(const CadastroApp());
}

class CadastroApp extends StatelessWidget {
  const CadastroApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attraction Register',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ListAtractions(),
      routes: {
        FiltroPage.routeName: (BuildContext context) => FiltroPage(),
      },
    );
  }
}
