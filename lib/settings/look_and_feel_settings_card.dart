import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import '../main.dart';
import '../cards.dart';
import 'settings_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LookAndFeelSettingsCard extends StatefulWidget {
  const LookAndFeelSettingsCard({
    super.key,
  });

  @override
  State<LookAndFeelSettingsCard> createState() => LookAndFeelSettingsCardState();
}

class LookAndFeelSettingsCardState extends State<LookAndFeelSettingsCard> {
  // double fontSize = 0;

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final Cards card = Cards();
    final storage = GetStorage();
    // fontSize = storage.read('fontSize') ?? 0;

    Widget cardWrapper (List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
        child: card.cardWrapper((paddingInterp) => Container(
          alignment: Alignment.center,
          color: Colors.white,
          padding: EdgeInsetsTween(
            begin: const EdgeInsets.symmetric(horizontal: 15), 
            end: const EdgeInsets.symmetric(horizontal: 75)
          ).lerp(paddingInterp),
          child: FocusTraversalGroup(
            descendantsAreFocusable: appState.cardFace == 'look-and-feel-settings',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children
            )
          )
        ))
      );
    }

    return cardWrapper([
      const Spacer(),
      const Spacer(),
      settingsItem(
        text: AppLocalizations.of(context)!.language,
        child: Transform.scale(
          scale: 1.2,
          child: IntrinsicWidth(
            child: DropdownButtonFormField<String>(
              value: storage.read('language') ?? Localizations.localeOf(context).languageCode,
              elevation: 20,
              iconSize: 0,
              style: const TextStyle(fontSize: 21, fontFamily: 'Univers', color: Colors.black),
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.1),
                ),
                focusColor: Colors.black12,
                contentPadding: EdgeInsets.symmetric(vertical: 3),
                isCollapsed: true
              ),
              onChanged: (String? value) {
                storage.write('language', value);
                appState.rebuildApp();
              },
              items: AppLocalizations.supportedLocales.map<DropdownMenuItem<String>>(
                (Locale locale) => DropdownMenuItem<String>(
                  value: locale.languageCode,
                  child: Localizations.override(
                    context: context,
                    locale: Locale(locale.languageCode),
                    child: Builder(
                      builder: (context) => Text(AppLocalizations.of(context)!.languageName)
                    )
                  )
                )
              ).toList(),
            ),
          ),
        )
      ),
      const Spacer(),
      // settingsItem(
      //   text: 'Font size',
      //   child: Expanded(
      //     child: Transform.scale(
      //       scale: 1.2,
      //       child: Slider(
      //         min: -2,
      //         max: 2,
      //         divisions: 4,
      //         value: fontSize,
      //         label: (() {
      //           switch (fontSize) {
      //             case -2:
      //               return 'Smaller';
      //             case -1:
      //               return 'Small';
      //             case 0:
      //               return null;
      //             case 1:
      //               return 'Large';
      //             case 2:
      //               return 'Larger';
      //           }
            
      //           return null;
      //         })(),
      //         onChanged: (val) {
      //           setState(() {
      //             fontSize = val;
      //           });
      //           storage.write('fontSize', val);
      //         }
      //       )
      //     ),
      //   )
      // ),
      // const Spacer(), 
      settingsItem(
        tooltip: 'A reload may be required for certain animation changes to take effect.',
        text: 'Reduce animations',
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: storage.read('reduceAnimations') ?? false,
            semanticLabel: 'Reduce animations',
            onChanged: (val) {
              if (val is bool) {
                storage.write('reduceAnimations', val);
                appState.rebuildApp();
              }
            }
          ),
        )
      ),
      const Visibility(visible: !kIsWeb, child: Spacer()),
      Visibility(
        visible: !kIsWeb,
        child: settingsItem(
          tooltip: 'Hides the navigation and status bars',
          text: 'Immersive mode',
          child: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: storage.read('immersiveMode') ?? false,
              semanticLabel: 'Immersive mode',
              onChanged: (val) {
                if (val is bool) {
                  storage.write('immersiveMode', val);
                  appState.rebuildApp();
                }
              }
            ),
          )
        ),
      ),
      const Spacer(), 
      settingsItem(
        tooltip: kIsWeb
          ? 'If disabled, controls will disappear after a few seconds of mouse inactivity.'
          : 'If disabled, controls will disappear after a few seconds. Tap anywhere to reveal them again.',
        text: 'Always show controls',
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: storage.read('alwaysShowControls') ?? true,
            semanticLabel: 'Always show controls',
            onChanged: (val) {
              if (val is bool) {
                storage.write('alwaysShowControls', val);
                appState.rebuildApp();
              }
            }
          ),
        )
      ),
      const Spacer(),
      const Spacer(),
    ]);
  }
}
