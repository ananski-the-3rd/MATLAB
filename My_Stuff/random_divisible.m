rnd1 = 0;
check1 = 0;
anan = 0;
     
while check1 == 0 % keep searching until check1~=0 (11 xor 13 is a factor)
rnd1 = 2*randi([50,500])+1; % random odd number from 101 to 1001
check1 = xor(mod(rnd1,11),mod(rnd1,13)); % is 11 xor 13 a factor
anan = anan+1;
end

fctrz = factor(rnd1);
msgbox(sprintf('The number of iterations it took was %d and the number is %d',anan,rnd1),'Finished');