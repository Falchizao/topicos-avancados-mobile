import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas_utfpr/pages/filtro_page.dart';
import '../domain/attractions.dart';
import '../widgets/conteudo_form_dialog.dart';

class ListAtractions extends StatefulWidget {
  @override
  _ListAtractionsState createState() => _ListAtractionsState();
}

class _ListAtractionsState extends State<ListAtractions> {
  static const ACAO_EDITAR = 'editar';
  static const ACTION_READ = 'readOnly';
  static const ACAO_EXCLUIR = 'excluir';

  List<Attraction> attractions = <Attraction>[];
  int _ultimoId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Add Attraction',
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: const Text('Attraction Viewer'),
      actions: [
        IconButton(
            onPressed: () {
              _abrirPaginaFiltro();
            },
            icon: const Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _criarBody() {
    if (attractions.isEmpty) {
      return const Center(
        child: Text(
          'No attraction registered!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        final attraction = attractions[index];
        return PopupMenuButton<String>(
          child: ListTile(
            title: Text('${attraction.id} - ${attraction.title}'),
            subtitle: Text('${attraction.content}'
                '\nRegistered on - ${attraction.registeredDate}'),
          ),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == ACAO_EDITAR) {
              _abrirForm(currentAttraction: attraction, idx: index);
            } else if (valorSelecionado == ACAO_EXCLUIR) {
              _excluir(index);
            } else {
              _view(index);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: attractions.length,
    );
  }

  void sortDate() {
    setState(() {
      attractions = attractions.reversed.toList();
    });
  }

  void filterList(String content) {
    List<Attraction> filteredAttraction = <Attraction>[];

    for (Attraction atr in attractions) {
      if (atr.content.contains(content)) {
        filteredAttraction.add(atr);
      }
    }

    if (filteredAttraction.isEmpty) {
      return;
    }

    setState(() {
      attractions = filteredAttraction;
    });
  }

  void _abrirPaginaFiltro() {
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.routeName).then((alterouValores) {
      if (alterouValores != null) {
        dynamic values = alterouValores;
        if (values[0] == true) {
          var contentFiter = values[1];
          var desc = values[2];

          if (desc) {
            sortDate();
          }

          if (contentFiter != null && contentFiter != "") {
            filterList(contentFiter);
          }
        }
      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopup() {
    return [
      PopupMenuItem<String>(
          value: ACTION_READ,
          child: Row(
            children: const [
              Icon(Icons.remove_red_eye, color: Colors.black),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('View'),
              )
            ],
          )),
      PopupMenuItem<String>(
          value: ACAO_EDITAR,
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.black),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Edit'),
              )
            ],
          )),
      PopupMenuItem<String>(
          value: ACAO_EXCLUIR,
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Delete'),
              )
            ],
          ))
    ];
  }

  void _view(int idx) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(attractions[idx].title),
            content: ConteudoFormDialog(
                key: key, actualAttraction: attractions[idx], ReadOnly: true),
          );
        });
  }

  void _abrirForm({Attraction? currentAttraction, int? idx}) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(currentAttraction == null
                ? 'New Attraction'
                : ' Update attraction ${currentAttraction.id}'),
            content: ConteudoFormDialog(
              key: key,
              actualAttraction: currentAttraction,
              ReadOnly: false,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (key.currentState != null &&
                      key.currentState!.dadosValidados()) {
                    setState(() {
                      final newAttraction = key.currentState!.newAttraction;
                      if (idx == null) {
                        newAttraction.id = ++_ultimoId;

                        attractions.add(newAttraction);
                      } else {
                        attractions[idx] = newAttraction;
                      }
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              )
            ],
          );
        });
  }

  void _excluir(int idx) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Warning'),
                ),
              ],
            ),
            content: const Text('This item will be deleted'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      attractions.removeAt(idx);
                    });
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }
}
