clc;
clear all;
close all;

aa=load('stp2_auto_signaltap_0.txt');

dat1i=aa(:,3);
dat1q=aa(:,4);

dat2i=aa(:,5);
dat2q=aa(:,6);

adc1=aa(:,17);
adc2=aa(:,18);
% fftfata3=20*log10(abs(fft(adc1.*blackman(8192))));
fdai1=dat1i(257:1280);
fdaq1=dat1q(257:1280);

fdai2=dat2i(257:1280);
fdaq2=dat2q(257:1280);

ffdat1=i*fdai1+fdaq1;
ffdat2=i*fdai2+fdaq2;

fftfata1=20*log10(abs(ffdat1));
fftfata2=20*log10(abs(ffdat2));

add1=mean(adc1)
add2=mean(adc2)


fftd1=fft(adc1);
fftd2=fft(adc2);

% ph1=angle(fftd1(2458))
% ph2=angle(fftd2(2458))

fftfata3=20*log10(abs(fftd1));
fftfata4=20*log10(abs(fftd2));

ph1=angle(fftd1(615))
ph2=angle(fftd2(615))

dph=ph2-ph1
thta=dph/pi*180;

if(thta>180)
    thta = thta -360;
elseif(thta<-180)
    thta = thta + 360;
end

thta


figure(1);
plot(fftfata1);

figure(2);
plot(fftfata2);

figure(3);
plot(fftfata3);

figure(4);
plot(fftfata4);







