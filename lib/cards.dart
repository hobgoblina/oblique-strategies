import 'strategies.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';

class Cards {
  Container nextCard(int index) {
    final storage = GetStorage();
    // minus 1 because this runs for the upcoming card
    storage.write('currentIndex', index - 1);

    final double minRedrawPercentage = storage.read('minRedrawPercentage') ?? 0.5;
    final int maxAllowedLastDraw = (index - (strategies.length * minRedrawPercentage)).floor();

    List<dynamic> strategyData = storage.read('strategyData') ?? [];
    Container? next;

    final existingCard = strategyData.where((card) => card['lastDrawnAtIndex'] == index).toList();
    if (existingCard.isNotEmpty) {
      next = strategies[existingCard.first['strategyNumber']]['card'];
    }

    while (next == null) {
      final int strategyNumber = Random().nextInt(strategies.length);
      final matches = strategyData.where((card) => card['strategyNumber'] == strategyNumber).toList();
      
      if (matches.isNotEmpty) {
        if (
          (matches.first['lastDrawnAtIndex'] > maxAllowedLastDraw) &&
          !(matches.first['favorite'] && (storage.read('canAlwaysRedrawFavorites') ?? false))
        ) {
          continue;
        }

        final int dataToUpdate = strategyData.indexWhere((card) => card['strategyNumber'] == strategyNumber);
        strategyData[dataToUpdate]['lastDrawnAtIndex'] = index;
      } else {
        strategyData.add({
          'strategyNumber': strategyNumber,
          'lastDrawnAtIndex': index,
          'favorite': false
        });
      }

      next = strategies[strategyNumber]['card'];
    }

    storage.write('strategyData', strategyData);
    return next;
  }
}