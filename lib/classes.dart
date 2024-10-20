library lib_geral;

export 'classes.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final String nome;
  final String email;
  final bool ativo;

  Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.ativo,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['ID'],
      nome: json['NOME'],
      email: json['EMAIL'] ?? '',
      ativo: (json['ATIVO'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'ativo': ativo ? 1 : 0,
    };
  }

  Future<void> salvar() async {
    // const String apiUrl = 'http://192.168.3.2:3465/salva-aluno';

    // try {
    //   final resposta = await http.post(
    //     Uri.parse(apiUrl),
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode(toJson()),
    //   );

    //   if (resposta.statusCode == 200) {
    //     print('Aluno salvo com sucesso');
    //   } else {
    //     throw Exception('Falha ao salvar aluno');
    //   }
    // } catch (e) {
    //   print('Erro ao salvar aluno: $e');
    // }
  }
}

class Professor {
  final int id;
  final String nome;
  final String email;
  final String telefone;
  final bool ativo;
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
      'ativo': ativo ? 1 : 0,
    };
  }

  Future<void> getIdiomas(int id) async {
    try {
      final resposta = await http.get(
          Uri.parse('http://192.168.3.2:3465/idiomas-prof')
              .replace(queryParameters: {'idProf': id.toString()}));

      if (resposta.statusCode == 200) {
        List<dynamic> dadosJson = json.decode(resposta.body);

        idiomas = dadosJson.map((jsonItem) => ProfIdiomas.fromJson(jsonItem)).toList();
      } else {
        idiomas = [];
      }
    } catch (e) {
      print(e);
    }
  }
}

class ProfIdiomas {
  final int idIdioma;
  final String descricao;
  final String nivel;

  ProfIdiomas({
    required this.idIdioma,
    required this.descricao,
    required this.nivel,
  });

  factory ProfIdiomas.fromJson(Map<String, dynamic> json) {
    return ProfIdiomas(
      idIdioma: json['ID_IDIOMA'],
      descricao: json['IDIOMA'],
      nivel: json['NIVEL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'ID_IDIOMA': idIdioma,
      // 'IDIOMA': descricao,
      // 'NIVEL': nivel,
    };
  }
}

class Aula {
  final int id;
  final int idProfessor;
  final int idIdioma;
  final int idNivel;
  String? professor, idioma, nivel;
  List<Aluno> alunos = [];

  Aula({
    required this.id,
    required this.idProfessor,
    required this.idIdioma,
    required this.idNivel,
    this.professor,
    this.idioma,
    this.nivel,
  });

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      id: json['ID'],
      idProfessor: json['ID_PROFESSOR'],
      idIdioma: json['ID_IDIOMA'],
      idNivel: json['ID_NIVEL'],
      professor: json['PROFESSOR'],
      idioma: json['IDIOMA'],
      nivel: json['NIVEL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_PROFESSOR': idProfessor,
      'ID_IDIOMA': idIdioma,
      'ID_NIVEL': idNivel,
    };
  }

  Future<void> getAlunos(int id) async {
    try {
      final resposta = await http.get(
          Uri.parse('http://192.168.3.2:3465/alunos-aula')
              .replace(queryParameters: {'idAula': id.toString()}));

      if (resposta.statusCode == 200) {
        List<dynamic> dadosJson = json.decode(resposta.body);

        alunos = dadosJson.map((jsonItem) => Aluno.fromJson(jsonItem)).toList();
      } else {
        alunos = [];
      }
    } catch (e) {
      print(e);
    }
  }
}

class Nivel {
  final int id;
  final String nivel;
  final String descricao;

  Nivel({
    required this.id,
    required this.nivel,
    required this.descricao,
  });

  // Converte um JSON para uma instância de Nivel
  factory Nivel.fromJson(Map<String, dynamic> json) {
    return Nivel(
      id: json['id'],
      nivel: json['nivel'],
      descricao: json['descricao'],
    );
  }

  // Converte uma instância de Nivel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nivel': nivel,
      'descricao': descricao,
    };
  }
}
