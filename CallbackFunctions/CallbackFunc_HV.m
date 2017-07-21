

% Callback function for HV
function [] = CallbackFunc_HV(hObject, event, funcName, rowcol)

    % Load handles from base workspace
    handles = evalin('base','handles');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    switch(funcName)

        case('connect HV')
            
            % Disable menu item (HV COM settings)
            set(handles.figGUI_menuHV_menuCOM, 'Enable', 'off');
            
            % Disable connect menu
            set(handles.figGUI_menuHV_menuConnect, 'Enable', 'off');

            % Change status
            handles.HV_comStatus = 'Connecting to server...';
            set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);

            % Change COM status box
            set(handles.figGUI_panHV_COMStatus, 'Enable', 'on');
            set(handles.figGUI_panHV_COMStatus, 'BackgroundColor', 'yellow');
            set(handles.figGUI_panHV_COMStatus, 'String', '!');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];
            handles.HV_serverObj = [];
            
            % Connect to server         
            [handles.HV_serverObj, err] = OpenServerConnection(...
                'open_serial', ...
                handles.HV_serverIP, ...
                handles.HV_serverPort...
                );
            
            handles.com_timeLastCOM.HV = now - handles.timer_timeNow;

            % Wait for server response
            pause(handles.com_waitTime.client_server);

            % Receive answer
            if(numel(err) < 1)
                [handles.HV_serverObj, serverAns, err] = SendReceiveSerial('receive', handles.HV_serverObj, [], []);
                 handles.com_timeLastCOM.HV = now - handles.timer_timeNow;
            end

            % Check for connection errors
            if(strcmp(serverAns, 'Connected to server!') > 0)
                
                % Change COM status
                handles.HV_comStatus = 'Connected to server!';
                set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);
                set(handles.figGUI_panHV_comStatus, 'Enable', 'on');  

                % Enable control menu
                set(handles.figGUI_menuHV_menuDiscon, 'Enable', 'on');

                % Open serial COM port to device
                serverCmd = sprintf('open COM%s %s %s', handles.HV_comPort, handles.HV_comBaudRate, handles.HV_comFlowControl);
                [handles.HV_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.HV_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                
                handles.com_timeLastCOM.HV = now - handles.timer_timeNow;
                

                if(strcmp(serverAns, 'COM successfully opened') > 0)    
                    % Change status
                    handles.HV_comStatus = 'COM successfully opened!';
                    set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);

                    % Change COM status box
                    set(handles.figGUI_panHV_COMStatus, 'BackgroundColor', 'green');
                    set(handles.figGUI_panHV_COMStatus, 'String', 'O');

                    % Disable menu
                    set(handles.figGUI_menuHV_menuConnect, 'Enable', 'off');
                    set(handles.figGUI_menuHV_menuStatus, 'Enable', 'on');
                    if(strcmp(get(handles.timer_obj,'Running'), 'on') == 1)
                        set(handles.figGUI_panHV_start, 'Enable', 'on');
                        set(handles.figGUI_panHV_ArcStatus, 'Enable', 'on');
                        set(handles.figGUI_panHV_AutoStatus, 'Enable', 'on');
                        set(handles.figGUI_panHV_shutdown, 'Enable', 'on');
                        set(handles.figGUI_panHV_NomVoltage, 'Enable', 'on');
                        set(handles.figGUI_panHV_NomVoltageAdd, 'Enable', 'on');
                        set(handles.figGUI_panHV_NomVoltageMinus, 'Enable', 'on');
                    end

                    
                    % Update device state
                    handles.com_devState_HV = 1;

                else
                    
                    % Change COM status box
                    set(handles.figGUI_panHV_COMStatus, 'Enable', 'on');
                    set(handles.figGUI_panHV_COMStatus, 'BackgroundColor', 'red');
                    set(handles.figGUI_panHV_COMStatus, 'String', 'X');

                    % Change status
                    handles.HV_comStatus = 'COM failed to open!';
                    set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);

                end

            else

                % Change COM status box
                set(handles.figGUI_panHV_COMStatus, 'Enable', 'on');
                set(handles.figGUI_panHV_COMStatus, 'BackgroundColor', 'red');
                set(handles.figGUI_panHV_COMStatus, 'String', 'X');

                % Change COM status
                handles.HV_comStatus =  'Server connection failed!';
                set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);

                % Re-enable connect menu
                set(handles.figGUI_menuHV_menuConnect, 'Enable', 'on');

                % Re-enable time stage COM sub-menu
                set(handles.figGUI_menuHV_menuCOM, 'Enable', 'on');

            end

        case('disconnect HV')
            
            % Disable menu
            set(handles.figGUI_menuHV_menuDiscon, 'Enable', 'off');

            % Change status
            handles.HV_comStatus = 'Disconnecting from server...';
            set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);

            % Change COM status box
            set(handles.figGUI_panHV_COMStatus, 'BackgroundColor', 'yellow');
            set(handles.figGUI_panHV_COMStatus, 'String', '!');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];

            % Close serial COM port
            serverCmd = 'close';
            [handles.HV_serverObj, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.HV_serverObj, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.HV = now - handles.timer_timeNow;
            
            % Change status
            if(strcmp(serverAns, 'COM successfully closed') > 0)

                % Update device state
                handles.com_devState_HV = 0;
                
                % Save handles in base workspace
                assignin('base','handles',handles)
                
                handles.HV_comStatus = sprintf('COM successfully closed!');
                set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);
            else

                handles.HV_comStatus = sprintf('COM failed to close!');
                set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);
            end

            % Disconnect from server
            serverCmd = 'close_serial';
            CloseServerConnection(handles.HV_serverObj, serverCmd);
            handles.com_timeLastCOM.HV = now - handles.timer_timeNow;

            handles.HV_serverObj = [];

            % Change status
            handles.stage_comStatus = 'Disconnected from server!';
            set(handles.figGUI_panHV_comStatus, 'String', handles.HV_comStatus);
            set(handles.figGUI_panHV_comStatus, 'Enable', 'off');

            % Change COM status box
            set(handles.figGUI_panHV_COMStatus, 'BackgroundColor', 'red');
            set(handles.figGUI_panHV_COMStatus, 'String', 'X');

            % Change COM menu
            set(handles.figGUI_menuHV_menuConnect, 'Enable', 'on');

            % Re-enable menu item (HV COM settings)
            set(handles.figGUI_menuHV_menuCOM, 'Enable', 'on');
            set(handles.figGUI_menuHV_menuStatus, 'Enable', 'off');
            set(handles.figGUI_panHV_comStatus, 'Enable', 'off');
            set(handles.figGUI_panHV_ArcStatus, 'Enable', 'off');
            set(handles.figGUI_panHV_AutoStatus, 'Enable', 'off');
            set(handles.figGUI_panHV_start, 'Enable', 'off');
            set(handles.figGUI_panHV_shutdown, 'Enable', 'off');
            set(handles.figGUI_panHV_NomVoltage, 'Enable', 'off');
            set(handles.figGUI_panHV_NomVoltageAdd, 'Enable', 'off');
            set(handles.figGUI_panHV_NomVoltageMinus, 'Enable', 'off');
            
        case('Arc detection')
            
            % Set Arc Protection to 'ON'
            if(get(handles.figGUI_panHV_ArcStatus, 'Value') == 1)

                handles.StatusArcDetect = 1;            

                % Get detection parameters
                handles.arcThreshCurrent = str2double(handles.HV.cmdList(15));
                handles.arcThreshVoltage = str2double(handles.HV.cmdList(16));

            else
                handles.StatusArcDetect = 0;
            end
        
        case('Autoconditioning')
            
            if(get(handles.figGUI_panHV_AutoStatus, 'Value') == 1)

                % Set auto-conditioning to 'ON'
                handles.StatusAutoCondition = 1;

                % Calculate parameters
                handles.autoDesireVoltage = str2double(handles.HV.cmdList(9));
                handles.autoThreshVoltagePercent = str2double(handles.HV.cmdList(12));
                handles.autoVoltageRateMin = str2double(handles.HV.cmdList(14));
                handles.autoVoltageRateMax = str2double(handles.HV.cmdList(13));
                
                set(handles.figGUI_menuHV_menuStatus, 'Enable', 'off')

            else
                
                % Set auto-conditioning to 'OFF'
                handles.StatusAutoCondition = 0;
                
                set(handles.figGUI_menuHV_menuStatus, 'Enable', 'on')

            end
            
        case('Start')

            % Start device control
            if((handles.com_devState_HV_start == 0) || (handles.com_devState_HV_start == 2))

                % Disable buttons temporarily
                set(handles.figGUI_panHV_start, 'String', 'Starting...');
                set(handles.figGUI_panHV_start, 'Enable', 'off');
                set(handles.figGUI_panHV_shutdown, 'Enable', 'off');

                handles.com_devState_HV_start = 1;

                % Enable control buttons
                set(handles.figGUI_panHV_start, 'String', 'Pause');
                set(handles.figGUI_panHV_start, 'Enable', 'on');
                set(handles.figGUI_panHV_shutdown, 'Enable', 'on');

            % Pause device control
            elseif(handles.com_devState_HV_start == 1)

                handles.com_devState_HV_start = 2;

                set(handles.figGUI_panHV_start, 'String', 'Restart');
            else
                errordlg('COM and/or device status: offline', 'Start Error');
            end


        case('Shutdown')

            % Disable buttons temporarily
            set(handles.figGUI_panHV_shutdown, 'String', 'Shutdown...');
            set(handles.figGUI_panHV_start, 'Enable', 'off');
            set(handles.figGUI_panHV_shutdown, 'Enable', 'off');

            % Shutdown for 'paused' state
            if(handles.com_devState_HV_start == 2)
                handles.com_devState_HV_start = 3;
            end


            % Change interface
            handles.com_devState_HV_start = 0;
            set(handles.figGUI_panHV_start, 'String', 'Start');
            set(handles.figGUI_panHV_shutdown, 'String', 'Shutdown');
            set(handles.figGUI_panHV_start, 'Enable', 'on');
            set(handles.figGUI_panHV_shutdown, 'Enable', 'off');
            set(handles.figGUI_panHV_ArcStatus, 'Enable', 'off');
            set(handles.figGUI_panHV_AutoStatus, 'Enable', 'off');
            set(handles.figGUI_panHV_NomVoltage, 'Enable', 'off');
            set(handles.figGUI_panHV_NomVoltageAdd, 'Enable', 'off');
            set(handles.figGUI_panHV_NomVoltageMinus, 'Enable', 'off');

            set(handles.figGUI_panHV_NomVoltage,'String','0.00');
            
            
        case('Nominal voltage')
            
            if(~isnan(str2double(get(handles.figGUI_panHV_NomVoltage, 'String'))))
                handles.nominalVoltage = str2double(get(handles.figGUI_panHV_NomVoltage, 'String'));
            end

            set(handles.figGUI_panHV_NomVoltage, 'String',num2str(handles.nominalVoltage, '%.3f'));

            
        case('Nominal voltage add')

            handles.nominalDeltaVoltage = str2double(handles.HV.cmdList(11));

            % Calculate new nominal value
            handles.nominalVoltage = handles.nominalVoltage + handles.nominalDeltaVoltage;

            % Update nominal value
            set(handles.figGUI_panHV_NomVoltage, 'String',num2str(handles.nominalVoltage, '%.3f'));
        
        case('Nominal voltage minus')

            handles.nominalDeltaVoltage = str2double(handles.HV.cmdList(11));

            % Calculate new nominal value
            handles.nominalVoltage = handles.nominalVoltage - handles.nominalDeltaVoltage;

            % Update nominal value
            set(handles.figGUI_panHV_NomVoltage, 'String',num2str(handles.nominalVoltage, '%.3f'));
            
        case('status')
            
            if(exist('hObject') == 0 || isempty(hObject) == 1)
                hObject = handles.HVtable;
            end
            
            try
                data = get(hObject,'Data');

                row = rowcol(1);
                column = rowcol(2);

                if (~isempty(data(row,column)))
                    numConfigParam = numel(handles.HV.cmdList)/3;
                    handles.HV.cmdList(row+numConfigParam) = data(row,column);
                end
            catch
                disp('Error: new values were not applied')
            end


%             set(hObject,'Data',handles.HV.cmdList);

            % Save handles in base workspace
            assignin('base','handles',handles)
            
            
            
%             numConfigParam = numel(handles.HV.cmdList)/3;
%             
% %             handles.com_timeLastCOM.HV = now - handles.timer_timeNow;
% 
%             currVal = {};
%             units = {};
%             for(j = 1:numConfigParam)
%                 descrip{j,1} = handles.HV.cmdList{j};
%                 currVal{j,1} = handles.HV.cmdList{j+numConfigParam};
%                 units{j,1} = handles.HV.cmdList{j+2*numConfigParam};
%             end
%             
%             % Set data in configuration parameter table
%             set(handles.figGUI_menuHV_menuConfig_fig_table, 'Data', [descrip, currVal, units]);

    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Save handles in base workspace
    assignin('base','handles',handles)
    
    % Restart timer
    if(strcmp(handles.timer_status, 'on') > 0)
        start(handles.timer_obj);
        disp('Timer restarted')
    end
    
end
