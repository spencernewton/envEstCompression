%% RealTimeEnvelope
r = 3;
thresh = 0.4;

fileReader = dsp.AudioFileReader( ...
    'male_5sec.wav');
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);

scope = dsp.TimeScope( ...
    'SampleRate',fileReader.SampleRate, ...
    'TimeSpan',2, ...
    'BufferLength',fileReader.SampleRate*2*2, ...
    'YLimits',[-1,1], ...
    'TimeSpanOverrunAction',"Scroll");

while ~isDone(fileReader)
    signal = fileReader();
    compressedSignal = newtonEst(signal,r,thresh);
    deviceWriter(compressedSignal);
%     scope([signal,mean(compressedSignal,2)]);
end

release(fileReader)
% release(deviceWriter)
release(scope)