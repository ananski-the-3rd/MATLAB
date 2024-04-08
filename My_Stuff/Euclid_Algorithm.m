A = input('Input first number: ');
B = input('Input second number: ');
C = B;
D = min(mod(A,C),mod(C,A));

while D==0||C==0
    C = mod(C,D);
    D = mod(D,C);
end
fprintf("The greatest common divisor of %d and %d is:\n\n %d\n",A, B, max(C,D));
