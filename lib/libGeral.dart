export 'libGeral.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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

void mostrarSnackMsg(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensagem),
    ),
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

class FieldCod extends StatelessWidget {
  final TextEditingController controller;

  FieldCod({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.text == "0") {
      controller.text = "";
    }

    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Código',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      textAlign: TextAlign.right,
    );
  }
}

class FieldBusca extends StatefulWidget {
  final String label;
  final String rota;
  final TextEditingController ctrlId;
  final Function(String)? onChanged;
  bool campoObrigatorio;

  FieldBusca({
    Key? key,
    required this.label,
    required this.rota,
    required this.ctrlId,
    this.onChanged,
    this.campoObrigatorio = false,
  }) : super(key: key);

  @override
  _FieldBuscaState createState() => _FieldBuscaState();
}

class _FieldBuscaState extends State<FieldBusca> {
  final TextEditingController ctrlNome = TextEditingController();
  final FocusNode foco = FocusNode();
  bool codInvalido = false;

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

    if (widget.ctrlId.text.isNotEmpty) {
      buscaDesc();
    }
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
          codInvalido = false;
        } else {
          ctrlNome.text = '';
          codInvalido = true;
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
              forceErrorText: codInvalido && ctrlNome.text.isEmpty
                  ? 'Código Inválido'
                  : widget.campoObrigatorio && widget.ctrlId.text.isEmpty
                      ? 'Campo Obrigatório'
                      : null,
              controller: widget.ctrlId,
              focusNode: foco,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
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
              onChanged: (value) {
                ctrlNome.text = '';
                setState(() {});
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
            ),
          ),
        ),
        Flexible(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              forceErrorText: codInvalido && ctrlNome.text.isEmpty
                  ? 'Código Inválido'
                  : widget.campoObrigatorio && widget.ctrlId.text.isEmpty
                      ? 'Campo Obrigatório'
                      : null,
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

class FieldData extends StatelessWidget {
  final BuildContext ctx;
  final TextEditingController controller;
  final String label;
  final bool mostraErro;
  final String erro;
  final Function(String?)? beforePick, afterPick;
  final Function(String)? onChanged;

  FieldData({
    Key? key,
    required this.ctx,
    required this.controller,
    required this.label,
    this.mostraErro = false,
    this.erro = 'Campo Obrigatório',
    this.beforePick,
    this.afterPick,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (beforePick != null) beforePick!(controller.text);
        FocusScope.of(context).requestFocus(FocusNode());
        final DateTime? dt = await showDatePicker(
          context: context,
          initialDate: controller.text.isEmpty
              ? DateTime.now()
              : DateFormat('dd/MM/yyyy').parse(controller.text),
          firstDate: controller.text.isEmpty
              ? DateTime.now()
              : DateFormat('dd/MM/yyyy').parse(controller.text),
          lastDate: DateTime.now().add(Duration(days: 365)),
          locale: Localizations.localeOf(ctx),
        );
        if (dt != null && dt != DateTime.tryParse(controller.text)) {
          controller.text = DateFormat('dd/MM/yyyy').format(dt);
          if (onChanged != null) {
            onChanged!(controller.text);
          }
          if (afterPick != null) afterPick!(controller.text);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            errorText: mostraErro && controller.text.isEmpty ? erro : null,
          ),
        ),
      ),
    );
  }
}

class FieldHora extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool mostraErro;
  final String erro;
  final Function(String)? onChanged;

  FieldHora({
    Key? key,
    required this.controller,
    required this.label,
    this.mostraErro = false,
    this.erro = 'Campo obrigatório',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final TimeOfDay? horario = await showTimePicker(
          context: context,
          initialTime: controller.text.isEmpty
              ? TimeOfDay.now()
              : TimeOfDay(
                  hour: int.parse(controller.text.split(':')[0]),
                  minute: int.parse(controller.text.split(':')[1]),
                ),
          helpText: 'SELECIONE O HORÁRIO',
          cancelText: 'CANCELAR',
          hourLabelText: 'Hora',
          minuteLabelText: 'Minuto',
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (horario != null &&
            '${horario.hour.toString().padLeft(2, '0')} : ${horario.minute.toString().padLeft(2, '0')}' !=
                controller.text) {
          controller.text =
              '${horario.hour.toString().padLeft(2, '0')} : ${horario.minute.toString().padLeft(2, '0')}';
          if (onChanged != null) {
            onChanged!(controller.text);
          }
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.schedule_outlined),
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            errorText: mostraErro && controller.text.isEmpty ? erro : null,
          ),
        ),
      ),
    );
  }
}

class BotoesCadastro extends StatefulWidget {
  final Function()? novo;
  final Function()? salvar;
  final Function()? cancelar;
  final Function()? excluir;
  bool insercao;
  bool edicao;

  BotoesCadastro({
    Key? key,
    required this.novo,
    required this.salvar,
    required this.cancelar,
    required this.excluir,
    required this.insercao,
    required this.edicao,
  }) : super(key: key);

  @override
  _BotoesCadastroState createState() => _BotoesCadastroState();
}

class _BotoesCadastroState extends State<BotoesCadastro> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ToggleButtons(
        borderWidth: 5,
        renderBorder: true,
        color: Colors.grey,
        fillColor: Colors.white,
        isSelected: [
          !widget.insercao && !widget.edicao,
          widget.insercao || widget.edicao,
          widget.insercao || widget.edicao,
          !widget.insercao && !widget.edicao,
        ],
        onPressed: (idx) async {
          if (idx == 0 && widget.novo != null) {
            widget.novo!();
          } else if (idx == 1) {
            widget.salvar!();
          } else if (idx == 2) {
            widget.cancelar!();
          } else if (idx == 3) {
            widget.excluir!();
          }
        },
        children: const [
          Icon(Icons.add_outlined),
          Icon(Icons.save_outlined),
          Icon(Icons.cancel_outlined),
          Icon(Icons.delete_outline),
        ],
      ),
    );
  }
}
