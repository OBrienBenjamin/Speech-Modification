% % % input
home = '/path/to/directory/'
samp = 'example';

% % % tier level
TIER = 3;

PATH.Text = [home, '.TextGrid'];
PATH.Input = [home, '.wav'];

% % % Modification Mode
METHOD.Mode = 'PITCH'; % % % 'TEMPO' or 'PITCH'
 
% % % Modification speed - 'FAST' or 'SLOW'
METHOD.Dir = 'DOWN';

% % % Modification based on number of sylables OR duration (percentage)
METHOD.Type = 'PCT'; 
METHOD.Num = 75; % % % EITHER number of sylables (SYL) OR percentage (PCT)

% % % Mapping type
METHOD.Map = 'LIN'; %  % % 'LIN' (linear), 'EXP' (exponential), 'LOG'
METHOD.Pause = 'F'; % % % % 'T' (keep pause), 'C' (compress pause), 'F' (remove pause)

% % % output
PATH.Output = [home, samp, '_', ...
    METHOD.Mode, '_', METHOD.Dir, '_', num2str(METHOD.Num), '_', METHOD.Map, '_', METHOD.Pause, '.wav'];

% % % % % 
% % % % % Do not touch
[TG] = ReadTextGrid(PATH.Text, TIER);

[LIN] = ExtractAndConcat(PATH, TG, METHOD);

PlotDist(LIN, METHOD);
