function [TG] = ReadTextGrid_Corrected_PTSVox(path, tier)
a = 0; flag = 0;
TG = [];
fid = fopen(path);
while ~feof(fid)
    tline = fgetl(fid);
    tmp = strsplit(tline, ' ');
    if length(tmp) > 2 && strcmp(tmp{2}, 'item')
        if strcmp(tmp{3}, ['[',num2str(tier),']:'])
            flag = 1;
        else
            if flag == 1
                break
            end
            flag = 0;
        end
    end
    
    if flag == 1;
        if strcmp(tmp{2}, 'intervals') && strcmp(tmp{3}(1), '[')
            a = a + 1;
            TG(a).T1 = []; TG(a).T2 = []; TG(a).Text = [];
            fnames = fieldnames(TG);
            for i = 1:length(fnames)
                tline = fgetl(fid);
                tmp = strsplit(tline, ' ');
                
                if i < 3;
                    TG(a).(fnames{i}) = str2num(tmp{4});
                else
                    TG(a).(fnames{i}) = tmp{4};
                end
            end
        end
    end
end

if isempty(TG)
    fid = fopen(path, 'r', 'n', 'UniCode');
    
    while ~feof(fid)
        tline = fgetl(fid);
        tmp = strsplit(tline, ' ');
        if length(tmp) > 2 && strcmp(tmp{2}, 'item')
            if strcmp(tmp{3}, ['[',num2str(tier),']:'])
                flag = 1;
            else
                if flag == 1
                    break
                end
                flag = 0;
            end
        end
        
        if flag == 1;
            if strcmp(tmp{2}, 'intervals') && strcmp(tmp{3}(1), '[')
                a = a + 1;
                TG(a).T1 = []; TG(a).T2 = []; TG(a).Text = [];
                fnames = fieldnames(TG);
                for i = 1:length(fnames)
                    tline = fgetl(fid);
                    tmp = strsplit(tline, ' ');
                    
                    if i < 3;
                        TG(a).(fnames{i}) = str2num(tmp{4});
                    else
                        TG(a).(fnames{i}) = tmp{4};
                    end
                end
            end
        end
    end
end
fclose(fid);
end