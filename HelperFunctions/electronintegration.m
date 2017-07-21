function electronintegration(hObject, ~, hfig, haxes, hstart, hstop, hstdsamples, hstd)
        
    [filename, pathname] = uigetfile('*.csv', 'Select log file');

    if isequal(filename,0) || isequal(pathname,0)

    else
       set(hstart, 'Enable', 'on');

        uiwait(hfig)

        set(hstop, 'Enable', 'on');
        set(hstart, 'Enable', 'off');
        set(hObject, 'Enable', 'off');

        numelec = [];
        fid = fopen(fullfile(pathname, filename),'r');

        hplot = plot(haxes, 0, 0, 'Color', 'r', 'LineWidth', 3);

        set(haxes, ...
            'Units', 'pixels', ...
            'Fontsize', 12, ...
            'XLim', [0 10], ...
            'LineWidth', 2, ...
            'FontSize', 12, ...
            'FontWeight', 'bold' ...
            );

        set(get(haxes,'XLabel'), ...
            'String', 'Number of Images', ...
            'FontSize', 14, ...
            'FontWeight', 'bold' ...
            );

        set(get(haxes,'YLabel'), ...
            'String', 'Number of Electrons (x 1000)', ...
            'FontSize', 14, ...
            'FontWeight', 'bold' ...
            );
        
        set(hstdsamples, ...
            'HorizontalAlignment', 'right', ...
            'FontSize', 12 ...
            );

        while(get(hstop,'Value')==0)
            
            stdsamplesnum = str2double(get(hstdsamples, 'String'));
            
            if(isnan(stdsamplesnum) == 1 || stdsamplesnum < 10)
                set(hstdsamples, 'String', '10');
            end
            

            CallbackFunc_Camera([], [], 'start acquisition')

            try
                C = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s%s', 'Delimiter', ',');
            catch
                fclose(fid);
            end

            try
                lastcol = C{12};
                numelec = [numelec str2double(char(lastcol(end)))*0.000014];
                x = 1:numel(numelec);
                set(haxes,'XLim', [0 max(10,max(numel(x)))]);
                set(hplot,'XData',x,'YData',numelec);
                
                
                if(numel(numelec) >= stdsamplesnum)
                    try
                        set(hstd, 'String' , num2str(std(numelec(end-stdsamplesnum+1:end))*100/mean(numelec(end-stdsamplesnum+1:end)), '%4.3f'));
                    catch
                    end
                end
            catch
            end

        end

        fclose(fid);
    end
    
    set(hstop, 'Enable', 'off', 'Value', 0);
    CallbackFunc_Close(hfig, [], '')

end

