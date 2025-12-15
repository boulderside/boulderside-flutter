import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/boulder/application/boulder_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderDetailDesc extends ConsumerWidget {
  const BoulderDetailDesc({super.key, required this.boulder});

  final BoulderModel boulder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(boulderEntityProvider(boulder.id)) ?? boulder;
    final locationText = entity.city.isEmpty
        ? entity.province
        : '${entity.province} ${entity.city}';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entity.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF9498A1),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locationText,
                      style: const TextStyle(
                        color: Color(0xFF7C7C7C),
                        fontSize: 14,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
            child: Text(
              entity.description.trim().isNotEmpty
                  ? entity.description.trim()
                  : 'Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante... (바위 설명)',
              style: const TextStyle(
                fontFamily: 'SFPRO',
                color: Color(0xFF7C7C7C),
                fontSize: 14,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
