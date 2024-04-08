% create a file-maze with hints
global folder_list_cell f_idx
%% first stuff
fclose('all');
my_matlab_dir = fullfile(cd, 'MAZE');
s = pathsep;
if contains([s, path, s], [s, my_matlab_dir, s], 'IgnoreCase', ispc)
    rmpath(genpath('MAZE'));
end
if isfolder(my_matlab_dir)
    yn_success = rmdir(my_matlab_dir, 's');
    if ~yn_success
        error('Cannot delete existing MAZE folder. Close all related files first.')
    end
end
if ~isfolder(my_matlab_dir)
    yn_success = mkdir(cd, 'MAZE');
    if ~yn_success
        error('Cannot create new MAZE directory.')
    end
end
%% second stuff - The 
alwaysname = 'PATH_';
levels = nan;
maxwidth = nan;
help_var = 'MAZE';
ii = 0;
s = [levels < 1, maxwidth < 1; levels > 7, maxwidth > 7; floor(levels)~=levels, floor(maxwidth)~=maxwidth; ~isscalar(levels), ~isscalar(maxwidth)];

while any(s, 'all')

    if ii
        warning('Input integers between 1 and 7 (about 5 is recommended).')
    end
    ii = ii + 1;
    l = inputdlg({'Enter maximum MAZE Levels: ', 'Enter max folders in each folder: '}, help_var, 1, {'6', '4'});
    levels = str2double(l{1});
    maxwidth = str2double(l{2});
    if ii == 4
        error('WTF dude!')
    else
        s = [levels < 1, maxwidth < 1; levels > 7, maxwidth > 7; floor(levels)~=levels, floor(maxwidth)~=maxwidth; ~isscalar(levels), ~isscalar(maxwidth)];
    end
end
folder_list_cell = cell(maxwidth^levels, 1);
f_idx = 1;
for ii = 1:maxwidth
    randmaze(my_matlab_dir, alwaysname, maxwidth, levels);
end

folder_list_cell(cellfun('isempty', folder_list_cell)) = [];
folder_lengths = cellfun(@length, folder_list_cell);
levels = max(folder_lengths) - length(alwaysname);
deepest_inds = find(folder_lengths == (levels+length(alwaysname)));
win_ind = deepest_inds(randi(length(deepest_inds)));
win_folder = folder_list_cell{win_ind};

%%
addpath(genpath('MAZE'));
win_path = what(win_folder);
win_path = win_path.path;
fid = fopen(fullfile(win_path, 'congrats.txt'), 'wt');
win_message = regexgen('n(o)?ice!\\nYou (found the way out|rescued the princess|defeated the maze|touched the goblet, killed Cedric Diggory and won The Triwizard Crap) or whatever\\n\\n----------\\nThe End\\n----------\\n\\n\\n\\n\\n');
win_poem = regexgen("""(I wrote you a letter,\\nand then another letter,\\nand another, and another,\\nuntil I wrote you a word\.\\n\\nSo I wrote you a word,\\nand then another word,\\nand another, and another,\\nuntil I wrote you a sentence\.\\n\\nSo I wrote you a sentence,\\nand then another sentence,\\nand another, and another,\\nuntil I wrote you a letter\.\\n\\nI hope it finds you as I found you\.\\n\\nYours truly,\\nYours, truly\.|" + ...
    "Fame achieved\\nby mere achievement\\nscarce deserves the name\.\\nProper fame\\nis being famous\\nsimply for your fame\.|" + ...
    "Solutions to problems\\nare easy to find:\\nthe problem's a great\\ncontribution\.\\nWhat's truly an art\\nis to wring from your mind\\na problem to fit\\na solution\.|" + ...
    "To make a name for learning\\nwhen other roads are barred,\\ntake something very easy\\nand make it very hard\.)""");
dedication = sprintf('\n\n\n\t\t\t\t\t\tThis maze is dedicated to Aline');
fprintf(fid, win_message + win_poem + dedication);
close_res = fclose(fid);
if close_res
    error('file not closed proper')
end

%% curiosities along the way
max_curios = 10;
howmany_curios = min(floor(f_idx/5), max_curios);
if howmany_curios
    curios = struct('thing', [], 'flavor', []);
    %1
    curios(max_curios).thing = regexgen('( b(ea)?utiful butterfly| magnificent bluebird| wise owl| curious-looking chicken|n overconfident dragon|n enormous bat);(are about to say something to it,\\nfoolishly thinking it could ease your loneliness|(are about to )?decide what to (do with|make of) it, you know\.{3}\\nTo pass the time, so to speak|think to yourself:\\n"now that''s a\1 if I''ve ever seen one");(, never to be seen again( by another human being)?(\.{3})(\\n\\nWell, no choice but to go on!)?|(\.{3}))');
    help_var = cellstr(strsplit(curios(max_curios).thing, ';'));
    curios(max_curios).flavor = sprintf('On your adventures you encounter a%s.\nBut just as you %s,\nit flies away%s', help_var{:});
    %2
    curios(max_curios-1).thing = regexgen('a( gold ring| delicious cookie|n open grave|n unused condom)!\\nYou walk away thinking "(I cannot believe my luck|This isn''t mine)"\.');
    help_var = regexgen('(!{1,2})| -|:|,');
    curios(max_curios-1).flavor = sprintf('Suddenly, you see a shadow in the bushes...\nCheck it out%s It''s %s', help_var, curios(max_curios-1).thing);
    %3
    curios(max_curios-2).thing = regexgen('a boy;him;his;he says, and runs;''s this kid|a girl;her;her;she says, and runs;''s this kid|two kids;them;their;they say, and run; are those kids');
    help_var = cellstr(strsplit(curios(max_curios-2).thing, ';'));
    curios(max_curios-2).flavor = sprintf('Randomly, %s asks you if you could help %s tie %s shoelaces.\nYou are quite flummoxed, but you quickly remember your manners and agree to help.\n"Thanks", %s away...\nThat was weird! what%s doing in a maze anyway?', help_var{:});
    %4
    curios(max_curios-3).thing = regexgen('([2-9]|[1-9]\d{0,3})((\.5)?|) (intelligence|wisdom|strength|courage|luck|vitality|health|mana)');
    help_var = regexgen('(!{1,2})| -|:|,');
    curios(max_curios-3).flavor = sprintf('Hey, look%s an apothecary table! I wonder what you could find here...\n\nIt''s a magic potion!\n\nYou drink it and gain %s points', help_var, curios(max_curios-3).thing);
    %5
    curios(max_curios-4).thing = regexgen('\\n\\n(?:0[1-9]|[12][0-9]|3[01])([-/.])(0[1-9]|1[012])\1(?:18|19)\d\d\\n\\nDear Diary,\\n\\nIt''s been [3-7] weeks and I am still stuck in this maze\. So! Much! Fun!\\nOh, hey - (a butterfly|a cat|the way out|a hint|a folder|a txt file(!|\.{3}) It reads:\\n\\n"You found a piece of paper from an old diary\. It reads:\\n\\n(?:0[1-9]|[12][0-9]|3[01])([-/.])(0[1-9]|1[012])\1(?:18|19)\d\d\\n\\nDear Diary,\\n\\nIt''s been [3-7] weeks and I am still stuck in this maze\. So! Much! Fun!\\nOh, hey - recursion")(!|\.{3})');
    curios(max_curios-4).flavor = sprintf('You found a piece of paper from an old diary. It reads:%s', curios(max_curios-4).thing);
    %6-10
    my_time = string(datetime);
    hr = str2double(regexp(my_time, '(\d\d)(?=:\d\d:\d\d)', 'match'));
    if (hr >= 0 && hr <= 3) || hr >= 22
        curios(max_curios-5).thing = (["You find a homeless person sleeping on the side of the road.\nShhhhh... Don't wake him up!";...
            "Even the moonlessest night has one star.";...
            "Careless and night-blind, you step on a twig.\nThis foolish misstep awakens a nearby troll from his slumber.\n""Hey dude! I'm trying to sleep!"", Says the troll.\nYou respond with a shrug.\n""What's that?! You wanna fight? That it?!""\nThen, suddenly, the troll begins to laugh uncon-troll-ably.\n""Oh boy! I really had you going there for a second!\nIt's me, uncle mario!""\nUncle mario gives you a big hug and you sing and drink beer all night, just like in the good old days...";...
            regexgen("Even though it's night-time, you look around you and see no cats\.\\nMaybe it's because it's dark\.\\nMaybe it's because I keep my maze rat-less, so all the cats go to my friend (Bobby|Tina)'s shitty rat-ridden maze\.\\nFUCK YOU, \1! And FUCK your maze too! I made it up! It was me! It's mine! My precious{3,7}\.{3}");...
            "Fun fact: the maze has no ceiling, so you can see the moon and stars above!\nThey tell you nothing about where you need to go, though."]);
    elseif hr > 3 && hr <= 6
        curios(max_curios-5).thing = (["Soon, a new sun will cast its light upon the maze.\nI am curious to see how the folders will unfold today.";...
            "A red sun rises, and it's time for blood!\n(Have you donated any blood recently? It could save lives!)";...
            "This is the dawn of a new world! A world of possibilities! Choose a folder! Any folder!\nYour way is ahead! Don't look behind! You're doing great!\nWe all believe in you! Optimism! Yay!\nError!\nGood_words_generator has stopped working";...
            "We starve, look at one another, short of breath\nWalking proudly in our winter coats\nWearing smells from laboratories\nFacing a dying nation of moving paper fantasy\nListening for the new told lies\nWith supreme visions of lonely tunes\nSomewhere, inside something there is a rush of\nGreatness, who knows what stands in front of\nOur lives, I fashion my future on films in space\nSilence tells me secretly\nEverything\nEverything\nManchester, England, England\nManchester, England, England\nAcross the Atlantic Sea\nAnd I'm a genius, genius\nI believe in God\nAnd I believe that God believes in Claude\nThat's me, that's me, that's me\nWe starve, look at one another, short of breath\nWalking proudly in our winter coats\nWearing smells from laboratories\nFacing a dying nation of moving paper fantasy\nListening for the new told lies\nWith supreme visions of lonely tunes\nSinging our space songs on a spider web sitar\nLife is around you and in you\nAnswer for Timothy Leary, dearie\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in\nLet the sunshine, let the sunshine in\nThe sunshine in";...
            "After a long, sleepless night, you wake up half-asleep and hungover at the break of day.\n""Oh right"", you remember vaguely: ""I was drinking last night with my uncle Mario,\noy vey, that guy can hold his liquor... He can also drink a lot without vomiting"".\nYou get to a sort-of vertical position, assuming your legs are where you think they are relative to the rest of your body.\n""Well! Time to hit the folders again! Or as I like to call them, 'golders'"".\nSomething is gnawing at you, like there's something important that you don't quite remember.\nSomething important that you don't quite remember, oops you thought that already, guess you really are hungover...\nAs you grab around for your shoes, you find that one of them is below a big stone that you can barely move.\n""That's it! Where is uncle Mario? that big block of a guy..."".\nBut then you look at the stone you just rolled over, and it seems awfully familiar.\n""By Allah, so Mario WAS a troll after all...""."]);
    elseif hr > 7 && hr <= 11
        curios(max_curios-5).thing = (["""Good Morning!"" said Bilbo, and he meant it. The sun was\nshining, and the grass was very green. But Gandalf looked\nat him from under long bushy eyebrows that stuck out\nfurther than the brim of his shady hat.\n\n""What do you mean?"" he said. ""Do you wish me a good\nmorning, or mean that it is a good morning whether\nI want it or not; or that you feel good this morning;\nor that it is a morning to be good on?""\n\n""All of them at once,"" said Bilbo. ""And a very fine\nmorning for a MAZE, into the bargain."""; ...
            "Have you had any coffee yet?"; ...
            "Good morning. have an aMAZEing day!\nI hope you win :)"; ...
            "WHY I'M NOT A MORNING PERSON\nEvery morning, my parents gave,\nA list of chores to me,\n""For every chore you cross off here, you\nGet a sweet for free"".\nSo I snuck into their room one night,\nAnd found tomorrow's list;\nI added ""get a sweet"" and then,\nKilled them for good measure.\nWhat you learn from that, my child,\nIs ""do what gives you pleasure.""\nSure, that is how Hitler died,\nBut this is beside the point!\nJust the thought\nOf doing what you ought,\nCan lead to so much sorrow.\nWhy not leave today's chores, then,\nto the ""you"" of tomorrow?"; ...
            "You don't know what to do.\n""Crap, crap, crap, crap CRAP!"".\nUncle Mario has turned into a stone again. What's more, when you rolled him over,\nlooking for your shoe, his nose kind of chafed off on the side walk...\n""Why the long nose, uncle?"""]);
    elseif hr > 11 && hr <= 13
        curios(max_curios-5).thing = (["""Can you take a picture of us with the folders?""\nAsked the wide-hatted tourist, in his tourist group.\n""Sure, why not"", you answer.\n*K'ching*\n\n"+regexgen("""Wow! Thanks for the picture, helpful person!""|""Jeez! That picture is all burned!\\nCan you take another please?""\\n""Nope""|""I( sure)? hope your maze-solving skills are better than your photography skills (ha){2,5}""|The picture is all burnt but you don't care, it's their problem for being fire-nation\.") + "\n\nEventually someone says: ""Let's get some ice cream, it's really hot today"".\nAnd they go away."; ...
            "In an orchard, you see a long haired dude,\nsitting in the shade of an apple tree. There,\nunder the sun, that man will have one simple idea\nthat will change the world forever. You kinda hope\nanother apple will fall on his head, maybe that way\nhe'll get an idea how to help you out of here..."; ...
            "The sound of some_religion_building_gathering is sounding.\nI guess it's noon o'clock!"; ...
            "All the other kids are still at school,\nAnd you're here, in this maze...\nMaybe they learned alchemy today,\nIf only you didn't skip school, maybe\nyou would have known how to turn the walls of this maze into air,\nor turn stones into living things. Maybe one of the creatures you would've\ncreated could've shown you the way out of here... If only you could turn\nstone into living things, you could have helped your troll-uncle Mario,\nwho turned to stone this morning. Wouldn't help his nose though, it chafed\noff on the sidewalk completely.\nIf only you didn't pull that shoe from under him...\nIf only you didn't drink and sing all night...\nIf only you didn't skip school...\nGuess the hangover is over, but the headache only got worse.\nMakes sense, it's noon already"; ...
            "Even though the sun is at its zenith,\nthe folders still have a shadow about them.\nThat's because the folders themselves are but shadows...\nSomething to think about"]);
    elseif hr > 13 && hr <= 17
        curios(max_curios-5).thing = (["Suddenly, I see a person walking in my maze.\nGood afternoon, person. How are you?\nI hope you don't stay for too long, if you know what I mean...\n""I don't believe you"", you say boldly.\n\nBut I speak the truth!\nAllow me to demonstrate:\nFirstly, you should consider perhaps that you simply don't know what I mean...\nAdditionally, you are indeed a person. Lastly, it's always good somewhere,\nand any time is after some noon (and in fact, all noons before last noon),\nhence ""good afternoon"" is almost a tautology!\n\n""I wasn't talking to you"", you say.\n\nOh.\nThen:\nWho  w e r e  you talking to?\n\n""Well, there's always someone you don't believe, and even if there isn't,\nthen by default it is not the case that you believe them, so basically I was\ntalking to whomever""\n\ntouché"; ...
            "You're counting the hours till the end of your shift.\nHope your boss doesn't walk in...\n\n\nYour boss walks in.\n""I told you to get me these documents TODAY!""\n""Shouldn't have put them inside a MAZE then!...""\n...Is what you wanted to say; but it's the boss, you know...\nso you say ""yes, boss"", like a well-trained dog.\nGotta hit the folders again, it's just a little longer.\n\nSoon the revolution will come."; ...
            "The bell rang, and all the kids went out of class. School is over for today.\nYou see a kid wandering around. ""Hey kid, could you please tell me how to turn\nmy uncle from stone to a troll again?""\n""I don't know, look it up on the internet! Besides, I'm done answering questions\nfor the day. Time to go home, and ask some!""\n""What's the 'internet'?"", You inquire, baffled.\n\nMaybe it will be added in a later version."; ...
            """Come, dear!, It's time for dinner!"" Said the mother witch.\n""What are we having?"", Said the daughter witch.\n""Caramelized lazy-kid"". Answered the mother, already a bit annoyed.\n""I don't wanna eat!"". \n\nOh, you've got to be kidding me...\n\n""Come, now, I made you your fa-vo-ri-te!"". Sang the mother weirdly.\n""Don't wanna! My tummy hurts!"".\nYesterday afternoon they had a Hanselburger at Gretel's. Maybe that's why.\nUgh, just -\nDon't have kids."; ...
            "You should be spending your afternoon on more productive things"]);
    elseif hr > 17 && hr <= 21
        curios(max_curios-5).thing = (["It's always lightest\nJust before sunset."; ...
            "'Buona sera, Bonasera, what have I ever done to make you treat me so disrespectfully?\nIf you'd come to me in friendship, this scum who ruined your daughter would be\nsuffering this very day. And if by some chance an honest man like yourself made\nenemies they would become my enemies. And then, they would fear you.'\n\n'Be my friend... MAZEfather.'"; ...
            "Dog News - is chocolate actually BAD for you?\nAnd coming right up - our evening show ""who's a good\nstar and celebrity? - let's find out!"""; ...
            "Same old evening,\nThe colourless sunset glimmering upon the grove.\nAs ancient trees dance slowly in the winds of yore.\nA quiet feeling of tranquil expectation,\nLike a swan afloat among wings galore,\n""Will we ever return home?"" Their song goes;\nTheir tears falling...\nFalling...\nHigh up above.\n\nTypical Monday"; ...
            "The time hath come, my brothers and sisters!\nThe prophecy shall be fulfilled!\n\n""MARK THESE WORDS, FOR THEY ARE TRUE\nIT IS I, SOME_GOD, WHO HATH SPOKEN THESE WORDS\nAND AS SOME_GOD I KNOW SOME_THINGS\nAND INFACT, ALL THINGS!\nAND SO, YOU CAN REALLY BELIEVE ME WHEN I TELL YOU THAT IT'S\nME SAYING THOSE WORDS AND NOT JUST SOME DUDE TELLING YOU THAT\nIT'S ME WHEN REALLY IT'S NOT CAUSE I WOULD KNOW OKAY?\nANYWAY, I SHALL RETURN TO PUT YOU ALL IN YOUR PROPER FOLDERS\nAS THE LAST LIGHT OF SOME_PROPHETS' DAY\nLINES UP GOOD WITH MY STONE TEMPLE OR SOMETHING!""\n\nAnd so, this evening, ladies and gentmenmen,\nas our calculations have foreseen, the light of the setting sun\nshall shine upon some_god's temple in a VERY lined-up fashion!\n\nAll that is left is a proper sacrifice!\n\n\n\nYou!\n\n""me?"" you ask, shocked\n\nYes! You have been chosen.\nBlessed be the Chosen!\n\nAll, in unison:\n*BLESSED BE THE CHOSEN*\n\nHeed me now! as we give this one's blood freely, may some_god\nreturn to us at the same time for some_reason!\n\n\n... You see the light of sunset drawing near, as the sacrificial knife draws to your throat...\nYou think:\n""The Last Light does shine on the temple in a most lined-up way!\nOh, some_god! is this really gonna be my last thought?...""\n\nThe crowd cheers as your mind races. You try thinking up some_thought\nthat will be better than your previous one and then - \n\n""Did the temple just move?""\n\nThe crowd is in awe... everyone looks to the temple's round door.\nThe door, which has been sealed since some_god left for some_reason.\nIt MOVED!\nWill he return?\nAs the big stone door starts turning, gasps are heard everywhere;\neven the speaker is too shocked to slice your throat.\n\n""Maybe I'm saved"", you think, looking at the near-open door;\nthe light upon it weirdly changing colour,\ndancing,\nbecoming almost alive...\n\n""Well, thank some_god that stone door moved when the light hit it, cause I don't know wh--"".\n\nWait, is that UNCLE MARIO?"]);
    end
    [curios(max_curios-9:max_curios-5).flavor] = curios(max_curios-5).thing{:};
    %
    l = length(curios);
    howmany_curios = min(howmany_curios, l);
    curios_cell = {curios(randperm(l, howmany_curios)).flavor};
    not_win_ind = 1:f_idx-1;
    not_win_ind(not_win_ind == win_ind) = [];
    maze_inds = not_win_ind(randperm(numel(not_win_ind), howmany_curios));

    for ii = 1:howmany_curios
        my_ = what(folder_list_cell{maze_inds(ii)});
        my_file = fullfile(my_.path, regexgen('(Wow!|something\.{3}|Hey|hmmm\.{3}|cool|here|surprise|you gotta see this|a message|something random|README)\.txt'));
        fid = fopen(my_file, 'wt');
        fprintf(fid, curios_cell{ii});
        close_res = fclose(fid);
        if close_res
            error('file not closed proper')
        end
    end
end

%% Poems
Poems = [...
    "A poet should be of the\n\t old-fahioned meaningless brand:\nobscure, esoteric, symbolic, --\n\t the critics demand it;\nso if there's a poem of mine\n\t that you do understand\nI'll gladly explain what it means\n\t till you don't understand it."; ...
    "Shun advice\nat any price -\nthat's what I call\ngood advice"; ...
    "The road to wisdom?—Well, it's plain\nand simple to express:\n\tErr\n\tand err\n\tand err again,\n\tbut less\n\tand less\n\tand less.";...
    regexgen('He that lets the small things bind him leaves the great undone (behind|before) him\.|She that lets the small things bind her leaves the great undone (behind|before) her\.');...
    "Those who always\nknow what's best\nare\na universal pest.";...
    "There's an art of knowing when.\nNever try to guess.\nToast until it smokes and then\ntwenty seconds less.";...
    "When you feel how depressingly\nslowly you climb,\nit's well to remember that\n\tThings Take Time.";...
    "Whenever you're called on to make up your mind,\nand you're hampered by not having any,\nthe best way to solve the dilemma, you'll find,\nis simply by spinning a penny.\nNo - not so that chance shall decide the affair\nwhile you're passively standing there moping;\nbut the moment the penny is up in the air,\nyou suddenly know what you're hoping";...
    "Let the world pass in its time-ridden race;\n\tnever get caught in its snare.\nRemember, the only acceptable case\nfor being in any particular place\n\tis having no business there.";...
    "Losing one glove\nis certainly painful,\nbut nothing\n\tcompared to the pain,\nof losing one,\nthrowing away the other,\nand finding\n\tthe first one again.";...
    "I am trying to rule\n\t over ten thousand things\nwhich I thought\n\t belonged to me.\nAll of a sudden\n\t a doubt take wings:\nDo they...\n\t or could it be..? \n\nA hardhanded hunch\n\t in my mind's ear rings\nfrom whence\n\t such suspicions may stem:\nthat if you posses\n\t more than just eight things\nthen y o u\n\t are possessed by t h e m.";...
    "LOOK AND THOU SHALT FIND \nFoes \nof what's cooking \nsee no worth behind it. \nThose \nthat are looking \nfor nothing - will find it. ";...
    "Nobody can be lucky all the time;\ndon't think you've been abandoned in your prime,\nbut rather that you're saving up your ration.";...
    "If a nasty jagged stone\ngets into your shoe,\nthank the Lord it came alone --\nwhat if it were two?";...
    "The heavens are draining,\nit's raining and raining,\nand everything couldn't be wetter,\nand things are so bad\nthat we ought to be glad:\nbecause now they can only get better.";...
    "The universe may be as great as they say.\nBut it wouldn't be missed if it didn't exist.";...
    "It ought to be plain\nhow little you gain\nby getting excited\nand vexed.\n\nYou'll always be late\nfor the previous train,\nand always in time\nfor the next";...
    "Read this to yourself. Read it silently.\nDon't move your lips. Don't make a sound.\nListen to yourself. Listen without hearing anything.\nWhat a wonderfully weird thing, huh?\n\nNOW MAKE THIS PART LOUD!\nSCREAM IT IN YOUR MIND!\nDROWN EVERYTHING OUT.\nNow, hear a whisper. A tiny whisper.\n\nNow, read this next line with your best crotchety-\n\told-man voice:\n""Hello there, sonny. Does your town\nhave a post office?""\nAwesome! Who was that? Whose voice was that?\nIt sure wasn't yours!\n\nHow do you do that?\nHow?!\nMust be magic.";...
    "When too many errands accrue\nit's useful to make out a list.\nYou're certain to lose it, it's true;\nbut somewhere, the thing will exist.\nAnd then, when some accident brings\nthe list you have lost into view,\nat least you've a list of the things\nyou've meanwhile forgotten to do.";...
    "Down from my attic room I swerve\nin one smooth, spiral, clockwise curve.\n\nThe staircase happens to be wound,\nI'm glad to say, the same way round:\n\nfor if it happened not to be,\nit couldn't keep in step with me.";...
    "To start in a hurry\nand finish in haste\nwill minimize worry\nand maximize waste.";...
    "As for art,\n\twhat can a halfway-honest man do\nto distinguish things that are\n\tfrom things that aren't?\nFor there's little art\n\tin doing what one can do,\nand there's none at all\n\tin doing what one can't";...
    "A MAXIM FOR VIKINGS \nHere is a fact \nthat should help you fight \na bit longer: \nThings that don't act- \nually kill you outright \nmake you stronger.";...
    ];
poem_chance = 0.1;
maze_inds = deepest_inds(deepest_inds~=win_ind).';
for ii = maze_inds
    if rand >= poem_chance
        continue
    end
    my_ = what(folder_list_cell{ii});
    my_file = fullfile(my_.path, regexgen('(Words for our times|a Poem|Consolation|the artistic bit of (our|my|MAZE''s) show|Poem#\d[1-9])\.txt'));
    choice = randi(length(Poems));
    fid = fopen(my_file, 'wt');
    fprintf(fid, Poems(choice));
    Poems(choice) = [];
    if isempty(Poems)
        break
    end
end
%% hints - no hints if 3 levels or less!
for a = 1
if levels > 3
%% hints - no hints if 3 levels or less!
%% 1. the excel crap - on level 2 or 3
% generate two random places one for the txtnote and one for the excel &
% riddle. both are on level 2.
my_level = 2;
maze_inds = find(folder_lengths == length(alwaysname)+my_level);
right_way = str2double(win_folder(length(alwaysname)+1:length(alwaysname)+my_level));
expression = sprintf('(?<!\\d)(\\d{%d})$', my_level);
possible_right_way = regexp(folder_list_cell, expression, 'match');
possible_right_way(cellfun(@isempty, possible_right_way)) = [];
possible_right_way = cellfun(@str2double, possible_right_way);
l = length(possible_right_way);
if l <= 1
    break
end
choice = folder_list_cell(maze_inds(randperm(length(maze_inds), 2)));
count_sins = str2double(regexp(choice{2}, '(?<!\d)(\d+)$', 'match'));
pretty_nums = [4,5; 5,6; 6,7; 8,9; 10,12; 14,15; 16,18; 18,20; 20,21];
ii = find(prod(pretty_nums, 2) > (count_sins+length(possible_right_way)), 1);
ex_size = pretty_nums(randi([ii, ii+1]), :);
cell2excel = cell(ex_size);
maze_inds = randperm(prod(ex_size));
sins = cellstr(regexgen('(\D){5,12}', count_sins));
leave_empty = randi(prod(ex_size)-count_sins-l);
if leave_empty == (prod(ex_size)-count_sins-l)
    blessings = num2cell(possible_right_way);
else
    blessings = num2cell([possible_right_way; randi([10^(my_level-1), 10^(my_level)-1], (prod(ex_size)-count_sins-length(possible_right_way)-leave_empty), 1)]);
end
[cell2excel{maze_inds(1:count_sins)}] = sins{:};
blessed_inds = maze_inds(count_sins+1:count_sins+length(blessings));
[cell2excel{blessed_inds}] = blessings{:};

my_ = what(choice{1});
my_file = fullfile(my_.path, 'Hint1.txt');
fid = fopen(my_file, 'wt');
fprintf(fid, "Count the sins and they shall tell you where to go,\nCount the blessings and they shall tell you where to look,\nUpon your return, you shall but look, tell, and go." + regexgen('(\\n){50}You see two types of data here\.\\nwhich is the "sins" and which the "blessings"\?\\nOne of the numbers in this data represents the first 2 digits in the right path\.'));
my_file = fullfile(my_.path, 'important data.xlsx');
writecell(cell2excel, my_file, "WriteMode","overwritesheet");
close_res = fclose(fid);
if close_res
    error('file not closed proper')
end

cell2excel = zeros(ex_size);
ii = l:(l+prod(ex_size)-count_sins-1);
help_var = find(possible_right_way == right_way, 1) - find(ii == length(blessings), 1);
ii = circshift(ii, help_var);
cell2excel(maze_inds(count_sins+1:end)) = ii;

my_ = what(choice{2});
my_file = fullfile(my_.path, 'more important data.xlsx');
writematrix(cell2excel, my_file, "WriteMode","overwritesheet");
%% 2. the dying lying man
% a dying lying dude sends you on a treasure hunt 2 levels below him. 1
% level below you find the treasure's owner...
if levels > 4
    my_level = my_level + 1;
    maze_inds = find(folder_lengths == length(alwaysname)+my_level);
    right_way = win_folder(length(alwaysname)+1:length(alwaysname)+my_level);
    for ii = 1:length(maze_inds)
        if strcmp(folder_list_cell{maze_inds(ii)}(length(alwaysname)+1:length(alwaysname)+my_level), right_way)
            maze_inds(ii) = [];
            break
        end
    end
    for ii = 1:100
        choice(3) = folder_list_cell(maze_inds(randi(length(maze_inds)))); % the dying
        possible_right_way = folder_list_cell(contains(folder_list_cell, choice{3}) & folder_lengths == (levels+length(alwaysname)));
        try
            choice(2) = possible_right_way(randi(length(possible_right_way))); % the treasure
            help_var = folder_list_cell(contains(folder_list_cell, choice{3}) & folder_lengths == length(alwaysname)+my_level+1 & ~contains(folder_list_cell, choice{2}(1:(length(alwaysname)+my_level+1))));
            choice(1) = help_var(randi(length(help_var))); % the owner
        catch
            continue
        end
        break
    end
    if ii == 100
        my_level = my_level - 1;
    else
        expression = strsplit(regexgen("(locked )?;(box|(treasure )?chest|Bag)"), ';');
        s = strings(2, 3);
        if isempty(char(expression(1)))
            s(1, 1) = "";
        else
            s(1, 1) = regexgen(', using your (cunning )?lockpicking skills you picked up (in highschool|in the hood|at uni)');
        end
        l = win_folder(length(alwaysname)+my_level)-'0';
        l(2) = randi([0, l-1]);
        l(1) = l(1)-l(2);
        if l(1) == 1
            s(2) = "is";
            s(3) = "";
        else
            s(2) = "are";
            s(3) = "s";
        end
        my_food = regexgen("pasta|pizza|falafel|amburger|schnitzel|food(ies)?");
        if l(2) == 1
            count_sins = sprintf("I have me 1 more coin in me purse, so I am goin' to get me some %s!", my_food);
        elseif l(2) == 0
            count_sins = sprintf("I have me 0 coins in me purse, so I am goin' to get me free %s!", my_food);
        else
            count_sins = sprintf("I have me %d more coins in me purse, so I am goin' to buy me some %s!", l(2), my_food);
        end
        
        help_var = [regexgen("An armed (wo)?man"), sprintf("""Dat fool thot he coud tek me treja!\nWell I proovd 'im wrong, now hasn't I?\nAkchuly, damn thief did done take it. almost lost 'em for a while...\nbut ON THE PLUS SIDE I know where it is, so it's all gud now...\n\nADDITIONally, %s\n\n\nHey, yu! I see you! Got a suspicious lookin' face... 'll be keepin' an eye on yu...\ndon't you try anyting funny or I'll peel you like a banana!\nYou tell anyone stupid enouf to enter dis maze: my treja here IS GARDED!\nYou can admire it if you like, though.""", count_sins);...
            "A "+expression(1)+expression(2), sprintf("You found a %s%s.\nAfter looking around cautiously, you approach it.\nThen, seeing that it's safe (probably), you open the %s%s...\n\nYou look inside, and -\n\nWhat?! there %s only %d gold coin%s in there!\nWorthless!\nDisappointed, you walk away.\n\nOh, wait! A mysterious writing appears on the %s. It says:\n""To know two is to know three. The right amount shall set you free""\n\nWhat's with all those riddles?? meh.", expression(1), expression(2), expression(2), s(1), s(2), l(1), s(3), expression(2));...
            regexgen("A dying (wo)?man"), """It's OK! I feel fine!\nJust get outta here, nothin' to see!\n\n\n\n\n\nYou still here? Alright, There! you see that folder? (*points vaguely*)\nThat's the way out of this maze... yea, *cough* definitely.\nJust check all the folders, he-he-he, you'll be fine!\nOh, *cough*... and did I mention there's no treasure down there whatsoever by the way?\nYep, just the way out...\nThe way out...\nThe....\n\nWay...\n\n\nOut..\n\n.""\n\n*dies*";...
            "Hint2", "BELIEVE NO ONE\n\nIt is the liars you should trust,\nFor you can always know they lie.\nAnd if to find belief you must -\nBelieve you shouldn't try." + regexgen('(\\n){50}You can tell one of the winning folder''s digits, if you can find all 3 parts of this\\nhint \(not including this file\) in this folder-branch, and solve the treasure riddle\.\\n\\nFinding the 1st hint is recommended, as it will help you know two of the winning digits\.')];
        for ii = 1:3
            my_ = what(choice{ii});
            my_file = fullfile(my_.path, help_var(ii, 1)+".txt");
            fid = fopen(my_file, 'wt');
            fprintf(fid, help_var(ii, 2));
        end
        my_file = fullfile(my_.path, help_var(4, 1)+".txt");
        fid = fopen(my_file, 'wt');
        fprintf(fid, help_var(4, 2));
    end
end
%% hints - no hints if 3 levels or less!

%% hints - no hints if 3 levels or less!
fid = fopen([my_matlab_dir, filesep, 'help.txt'], 'wt');
fprintf(fid, "MAZE is %d folders wide and %d folders deep.\nIt has %d hints on levels: ", maxwidth, levels, my_level-1);
if my_level > 3
    fprintf(fid, '%d, ', 2:my_level-2);
end
fprintf(fid, '%d and %d.', my_level-1, my_level);
fprintf(fid, '\n\nIf hint riddles are too hard, try scrolling down for a hint on the hint!');
close_res = fclose("all");
if close_res
    error("File not closed proper, after all")
end
end
end
%% hints - no hints if 3 levels or less!
rmpath(genpath('MAZE'));
final_msg = regexgen('Good luck!|Don''t cheat\.\.\. :\)|Hope you enjoy!|Get Going!|Break a leg!|Have fun!|Ciao!|Enjoy!|Winning folder is \d\. Haha just kidding!|Tell me how you liked it :\)|Contact me if there''s a bug!');
msgbox(sprintf('Find MAZE in %s\n\n%s', my_matlab_dir, final_msg), 'Done!');
clear; clc;
function randmaze(my_dir, dir_name, max, levels, og_levels)
global folder_list_cell f_idx
if ~exist('og_levels', 'var')
    og_levels = levels;
end
chance_end = rand <= ((og_levels-levels)/og_levels);
if chance_end || levels == 0
    return
end
dir_name(end+1) = ' ';
s = filesep;
for ii = 1:max
    dir_name(end) = char(ii + '0');
    if ~isfolder([my_dir, s, dir_name])
        mkdir(my_dir, dir_name);
        folder_list_cell{f_idx} = dir_name;
        f_idx = f_idx + 1;
        break
    end
end
my_dir = [my_dir, s, dir_name];

for ii = 1:max
    randmaze(my_dir, dir_name, max, levels-1, og_levels);
end
end