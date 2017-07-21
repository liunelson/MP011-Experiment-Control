% Callback function for oscilloscope
function [] = CallbackFunc_Oscilloscope(hObject, event, funcName, hValueedit)

    % Load handles from base workspace
    handles = evalin('base','handles');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    err = [];

    switch(funcName)

        case('connect oscilloscope')

            % Write resource name of oscilloscope
            handles.Oscilloscope_Visa = sprintf('TCPIP0::%s::inst0::INSTR', handles.OscilloscopeIP);

            % Check interface object
            if(isempty(handles.interfaceOscilloscope))

                hInt = instrfindall('Type', 'visa-tcpip', 'RemoteHost', handles.OscilloscopeIP);
                if(isempty(hInt))
                    handles.interfaceOscilloscope = visa('NI', handles.Oscilloscope_Visa);
                else
                    handles.interfaceOscilloscope = hInt;
                end

                clear hInt;

                % Check device object
                if(isempty(handles.deviceOscilloscope))

                    hDev = instrfindall('Type', 'scope');
                    if(isempty(hDev))
                        handles.deviceOscilloscope = icdevice('tektronix_dpo2024.mdd', handles.interfaceOscilloscope);
                    else

                        if(strcmp(hDev.Interface.RemoteHost, handles.OscilloscopeIP))
                            handles.deviceOscilloscope = hDev;
                        else
                            delete(hDev);
                            handles.deviceOscilloscope = icdevice('tektronix_dpo2024.mdd', handles.interfaceOscilloscope);
                        end
                    end

                    clear hDev;
                end
            end

            % Check current device status
            if(strcmp(handles.deviceOscilloscope.Status, 'closed') == 1)

                % Try to connect device
                try
                    connect(handles.deviceOscilloscope);
        
                    % Wait for server response
                    pause(handles.com_waitTime.client_server);

                    % Update device state
                    handles.com_devState_oscilloscope = 1;

                    % Enable menu item
                    set(handles.figGUI_menuOscilloscope_menuStatus, 'Enable', 'on');
                    set(handles.figGUI_menuOscilloscope_menuDisconnect, 'Enable', 'on');

                    % Disable button
                    set(handles.figGUI_menuOscilloscope_menuConnect, 'Enable', 'off');

                catch ME
                    rethrow(ME);
                end

             end

        case('disconnect oscilloscope')
            

            % Disconnect from oscilloscope
            try

                disconnect(handles.deviceOscilloscope);
                handles.com_devState_oscilloscope = 0;

                % Enable menu item
                set(handles.figGUI_menuOscilloscope_menuConnect, 'Enable', 'on');
                
                % Disable menu item
                set(handles.figGUI_menuOscilloscope_menuDisconnect, 'Enable', 'off');
                set(handles.figGUI_menuOscilloscope_menuStatus, 'Enable', 'off');
                handles.oscilloscope_serverObj = [];
                
                % Update device state
                handles.com_devState_oscilloscope = 0;

            catch ME
                rethrow(ME)
            end
            
            case('set measurement')
                
                % Set measurement value
                if(get(hObject,'Value') ~= 1)
                    measurement = get(hObject,'String');
                    handles.oscilloscope.active_measurement = char(measurement(get(hObject,'Value')));
                    handles.oscilloscope.lastselected_measurement = handles.oscilloscope.active_measurement;
                    set(handles.deviceOscilloscope.Measurement(1), 'MeasurementType', handles.oscilloscope.active_measurement);
                    set(handles.deviceOscilloscope.Measurement(1), 'State', 'ON');
                end
                
                if(~isempty(handles.oscilloscope.active_source))
                    value = get(handles.deviceOscilloscope.Measurement(1), 'Value');
                    units = get(handles.deviceOscilloscope.Measurement(1), 'Units');
                    set(hValueedit,'String',sprintf('%4.2e %s',value,units));
                end
                
            case('set channel')
                
                % Set measurement value
                if(get(hObject,'Value') ~= 1)
                    source = get(hObject,'String');
                    handles.oscilloscope.active_source = char(source(get(hObject,'Value')));
                    handles.oscilloscope.lastselected_source = handles.oscilloscope.active_source;
                    set(handles.deviceOscilloscope.Measurement(1), 'Source', handles.oscilloscope.active_source);
                    set(handles.deviceOscilloscope.Measurement(1), 'State', 'ON');
                end
                
                if(~isempty(handles.oscilloscope.active_measurement))
                    value = get(handles.deviceOscilloscope.Measurement(1), 'Value');
                    units = get(handles.deviceOscilloscope.Measurement(1), 'Units');
                    set(hValueedit,'String',sprintf('%4.2e %s',value,units));
                end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Restart timer
    if(strcmp(handles.timer_status, 'on') > 0)
        start(handles.timer_obj);
        disp('Timer restarted')
    end

	% Save handles in base workspace
    assignin('base','handles',handles)
    
end