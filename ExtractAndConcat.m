function [Plot] = ExtractAndConcat(PATH, TG, METHOD)
Fade.IN = 0.01; % fade out (s) for all non-pause segments
Fade.OUT = 0.01; % fade out (s) for all non-pause segments

% % % generate Alpha
if strcmp(METHOD.Mode, 'TEMPO') % % % TEMPO
    [ALPHA] = GenAlphaTempoPct(METHOD, TG);
else % % % PITCH
    [ALPHA] = GenAlphaPitchPct(METHOD, TG);
end

% % % for plotting ; comparing to human performance
Plot = [];

% % % % load audio file
[snd, fs] = audioread(PATH.Input);

% % % % filter and normalise
a = [1, -0.98];
b = [1, -1];

% % remove DC
Y = filtfilt(b, a, snd(:,1));

% % normalise
if max(Y) > abs(min(Y))
    N = Y * (1.0 / max(Y));
else
    N = Y * ((-1.0) / min(Y));
end

% % % signal to be saved and then concatenated at terminus
Data = []; c = 0;
a = 0; TIME = 0;
for i = 1:length(TG)
    t0 = TG(i).T1;
    t1 = TG(i).T2;
    
    % start frame
    first =  floor(t0 * fs);
    
    if t0 == 0; first = 1; end
    
    % end frame
    last = floor(t1* fs);
    
    if last > length(snd(:,1)); last = length(snd(:,1)); end
    
    X = N(first:last, 1);
    
    % % % % ignore silences
    if strcmp(TG(i).Text, '"[pause]"') || strcmp(TG(i).Text, '"_"')
        switch METHOD.Pause
            case 'T'
                c = c + 1;
                Data(c).Signal = X;
            case 'C'
                if strcmp(METHOD.Mode, 'TEMPO')
                    Y = wsolaTSM(X, ALPHA(1));
                else
                    [Y] = PitchShift(X, fs, ALPHA(1));
                end
                
                % % % add fade in, out
                [Y] = AddFades(Y, fs, Fade);
                
                % % % save signal
                c = c + 1;
                Data(c).Signal = Y;
                
                % % % for plotting / comparing to human perf
                a = a + 1;
                Plot(a).X = ALPHA(1);
                Plot(a).Y = i;
                Plot(a).Text = '___';
                Plot(a).Time = TIME;
                
                % % % go to next ALPHA
                ALPHA(1) = [];
                
                % % % add to TIME
                TIME = TIME + (length(Y) / fs);
                
            case 'F'
                fprintf('pause has been excluded\n');
        end
    else
        fprintf('word: %d\t%s\t%s', i, TG(i).Text);
        if strcmp(METHOD.Mode, 'TEMPO')
            Y = wsolaTSM(X,ALPHA(1));
        else
            [Y] = PitchShift(X, fs, ALPHA(1));
        end
        
        % % % add fade in, out
        [Y] = AddFades(Y, fs, Fade);
        
        % % % save signal
        c = c + 1;
        Data(c).Signal = Y;
        
        % % % for plotting / comparing to human perf
        a = a + 1;
        Plot(a).X = ALPHA(1);
        Plot(a).Y = i;
        Plot(a).Text = TG(i).Text;
        Plot(a).Time = TIME;
        
        % % % go to next ALPHA
        ALPHA(1) = [];
        
        % % % add to TIME
        TIME = TIME + (length(Y) / fs);
        if ~isempty(ALPHA); fprintf('alpha: %f\n', ALPHA(1)); else fprintf('\n'); end;
    end
    if isempty(ALPHA); break; end
end

% % % get remaining pseudo-syllables (for plot / comparing w/ human perf
for j = i+1:length(TG)
    t0 = TG(j).T1;
    t1 = TG(j).T2;
    
    % start frame
    first =  floor(t0 * fs);
    
    if t0 == 0; first = 1; end
    
    % end frame
    last = floor(t1 * fs);
    
    if last > length(snd(:,1)); last = length(snd(:,1)); end
    
    X = N(first:last, 1);
    
    if ~strcmp(TG(j).Text, '"[pause]"') && ~strcmp(TG(j).Text, '"_"')
        % % % save signal
        c = c + 1;
        Data(c).Signal = X;
        
        % % % for plotting
        a = a + 1;
        if strcmp(METHOD.Mode, 'PITCH'); Plot(a).X = 0; else Plot(a).X = 1.0; end
        Plot(a).Y = j;
        Plot(a).Text = TG(j).Text;
        Plot(a).Time = TIME;
    
        % % % add to TIME
        TIME = TIME + (length(X) / fs);
    end
end

% % % concatenate signal and save to file
SND = [];
for i = 1:length(Data)
    SND = [SND, Data(i).Signal'];
end

% % % normalize at the end again!
% % normalise
if max(SND) > abs(min(SND))
    SND_N = SND * (1.0 / max(SND));
else
    SND_N = SND * ((-1.0) / min(SND));
end

audiowrite(PATH.Output, SND_N, fs);

end

% % % % % FADE
function [SND] = AddFades(SND, fs, Fade)
% % % add fade in
fade_scale = linspace(0, 1, round(Fade.IN .* fs));
deb = 1;
fin = length(fade_scale);
SND(deb:fin) = SND(deb:fin) .* fade_scale';

% % % add fade out
fade_scale = linspace(1, 0, round(Fade.OUT .* fs));
fin = length(SND);
deb = fin - length(fade_scale) + 1;
SND(deb:fin) = SND(deb:fin) .* fade_scale';
end

% % % % TEMPO
function [Alpha] = GenAlphaTempoPct(METHOD, TG)
non_syl = 0;
for i = 1:length(TG)
    if strcmp(METHOD.Pause, 'C')
        non_syl = non_syl + 1;
    else
        if ~strcmp(TG(i).Text, '"[pause]"') && ~strcmp(TG(i).Text, '"_"')
            non_syl = non_syl + 1; 
        end
    end
end

len_mod = round((METHOD.Num * non_syl) / 100);
Alpha = GenAlphaTempo(METHOD, len_mod);
end

function [Alpha] = GenAlphaTempo(METHOD, NUM)
if strcmp(METHOD.Dir, 'UP')
    switch METHOD.Map
        case 'LIN'
            Alpha = linspace(0.5, 1.0, NUM);
        case 'EXP'
            [Alpha] = nonLinspace(0.5, 1.0, NUM, 'exp10');
        case 'LOG'
            [Alpha] = nonLinspace(0.5, 1.0, NUM, 'log10');
    end
else
    switch METHOD.Map
        case 'LIN'
            Alpha = linspace(1.5, 1.0, NUM);
        case 'EXP'
            [Alpha] = nonLinspace(1.5, 1.0, NUM, 'exp10');
        case 'LOG'
            [Alpha] = nonLinspace(1.5, 1.0, NUM, 'log10');
    end
end
end

function [SND] = PitchShift(x, fsAudio, alpha)
clear parameter
parameter.fsAudio = fsAudio;
% parameter.algTSM = @twoStepTSM;
parameter.algTSM = @wsolaTSM;
y = pitchShiftViaTSM(x, alpha, parameter);

clear parameter
parameter.anaHop = 512;
parameter.win = win(2048,1); % sin window
parameter.filterLength = 60;
SND = modifySpectralEnvelope(y, x, parameter);
end

function [Alpha] = GenAlphaPitchPct(METHOD, TG)
non_syl = 0;
for i = 1:length(TG)
    if strcmp(METHOD.Pause, 'C')
        non_syl = non_syl + 1;
    else
        if ~strcmp(TG(i).Text, '"[pause]"') && ~strcmp(TG(i).Text, '"_"')
            non_syl = non_syl + 1; 
        end
    end
end

len_mod = round((METHOD.Num * non_syl) / 100);
Alpha = GenAlphaPitch(METHOD, len_mod);
end

function [Alpha] = GenAlphaPitch(METHOD, NUM)
if strcmp(METHOD.Dir, 'UP')
    switch METHOD.Map
        case 'LIN'
            Alpha = linspace(600, 0, NUM);
        case 'EXP'
            [Alpha] = nonLinspace(600, 0, NUM, 'exp10');
        case 'LOG'
            [Alpha] = nonLinspace(600, 0, NUM, 'log10');
    end
else
    switch METHOD.Map
        case 'LIN'
            Alpha = linspace(-600, 0, NUM);
        case 'EXP'
            [Alpha] = nonLinspace(-600, 0, NUM, 'exp10');
        case 'LOG'
            [Alpha] = nonLinspace(-600, 0, NUM, 'log10');
    end
end
end
