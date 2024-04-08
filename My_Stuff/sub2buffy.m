folder_name = 'C:\Users\anan_\Videos\movies\Buffy';

list = strsplit(genpath(folder_name), ';');
list(1) = [];
all_sub_files = [];
for ii = 1:length(list)
    S = dir(list{ii});
    issubs = string({S(contains({S.name}, '.srt')).name});
    all_sub_files = [all_sub_files, issubs];
end

%%
S_E = 'S01E01';
my_file = all_sub_files(contains(all_sub_files, S_E));