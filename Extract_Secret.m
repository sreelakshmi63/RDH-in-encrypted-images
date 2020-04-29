%Prepare Workspace
clear;clc;close all
%%
Mosaic=imread('Mosaic.png');
n=4;
[M,N,ch]=size(Mosaic);
numberOfblocks=M*N/n^2;
Mosaic=double(Mosaic(:));
len_ld=Mosaic(end);
for i=len_ld:-1:1
   ld(i)=num2str(Mosaic(end-i));
end
ld=str2double(ld);
dat=rem(Mosaic,4);
dat=dat(1:ld);
dat=de2bi(dat,2);
data=dat(:);
% Decryption
Key=input('Enter Key =  ');
rng(Key);
K=randi([0,1],size(data,1),size(data,2));
data=bitxor(data,K);


dec=bi2de(reshape(data,length(data)/8,8))';
muR1=dec(1:numberOfblocks);
muG1=dec(numberOfblocks+1:2*numberOfblocks);
muB1=dec(2*numberOfblocks+1:3*numberOfblocks);
muR=dec(3*numberOfblocks+1:4*numberOfblocks);
muG=dec(4*numberOfblocks+1:5*numberOfblocks);
muB=dec(5*numberOfblocks+1:6*numberOfblocks);
avgstd=dec(6*numberOfblocks+1:7*numberOfblocks);
avgstd1=dec(7*numberOfblocks+1:8*numberOfblocks);
[val1,tileindx]=sort(avgstd);
[val2,targetindx]=sort(avgstd1);
%%
Mosaic=reshape(Mosaic,[M,N,3]);
k=1;
for i=1:n:M
    for j=1:n:N
        ntile{k}=Mosaic(i:i+n-1,j:j+n-1,:);
        k=k+1;
    end
end
%secret Image Extraction
ntile=ntile(targetindx);
for k=1:numberOfblocks
    ci=ntile{k};
  
   nci(:,:,1)=(ci(:,:,1)-muR1(k))+muR(k);
   nci(:,:,2)=(ci(:,:,2)-muG1(k))+muG(k);
   nci(:,:,3)=(ci(:,:,3)-muB1(k))+muB(k);
   ntile3{k}=nci;
end
ntile3(tileindx)=ntile3;
k=1;
for i=1:n:M
    for j=1:n:N
       RI(i:i+n-1,j:j+n-1,:)=ntile3{k};
        k=k+1;
    end
end
figure,imshow(uint8(RI));
title('Retrieved Secret')
