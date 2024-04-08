%Generate_our_next_exam
% a = '(?>superior |inferior |anterior |posterior |middle |median |medial |lateral |ventral |dorsal |inter-|mid-|post-)';
% b = '(?:((qu[aeio]|(((sh?)?[klmnpt]|(?=[a-v])[^aeiouhq])[aeiou]))([mnr][ptckgbd]|(?=[a-vz])[^aeiouhq])([aeiou]([mnlr][ptckgbd]|(?=[a-tz])[^aeioukhq]))?)|(?:((sh?)[klmnpt]|(?=[a-tz])[^aeiouhq])[aeio]([mnlr][pktb]|(?=[a-tz])[^aeiouhq])([aeiou]([mnlr][ptkc]|(?=[a-tz])[^aeioukh]))?)|(?:((?=[a-vz])[^aeiouhq])[aeiou]([mnlr][pktb]|(?=[a-tz])[^aeiouhq])([aeiou]([mnlr][ptkc]|(?=[a-vz])[^aeioukhq]))?)|(([kbtpzs])[aeiou]\2|(ae|eu|[aei])(th|(?=[a-vz])[^aeiouhq]))(([aeiou](?=[a-vz])[^aeioukhq])?)?)';
% c = '(?>ullary |ular |oidal |(o?)?us |ulate |illae )';
% d = '(?>peduncles|gyrus|sulcus|eminence|foramen|fossa|nucleus|ganglion|funiculus|nerve|funiculus)';

randword = regexpgen('', 10);

% fprintf(fopen('Next_Exam.txt', 'w'), '\n%s\n', randword);
% fprintf('\n%s\n', randword);
