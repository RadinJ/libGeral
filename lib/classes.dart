library lib_geral;

export 'classes.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Idioma {
  final int id;
  final String descricao;

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
}

class Aluno {
  final int id;
  String nome;
  String email;
  bool ativo;
  String telefone;

  Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.ativo,
    required this.telefone,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['ID'],
      nome: json['NOME'],
      email: json['EMAIL'] ?? '',
      ativo: (json['ATIVO'] ?? 0) == 1,
      telefone: json['TELEFONE'] ?? '',
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

class Professor {
  final int id;
  String nome;
  String email;
  String telefone;
  bool ativo;
  List<ProfIdiomas> idiomas = [];

  Professor({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.ativo,
  });

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
      print(e);
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
    if (perIni == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(perIni);
  }

  String perFinFormat() {
    if (perFin == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(perFin);
  }

  // String horarioFormat() {
  //   if (horario == null) {
  //     return '';
  //   } else {
  //     final DateTime dateTime = DateTime(2000, 1, 1, horario!.hour, horario!.minute);
  //     return DateFormat('HH:mm').format(dateTime);
  //   }
  // }

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      id: json['ID'],
      professor: Professor(
          id: json['ID_PROFESSOR'],
          nome: json['NOME_PROF'],
          email: '',
          telefone: '',
          ativo: true),
      idioma: Idioma(id: json['ID_IDIOMA'], descricao: json['DESCR_IDIOMA']),
      nivel: Nivel(id: json['ID_NIVEL'], nivel: json['DESCR_NIVEL']),
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
      'ID': id,
      'ID_PROFESSOR': professor.id,
      'ID_IDIOMA': idioma.id,
      'ID_NIVEL': nivel.id,
      'PERINI': perIni,
      'PERFIN': perFin,
      'DIASEMANA': diaSemana,
      'HORARIO': horario,
      'ALUNOS': alunos,
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
      print(e);
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
