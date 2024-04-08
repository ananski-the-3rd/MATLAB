function path = collatz(num, oddadd, oddtimes)
arguments
    num double {mustBeInteger}
    oddadd {mustBeInteger} = 1
    oddtimes {mustBeInteger} = 3
end

try mustBeInteger(0.5*(oddadd+1));
catch
    error('Odd explosive loop detected');
end

path = zeros(1, 1e4);
i = 0;
num_t = num;
while 1
    i = i + 1;
    path(i) = num_t;

    if mod(num_t,2)
        num_t = num_t * oddtimes + oddadd;
    else
        num_t = num_t * 0.5;
    end

    if ismember(num_t,path)
        if ~num_t
            path = path(1:i+2);
        else
            path(i+1) = num_t;
            path = path(1:i+1);
        end
        return
    end

    if path(end) || num_t > 1e300
        error('collatz(%d %d %d) has exploded!',num, oddadd, oddtimes);
    end
end
end
