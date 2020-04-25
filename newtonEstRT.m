function [output] = newtonEstRT(signal,r,thresh)
%newtonEstRT
% 
%This function can be used to compress an audio file in the real-time
%system using a signal input with dsp.AudioFileReader
% 
%   signal needs to be a string location of the audio file to use
%   
%   for example, audioFile = dsp.AudioFileReader('male_5sec.wav');
% 
%   r is the ratio >= 1, i.e. r = 4, ratio = 4:1
% 
%   thresh is the threshold above which the amplitude is compressed between
%   0 and 1
%   
%   when called, the function would look something like
%   outfile = newtonEst(audioFile,3,0.4);
% 
%   needs normalizeAudio.m to work, can be downloaded or commented out
%   https://www.mathworks.com/matlabcentral/fileexchange/69958-audio-normalization-by-matlab

% Envelope Single File Test

    v_data = signal; %Read external wav file

    amp = 0.99;
    v_data = normalizeAudio(v_data, amp);
    
    % normalize audio to certain amplitude, for this project, 1 
    % function from
    % https://www.mathworks.com/matlabcentral/fileexchange/69958-audio-normalization-by-matlab
    
    points = max(size(v_data)); % length of input data
    dp = 1:points;


    data_in = v_data; % input .wav file


    AV_in=abs(data_in);
    b=0.01;
    a=[1 -0.995];
    %E_in array contains estimated envelope
    E_in=filter(b,a,AV_in);
    %Also compute estimated power in the input

    % Compression System

    threshold = thresh;
    % choose threshold over which the amplitude will be compressed

    ratio = r;
    % this is a ratio of compression, "ratio:1". the higher the
    % number, the more agressive the compression will hit the signal above the
    % threshold

    % Parameters
    slope = 1/ratio;                 %input('Enter the 1st slope    ');
    th = threshold;
    s = slope;

    old_Data_est = 0.0;
    old_powest_compress = 0.0;

    l=1;
    h=l+49;

    for k = h:points;
        Av_est = (AV_in(k)); %beta*old_pow_est + (1-beta)*
        old_Data_est = Av_est;
        D_est1(k) = Av_est;

        %Compression Routine
        if (Av_est > th) % & Av_est < limit)

            %         gain = P_in(k)+(P_in(k)/3);
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
        end

    end
    output = out;
end

