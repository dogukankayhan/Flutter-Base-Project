import '../../domain/entity/evolution_chain_entity.dart';

class EvolutionChainDto {
  final int id;
  final EvolutionNodeDto root;

  EvolutionChainDto({required this.id, required this.root});

  factory EvolutionChainDto.fromJson(Map<String, dynamic> json) {
    return EvolutionChainDto(
      id: json['id'] as int,
      root: EvolutionNodeDto.fromJson(json['chain']),
    );
  }

  EvolutionChain toDomain() {
    return EvolutionChain(id: id, root: _convertNode(root));
  }

  static EvolutionNode _convertNode(EvolutionNodeDto nodeDto) {
    return EvolutionNode(
      speciesName: nodeDto.speciesName,
      speciesId: nodeDto.speciesId,
      evolvesTo: nodeDto.evolvesTo.map((e) => _convertNode(e)).toList(),
    );
  }
}

class EvolutionNodeDto {
  final String speciesName;
  final int speciesId;
  final List<EvolutionNodeDto> evolvesTo;

  EvolutionNodeDto({
    required this.speciesName,
    required this.speciesId,
    required this.evolvesTo,
  });

  factory EvolutionNodeDto.fromJson(Map<String, dynamic> json) {
    final speciesUrl = json['species']['url'] as String;
    final speciesId = int.parse(
      speciesUrl.split('/').where((e) => e.isNotEmpty).last,
    );

    return EvolutionNodeDto(
      speciesName: json['species']['name'] as String,
      speciesId: speciesId,
      evolvesTo: (json['evolves_to'] as List<dynamic>)
          .map((e) => EvolutionNodeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
