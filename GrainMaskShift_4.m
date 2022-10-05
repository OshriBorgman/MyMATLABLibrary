%%  Load the basic mask

% Define the dilation mask
dilationMask = strel('disk',3,0);

% Create a dilated grain mask
% mkDil = imdilate(~grainMask, dilationMask);
mkDil = ~grainMask;

% Divide the mask to regions, where each region will be treated differently
[parts] = DivideGrainMask2(mkDil, [0 1400 size(mkDil,2)]);

%% Make the shifted mask

% Create the accumulated grain mask
mkDilAccum = zeros(size(mkDil));

% Define the steps to take at each iteration, for each part. 
% % The steps are defined as a 4-element vector indicating
% % forward-down-back-up steps
% steps = [1 0.5 0 0; 0.5 0.5 0 0];
% The steps are defined as an 8-element vector indicating
% forward-forward+down-down-down+back-back-back+up-up-up+forward steps
steps = [1 0.75 0.5 0 0 0 0 0; 0.5 0.5 0.5 0 0 0 0 0];

% create a shifted grain masks, with increased grain sizes
for n = 1:5        
    % Make the shifting grain mask, in each section
    for t = 1:length(parts)
        mkDil2 = imdilate(parts{t},  strel('disk',1,0));
        % For each step move the mask
        switch steps(t,1)~=0
            case true
                %                 Calculate the step length
                sl = floor(steps(t,1)*n);
                % Check the step is >0
                if sl>0
                    % move the grain mask forward
                    mkShift1 = [false(size(mkDil2,1),sl) mkDil2(:,1:end-sl)];
                else
                    mkShift1 = zeros(size(mkDil));
                end
            case false; mkShift1 = zeros(size(mkDil));
        end
        switch steps(t,2)~=0
            case true
                % Calculate the step length
                sl = floor(steps(t,2)*n);
                % Check the step is >0
                if sl>0
                    % move the grain mask forward and down
                    mkShift2 = [false(sl,size(mkDil2,2)); false(size(mkDil2,1)-sl,sl) mkDil2(1:end-sl,1:end-sl)];
                else
                    mkShift2 = zeros(size(mkDil));
                end
            case false; mkShift2 = zeros(size(mkDil));
        end
        switch steps(t,3)~=0
            case true; sl = floor(steps(t,3)*n);
                % Check the step is >0
                if sl>0
                    % move the grain mask down
                    mkShift3 = [false(sl,size(mkDil2,2)); mkDil2(1:end-sl,:)];
                else 
                    mkShift3 = zeros(size(mkDil));
                end
            case false; mkShift3 = zeros(size(mkDil));
        end
        switch steps(t,5)~=0
            case true; sl = floor(steps(t,5)*n);
                % Check the step is >0
                if sl>0
                    % move the grain mask back
                    mkShift5 = [mkDil2(:,sl+1:end) false(size(mkDil2,1),sl) ];
                else
                    mkShift5 = zeros(size(mkDil));
                end
            case false; mkShift5 = zeros(size(mkDil));
        end
        switch steps(t,7)~=0
            case true; sl = floor(steps(t,7)*n);
                % Check the step is >0
                if sl>0
                    % move the grain mask up
                    mkShift7 = [mkDil2(sl+1:end,:); false(sl,size(mkDil2,2))];
                else
                    mkShift7 = zeros(size(mkDil));
                end
            case false; mkShift7 = zeros(size(mkDil));
        end
        % Add the shifted masks together
        mkDilAccum = mkDilAccum + mkShift1 + mkShift2 + mkShift3 + mkShift5 + mkShift7;
        clear mkShift1 mkShift2 mkShift3 mkShift5 mkShift7
    end
end


%%

% Plot the accumulated shift
PlotFieldImage(mkDilAccum, 'Accumulated shifted mask')

% obtain the logical image of the grain mask. Next, save it using imsave
mkShiftFinal = ~logical(mkDilAccum);
% % dilate everything one last time
% mkShiftFinal = imdilate(mkShiftFinal, strel('disk',1,0));
PlotFieldImage(mkShiftFinal, 'Final logical mask')
