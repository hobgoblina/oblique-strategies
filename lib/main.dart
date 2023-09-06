import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'strategy_card.dart';
import 'package:ionicons/ionicons.dart';

void main() async {
  await GetStorage.init();
  runApp(const StrategiesApp());
}

class StrategiesApp extends StatelessWidget {
  const StrategiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Oblique Strategies',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            background: const Color.fromRGBO(25, 25, 25, 1)
          ),
          textTheme: GoogleFonts.interTextTheme()
        ),
        home: MainPage(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
    bool? currentIsFavorite;

    void setCurrentFavorite(bool favorite) {
      currentIsFavorite = favorite;
      notifyListeners();
    }
}

class MainPage extends StatelessWidget {
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    AppState state = context.watch<AppState>();

    void addToFavorites() {
      int? index = storage.read('currentIndex');

      if (storage.read('currentIndex') is int) {
        final List<dynamic> strategyData = storage.read('strategyData');
        final int dataToUpdate = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        final bool favorite = !strategyData[dataToUpdate]['favorite'];
        strategyData[dataToUpdate]['favorite'] = favorite;
        storage.write('strategyData', strategyData);
        state.setCurrentFavorite(favorite);
      }
    }

    if (state.currentIsFavorite == null) {
      int? index = storage.read('currentIndex');
      if (storage.read('currentIndex') is int) {
        List<dynamic> strategyData = storage.read('strategyData');
        final int currentIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        state.currentIsFavorite = strategyData[currentIndex]['favorite'];
      } else {
        state.currentIsFavorite = false;
      }
    }

    return Stack(
      children: [
        const StrategyCard(),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: addToFavorites,
            tooltip: 'Add to favorites',
            icon: Icon(
              Ionicons.heart_outline,
              semanticLabel: 'Add to favorites',
              color: (state.currentIsFavorite ?? false) ? Colors.red : Colors.white,
              size: 40
            ),
          ),
        ),
      ]
    );
  }
}
