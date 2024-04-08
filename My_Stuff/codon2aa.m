function [amino_acid, amn, a, anti_codon] = codon2aa(codon)
%CODON2AA get amino acid from codon according to human genetic code.    
%   [AMINO_ACID, AMN, A] = CODON2AA(CODON) returns the AMINO_ACID that
%   would normally be attached to a tRNA molecule with an anti-codon that
%   matches CODON. the function first calculates the anti codon by A-U, C-G
%   matching, then returns the matching amino acid in full name, 3 letter,
%   and 1 letter name.
%   Codon can include an entire code as well.

codon = upper(convertStringsToChars(codon));
codon = codon(:);
codon(codon == 'T') = 'U';
l = length(codon);
aucg = repmat('AUCG', l, 1);
uagc = aucg(:, [2,1,4,3]).';
anti_codon = uagc((aucg == codon).').';
if length(anti_codon) ~= l
    error('Codon contains non-nucleotide letters. Stick with A, T, C, U and G only!')
end

codes = {'CG[UCAG]|AG[AG]'; 'CA[UC]'; 'AA[AG]'; 'GA[UC]'; 'GA[AG]'; 'UC[UCAG]|AG[UC]'; 'AC[UCAG]'; 'AA[UC]'; 'CA[AG]'; 'UG[UC]'; 'GG[UCAG]'; 'CC[UCAG]'; 'GC[UCAG]'; 'AU[UCA]'; 'UU[AG]|CU[UCAG]'; 'AUG'; 'UU[UC]'; 'UGG'; 'UA[UC]'; 'GU[UCAG]'; 'UA[AG]|UGA'};
long_names = ["Arginine"; "Histidine"; "Lysine"; "Aspartic Acid"; "Glutamic Acid"; "Serine"; "Threonine"; "Asparagine"; "Glutamine"; "Cysteine"; "Glycine"; "Proline"; "Alanine"; "Isoleucine"; "Leucine"; "Methionine"; "Phenylalanine"; "Tryptophan"; "Tyrosine"; "Valine"];
short_names = ['Arg';'His';'Lys';'Asp';'Glu';'Ser';'Thr';'Asn';'Gln';'Cys';'Gly';'Pro';'Ala';'Ile';'Leu';'Met';'Phe';'Trp';'Tyr';'Val'];
letter = ['R';'H';'K';'D';'E';'S';'T';'N';'Q';'C';'G';'P';'A';'I';'L';'M';'F';'W';'Y';'V'];

ldev3 = l/3;
if mod(ldev3, 1)
    ldev3 = ceil(ldev3);
    not3 = true;
else
    not3 = false;
end

amino_acid = strings(1, ldev3);
amn = repmat(' ', ldev3, 3);
a = blanks(ldev3);
len = length(codes);

for i = 1:ldev3 - not3
    for j = 1:len
        idxs = i*3-2:i*3;
        if ~isempty(regexp(anti_codon(idxs), ['^',codes{j},'$'], 'once'))
            if j == len
                amino_acid = amino_acid(1:i-1);
                amn = amn(1:i-1, :);
                a = a(1:i-1);
                if not3
                    amino_acid(end) = missing;
                    amn(end, :) = 'NaN';
                    a(end) = '0';
                end
                return
            else
                amino_acid(i) = long_names(j);
                amn(i, :) = short_names(j, :);
                a(i) = letter(j);
                break
            end
        end
        if j == len
            amino_acid(end) = missing;
            amn(end, :) = 'NaN';
            a(end) = '0';
        end
    end
    
end
if not3
    amino_acid(end) = missing;
    amn(end, :) = 'NaN';
    a(end) = '0';
end





end