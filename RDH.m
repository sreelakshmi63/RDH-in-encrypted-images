%Prepare Workspace
clear;clc;close all
%% Read Secret and Target images;
S=imread('autumn.jpg');                      %Secret Image
T=imread('fallingwater.jpg');                      %Target Image 
%% Mosaic Image Creation
%Stage 1. fitting the tile images into the target blocks.
M=256;
N=192;
S=imresize(S,[M,N]);
T=imresize(T,[M,N]);
subplot(131),imshow(S);title('Secret Image');
subplot(132),imshow(T);title('Target Image');
%%
% S=double(S);
% T=double(T);
wb=waitbar(0,'please wait.......');
n=4;
[M,N,ch]=size(S);
numberOfblocks=M*N/n^2;

muR=zeros(1,M*N/n^2);
muG=muR;muB=muR;sigmaR=muR;sigmaG=muR;sigmaB=muR; 
muG1=muR;muB1=muR;sigmaR1=muR;muR1=muR;sigmaG1=muR;sigmaB1=muR; 
avgstd=muR;avgstd1=muR;
count=1;
waitbar(0.1);
Stile=cell(1,numberOfblocks);Starget=cell(1,numberOfblocks);
for i=1:n:M
    for j=1:n:N
        tile=S(i:i+n-1,j:j+n-1,:);
        blk=T(i:i+n-1,j:j+n-1,:);
        muR(count)=round(mean2(tile(:,:,1))+eps);
        muG(count)=round(mean2(tile(:,:,2))+eps);
        muB(count)=round(mean2(tile(:,:,3))+eps);  
        muR1(count)=round(mean2(blk(:,:,1))+eps);
        muG1(count)=round(mean2(blk(:,:,2))+eps);
        muB1(count)=round(mean2(blk(:,:,3))+eps);
        sigmaR(count)=round((std2(tile(:,:,1))+eps)*10)/10;
        sigmaG(count)=round((std2(tile(:,:,2))+eps)*10)/10;
        sigmaB(count)=round((std2(tile(:,:,3))+eps)*10)/10;
        sigmaR1(count)=round((std2(blk(:,:,1))+eps)*10)/10;
        sigmaG1(count)=round((std2(blk(:,:,2))+eps)*10)/10;
        sigmaB1(count)=round((std2(blk(:,:,3))+eps)*10)/10;
        avgstd(count)=round((sigmaR(count)+sigmaG(count)+sigmaB(count))/3);
        avgstd1(count)=round((sigmaR1(count)+sigmaG1(count)+sigmaB1(count))/3);
        Stile{count}=tile;Starget{count}=blk;
        count=count+1;
    end
end
waitbar(0.5);
[val1,tileindx]=sort(avgstd);
[val2,targetindx]=sort(avgstd1);
Stile=Stile(tileindx);
Starget=Starget(targetindx);
muR=muR(tileindx); muG=muG(tileindx);muB=muB(tileindx);
muR1=muR1(targetindx); muG1=muG1(targetindx);muB1=muB1(targetindx);
sigmaR=sigmaR(tileindx);sigmaG=sigmaG(tileindx);sigmaB=sigmaB(tileindx);
sigmaB1=sigmaB1(targetindx);sigmaG1=sigmaG1(targetindx);sigmaR1=sigmaR1(targetindx);
waitbar(0.6);
for k=1:numberOfblocks
    ci=Stile{k};
   nci(:,:,1)=((ci(:,:,1)-muR(k)))+muR1(k);
   nci(:,:,2)=((ci(:,:,2)-muG(k)))+muG1(k);
   nci(:,:,3)=((ci(:,:,3)-muB(k)))+muB1(k); 
   ntile{k}=nci;
end
waitbar(0.8);
ntile(targetindx)=ntile;
k=1;
for i=1:n:M
    for j=1:n:N
        Mosaic(i:i+n-1,j:j+n-1,:)=ntile{k};
        k=k+1;
    end
end
waitbar(1);
close(wb);
%% 
%hide data in image using key
Mb=[muR1,muG1,muB1,muR,muG,muB,avgstd,avgstd1];
binary=de2bi(Mb',8);
binary=binary(:);
%% Encryption
Key=input('Enter Key =  ');
rng(Key);
K=randi([0,1],size(binary,1),size(binary,2));
binary=bitxor(binary,K);
%LSB detection
ld=length(binary)/2;
dat=reshape(binary,ld,2);
Dat=bi2de(dat,2);
Mosaic=double(Mosaic(:));
Mosaic=Mosaic-rem(Mosaic,4);
Mosaic(1:ld)=Mosaic(1:ld)+Dat;
ld=num2str(ld);
Mosaic(end)=length(ld);
for i=length(ld):-1:1
Mosaic(end-i)=str2double(ld(i));
end
Mosaic=uint8(reshape(Mosaic,[M,N,3]));
subplot(133),imshow(Mosaic)
title('Encrypted image')
imwrite(Mosaic,'Mosaic.png')
