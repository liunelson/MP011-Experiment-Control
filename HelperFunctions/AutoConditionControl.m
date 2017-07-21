function AutoConditionControl

    % Load handles from base workspace
    handles = evalin('base','handles');
    
    % Get auto-conditioning settings
    handles.autoDesireVoltage = str2double(handles.HV.cmdList(9));
    handles.autoTolerance = str2double(handles.HV.cmdList(10));
    handles.autoThreshVoltagePercent = str2double(handles.HV.cmdList(12));
    handles.autoVoltageRateMin = str2double(handles.HV.cmdList(14));
    handles.autoVoltageRateMax = str2double(handles.HV.cmdList(13));

    % Get effective output voltage
    if(handles.CurrTimePoint == 1)
        i = handles.numTimePoints;
    else
        i = handles.CurrTimePoint - 1;
    end
    handles.effectiveVoltage = handles.Voltage(i,3);
    
    if(abs(handles.effectiveVoltage - handles.autoDesireVoltage) > handles.autoTolerance)
        % Set voltage adjustment rate
        if(handles.effectiveVoltage < (handles.autoThreshVoltagePercent/100)*handles.autoDesireVoltage)
            R = handles.autoVoltageRateMax;
        elseif((handles.effectiveVoltage >= (handles.autoThreshVoltagePercent/100)*handles.autoDesireVoltage)...
                && (handles.effectiveVoltage < handles.autoDesireVoltage))
            R = handles.autoVoltageRateMin;
        elseif(handles.effectiveVoltage > handles.autoDesireVoltage)
            R = -handles.autoVoltageRateMin;
        elseif(handles.effectiveVoltage == handles.autoDesireVoltage)
            R = 0;
        end

        % Calculate target nominal voltage
        dT = (handles.Voltage(handles.CurrTimePoint,1) - handles.Voltage(i,1))*24*3600;

        if(dT > 0 && (dT < 5.0))
            handles.nominalVoltage = handles.nominalVoltage + (dT)*(R/60);
        else
            handles.nominalVoltage = handles.nominalVoltage + (2.0)*(R/60);
        end
        if(handles.nominalVoltage <= 0)
            handles.nominalVoltage = 0;
        end
        handles.Voltage(handles.CurrTimePoint,2) = handles.nominalVoltage;
        
        % Set target nominal voltage
        set(handles.figGUI_panHV_NomVoltage,'String',num2str(handles.nominalVoltage,'%.3f'));
    end

    % DEBUGGING
    %fprintf(1,'V_auto = %.2f kV \t V_eff = %.2f kV \t R = %.1f kV/min \t V_tar = %.2f kV\n',handles.autoDesireVoltage,handles.effectiveVoltage,R,handles.nominalVoltage);

    % Save handles in base workspace
    assignin('base','handles',handles)
    
end