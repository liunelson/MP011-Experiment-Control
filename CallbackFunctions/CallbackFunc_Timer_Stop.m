function CallbackFunc_Timer_Stop(hObject, event)

    handles = evalin('base','handles');
    disp('Timer Stopped')
    
    try
        newvalues = get(handles.HVtable,'Data')
    end
    
    global whostopped

    set(handles.figGUI_panHV_start, 'Enable', 'off');
    set(handles.figGUI_panHV_ArcStatus, 'Enable', 'off');
    set(handles.figGUI_panHV_AutoStatus, 'Enable', 'off');
    set(handles.figGUI_panHV_shutdown, 'Enable', 'off');
    set(handles.figGUI_panHV_NomVoltage, 'Enable', 'off');
    set(handles.figGUI_panHV_NomVoltageAdd, 'Enable', 'off');
    set(handles.figGUI_panHV_NomVoltageMinus, 'Enable', 'off');
    set(handles.figGUI_menuHV, 'Enable', 'off');
    
    if(~isempty(whostopped))

        if(strcmp(whostopped{2},'Shutdown') == 1)
            try
                % Cannot shutdown when already offline
%                 if(handles.com_devState_HV_start == 0)
%                     errordlg('Device status: offline','Shutdown Error');
%                 end

                % Shutdown sequence
%                 if((handles.com_devState_HV_start > 0) && (handles.com_devState_HV_start < 4))

                    % Reduce nominal output voltage to 0
%                     if((handles.com_devState_HV_start == 1) || (handles.com_devState_HV_start == 3))

                        serverCmd = sprintf('sendrcv %s %s', handles.HV_comTermChar, 'S3=0.000');
                        [handles.HV_serverObj, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.HV_serverObj, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );
                    
                    pause(4)
                    
                    % Query effective voltage (in kV)
                    serverCmd = sprintf('sendrcv %s %s', handles.HV_comTermChar, '?1');
                    [handles.HV_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.HV_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );

                    handles.Voltage(handles.CurrTimePoint,3) = -10*str2double(serverAns(1:end-1)); % drop ';' at the end of returned value

                    % Update panel
                    set(handles.figGUI_panHV_Voltage, 'String',sprintf('%.3f',handles.Voltage(handles.CurrTimePoint,3)));

                    % Query effective current (in uA)
                    serverCmd = sprintf('sendrcv %s %s', handles.HV_comTermChar, '?2');
                    [handles.HV_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.HV_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );

                    handles.Current(handles.CurrTimePoint,3) = 10*str2double(serverAns(1:end-1)); % drop ';' at the end of returned value

                    % Update panel
                    set(handles.figGUI_panHV_Current, 'String',sprintf('%.3f',handles.Current(handles.CurrTimePoint,3)));


%                     end
%                 end

            catch err
                rethrow(err)
            end
        end
        
        switch char(whostopped(1))
            
            case 'Stages'
                CallbackFunc_Stages([], [], whostopped{2}, handles.labelstages)
                
            case 'Shutters'
                CallbackFunc_Shutters([], [], whostopped{2}, handles.labelshutters)
                
            case 'Micra'
                pause(0.2)
                CallbackFunc_Micra([], [], whostopped{2})
                
            case 'Oscilloscope'
                CallbackFunc_Oscilloscope(handles.Oscilloscope_meas_chan, [], whostopped{2}, handles.figGUI_menuOscilloscope_menuConfig_fig_value)
                
            case 'Chiller'
                pause(0.4)
                CallbackFunc_Chiller([], [], whostopped{2})
                
            case 'CLI'
                CallbackFunc_CLI(handles.cliselection, [], whostopped{2}, handles.clireply)
                
            case 'Scanupdate'
                if(strcmp(whostopped{2},'scanNum') == 1)
                    oldpath = get(handles.figGUI_panCamera_autoSave_path, 'String');
                    oldpath(end) = get(handles.figGUI_panScan1_scanNum,'String');
                    newpath = oldpath;
                    set(handles.figGUI_panCamera_autoSave_path, 'String', newpath);
                    set(handles.figGUI_panCamera_autoSave_filename, 'String', sprintf('%s_00001', newpath(end-4:end)));
                end
                UpdateEditValue(handles.scanupobj, [], whostopped{2})
                
            case 'Scan'
                CallbackFunc_Scan(handles.scanobj, [], whostopped{2})

            case 'HV'
%                 try
%                 get(handles.HVtable, 'Data')
%                 end
%                 whostopped{2}
%                 aaa = handles.HVrowcol
                CallbackFunc_HV(handles.HVtable, [], whostopped{2}, handles.HVrowcol)

            case 'Camera'
                CallbackFunc_Camera(handles.cameraobj, [], whostopped{2})

        end
    end

end