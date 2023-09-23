import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'main.dart';
import 'cards.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final Cards card = Cards();
    final storage = GetStorage();
    final ValueNotifier<bool> canAlwaysRedrawFavorites = ValueNotifier(storage.read('canAlwaysRedrawFavorites') ?? true);

    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
      child: card.cardWrapper((paddingInterp) => Container(
        alignment: Alignment.center,
        color: Colors.white,
        padding: EdgeInsetsTween(
          begin: const EdgeInsets.all(15), 
          end: const EdgeInsets.all(75)
        ).lerp(paddingInterp),
        child: FocusTraversalGroup(
          descendantsAreFocusable: appState.settingsOpen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      message: 'A reload may be required for certain animation changes to take effect.',
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Ionicons.information_circle_outline,
                              color: Colors.black,
                              size: 25
                            ),
                          ),
                          Text(
                            'Reduce animations',
                            textWidthBasis: TextWidthBasis.longestLine,
                            style: GoogleFonts.inter(),
                            textScaleFactor: 1.5
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        autofocus: true,
                        value: storage.read('reduceAnimations') ?? false,
                        semanticLabel: 'Reduce animations',
                        onChanged: (val) => {
                          if (val is bool) {
                            storage.write('reduceAnimations', val),
                            appState.rebuildApp()
                          }
                        }
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      message: 'Allows favorited cards to be redrawn anytime. It usually takes a while before a card can be redrawn.',
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Ionicons.information_circle_outline,
                              color: Colors.black,
                              size: 25
                            ),
                          ),
                          Text(
                            'Keep favorites in the deck',
                            textWidthBasis: TextWidthBasis.longestLine,
                            style: GoogleFonts.inter(),
                            textScaleFactor: 1.5
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ListenableBuilder(
                      listenable: canAlwaysRedrawFavorites,
                      builder: (context, child) => Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: canAlwaysRedrawFavorites.value,
                          semanticLabel: 'Allows favorited cards to be redrawn anytime. It usually takes a while before a card can be redrawn.',
                          onChanged: (val) => {
                            if (val is bool) {
                              storage.write('canAlwaysRedrawFavorites', val),
                              canAlwaysRedrawFavorites.value = val
                            }
                          }
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}