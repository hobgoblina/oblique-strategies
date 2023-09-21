import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cards.dart';

Cards card = Cards();

Container settingsCard = card.cardWrapper((paddingInterp) => Container(
  alignment: Alignment.center,
  color: Colors.white,
  padding: EdgeInsetsTween(
    begin: const EdgeInsets.all(20), 
    end: const EdgeInsets.all(75)
  ).lerp(paddingInterp),
  child: Text(
    'Settings go here',
    textWidthBasis: TextWidthBasis.longestLine,
    style: GoogleFonts.inter(),
    textScaleFactor: 1.6
  ),
));