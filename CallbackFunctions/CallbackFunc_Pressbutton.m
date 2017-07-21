function CallbackFunc_Pressbutton(hObject, event, funcName, param1)

    handles = evalin('base','handles');

    handles.figGUI_menuOscilloscope_menuConfig_fig_value = param1;

	% Save handles in base workspace
    assignin('base','handles',handles)
    
    global whostopped

    % Stop timer
    if(strcmp(get(handles.timer_obj,'Running'), 'on') > 0 || strcmp(handles.timer_status,'on') > 0)
        handles.timer_status = 'on';
        whostopped = funcName;
        
        switch funcName{1}
            
            case 'Stages'
                handles.labelstages = param1;

            case 'Shutters'
                handles.labelshutters = param1;
                
            case 'Oscilloscope'
                handles.Oscilloscope_meas_chan = hObject;
                    
            case 'CLI'
                handles.cliselection = hObject;
                handles.clireply = param1;
                
            case 'Scan'
                handles.scanobj = hObject;

            case 'HV'
                handles.HVrowcol = param1;
                handles.HVtable = hObject;
                try
%                 get(handles.HVtable,'Data')
                catch
                end
                
            case 'Camera'
                handles.cameraobj = hObject;
                if(strcmp(funcName{2},'start scan') == 1)
                    handles.scanrunning = 1;
                end

        end
        
        % Save handles in base workspace
        assignin('base','handles',handles)
        
        pause(1.1)
        
        stop(handles.timer_obj);

    else

        handles.timer_status = 'off';
        % Save handles in base workspace
        assignin('base','handles',handles)
        
        switch funcName{1}
            
            case 'Stages'
                CallbackFunc_Stages(hObject, [], funcName{2}, param1)
            
            case 'Shutters'
                CallbackFunc_Shutters(hObject, [], funcName{2}, param1)
                
            case 'Micra'
                CallbackFunc_Micra(hObject, [], funcName{2})
                
            case 'Oscilloscope'
                CallbackFunc_Oscilloscope(hObject, [], funcName{2}, param1)
                
            case 'Chiller'
                CallbackFunc_Chiller(hObject, [], funcName{2})
                
            case 'CLI'
                CallbackFunc_CLI(hObject, [], funcName{2}, param1)
                
%             case 'Scanupdate'
%                 if(strcmp(funcName{2},'scanNum') == 1)
%                     oldpath = get(handles.figGUI_panCamera_autoSave_path, 'String');
%                     oldpath(end) = get(handles.figGUI_panScan1_scanNum,'String');
%                     newpath = oldpath;
%                     set(handles.figGUI_panCamera_autoSave_path, 'String', newpath);
%                     set(handles.figGUI_panCamera_autoSave_filename, 'String', sprintf('%s_00001', newpath(end-4:end)));
%                 end
%                 UpdateEditValue(hObject, [], funcName{2})
                
            case 'Scan'
                CallbackFunc_Scan(hObject, [], funcName{2})

            case 'HV'
                CallbackFunc_HV(hObject, [], funcName{2}, param1)
                
            case 'Camera'
                CallbackFunc_Camera(hObject, [], funcName{2})

        end
    end
    
end
