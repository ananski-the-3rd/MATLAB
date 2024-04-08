function output = arraypat(array, pat)
% This function searches for an n-dimentional pattern in a k-dimentional array.

%% DEBUG
% deb_maxdims = [8, 8];
% deb_arraylens = [10, 15];
% deb_patlen = [2, 3];
% debug_dims = randi(deb_maxdims);
% if debug_dims == 1
%     debug_no = randi(deb_arraylens);
%     array = randi([0, 2], debug_no, 1);
%     pat = randi([0, 1], randi(deb_patlen), 1);
% else
%     debug_cell = num2cell(randi(deb_arraylens, 1, debug_dims));
%     array = randi([0, 2], debug_cell{:});
%     debug_dims = randi([3, 4]);
%     if debug_dims == 1
%         pat = randi([0, 1], randi(deb_patlen), 1);
%     else
%         debug_cell = num2cell(randi(deb_patlen, 1, debug_dims));
%         pat = randi([0, 1], debug_cell{:});
%     end
% end
% clearvars -except array pat
%%
aDims = ndims(array);
pDims = ndims(pat);
if aDims < pDims
    output = [];
    return
end
aSize = size(array);
pSize = ones(1, aDims);
pSize(1:pDims) = size(pat);
ap_lens = aSize-pSize+1;
rangeCell = cell(1, aDims);
for i0 = 1:aDims
    rangeCell{i0} = 1:ap_lens(i0);
end
cut_pat_size_from_array_edges = false(size(array));
cut_pat_size_from_array_edges(rangeCell{:}) = true;
inds = find(cut_pat_size_from_array_edges);
inds = inds(:).';

match = false(1, length(inds));
prodVec1 = cumprod(aSize(1:end-1));
prodVec2 = cumprod(pSize);
first_val = pat(1);
vi = aSize(1);
for ii = inds
    if array(ii) == first_val
        if inSearch(ii, vi, pSize, array, pat, pDims, aDims, prodVec1, prodVec2)
            match(ii) = true;
        end
    end
end

output = find(match);


%% DEBUG
% for jj = 1:length(output)
%         indCell = cell(1, aDims);
%         [indCell{:}] = ind2sub(aSize, output(jj));
%         for i0 = aDims:-1:1
%             my_ind = indCell{i0};
%             rangeCell{i0} = my_ind:my_ind+pSize(i0)-1;
%         end
%         my_part = array(rangeCell{:});
%         if ~isequal(my_part, pat)
%             error('you suck!')
%         end
%         if jj == length(output)
%             disp('noice!')
%         end
% end
%%

    function flag = inSearch(ii, vi, pSize, array, pat, pDims, aDims, prodVec1, prodVec2)
    p_i = 1;
    for cc = ii:vi:ii+vi*(pSize(2)-1)
        for rr = cc:cc+pSize(1)-1
            if array(rr) ~= pat(p_i)
                flag = false;
                return
            end
            p_i = p_i + 1;
        end
    end

    flag = true;
    if pDims < 3
        return
    end
    rr = ii + prodVec1(2);
    while flag
        for cc = 1:pSize(1)
            if array(rr) ~= pat(p_i)
                flag = false;
                return
            end
            rr = rr + 1;
            p_i = p_i + 1;
        end
        if p_i > prodVec2(end)
            return
        end
        vj = p_i;
        for cc = aDims-1:-1:1
            vi = rem(vj-1, prodVec2(cc)) + 1;
            indVec(cc) = (vj - vi)/prodVec2(cc);
            vj = vi;
        end
        rr = ii + dot(prodVec1, indVec);
    end

    end
end