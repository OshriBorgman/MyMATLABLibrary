function [] = SaveDatToTXT(expName, lambda, het, sat, saveFolder, x_var_name, ...
    y_var_name, t_var_name, x_var, y_var, t_var)
%SAVE DATA TO TXT FILE Save numerical data to a txt list
 
    % the header row
    infoString = sprintf('diam_dis=%1.3g, corr_len=%1.2g, sat=%1.2g, %s = %1.2d, Columns: %s; %s', ...
        het, lambda, sat, t_var_name, t_var, x_var_name, y_var_name);
    
    % Construct the file name:
    txtFileName = sprintf('%s_%s_%s_%s_%s', ...
        expName, x_var_name, y_var_name, t_var_name, strrep(num2str(t_var), '.', '_'));
    
% % Write the data to a file
    A = [x_var; y_var];
    fileID = fopen(fullfile(saveFolder,strcat(txtFileName,'.txt')),'w');
    fprintf(fileID, strcat(infoString,'\n'));
    fprintf(fileID,'%6.10f\t%6.10f\n', A);
    fclose(fileID);
    
    
    
end

