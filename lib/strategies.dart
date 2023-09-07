import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Container cardWrapper(Function cardBuilder) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: const Color.fromRGBO(25, 25, 25, 1)
      )
    ),
    child: ClipRRect(
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
      }),
    ),
  );
}

Map<String, dynamic>  basic(String cardText) {
  return {
    'text': cardText,
    'card': cardWrapper((paddingInterp) => Container(
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
        textScaleFactor: 1.6
      ),
    )),
  };
}

Map<String, dynamic> attribution(String cardText, String contributor) {
  return {
    'text': cardText,
    'card': cardWrapper((paddingInterp) => Container(
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
              textScaleFactor: 1.6
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(bottom: 20, right: 27),
            child: Text(
              '(given by $contributor)',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    )),
  };
}

Map<String, dynamic> multiple(String cardText, List<String> options, double optionPadding) {
  String text = cardText;
  for (int i = 0; i < options.length; ++i) {
    text += ' •$options[i]';
  }
  
  return {
    'text': text,
    'card': cardWrapper((paddingInterp) => Container(
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
            textScaleFactor: 1.6,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
          Padding(
            padding: EdgeInsets.only(left: optionPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: options.map((option) => Text(
                option,
                style: GoogleFonts.inter(),
                textScaleFactor: 1.6,
                textWidthBasis: TextWidthBasis.longestLine,
              )).toList(),
            ),
          )
        ],
      ),
    )),
  };
}

Map<String, dynamic> options(String cardText, List<String> options, double optionPadding) {
  String text = cardText;
  for (int i = 0; i < options.length; ++i) {
    text += ' •$options[i]';
  }

  return {
    'text': text,
    'card': cardWrapper((paddingInterp) => Container(
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
            textScaleFactor: 1.6,
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
                      textScaleFactor: 1.6,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      option,
                      style: GoogleFonts.inter(),
                      textScaleFactor: 1.6,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                  ),
                ],
              )).toList(),
            ),
          )
        ],
      ),
    ))
  };
}

List<dynamic> strategies = [
  options('Destroy', [ 'nothing', 'the most important thing' ], 95),
  options('Bridges', [ 'build', 'burn' ], 95),
  options('Intentions', [ 'credibility of', 'nobility of', 'humility of' ], 125),
  multiple('Think:', [ 'Inside the work', 'Outside the work' ], 30),
  attribution('Try faking it!', 'Stewart Brand'),
  attribution('Faced with a choice do both', 'Diter Rot'),
  attribution('Tape your mouth', 'Ritva Saarikko'),
  attribution('Always give yourself credit for having more than personality', 'Arto Lindsay'),
  basic('Use filters'),
  basic('Which elements can be grouped?'),
  basic('Gardening, not architecture'),
  basic('Where\'s the edge?\nWhere does the frame start?'),
  basic('Just carry on'),
  basic('Listen to the quiet voice'),
  basic('Question the heroic approach'),
  basic('Take away the elements in order of apparent non importance'),
  basic('The inconsistency principle'),
  basic('You don\'t have to be ashamed of using your own ideas'),
  basic('What to maintain?'),
  basic('Decorate, decorate'),
  basic('When is it for?'),
  basic('Is it finished?'),
  basic('Is there something missing?'),
  basic('Cut a vital connection'),
  basic('Ask people to work against their better judgment'),
  basic('Only one element of each kind'),
  basic('Overtly resist change'),
  basic('Accretion'),
  basic('Be less critical more often'),
  basic('State the problem in words as clearly as possible'),
  basic('Take a break'),
  basic('Emphasize the flaws'),
  basic('Breathe more deeply'),
  basic('Distorting time'),
  basic('Make an exhaustive list of everything you might do and do the last thing on the list'),
  basic('Emphasize differences'),
  basic('Discover the recipes you are using and abandon them'),
  basic('Disconnect from desire'),
  basic('Be extravagant'),
  basic('Do nothing for as long as possible'),
  basic('Remove specifics and convert to ambiguities'),
  basic('The most important thing is the thing most easily forgotten'),
  basic('Tidy up'),
  basic('In total darkness or in a very large room, very quietly'),
  basic('Once the search is in progress, something will be found'),
  basic('Only a part, not the whole'),
  basic('Go outside. Shut the door'),
  basic('Go to an extreme, move back to a more comfortable place'),
  basic('Simple subtraction'),
  basic('Simply a matter of work'),
  basic('Make a blank valuable by putting it in an exquisite frame'),
  basic('Don\'t stress one thing more than another'),
  basic('Make a sudden, destructive unpredictable action; incorporate'),
  basic('Don\'t break the silence'),
  basic('Disciplined self-indulgence'),
  basic('Repetition is a form of change'),
  basic('Discard an axiom'),
  basic('Retrace your steps'),
  basic('Ask your body'),
  basic('Are there sections? Consider transitions'),
  basic('Don\'t be afraid of things because they\'re easy to do'),
  basic('Turn it upside down'),
  basic('Use an old idea'),
  basic('You are an engineer'),
  basic('Do we need holes?'),
  basic('Humanize something free of error'),
  basic('Use \'unqualified\' people'),
  basic('Do the words need changing?'),
  basic('Do something boring'),
  basic('Towards the insignificant'),
  basic('Trust in the you of now'),
  basic('Courage!'),
  basic('Change nothing and continue with immaculate consistency'),
  basic('Work at a different speed'),
  basic('Would anybody want it?'),
  basic('Accept advice'),
  basic('Abandon normal instruments'),
  basic('Which frame would make this look right?'),
  basic('Look at the order in which you do things'),
  basic('Look closely at the most embarrassing details and amplify them'),
  basic('Remove ambiguities and convert to specifics'),
  basic('What to increase? What to reduce?'),
  basic('What would your closest friend do?'),
  basic('Who should be doing this job?\nHow would they do it?'),
  basic('Reverse'),
  basic('Slow preparation..Fast execution'),
  basic('Short circuit (example; a man eating peas with the idea that they will improve his virility shovels them straight into his lap)'),
  basic('Voice nagging suspicions'),
  basic('Make it more sensual'),
  basic('Don\'t be frightened to display your talents'),
  basic('What wouldn\'t you do?'),
  basic('Don\'t be frightened of cliches'),
  basic('What mistakes did you make last time?'),
  basic('Water'),
  basic('Make something implied more definite (reinforce, duplicate)'),
  basic('What are you really thinking about just now? incorporate'),
  basic('Define an area as \'safe\' and use it as an anchor'),
  basic('Always first steps'),
  basic('Allow an easement (an easement is the abandonment of structure)'),
  basic('How would you have done it?'),
  basic('Give the game away'),
  basic('Not building a wall but making a brick'),
  basic('Be dirty'),
  basic('Give way to your worst impulse'),
  basic('Honour thy error as a hidden intention'),
  basic('Use an unacceptable colour'),
  basic('Remember  .those quiet evenings'),
  basic(''),
  basic('A line has two sides'),
  basic('Fill every beat with something'),
  basic('Infinitesimal gradations'),
  basic('Into the impossible'),
  basic('Left channel, right channel, centre channel'),
  basic('Look at a very small object, look at its centre'),
  basic('Spectrum analysis'),
  basic('The tape is now the music'),
  basic('Go slowly all the way round the outside'),
  basic('Put in earplugs'),
  basic('Assemble some of the elements in a group and treat the group'),
  basic('Lowest common denominator'),
  basic('(Organic) machinery'),
  basic('Revaluation (a warm feeling)'),
  basic('You can only make one dot at a time'),
];