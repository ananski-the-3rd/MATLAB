secret_number = input('What is nice number? ');
while secret_number ~= 69
    fprintf('%d is not nice!\ntry again, ', secret_number)
    secret_number = input('What is nice number? ');
end
a = char([secret_number-13, linspace(secret_number-8,secret_number-8,secret_number),secret_number-1]);
disp(a);

%I hate myself