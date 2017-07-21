function CheckArcThreshold

    % Load handles from base workspace
    handles = evalin('base','handles');


    % Check arc protection status
    if(get(handles.figGUI_panHV_ArcStatus,'Value') == 1)
        handles.StatusArcDetect = 1;
    else
        handles.StatusArcDetect = 0;
    end

    if(handles.StatusArcDetect == 1)
        
        % Check arc voltage change threshold
        if(handles.CurrTimePoint > 1)
            i1 = handles.CurrTimePoint - 1;
        elseif(handles.CurrTimePoint == 1)
            i1 = handles.numTimePoints;
        end
        if(i1 > 1)
            i2 = i1 - 1;
        elseif(i1 == 1)
            i2 = handles.numTimePoints;
        end
        meanV = mean([handles.Voltage(i1,3),handles.Voltage(i2,3)]);
        deltaVoltage = abs(meanV - handles.Voltage(handles.CurrTimePoint,3));
        if(deltaVoltage >= handles.arcThreshVoltage)
            
            % Take care of sudden voltage rise at initialization
            if(meanV > 0)
                % Voltage drop!
                handles.arcVoltageStatus = 1;
%                 set(handles.TextArcPanelVoltageStatus,'String','!','BackgroundColor','red');
            end
            
        else
            
            % If no arc...
            handles.arcVoltageStatus = 0;
%             set(handles.TextArcPanelVoltageStatus,'String','O','BackgroundColor','green');
            
        end
        
        
        % Detect arc
        if((handles.arcCurrentStatus == 1) || (handles.arcVoltageStatus == 1))
            
            % Drop nominal voltage to safe value
            handles.Voltage(handles.CurrTimePoint,2) = (handles.autoThreshVoltagePercent/100)*handles.Voltage(handles.CurrTimePoint,3);
            handles.nominalVoltage = handles.Voltage(handles.CurrTimePoint,2);
            set(handles.figGUI_panHV_NomVoltage,'String',num2str(handles.nominalVoltage,'%.3f'));
            
            % Set nominal device voltage
            serverCmd = sprintf('sendrcv %s %s%s', handles.HV_comTermChar, ' S3=', num2str(0.1*str2double(get(handles.figGUI_panHV_NomVoltage,'String'))));
                [handles.HV_serverObj, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.HV_serverObj, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
        end
        
    end
    
    % Save handles in base workspace
    assignin('base','handles',handles)

end
