%% Setting Parameters


[v_data, fs] = audioread('male_5sec.wav'); %Read external wav file

% normalize audio to certain amplitude, for this project, 1 function from
% https://www.mathworks.com/matlabcentral/fileexchange/69958-audio-normalization-by-matlab

amp = 0.99;
v_data = normalizeAudio(v_data, amp);
points = max(size(v_data)); % length of input data
dp = 1:points;

audiowrite('male_5sec_n.wav',v_data,fs); % writes normalized file

t=0:1/fs:2;

%Sine wave Generation
% v_data=sin(2*pi*f0*t);
% audiowrite('200Hz.wav',v_data,20000)




outName = 'male_5sec_csn.wav';

%% Compression Filter - Magotra/Newton
data_in = v_data; % input .wav file

%i/p signal stats
IPmax_in = max(data_in)
IPmin_in = min(data_in)
IPvar_in = var(data_in)
%Take abs. value of i/p data and pass through smoothing filter (1 pole IIR)
%to estimate the envelope. Keep in mind transient phase of o/p(approx.
%2/(1-Beta))samples and effect of pole position (depends on Beta in
%corresponding equation for the filter) on estimated envelope (output)
AV_in=abs(data_in);
b=0.01;
a=[1 -0.99];
%E_in array contains estimated envelope
E_in=filter(b,a,AV_in);

%% Compression System

% Parameters 
beta = 0.9; 				 %input('Enter Beta   ');
%thresh_low = 0.003; 		 %input('Enter the low threshold in   ');
threshold = 0.2;             %0.55
slope = 0.9;                 %input('Enter the 1st slope    ');
%psat_out =0.01;             %input('Enter the highest saturation value ');
limit = 0.6;                 %0.65
th = threshold;
s = slope;
b = 1;

l=1;
h=l+49;

for k = h:points;
    Av_est = (AV_in(k));
    
    %Compression Routine
    if (Av_est > th)
        
        gain = mean(E_in(l:h))*3*s;
        compressed(k) = (data_in(k) * gain);
        
        
        if (abs(compressed(k)) < th) && (compressed(k) >= 0)
            out(k) = (compressed(k)/2) + th;
        elseif (abs(compressed(k)) < th) && (compressed(k) < 0)
            out(k) = (compressed(k)/2) - th;
        elseif (abs(compressed(k)) >= th)
            out(k) = compressed(k);
        end
        
        if (abs(out(k)) > AV_in(k))
            out(k) = data_in(k);
        else
            out(k) = out(k);
        end
        
        l = l+1;
        h = h+1;

    else
        out(k) = data_in(k);
        l = l+1;
        h = h+1;
    end;
     
end;

audiowrite(outName,out,fs)

figure;
subplot(2,1,1);
plot(data_in);
title('Input');
grid;

hold on

plot((out));
title('Input vs Compressed Output');
grid;

AV_out=abs(out);
b=0.01;
a=[1 -0.99];
E_out=filter(b,a,AV_out);

subplot(2,1,2);
plot(E_in);
title('Envelope Estimate of the Input vs Output');
grid;

hold on

plot(E_out);
grid;