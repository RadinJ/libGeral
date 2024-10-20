export 'libGeral.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void mostrarMsg(BuildContext context, String titulo, String texto) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          ),
        ],
      );
    },
  );
}

void mostrarPopUp(BuildContext context, String titulo, Widget conteudo) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: conteudo,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
        ],
      );
    },
  );
}

Future<dynamic> mostrarBusca(BuildContext ctx, String rota, String titulo) {
  TextEditingController ctrlFiltro = TextEditingController();
  List<Map<String, dynamic>> dadosOriginais = [];
  List<Map<String, dynamic>> dadosFiltrados = [];

  Future<List<Map<String, dynamic>>> buscaDados() async {
    try {
      final resposta =
          await http.get(Uri.parse('http://192.168.3.2:3465/busca-$rota'));

      if (resposta.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(resposta.body));
      } else {
        throw Exception('Falha ao carregar dados');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  return showDialog(
    context: ctx,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(titulo),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrlFiltro,
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (valor) {
                      setState(() {
                        dadosFiltrados = dadosOriginais.where((dado) {
                          return dado['DESCR']
                                  .toString()
                                  .toLowerCase()
                                  .contains(valor.toLowerCase()) ||
                              dado['ID'] == (int.tryParse(valor) ?? 0);
                        }).toList();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: buscaDados(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Erro ao carregar dados");
                      } else if (snapshot.hasData) {
                        dadosOriginais = snapshot.data!;
                        dadosFiltrados = dadosFiltrados.isEmpty
                            ? dadosOriginais
                            : dadosFiltrados;

                        return Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: dadosFiltrados.length,
                            itemBuilder: (context, index) {
                              final dado = dadosFiltrados[index];
                              return ListTile(
                                title: Text(dado['DESCR']),
                                subtitle: Text('Código: ${dado['ID']}'),
                                onTap: () {
                                  Navigator.of(context).pop(dado);
                                },
                              );
                            },
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );
}

class FieldBusca extends StatefulWidget {
  final String label;
  final String rota;
  final TextEditingController ctrlId;

  const FieldBusca({
    Key? key,
    required this.label,
    required this.rota,
    required this.ctrlId,
  }) : super(key: key);

  @override
  _FieldBuscaState createState() => _FieldBuscaState();
}

class _FieldBuscaState extends State<FieldBusca> {
  final TextEditingController ctrlNome = TextEditingController();
  final FocusNode foco = FocusNode();

  @override
  void initState() {
    super.initState();

    foco.addListener(() async {
      if (!foco.hasFocus &&
          widget.ctrlId.text.isNotEmpty &&
          ctrlNome.text.isEmpty) {
        buscaDesc();
      }
    });

    buscaDesc();
  }

  @override
  void dispose() {
    widget.ctrlId.dispose();
    ctrlNome.dispose();
    foco.dispose();
    super.dispose();
  }

  void buscaDesc() async {
    try {
      final resposta = await http.get(Uri.parse(
          'http://192.168.3.2:3465/busca-${widget.rota}?id=${int.parse(widget.ctrlId.text)}'));

      if (resposta.statusCode == 200) {
        final retorno = json.decode(resposta.body);
        if (retorno.length > 0) {
          ctrlNome.text = retorno[0]['DESCR'];
        } else {
          ctrlNome.text = '';
        }
        setState(() {});
      } else {
        throw Exception('Falha ao carregar dados');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              forceErrorText: ctrlNome.text.isEmpty ? 'Código Inválido' : null,
              controller: widget.ctrlId,
              focusNode: foco,
              decoration: InputDecoration(
                labelText: widget.label,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: FittedBox(
                  fit: BoxFit.contain,
                  child: IconButton(
                    onPressed: () async {
                      final retorno = await mostrarBusca(
                          context, widget.rota, widget.label);
                      widget.ctrlId.text = retorno['ID'].toString();
                      ctrlNome.text = retorno['DESCR'];
                      setState(() {});
                    },
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
              textAlign: TextAlign.end,
              onChanged: (value) => ctrlNome.text = '',
            ),
          ),
        ),
        Flexible(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              forceErrorText: ctrlNome.text.isEmpty ? '   ' : null,
              controller: ctrlNome,
              readOnly: true,
              onChanged: (value) => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }
}
