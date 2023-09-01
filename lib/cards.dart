import 'strategies.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Cards {
  ClipRRect nextCard(int index, BuildContext context) {
    final storage = GetStorage();
    // minus 1 because this runs for the upcoming card
    storage.write('currentIndex', index - 1);

    return strategies[index];
  }

  int numCards() {
    return strategies.length;
  }
}