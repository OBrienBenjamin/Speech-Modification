% % % input
Set = 'LPL';
Spk = 'Serge';
Ses = '01';
Chk = '02'; 
Samp = [Spk, '_', Ses, '_', Chk];

% % % tier level -- LPL (4)
TIER = 3;

PATH.Text = ['/Users/benjiobrien/Documents/LPL/Modulation/Stimuli/', Set, '/', Spk,'/',Ses, '/Raw/',Samp,'.TextGrid'];
PATH.Input = ['/Users/benjiobrien/Documents/LPL/Modulation/Stimuli/', Set, '/', Spk,'/',Ses, '/Raw/',Samp,'.wav'];

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
PATH.Output = ['/Users/benjiobrien/Documents/LPL/Modulation/', Spk, '_', Samp, '_', ...
    METHOD.Mode, '_', METHOD.Dir, '_', num2str(METHOD.Num), '_', METHOD.Map, '_', METHOD.Pause, '.wav'];

% % % % % 
% % % % % Do not touch
[TG] = ReadTextGrid_Corrected_PTSVox(PATH.Text, TIER);

[LIN] = ExtractAndConcatV2(PATH, TG, METHOD);

PlotDist(LIN, METHOD);
