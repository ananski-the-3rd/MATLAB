% function PR = derive(UR,rules)
%DERIVE Summary of this function goes here
%   Detailed explanation goes here
all_ipa_chars = 'aɑæɐbβɓʙcçɕdðɖɗeəɚɵɘɛɜɝɞgɠɢʛhħɦɥɧʜiɪɨjʝɟʄlɫɭɬʟɮmɱnŋɲɳɴoɔœɒɔɶøpɸqrɾɹʀʁɻɽɺsʃʂtθʈuʊʉvʌʋⱱwɯʍɰxχyɣʎʏɤzʒʐʑʔʕʢʡ∅→ˈˌ͜͡ː̆ʰʲʷ̩̯̥̬̪̺̝̞̟̠̃̈̚˩˨˧˦˥˥˩˩˥˩˨˦˥˧˦˧ˑ‿ˤˀᵝᵊʱˡⁿʳᵗˠʼǀǁǂǃʘ̴̹̜̤̰̼̘̙̻̏̀̄́̋̂̌᷅᷄᷈˞̑̊̽ꜜꜛ↘︎↗︎·';

UR = 'hala:l + hatin + i:n';
rules = ["";"0->V/C__C{#,C}";"";"C->0/CC+__";"";""];

% end