%% Select the video file
[vidReadFileName, vidReadFilePath] = uigetfile('*.*', 'Choose video file');
% create the video reader class
vr = VideoReader(fullfile(vidReadFilePath, vidReadFileName));

%% Open a video file to write in AVI format
[vidFileWritePath] = uigetdir('*.*', 'Choose path to write video file to');
vidFileWriteName = '07-01-2022_inter_point_fluorescein_1_green';

%% %% Write in AVI format in parts
numParts = 20;
for part = 1:numParts
allFrames = {};
    frstFr = floor((part-1)*vr.NumFrames/numParts)+1;
    lstFr = floor(part*vr.NumFrames/numParts);
% Collect the frames
    allFrames = read(vr, [frstFr lstFr]);
% create the video file
    vw = VideoWriter(fullfile(vidFileWritePath, [vidFileWriteName '_' num2str(part)]));
    vw.FrameRate = vr.FrameRate;    
    open(vw)
    for f = 1:size(allFrames,4)
%         Write only the green channel
        writeVideo(vw,allFrames(:,:,2,f))
    end
    close(vw)
end



%%
% Display the full image
PlotFieldImage(allFrames(:,:,:,50));
axis equal tight


%%
% Display the green channel
PlotFieldImage(allFrames(:,:,2,50));
axis equal tight

%%

AA = (allFrames(:,:,:,100));
AAGreen = double(AA(:,:,2))./(2^8-1);

PlotFieldImage(AAGreen);
axis equal tight

figure
histogram(AAGreen)

[Gx, Gy] = gradient(AAGreen);
G = sqrt(Gx.^2 + Gy.^2);

PlotFieldImage(G);
axis equal tight
