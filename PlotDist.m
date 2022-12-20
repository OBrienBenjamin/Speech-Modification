function[] = PlotDist(Output, METHOD)
figure('Name', [METHOD.Mode, '-', METHOD.Dir, '-', METHOD.Map])
for i = 1:length(Output)
    syl = strsplit(Output(i).Text, '"');
    plot(Output(i).Time, Output(i).X,'k.', 'MarkerSize', 2);
    hold on
    text(Output(i).Time, Output(i).X, syl{2}, 'FontSize', 12);
    hold on
end
set(gca, 'FontSize', 20);
xlabel('Time (s)'); ylabel('Alpha');
if strcmp(METHOD.Mode, 'PITCH')
    if strcmp(METHOD.Dir, 'UP')
        ylim([-5 605])
    else
        ylim([-605 5])
    end
else
    if strcmp(METHOD.Dir, 'UP')
        ylim([0.49 1.01])
    else
        ylim([0.99 1.51])
    end
end
grid on
hold off

end