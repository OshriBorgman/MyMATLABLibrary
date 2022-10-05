clear
% The viscosity values
para{1,1} = 0.001;
para{2,1} = 0.015;
para{3,1} = 0.19;
% para{4,1} = 1.1;
% para{2,1} = 0.001;
% para{3,1} = 0.001;
% para{4,1} = 0.001;
% The pressure values
para{1,2} = {40000;80000};
para{2,2} = {80000;160000};
para{3,2} = {500000;1000000};
% para{4,2} = {80000};
% % The surface tension values
para{1,3} = 0.072;
para{2,3} = 0.068;
para{3,3} = 0.065;
% para{4,3} = 0.062;
% % Different contact angles:
% para{1,3} = {10; 20; 30; 40; 50; 60; 70; 80; 90; 100; 110};
m=0;
% Select folder for geometry files:
fprintf('select folder for geometry files:\n');
[readGeomFolder] = uigetdir('Select folder');
fprintf('will search in folder : %s\n',readGeomFolder);
% Select folder for output files:
fprintf('select folder to save simulation data files:\n');
[saveSimFolder] = uigetdir('Select folder');
fprintf('will save in folder : %s\n',saveSimFolder);
fileNames = dir(fullfile(readGeomFolder,'120p_r_40_t_20_psv10_cl*.txt'));
for n = 1:length(fileNames)
clear parameters geometry
txtFile = fileNames(n).name;
[parameters,geometry] = load_grids_fun(txtFile,readGeomFolder);
for k = 1:length([para{:,1}])
for l = 1:length(para{k,2})
for q = 1:length(para{k,3})
    m = m+1;
    parameters.label = ['Pi=' sprintf('%g',para{k,2}{l})];
    parameters.mu = para{k,1};
    parameters.P = para{k,2}{l};
    parameters.Gamma = para{k,3};
%     parameters.theta = (180-para{k,3}{q})*pi/180;
    parameters.theta = (180-72)*pi/180;
    job(m)=batch('run_from_batch','AttachedFiles',{'CR_input.m'});
%      run_from_batch
end
end
end
end
