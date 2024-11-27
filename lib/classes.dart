library lib_geral;

export 'classes.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

abstract class Pessoa {
  final int id;
  String nome;
  String email;
  bool ativo;
  String telefone;

  Pessoa({
    required this.id,
    required this.nome,
    required this.email,
    required this.ativo,
    required this.telefone,
  });
}

class Idioma {
  final int id;
  String descricao;

  Idioma({
    required this.id,
    required this.descricao,
  });

  factory Idioma.fromJson(Map<String, dynamic> json) {
    return Idioma(
      id: json['ID'],
      descricao: json['IDIOMA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'IDIOMA': descricao,
    };
  }

  Future<Map<String, dynamic>> _validar() async {
    if (descricao == '') {
      return {'valido': false, 'msg': 'Informe a Descrição'};
    }
    return {'valido': true};
  }

  Future<Map<String, dynamic>> gravar() async {
    try {
      final validar = await _validar();
      if (validar['valido'] == false) {
        return {
          'code': -1,
          'msg': validar['msg'],
          'success': false,
        };
      } else {
        final resposta = await http.post(
          Uri.parse('http://192.168.3.2:3465/salvar-idioma'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(toJson()),
        );

        final resultado = json.decode(resposta.body);
        return {
          'code': resposta.statusCode,
          'msg': resultado['message'],
          'success': resultado['success']
        };
      }
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false,
      };
    }
  }

  Future<Map<String, dynamic>> excluir() async {
    try {
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/excluir-idioma'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final resultado = json.decode(resposta.body);
      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }
}

class Aluno extends Pessoa {
  int aulasRepo;

  Aluno({
    required final int id,
    required String nome,
    required String email,
    required bool ativo,
    required String telefone,
    this.aulasRepo = 0,
  }) : super(id: id, nome: nome, email: email, ativo: ativo, telefone: telefone);

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['ID'],
      nome: json['NOME'],
      email: json['EMAIL'] ?? '',
      ativo: (json['ATIVO'] ?? 0) == 1,
      telefone: json['TELEFONE'] ?? '',
      aulasRepo: json['AULAS_REPO'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'ativo': ativo ? 1 : 0,
      'telefone': telefone,
    };
  }

  Future<Map<String, dynamic>> gravar() async {
    try {
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/salvar-aluno'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(toJson()),
      );

      final resultado = json.decode(resposta.body);
      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }

  Future<Map<String, dynamic>> excluir() async {
    try {
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/excluir-aluno'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final resultado = json.decode(resposta.body);
      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }
}

class Professor extends Pessoa {
  List<ProfIdiomas> idiomas = [];

  Professor({
    required final int id,
    required String nome,
    required String email,
    required bool ativo,
    required String telefone,
  }) : super(id: id, nome: nome, email: email, ativo: ativo, telefone: telefone);

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['ID'],
      nome: json['NOME'],
      email: json['EMAIL'],
      telefone: json['TELEFONE'],
      ativo: json['ATIVO'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'ativo': ativo,
      'idiomas': idiomas
          .where((idioma) => idioma.ope != 'N')
          .map((idioma) => idioma.toJson())
          .toList(),
    };
  }

  Future<void> getIdiomas(int id) async {
    try {
      final resposta = await http.get(
          Uri.parse('http://192.168.3.2:3465/idiomas-prof')
              .replace(queryParameters: {'idProf': id.toString()}));

      if (resposta.statusCode == 200) {
        List<dynamic> dadosJson = json.decode(resposta.body);

        idiomas = dadosJson
            .map((jsonItem) => ProfIdiomas.fromJson(jsonItem))
            .toList();
      } else {
        idiomas = [];
      }
    } catch (e) {
      // print(e);
    }
  }

  Future<Map<String, dynamic>> gravar() async {
    try {
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/salvar-professor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(toJson()),
      );

      final resultado = json.decode(resposta.body);
      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }

  Future<Map<String, dynamic>> excluir() async {
    try {
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/excluir-professor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final resultado = json.decode(resposta.body);

      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }
}

class ProfIdiomas {
  final Idioma idioma;
  final Nivel nivel;
  String ope;

  ProfIdiomas({
    required this.idioma,
    required this.nivel,
    String? ope,
  }) : this.ope = ope ?? 'N';

  factory ProfIdiomas.fromJson(Map<String, dynamic> json) {
    return ProfIdiomas(
      idioma: Idioma(
        id: json['ID_IDIOMA'],
        descricao: json['IDIOMA'],
      ),
      nivel: Nivel(
        id: json['ID_NIVEL'],
        nivel: json['NIVEL'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_IDIOMA': idioma.id,
      'ID_NIVEL': nivel.id,
      'OPE': ope,
    };
  }
}

class Aula {
  final int id;
  Professor professor;
  Idioma idioma;
  Nivel nivel;
  DateTime? perIni;
  DateTime? perFin;
  int? diaSemana;
  TimeOfDay? horario;
  List<AulaAlunos> alunos = [];

  Aula({
    required this.id,
    required this.professor,
    required this.idioma,
    required this.nivel,
    required this.perIni,
    required this.perFin,
    required this.diaSemana,
    required this.horario,
  });

  String perIniFormat() {
    if (perIni == null) return '';
    return DateFormat('dd/MM/yyyy').format(perIni!);
  }

  String perFinFormat() {
    if (perFin == null) return '';
    return DateFormat('dd/MM/yyyy').format(perFin!);
  }

  String horarioFormat() {
    if (horario == null) {
      return '';
    } else {
      final DateTime dateTime =
          DateTime(2000, 1, 1, horario!.hour, horario!.minute);
      return DateFormat('HH:mm').format(dateTime);
    }
  }

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      id: json['ID'],
      professor: Professor(
          id: json['ID_PROFESSOR'],
          nome: json['NOME_PROF'] ?? '',
          email: '',
          telefone: '',
          ativo: true),
      idioma:
          Idioma(id: json['ID_IDIOMA'], descricao: json['DESCR_IDIOMA'] ?? ''),
      nivel: Nivel(id: json['ID_NIVEL'], nivel: json['DESCR_NIVEL'] ?? ''),
      perIni: DateTime.tryParse(json['PERINI']),
      perFin: DateTime.tryParse(json['PERFIN']),
      diaSemana: json['DIASEMANA'],
      horario: TimeOfDay(
        hour: int.parse(json['HORARIO'].split(":")[0]),
        minute: int.parse(json['HORARIO'].split(":")[1]),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idprofessor': professor.id,
      'ididioma': idioma.id,
      'idnivel': nivel.id,
      'perini': perIni!.toIso8601String(),
      'perfin': perFin!.toIso8601String(),
      'diasemana': diaSemana,
      'horario': horarioFormat(),
      'alunos': alunos
          .where((aluno) => aluno.ope != 'N')
          .map((aluno) => aluno.toJson())
          .toList(),
    };
  }

  Future<void> getAlunos(int id) async {
    try {
      final resposta = await http.get(
          Uri.parse('http://192.168.3.2:3465/alunos-aula')
              .replace(queryParameters: {'idAula': id.toString()}));

      if (resposta.statusCode == 200) {
        List<dynamic> dadosJson = json.decode(resposta.body);

        alunos =
            dadosJson.map((jsonItem) => AulaAlunos.fromJson(jsonItem)).toList();
      } else {
        alunos = [];
      }
    } catch (e) {
      // print(e);
    }
  }

  Future<Map<String, dynamic>> _validar() async {
    List<String> msgs = [];
    if (professor.id == 0) {
      msgs.add('Informe o campo "Professor".');
    }
    if (idioma.id == 0) {
      msgs.add('Informe o campo "Idioma".');
    }
    if (nivel.id == 0) {
      msgs.add('Informe o campo "Nível".');
    }
    if (perIni == null) {
      msgs.add('Informe o campo "Início Período".');
    }
    if (perFin == null) {
      msgs.add('Informa o campo "Fim Período".');
    }
    if (diaSemana == null || diaSemana == 0) {
      msgs.add('Informe o campo "Dia da Semana".');
    }
    if (horario == null) {
      msgs.add('Informe o campo "Horário".');
    }
    if (alunos.where((alu) => alu.ope != 'D').toList().length <= 0) {
      msgs.add('Informe ao menos um Aluno.');
    }
    if (msgs.length > 0) {
      return {'valido': false, 'msg': msgs};
    }

    if (perIni != null &&
        perFin != null &&
        (perIni!.isAfter(perFin!) || perIni!.isAtSameMomentAs(perFin!))) {
      msgs.add(
          'O valor campo "Início Período" deve ser anterior ao valor do campo "Fim Período".');
    }
    await professor.getIdiomas(professor.id);
    if (professor.idiomas
            .where((idi) => idi.idioma.id == idioma.id)
            .toList()
            .where((idi) => idi.nivel.id >= nivel.id)
            .toList()
            .length <=
        0) {
      msgs.add(
          'O professor informado não está apto a dar uma aula desse idioma nesse nível.');
    }
    try {
      final resposta = await http.get(
          Uri.parse('http://192.168.3.2:3465/verifica-horario')
              .replace(queryParameters: {
        'idProfessor': professor.id.toString(),
        'diaSemana': diaSemana.toString(),
        'horario': horarioFormat()
      }));

      if (resposta.statusCode == 200) {
        final horarios = json.decode(resposta.body);
        if (horarios.length > 0) {
          msgs.add(
              'O professor informado tem aulas conflitantes nesse dia, que começam nos horários: ${horarios.map((item) => item['HORARIO'].substring(0, 5)).join(', ')}.');
        }
      }
    } catch (e) {
      // print(e);
    }
    if (msgs.length > 0) {
      return {'valido': false, 'msg': msgs};
    }

    return {'valido': true};
  }

  Future<Map<String, dynamic>> gravar() async {
    try {
      final validar = await _validar();
      if (validar['valido'] == false && validar['msg'].length > 0) {
        return {
          'code': -1,
          'msg': validar['msg'].join('\n'),
          'success': false,
        };
      } else {
        final resposta = await http.post(
          Uri.parse('http://192.168.3.2:3465/salvar-aula'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(toJson()),
        );

        final resultado = json.decode(resposta.body);
        return {
          'code': resposta.statusCode,
          'msg': resultado['message'],
          'success': resultado['success']
        };
      }
    } catch (e) {
      // print(e);
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }

  Future<Map<String, dynamic>> excluir() async {
    try {
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/excluir-aula'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final resultado = json.decode(resposta.body);
      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }
}

class AulaAlunos {
  final Aluno aluno;
  String ope;

  AulaAlunos({
    required this.aluno,
    String? ope,
  }) : this.ope = ope ?? 'N';

  factory AulaAlunos.fromJson(Map<String, dynamic> json) {
    return AulaAlunos(
      aluno: Aluno(
        id: json['ID_ALUNO'],
        nome: json['NOME_ALUNO'],
        ativo: true,
        email: '',
        telefone: '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_ALUNO': aluno.id,
      'OPE': ope,
    };
  }
}

class Nivel {
  final int id;
  String nivel;
  String? descricao;

  Nivel({
    required this.id,
    required this.nivel,
    this.descricao,
  });

  factory Nivel.fromJson(Map<String, dynamic> json) {
    return Nivel(
      id: json['ID'],
      nivel: json['NIVEL'],
      descricao: json['DESCRICAO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nivel': nivel,
      'descricao': descricao,
    };
  }
}

class Solicitacao {
  final int id;
  Aluno aluno;
  Aula aula;
  DateTime? data;
  TimeOfDay? hora;
  String motivo;
  String situacao;
  String? justificativa;
  Professor? professor;

  Solicitacao({
    required this.id,
    required this.aluno,
    required this.aula,
    required this.data,
    required this.hora,
    required this.motivo,
    required this.situacao,
    required this.justificativa,
    this.professor,
  });

  String dataFormat() {
    if (data == null) return '';
    return DateFormat('dd/MM/yyyy').format(data!);
  }

  String horarioFormat() {
    if (hora == null) {
      return '';
    } else {
      final DateTime dateTime = DateTime(2000, 1, 1, hora!.hour, hora!.minute);
      return DateFormat('HH:mm').format(dateTime);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_ALUNO': aluno.id,
      'ID_AULA': aula.id,
      'DTSOLIC': this.data!.toIso8601String(),
      'HORA': horarioFormat(),
      'MOTIVO': motivo,
      'SITUACAO': situacao,
      'JUSTIFICATIVA': justificativa,
    };
  }

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      id: json['ID'],
      aluno: Aluno(
          id: json['ID_ALUNO'],
          nome: json['NOME_ALUNO'] ?? '',
          email: '',
          ativo: true,
          telefone: ''),
      aula: Aula(
          id: json['ID_AULA'],
          professor: Professor(
              id: json['ID_PROF_AULA'] ?? 0,
              nome: json['NOME_PROF_AULA'] ?? '',
              email: '',
              telefone: '',
              ativo: true),
          idioma:
              Idioma(id: json['ID_AULA'] ?? 0, descricao: json['IDIOMA'] ?? ''),
          nivel: Nivel(id: json['ID_NIVEL'] ?? 0, nivel: json['NIVEL'] ?? ''),
          perIni: null,
          perFin: null,
          diaSemana: null,
          horario: null),
      data: DateTime.parse(json['DTSOLIC']),
      hora: TimeOfDay(
        hour: int.parse(json['HORA'].split(":")[0]),
        minute: int.parse(json['HORA'].split(":")[1]),
      ),
      motivo: json['MOTIVO'],
      situacao: json['SITUACAO'],
      justificativa: json['JUSITIFICATIVA'],
    );
  }

  Future<Map<String, dynamic>> _validar() async {
    List<String> msgs = [];
    if (aluno.id == 0) {
      msgs.add('Informe o campo "Aluno".');
    }
    if (aula.id == 0) {
      msgs.add('Informe o campo "Aula".');
    }
    if (data == null) {
      msgs.add('Informe o campo "Data".');
    }
    if (hora == null) {
      msgs.add('Informe o campo "Hora".');
    }
    if (motivo.isNotEmpty) {
      msgs.add('Informa o campo "Motivo".');
    }
    if (msgs.length > 0) {
      return {'valido': false, 'msg': msgs};
    }

    try {
      final resposta = await http.get(
          Uri.parse('http://192.168.3.2:3465/verifica-horario-repo')
              .replace(queryParameters: {
        'data': data,
        'horario': horarioFormat(),
      }));

      if (resposta.statusCode == 200) {
        final horarios = json.decode(resposta.body);
        if (horarios.length > 0) {
          msgs.add(
              'O professor informado tem aulas conflitantes nesse dia, que começam nos horários: ${horarios.map((item) => item['HORARIO'].substring(0, 5)).join(', ')}.');
        }
      }
    } catch (e) {
      // print(e);
    }
    if (msgs.length > 0) {
      return {'valido': false, 'msg': msgs};
    }

    return {'valido': true};
  }

  Future<Map<String, dynamic>> gravar() async {
    try {
      // final validar = await _validar();
      // if (validar['valido'] == false && validar['msg'].length > 0) {
      //   return {
      //     'code': -1,
      //     'msg': validar['msg'].join('\n'),
      //     'success': false,
      //   };
      // } else {
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/salvar-solicitacao'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(toJson()),
      );

      final resultado = json.decode(resposta.body);
      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
      // }
    } catch (e) {
      // print(e);
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }

  Future<Map<String, dynamic>> aprovaReprova(String situacao) async {
    try {
      List<String> msgs = [];
      if (situacao == 'R' &&
          (justificativa == null || justificativa!.isEmpty)) {
        msgs.add('Você deve informar a justificativa!');
      }
      if (situacao == 'A' && professor == null || professor!.id == 0) {
        msgs.add('Você deve informar o professor!');
      }
      if (msgs.length > 0) {
        return {
          'code': -1,
          'msg': msgs.join('\n'),
          'success': false
        };
      }
      final resposta = await http.post(
        Uri.parse('http://192.168.3.2:3465/solic-aprova-reprova'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'ID': id,
            'SITUACAO': situacao,
            'JUSTIFICATIVA': justificativa,
            if (professor != null) 'ID_PROFESSOR': professor!.id,
          },
        ),
      );
      final resultado = json.decode(resposta.body);
      return {
        'code': resposta.statusCode,
        'msg': resultado['message'],
        'success': resultado['success']
      };
    } catch (e) {
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }
}

class Chamada {
  int id;
  Aula aula;
  Professor profe;
  DateTime datahora;
  List<ChamadaPresenca> presencas = [];

  Chamada({
    required this.id,
    required this.aula,
    required this.profe,
    required this.datahora,
  });

  factory Chamada.fromJson(Map<String, dynamic> json) {
    return Chamada(
      id: json['ID'],
      profe: Professor(
          id: json['ID_PROFESSOR'],
          nome: json['NOME_PROFESSOR'],
          email: '',
          telefone: '',
          ativo: true),
      aula: Aula(
        id: json['ID_AULA'],
        professor: Professor(
            id: json['ID_PROFESSOR'],
            nome: json['NOME_PROFESSOR'],
            email: '',
            telefone: '',
            ativo: true),
        idioma: Idioma(id: json['ID_IDIOMA'], descricao: json['DESC_IDIOMA']),
        nivel: Nivel(id: json['ID_NIVEL'], nivel: json['DESC_NIVEL']),
        perIni: null,
        perFin: null,
        diaSemana: null,
        horario: null,
      ),
      datahora: DateTime.parse(json['DATAHORA']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_AULA': aula.id,
      'ID_PROFESSOR': profe.id,
      'DATAHORA': datahora.toIso8601String(),
      'PRESENCAS': presencas.map((presenca) => presenca.toJson()).toList(),
    };
  }

  Future<void> getPresenca() async {
    try {
      await aula.getAlunos(aula.id);

      print(aula.alunos[0].aluno.id);

      for (var alu in aula.alunos) {
        presencas.add(ChamadaPresenca(aluno: alu.aluno, presente: null));
      }
    } catch (e) {
      // print(e);
    }
  }

  Future<Map<String, dynamic>> _validar() async {
    List<String> msgs = [];
    if (aula.id == 0) {
      msgs.add('Houve um problema com o campo "Aula".');
    }
    if (profe.id == 0) {
      msgs.add('Houve um problema com o campo "Professor".');
    }
    if (presencas.any((chamada) => chamada.presente == null)) {
      msgs.add(
          'É necessário responder a chamada de todos os alunos para prosseguir.');
    }
    if (msgs.length > 0) {
      return {'valido': false, 'msg': msgs};
    }

    return {'valido': true};
  }

  Future<Map<String, dynamic>> gravar() async {
    try {
      final validar = await _validar();
      if (validar['valido'] == false && validar['msg'].length > 0) {
        return {
          'code': -1,
          'msg': validar['msg'].join('\n'),
          'success': false,
        };
      } else {
        final resposta = await http.post(
          Uri.parse('http://192.168.3.2:3465/salvar-chamada'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(toJson()),
        );

        final resultado = json.decode(resposta.body);
        return {
          'code': resposta.statusCode,
          'msg': resultado['message'],
          'success': resultado['success']
        };
      }
    } catch (e) {
      print(e);
      return {
        'code': 0,
        'msg': 'Houve um erro de comunicação com o servidor.',
        'success': false
      };
    }
  }
}

class ChamadaPresenca {
  Aluno aluno;
  int? presente;

  ChamadaPresenca({
    required this.aluno,
    this.presente,
  });

  factory ChamadaPresenca.fromJson(Map<String, dynamic> json) {
    return ChamadaPresenca(
      aluno: Aluno(
        id: json['ID_ALUNO'],
        nome: json['NOME_ALUNO'],
        ativo: true,
        email: '',
        telefone: '',
      ),
      presente: json['PRESENCA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_ALUNO': aluno.id,
      'PRESENCA': presente,
    };
  }
}
