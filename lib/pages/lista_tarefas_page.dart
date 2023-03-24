import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas_utfpr/pages/filtro_page.dart';
import '../model/tarefa.dart';
import '../widgets/conteudo_form_dialog.dart';

class ListaTarefasPage extends StatefulWidget{

  @override
  _ListaTarefasPageState createState() => _ListaTarefasPageState();
}

class _ListaTarefasPageState extends State<ListaTarefasPage>{

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';

  final tarefas = <Tarefa>[

  ];
   int _ultimoId = 0;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Nova Tarefa',
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: Text('Gerenciador de Tarefas'),
      actions: [
        IconButton(
            onPressed: _abrirPaginaFiltro,
            icon: Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _criarBody(){
    if(tarefas.isEmpty){
      return const Center(
        child: Text('Nenhuma tarefa cadastrada',
       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        itemBuilder: (BuildContext context, int index){
          final tarefa = tarefas[index];
          return PopupMenuButton<String>(
            child: ListTile(
              title: Text('${tarefa.id} - ${tarefa.descricao}'),
              subtitle: Text(tarefa.prazo == null ? 'Sem prazo definido' : 'Prazo - ${tarefa.prazoFormatado}'),
            ),
              itemBuilder: (BuildContext context) => criarItensMenuPopup(),
            onSelected: (String valorSelecionado){
              if (valorSelecionado == ACAO_EDITAR){
                _abrirForm(tarefaAtual: tarefa, indice: index);
              }else{
                _excluir(index);
              }
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemCount: tarefas.length,
    );
  }

  void _abrirPaginaFiltro(){
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.routeName).then((alterouValores) {
      if(alterouValores == true){
        ////
      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopup(){
    return[
      PopupMenuItem<String>(
        value: ACAO_EDITAR,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.black),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                child: Text('Editar'),
              )
            ],
          )
      ),
      PopupMenuItem<String>(
          value: ACAO_EXCLUIR,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Excluir'),
              )
            ],
          )
      )
    ];
  }

  void _abrirForm({Tarefa? tarefaAtual, int? indice}){
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(tarefaAtual == null ? 'Nova tarefa' :
            ' Alterar a tarefa ${tarefaAtual.id}'),
            content: ConteudoFormDialog(key: key, tarefaAtual: tarefaAtual),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (key.currentState != null && key.currentState!.dadosValidados()){
                    setState(() {
                      final novaTarefa = key.currentState!.novaTarefa;
                      if (indice == null){
                        novaTarefa.id = ++ _ultimoId;
                      }else{
                        tarefas[indice] = novaTarefa;
                      }
                      tarefas.add(novaTarefa);

                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Salvar'),
              )
            ],
          );
        }
    );
  }

  void _excluir(int indice){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red,),
                Padding(
                    padding: EdgeInsets.only(left: 10),
                  child: Text('ATENÇÃO'),
                ),
              ],
            ),
            content: Text('Esse registro será deletado definitivamente'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')
              ),
              TextButton(
                  onPressed: () {
                     Navigator.of(context).pop();
                     setState(() {
                       tarefas.removeAt(indice);
                     });
                     },
                  child: Text('OK')
              )
            ],
          );
        }
    );

  }
}