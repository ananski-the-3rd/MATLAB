% Langton's ant 2 or 3-D
dims = 2;
b_size = 200-1;
board = zeros(repmat(b_size, 1, dims), 'uint8');

close all
f = figure(); set(f, 'windowstyle', 'docked')
%% rotations and image
if dims == 2
    % rot
    rotx = @(t) [0,t;-t,0];
    ori = [-1,0];
    % image
    H = imagesc(255-board);
    H.CDataMapping = 'direct';
    colormap bone
elseif dims == 3
    %rot
    ori = [-1,0,0;0,1,0;0,0,1];
    directions = 'xyz';
    % image
end

%%



%for 3d plot with one arrray?

%% ant setup
ant_place = num2cell(repmat(0.5*(b_size+1), 1, dims));
ant_direction = ori(1,:);
%% setup is done!
while 1

    board(ant_place{:}) = mod(board(ant_place{:}), dims*2-2)+1;
    ant_place = num2cell([ant_place{:}] + ant_direction);
    try
        which_turn = board(ant_place{:});
    catch
        disp('ant is out of bounds')
        return
    end
    if dims == 2
        switch which_turn
            case 1
                ant_direction = ant_direction*rotx(1);
            otherwise
                ant_direction = ant_direction*rotx(-1);
        end
        set(H, 'CData', 255-(255./(dims*2-2))*board);
        drawnow
    elseif dims == 3
        switch which_turn
            case 1
                ori = ori*rotz(-1); % preserve back direction
            case 2
                ori = ori*roty(-1); % preserve righthand direction
            case 3
                ori = ori*roty(1); % preserve righthand direction
            otherwise
                ori = ori*rotz(1); % preserve back direction
        end
        ant_direction = ori(1,:);
    end


end

function mat = rotant3d(deg, axi)
switch axi
    case 'x'
        mat = [1 0 0; 0 0 -deg ; 0 deg 0];
    case 'y'
        mat = [0 0 deg ; 0 1 0 ; -deg 0  0];
    case 'z'
        mat = [0 -deg 0 ; deg 0 0 ; 0 0 1];
end


end