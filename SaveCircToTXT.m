function [] = SaveCircToTXT(samNum, Lx, Ly, Dg, Xg, lambda, meshL, phi, ...
    DMean, het, saveFolder)
%SAVE CIRCLES TO TXT FILE Save positions and diameters of circles to a txt
%list

% Save text file of the pillars position and diameter

 
    % the header row
    infoString = sprintf('units=mm, xmax=%1.3g, ymax=%1.3g, diam_mean=%1.2g, diam_dev=%1.3g, corr_len=%1.2g ,porosity=%1.2g, Columns: X Y Diameter', ...
        Lx, Ly, mean(Dg), std(Dg), ...
        lambda*meshL, phi);
    
    % Construct the file name:
    txtFileName = sprintf('%0.3d_Lx=%d_Ly=%d_MeshL=%1.2g_AveGr=%1.2g_het=%1.2f_corrLen=%1.1f', ...
        samNum, Lx, Ly, meshL, DMean, het, lambda*meshL);
    
    % Arrange the text file to avoid placing grains in proximity to each other,
    % for the laser cutting process.
    listToWrite(length(Dg)).x = [];
    listToWrite(length(Dg)).y = [];
    listToWrite(length(Dg)).d = [];
    
    % Create the list of remaining grains
    remGrains = [];
    remGrains.x = Xg(:,1);
    remGrains.y = Xg(:,2);
    remGrains.d = Dg;
    % The first point
    x_i = remGrains.x(1);
    y_i = remGrains.y(1);
    listToWrite(1).x = x_i;
    listToWrite(1).y = y_i;
    listToWrite(1).d = remGrains.d(1);
    % Remove it from further searches
    remGrains.x(1) = [];
    remGrains.y(1) = [];
    remGrains.d(1) = [];
    % the maximum search radius,
    RPlaceGrainSear = Ly;
    for t = 2:length(Dg)
        % Use the search model to find the point with the maximum distance within
        % radius R of the current point
        placeGrainsSearch = KDTreeSearcher([remGrains.x remGrains.y]);
        [Idx,D] = rangesearch(placeGrainsSearch, [x_i y_i], RPlaceGrainSear);
        % If no grains apear on the search, increase the radius
        if isempty(D{:})
            RPlaceGrainSear = 2*RPlaceGrainSear;
            [Idx,D] = rangesearch(placeGrainsSearch, [x_i y_i], RPlaceGrainSear);
        end
        % The coordinates of the next point
        x_i = remGrains.x(Idx{:}(end));
        y_i = remGrains.y(Idx{:}(end));
        % Write the data to the list
        listToWrite(t).x = x_i;
        listToWrite(t).y = y_i;
        listToWrite(t).d = remGrains.d(Idx{:}(end));
        % Remove it from further searches
        remGrains.x(Idx{:}(end)) = [];
        remGrains.y(Idx{:}(end)) = [];
        remGrains.d(Idx{:}(end)) = [];
    end
    
    
    % % Plot the position of the grains in the order of placement
    % figure
    % ax = gca;
    % hold on
    % for q = 1:length(listToWrite)
    % plot([listToWrite(1:q).x], [listToWrite(1:q).y], '.', "Color", [0.5 0.5 0.5], "MarkerSize", 10)
    % if q>1
    % plot(listToWrite(q).x, listToWrite(q).y, '.', "Color", 'r', "MarkerSize", 10)
    % plot(listToWrite(q-1).x, listToWrite(q-1).y, '.', "Color", 'b', "MarkerSize", 10)
    % end
    % pause
    % end
    % axis equal tight
    
% % Write the samples to a file
    fileID = fopen(fullfile(saveFolder,strcat(txtFileName,'.txt')),'w');
    fprintf(fileID, strcat(infoString,'\n'));
    for j = 1:length([listToWrite.d])
        fprintf(fileID,'%6.10f\t%6.10f\t%6.10f\n', (listToWrite(j).x), ...
            (listToWrite(j).y), listToWrite(j).d);
    end
    fclose(fileID);
    
    
    
end

