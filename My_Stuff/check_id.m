function res = check_id(varargin)
%CHECK_ID checks ID's for errors
l = length(varargin);
res = cell(l, 1);

for ii = 1:length(varargin)
    ID = varargin{ii};

    if iscell(ID)
        res{ii} = check_id(ID{:});
    else
        ID = string(ID);
        res{ii} = false(numel(ID), 1);
        for jj = 1:numel(ID)
            if ismissing(ID(jj))
                res{ii}(jj) = false;
                continue
            end
            numdigits = length(ID{jj});
            if numdigits == 9 || (numdigits < 9 && numdigits > 6 && ID{jj}(1) ~= '0')
                temp = '000000000';
                temp(end-numdigits+1:end) = ID{jj};
                id_sum = sum(temp(1:2:end)-'0') + sum(rem((temp(2:2:end)-'0').*2-1, 9)+1);
                res{ii}(jj) = floor(id_sum./10) == id_sum./10;
            else
                res{ii}(jj) = false;
            end
        end
    end
end

siz = cellfun(@size, res, 'UniformOutput', false);
siz = vertcat(siz{:});
if size(siz, 1) == 1
    res = [res{:}];
else
    d = siz(2:end, 1) - siz(1:end-1, 1);
    if ~any(d(:)) && ~any(cellfun(@iscell, res))
        res = [res{:}];
    end
end

end