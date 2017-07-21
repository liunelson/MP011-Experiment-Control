function SetNominalDeviceOutput

    % Load handles from base workspace
    handles = evalin('base','handles');
    
    if(handles.CurrTimePoint > 1)
        i = handles.CurrTimePoint - 1;
    elseif(handles.CurrTimePoint == 1)
        i = handles.numTimePoints;
    end
    
    % DEBUGGING
    %fprintf(1,'\t CurrTimePoint = %d \t i = %d\n',handles.CurrTimePoint,i);

    % Set nominal device voltage
    if(handles.Voltage(handles.CurrTimePoint,2) ~= handles.Voltage(i,2))
        serverCmd = sprintf('sendrcv %s %s%s', handles.HV_comTermChar, ' S3=', num2str(0.1*str2double(get(handles.figGUI_panHV_NomVoltage,'String'))));
            [handles.HV_serverObj, serverAns, err] = SendReceiveSerial(...
            'send_receive', ...
            handles.HV_serverObj, ...
            serverCmd, ...
            handles.com_waitTime.client_server, ...
            handles.com_numTry...
            );

        handles.Voltage(handles.CurrTimePoint,2) = str2double(get(handles.figGUI_panHV_NomVoltage,'String'));
        
        % DEBUGGING
        %fprintf(1,'\t set V_nom = %.2f kV\n',str2double(get(handles.EditDeviceStatusPanelNomVoltage,'String')));
    end
    
    % Save handles in base workspace
    assignin('base','handles',handles)

end
