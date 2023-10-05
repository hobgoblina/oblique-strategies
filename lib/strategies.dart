import 'cards.dart';

Cards card = Cards();

List<dynamic> strategies = [
  card.options('Destroy', [ 'nothing', 'the most important thing' ], 95),
  card.options('Bridges', [ 'build', 'burn' ], 95),
  card.options('Intentions', [ 'credibility of', 'nobility of', 'humility of' ], 125),
  card.multiple('Think:', [ 'Inside the work', 'Outside the work' ], 30),
  card.attribution('Try faking it!', 'Stewart Brand'),
  card.attribution('Faced with a choice do both', 'Diter Rot'),
  card.attribution('Tape your mouth', 'Ritva Saarikko'),
  card.attribution('Always give yourself credit for having more than personality', 'Arto Lindsay'),
  card.basic('Use filters'),
  card.basic('Which elements can be grouped?'),
  card.basic('Gardening, not architecture'),
  card.basic('Where\'s the edge?\nWhere does the frame start?'),
  card.basic('Just carry on'),
  card.basic('Listen to the quiet voice'),
  card.basic('Question the heroic approach'),
  card.basic('Take away the elements in order of apparent non importance'),
  card.basic('The inconsistency principle'),
  card.basic('You don\'t have to be ashamed of using your own ideas'),
  card.basic('What to maintain?'),
  card.basic('Decorate, decorate'),
  card.basic('When is it for?'),
  card.basic('Is it finished?'),
  card.basic('Is there something missing?'),
  card.basic('Cut a vital connection'),
  card.basic('Ask people to work against their better judgment'),
  card.basic('Only one element of each kind'),
  card.basic('Overtly resist change'),
  card.basic('Accretion'),
  card.basic('Be less critical more often'),
  card.basic('State the problem in words as clearly as possible'),
  card.basic('Take a break'),
  card.basic('Emphasize the flaws'),
  card.basic('Breathe more deeply'),
  card.basic('Distorting time'),
  card.basic('Make an exhaustive list of everything you might do and do the last thing on the list'),
  card.basic('Emphasize differences'),
  card.basic('Discover the recipes you are using and abandon them'),
  card.basic('Disconnect from desire'),
  card.basic('Be extravagant'),
  card.basic('Do nothing for as long as possible'),
  card.basic('Remove specifics and convert to ambiguities'),
  card.basic('The most important thing is the thing most easily forgotten'),
  card.basic('Tidy up'),
  card.basic('In total darkness or in a very large room, very quietly'),
  card.basic('Once the search is in progress, something will be found'),
  card.basic('Only a part, not the whole'),
  card.basic('Go outside. Shut the door'),
  card.basic('Go to an extreme, move back to a more comfortable place'),
  card.basic('Simple subtraction'),
  card.basic('Simply a matter of work'),
  card.basic('Make a blank valuable by putting it in an exquisite frame'),
  card.basic('Don\'t stress one thing more than another'),
  card.basic('Make a sudden, destructive unpredictable action; incorporate'),
  card.basic('Don\'t break the silence'),
  card.basic('Disciplined self-indulgence'),
  card.basic('Repetition is a form of change'),
  card.basic('Discard an axiom'),
  card.basic('Retrace your steps'),
  card.basic('Ask your body'),
  card.basic('Are there sections? Consider transitions'),
  card.basic('Don\'t be afraid of things because they\'re easy to do'),
  card.basic('Turn it upside down'),
  card.basic('Use an old idea'),
  card.basic('You are an engineer'),
  card.basic('Do we need holes?'),
  card.basic('Humanize something free of error'),
  card.basic('Use \'unqualified\' people'),
  card.basic('Do the words need changing?'),
  card.basic('Do something boring'),
  card.basic('Towards the insignificant'),
  card.basic('Trust in the you of now'),
  card.basic('Courage!'),
  card.basic('Change nothing and continue with immaculate consistency'),
  card.basic('Work at a different speed'),
  card.basic('Would anybody want it?'),
  card.basic('Accept advice'),
  card.basic('Abandon normal instruments'),
  card.basic('Which frame would make this look right?'),
  card.basic('Look at the order in which you do things'),
  card.basic('Look closely at the most embarrassing details and amplify them'),
  card.basic('Remove ambiguities and convert to specifics'),
  card.basic('What to increase? What to reduce?'),
  card.basic('What would your closest friend do?'),
  card.basic('Who should be doing this job?\nHow would they do it?'),
  card.basic('Reverse'),
  card.basic('Slow preparation..Fast execution'),
  card.basic('Short circuit (example; a man eating peas with the idea that they will improve his virility shovels them straight into his lap)'),
  card.basic('Voice nagging suspicions'),
  card.basic('Make it more sensual'),
  card.basic('Don\'t be frightened to display your talents'),
  card.basic('What wouldn\'t you do?'),
  card.basic('Don\'t be frightened of cliches'),
  card.basic('What mistakes did you make last time?'),
  card.basic('Water'),
  card.basic('Make something implied more definite (reinforce, duplicate)'),
  card.basic('What are you really thinking about just now? incorporate'),
  card.basic('Define an area as \'safe\' and use it as an anchor'),
  card.basic('Always first steps'),
  card.basic('Allow an easement (an easement is the abandonment of structure)'),
  card.basic('How would you have done it?'),
  card.basic('Give the game away'),
  card.basic('Not building a wall but making a brick'),
  card.basic('Be dirty'),
  card.basic('Give way to your worst impulse'),
  card.basic('Honour thy error as a hidden intention'),
  card.basic('Use an unacceptable colour'),
  card.basic('Remember  .those quiet evenings'),
  card.basic('A line has two sides'),
  card.basic('Fill every beat with something'),
  card.basic('Infinitesimal gradations'),
  card.basic('Into the impossible'),
  card.basic('Left channel, right channel, centre channel'),
  card.basic('Look at a very small object, look at its centre'),
  card.basic('Spectrum analysis'),
  card.basic('The tape is now the music'),
  card.basic('Go slowly all the way round the outside'),
  card.basic('Put in earplugs'),
  card.basic('Assemble some of the elements in a group and treat the group'),
  card.basic('Lowest common denominator'),
  card.basic('(Organic) machinery'),
  card.basic('Revaluation (a warm feeling)'),
  card.basic('You can only make one dot at a time'),
];