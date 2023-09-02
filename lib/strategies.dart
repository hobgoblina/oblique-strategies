import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ClipRRect cardWrapper(Function cardBuilder) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: LayoutBuilder(builder: (context, constraints) {
      double paddingInterp;

      if (constraints.maxWidth >= 750) {
        paddingInterp = 1;
      } else if (constraints.maxWidth <= 400) {
        paddingInterp = 0;
      } else {
        paddingInterp = (constraints.maxWidth - 400) / 350;
      }
      
      return cardBuilder(paddingInterp);
    })
  );
}

ClipRRect basicCard(String cardText) {
  return cardWrapper((paddingInterp) => Container(
    alignment: Alignment.center,
    color: Colors.white,
    padding: EdgeInsetsTween(
      begin: const EdgeInsets.all(20), 
      end: const EdgeInsets.all(75)
    ).lerp(paddingInterp),
    child: Text(
      cardText,
      textWidthBasis: TextWidthBasis.longestLine,
      style: GoogleFonts.inter(),
      textScaleFactor: 1.5
    ),
  ));
}

ClipRRect attributionCard(String cardText, String contributor) {
  return cardWrapper((paddingInterp) => Container(
    color: Colors.white,
    child: Stack(
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsetsTween(
            begin: const EdgeInsets.all(20), 
            end: const EdgeInsets.all(75)
          ).lerp(paddingInterp),
          child: Text(
            cardText,
            textWidthBasis: TextWidthBasis.longestLine,
            style: GoogleFonts.inter(),
            textScaleFactor: 1.5
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(bottom: 20, right: 27),
          child: Text(
            '(given by $contributor)',
            style: GoogleFonts.inter(),
          ),
        )
      ],
    ))
  );
}

ClipRRect multipleCard(String cardText, List<String> options, double optionPadding) {
  return cardWrapper((paddingInterp) => Container(
    alignment: Alignment.center,
    padding: EdgeInsetsTween(
      begin: const EdgeInsets.all(20), 
      end: const EdgeInsets.all(75)
    ).lerp(paddingInterp),
    color: Colors.white,
    child: Wrap(
      direction: Axis.horizontal,
      children: [
        Text(
          cardText,
          style: GoogleFonts.inter(),
          textScaleFactor: 1.5,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
        Padding(
          padding: EdgeInsets.only(left: optionPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((option) => Text(
              option,
              style: GoogleFonts.inter(),
              textScaleFactor: 1.5,
              textWidthBasis: TextWidthBasis.longestLine,
            )).toList(),
          ),
        )
      ],
    ),
  ));
}

ClipRRect optionsCard(String cardText, List<String> options, double optionPadding) {
  return cardWrapper((paddingInterp) => Container(
    alignment: Alignment.center,
    padding: EdgeInsetsTween(
      begin: const EdgeInsets.all(20), 
      end: const EdgeInsets.all(75)
    ).lerp(paddingInterp),
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          cardText,
          style: GoogleFonts.inter(),
          textScaleFactor: 1.5,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
        Padding(
          padding: EdgeInsetsTween(
            begin: const EdgeInsets.only(left: 20), 
            end: EdgeInsets.only(left: optionPadding)
          ).lerp(paddingInterp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((option) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '•',
                    style: GoogleFonts.inter(),
                    textScaleFactor: 1.5,
                  ),
                ),
                Flexible(
                  child: Text(
                    option,
                    style: GoogleFonts.inter(),
                    textScaleFactor: 1.5,
                    textWidthBasis: TextWidthBasis.longestLine,
                  ),
                ),
              ],
            )).toList(),
          ),
        )
      ],
    ),
  ));
}

List<ClipRRect> strategies = [
  optionsCard('Destroy', [ 'nothing', 'the most important thing' ], 95),
  optionsCard('Bridges', [ 'build', 'burn' ], 95),
  optionsCard('Intentions', [ 'credibility of', 'nobility of', 'humility of' ], 125),
  multipleCard('Think:', [ 'Inside the work', 'Outside the work' ], 30),
  attributionCard('Try faking it!', 'Stewart Brand'),
  attributionCard('Faced with a choice do both', 'Diter Rot'),
  attributionCard('Tape your mouth', 'Ritva Saarikko'),
  attributionCard('Always give yourself credit for having more than personality', 'Arto Lindsay'),
  basicCard('Use filters'),
  basicCard('Which elements can be grouped?'),
  basicCard('Gardening, not architecture'),
  basicCard('Where\'s the edge?\nWhere does the frame start?'),
  basicCard('Just carry on'),
  basicCard('Listen to the quiet voice'),
  basicCard('Question the heroic approach'),
  basicCard('Take away the elements in order of apparent non importance'),
  basicCard('The inconsistency principle'),
  basicCard('You don\'t have to be ashamed of using your own ideas'),
  basicCard('What to maintain?'),
  basicCard('Decorate, decorate'),
  basicCard('When is it for?'),
  basicCard('Is it finished?'),
  basicCard('Is there something missing?'),
  basicCard('Cut a vital connection'),
  basicCard('Ask people to work against their better judgment'),
  basicCard('Only one element of each kind'),
  basicCard('Overtly resist change'),
  basicCard('Accretion'),
  basicCard('Be less critical more often'),
  basicCard('State the problem in words as clearly as possible'),
  basicCard('Take a break'),
  basicCard('Emphasize the flaws'),
  basicCard('Breathe more deeply'),
  basicCard('Distorting time'),
  basicCard('Make an exhaustive list of everything you might do and do the last thing on the list'),
  basicCard('Emphasize differences'),
  basicCard('Discover the recipes you are using and abandon them'),
  basicCard('Disconnect from desire'),
  basicCard('Be extravagant'),
  basicCard('Do nothing for as long as possible'),
  basicCard('Remove specifics and convert to ambiguities'),
  basicCard('The most important thing is the thing most easily forgotten'),
  basicCard('Tidy up'),
  basicCard('In total darkness or in a very large room, very quietly'),
  basicCard('Once the search is in progress, something will be found'),
  basicCard('Only a part, not the whole'),
  basicCard('Go outside. Shut the door'),
  basicCard('Go to an extreme, move back to a more comfortable place'),
  basicCard('Simple subtraction'),
  basicCard('Simply a matter of work'),
  basicCard('Make a blank valuable by putting it in an exquisite frame'),
  basicCard('Don\'t stress one thing more than another'),
  basicCard('Make a sudden, destructive unpredictable action; incorporate'),
  basicCard('Don\'t break the silence'),
  basicCard('Disciplined self-indulgence'),
  basicCard('Repetition is a form of change'),
  basicCard('Discard an axiom'),
  basicCard('Retrace your steps'),
  basicCard('Ask your body'),
  basicCard('Are there sections? Consider transitions'),
  basicCard('Don\'t be afraid of things because they\'re easy to do'),
  basicCard('Turn it upside down'),
  basicCard('Use an old idea'),
  basicCard('You are an engineer'),
  basicCard('Do we need holes?'),
  basicCard('Humanize something free of error'),
  basicCard('Use \'unqualified\' people'),
  basicCard('Do the words need changing?'),
  basicCard('Do something boring'),
  basicCard('Towards the insignificant'),
  basicCard('Trust in the you of now'),
  basicCard('Courage!'),
  basicCard('Change nothing and continue with immaculate consistency'),
  basicCard('Work at a different speed'),
  basicCard('Would anybody want it?'),
  basicCard('Accept advice'),
  basicCard('Abandon normal instruments'),
  basicCard('Which frame would make this look right?'),
  basicCard('Look at the order in which you do things'),
  basicCard('Look closely at the most embarrassing details and amplify them'),
  basicCard('Remove ambiguities and convert to specifics'),
  basicCard('What to increase? What to reduce?'),
  basicCard('What would your closest friend do?'),
  basicCard('Who should be doing this job?\nHow would they do it?'),
  basicCard('Reverse'),
  basicCard('Slow preparation..Fast execution'),
  basicCard('Short circuit (example; a man eating peas with the idea that they will improve his virility shovels them straight into his lap)'),
  basicCard('Voice nagging suspicions'),
  basicCard('Make it more sensual'),
  basicCard('Don\'t be frightened to display your talents'),
  basicCard('What wouldn\'t you do?'),
  basicCard('Don\'t be frightened of cliches'),
  basicCard('What mistakes did you make last time?'),
  basicCard('Water'),
  basicCard('Make something implied more definite (reinforce, duplicate)'),
  basicCard('What are you really thinking about just now? incorporate'),
  basicCard('Define an area as \'safe\' and use it as an anchor'),
  basicCard('Always first steps'),
  basicCard('Allow an easement (an easement is the abandonment of structure)'),
  basicCard('How would you have done it?'),
  basicCard('Give the game away'),
  basicCard('Not building a wall but making a brick'),
  basicCard('Be dirty'),
  basicCard('Give way to your worst impulse'),
  basicCard('Honour thy error as a hidden intention'),
  basicCard('Use an unacceptable colour'),
  basicCard('Remember  .those quiet evenings'),
  basicCard(''),
  basicCard('A line has two sides'),
  basicCard('Fill every beat with something'),
  basicCard('Infinitesimal gradations'),
  basicCard('Into the impossible'),
  basicCard('Left channel, right channel, centre channel'),
  basicCard('Look at a very small object, look at its centre'),
  basicCard('Spectrum analysis'),
  basicCard('The tape is now the music'),
  basicCard('Go slowly all the way round the outside'),
  basicCard('Put in earplugs'),
  basicCard('Assemble some of the elements in a group and treat the group'),
  basicCard('Lowest common denominator'),
  basicCard('(Organic) machinery'),
  basicCard('Revaluation (a warm feeling)'),
  basicCard('You can only make one dot at a time'),
];