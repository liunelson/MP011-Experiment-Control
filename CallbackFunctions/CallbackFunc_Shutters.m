% Callback function for shutter control
function CallbackFunc_Shutters(hObject, event, funcName, label)

    % Load handles from base workspace
    handles = evalin('base','handles');

    switch(funcName(1:7))

        case('connect')

            % Change status
            handles.shutters_comStatus = 'Connecting to server...';
            set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);

            % Disable shutters COM sub-menu
            set(handles.figGUI_menuShutters_menuCOM, 'Enable', 'off');

            % Disable connect button
            set(handles.figGUI_panShutters_buttConn, 'Enable', 'off');

            % Initialize shutters communication
            j = 0;
            for(i = 1:3)

                % Initialize variables
                serverCmd = [];
                serverAns = [];
                err = [];
                handles.shutters_serverObj{i} = [];      

                % Do only for checkmarked shutters
                if(get(handles.figGUI_panShutters_check(i), 'Value') > 0)
                    
                    % Change COM status box
                    set(handles.figGUI_panShutters_COMStatus(i), 'Enable', 'on');
                    set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'yellow');
                    set(handles.figGUI_panShutters_COMStatus(i), 'String', '!');

                    % Connect to server            
                    [handles.shutters_serverObj{i}, err] = OpenServerConnection(...
                        'open_serial', ...
                        handles.shutters_serverIP{i}, ...
                        handles.shutters_serverPort{i}...
                        );
                    handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;

                    % Wait for server response
                    pause(handles.com_waitTime.client_server);

                    % Receive answer
                    if(numel(err) < 1)
                        [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial('receive', handles.shutters_serverObj{i}, [], []);
                        handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;
                    end

                    % Check for connection errors
                    if(strcmp(serverAns, 'Connected to server!') > 0)

                        % Update device state
                        handles.com_devState_shutters{i} = 1;

                        % Change COM status
                        set(handles.figGUI_panShutters_COMStatus(i), 'String', 'C');
                        
                        handles.shutters_comStatus = sprintf('Shutter %d: Connected to server!', i);
                        set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                        set(handles.figGUI_panShutters_shuttersCOMStatus, 'Enable', 'on');

                        % Enable control buttons
                        set(handles.figGUI_panShutters_buttDiscon, 'Enable', 'on');

                        % Open serial COM port to device
                        serverCmd = sprintf('open COM%s %s %s', handles.shutters_comPort{i}, handles.shutters_comBaudRate{i}, handles.shutters_comFlowControl{i});
                        [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.shutters_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );
                        handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;

                        if(strcmp(serverAns, 'COM successfully opened') > 0)

                            % Enable control buttons
                            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'green');
                            set(handles.figGUI_panShutters_COMStatus(i), 'String', 'O');
                            set(handles.figGUI_panShutters_ShutStatus(i), 'Enable', 'on');
                            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'on');
                            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'on');
                            set(handles.figGUI_menuShutters_menuTrigger_shutterList(i), 'Enable', 'on');
                            set(handles.figGUI_menuShutters_menuReset_shutterList(i), 'Enable', 'on');

                            handles.shutters_comStatus = sprintf('Shutter %d: COM successfully opened!', i);
                            set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                        else
                          
                            handles.shutters_comStatus = sprintf('Shutter %d: COM failed to open!', i);
                            set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);

                        end
                    end

                    % Check for error
                    if(numel(err) > 0)

                        % Re-enable connect button
                        set(handles.figGUI_panShutters_buttConn, 'Enable', 'on');

                        % Re-enable shutters COM sub-menu
                        set(handles.figGUI_menuShutters_menuCOM, 'Enable', 'on');

                        % Change COM status
                        set(handles.figGUI_panShutters_COMStatus(i), 'String', 'X');
                        set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'red');

                        handles.shutters_comStatus = sprintf('Shutter %d: Server connection failed!', i);
                        set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                    end    
                else

                    j = j + 1;

                end

            end

            if(j == 3)

                % Change status
                handles.shutters_comStatus = sprintf('No server selected!', i);
                set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);

                % Re-enable connect button
                set(handles.figGUI_panShutters_buttConn, 'Enable', 'on');

                % Re-enable shutters COM sub-menu
                set(handles.figGUI_menuShutters_menuCOM, 'Enable', 'on');

            end

            % Change status
            if(strcmp(serverAns, 'COM successfully opened') > 0)
                handles.shutters_comStatus = sprintf('Shutters ready!', i);
                set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
            end

        case('disconn')

            % Change status
            set(handles.figGUI_panShutters_buttDiscon, 'Enable', 'off');

            handles.shutters_comStatus = 'Disconnecting from server...';
            set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);

            % Disconnect from shutters
            for(i = 1:3)

                % Do only for checkmarked shutters
                if(get(handles.figGUI_panShutters_check(i), 'Value') > 0)

                    % Change COM status box
                    set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'yellow');
                    set(handles.figGUI_panShutters_COMStatus(i), 'String', '!');

                    serverCmd = [];
                    serverAns = [];
                    err = [];

                    % Close serial COM port
                    serverCmd = 'close COM';
                    [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.shutters_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );
                    handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;
                    
                    % Change status
                    if(strcmp(serverAns, 'COM successfully closed') > 0)

                        handles.shutters_comStatus = sprintf('Shutter %d: COM successfully closed!', i);
                        set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                    else

                        handles.shutters_comStatus = sprintf('Shutter %d: COM failed to close!', i);
                        set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                    end

                    % Disconnect from server
                    serverCmd = 'close_serial';
                    CloseServerConnection(handles.shutters_serverObj{i}, serverCmd);
                    handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;

                    if(numel(err) < 1)

                        % Update device state
                        handles.com_devState_shutters{i} = 0;

                        % Disable control buttons
                        set(handles.figGUI_panShutters_buttO(i), 'Enable', 'off');
                        set(handles.figGUI_panShutters_buttX(i), 'Enable', 'off');
                        set(handles.figGUI_menuShutters_menuTrigger_shutterList(i), 'Enable', 'off');
                        set(handles.figGUI_menuShutters_menuReset_shutterList(i), 'Enable', 'off');

                        % Change COM status
                        set(handles.figGUI_panShutters_COMStatus(i), 'String', 'X');
                        set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'red');

                        % Change control status
                        set(handles.figGUI_panShutters_ShutStatus(i), 'Enable', 'off');
                        set(handles.figGUI_panShutters_ShutStatus(i), 'BackgroundColor', 'yellow');

                    end

                    handles.shutters_serverObj{i} = [];
                end
            end

            % Change status
            handles.shutters_comStatus = 'Disconnected from server!';
            set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
            set(handles.figGUI_panShutters_shuttersCOMStatus, 'Enable', 'off');

            % Change COM button
            set(handles.figGUI_panShutters_buttConn, 'Enable', 'on');

            % Enable shutters COM sub-menu
            set(handles.figGUI_menuShutters_menuCOM, 'Enable', 'on');

        case('open sh')

            % Shutter ID
            i = str2num(funcName(14));

            % Disable control buttons
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'off');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'off');

            % Do only for checkmarked shutters
            if((get(handles.figGUI_panShutters_check(i), 'Value') > 0) && (strcmp(get(handles.figGUI_panShutters_COMStatus(i), 'String'), 'O') > 0))

                % Change COM status box
                set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'yellow');
                set(handles.figGUI_panShutters_COMStatus(i), 'String', '!');

                % Send open shutter command
                serverCmd = sprintf('sendrcv %s %s', handles.shutters_comTermChar{i}, handles.shutters_cmd.Open);
                [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.shutters_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;
                    
                % Change status
                if(strcmp(serverAns, handles.shutters_cmd.Open) > 0)

                    handles.shutters_comStatus = sprintf('Shutter %d: Opened successfully', i);
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);

                    set(handles.figGUI_panShutters_ShutStatus(i), 'String', 'O');
                    set(handles.figGUI_panShutters_ShutStatus(i), 'BackgroundColor', 'green');
                else

                    handles.shutters_comStatus = sprintf('Shutter %d: Open failed!', i);
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                end


            end

            % Change status
            set(handles.figGUI_panShutters_COMStatus(i), 'String', 'O');
            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'green');

            % Enable control buttons
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'on');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'on');
            
        case('close s')

            % Shutter ID
            i = str2num(funcName(15));

            % Disable control buttons
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'off');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'off');


            % Do only for checkmarked shutters
            if((get(handles.figGUI_panShutters_check(i), 'Value') > 0) && (strcmp(get(handles.figGUI_panShutters_COMStatus(i), 'String'), 'O') > 0))

                % Change COM status box
                set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'yellow');
                set(handles.figGUI_panShutters_COMStatus(i), 'String', '!');

                % Send close shutter command
                serverCmd = sprintf('sendrcv %s %s', handles.shutters_comTermChar{i}, handles.shutters_cmd.Close);
                [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.shutters_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;
                    
                % Change status
                if(strcmp(serverAns, handles.shutters_cmd.Close) > 0)

                    handles.shutters_comStatus = sprintf('Shutter %d: Closed successfully!', i) ;
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String',handles.shutters_comStatus);
                    set(handles.figGUI_panShutters_ShutStatus(i), 'String', 'X');
                    set(handles.figGUI_panShutters_ShutStatus(i), 'BackgroundColor', 'red');
                else

                    handles.shutters_comStatus = sprintf('Shutter %d: Close failed!', i);
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                end


            end

            % Change status
            set(handles.figGUI_panShutters_COMStatus(i), 'String', 'O');
            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'green');

            % Enable control buttons
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'on');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'on');

        case('trigger')

            % Get shutter name
            shutterName = label; %get(hObject, 'Label');
            i = str2num(shutterName(end));
            
            eval(sprintf('hObject = handles.figGUI_menuShutters_menuTrigger_shutterList(%d);',i));

            % Disable control buttons
            set(hObject, 'Enable', 'off');
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'off');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'off');

            % Do only if connected
            if((strcmp(get(handles.figGUI_panShutters_COMStatus(i), 'String'), 'O') > 0))

                % Change COM status box
                set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'yellow');
                set(handles.figGUI_panShutters_COMStatus(i), 'String', '!');

                % Send open shutter command
                serverCmd = sprintf('sendrcv %s %s', handles.shutters_comTermChar{i}, handles.shutters_cmd.Trigger);
                [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.shutters_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;
                    
                % Change status
                if(strcmp(serverAns, handles.shutters_cmd.Trigger) > 0)

                    handles.shutters_comStatus = sprintf('Shutter %d: set to trigger control successfully', i);
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);

                    set(handles.figGUI_panShutters_ShutStatus(i), 'String', 'T');
                    set(handles.figGUI_panShutters_ShutStatus(i), 'BackgroundColor', 'cyan');
                else

                    handles.shutters_comStatus = sprintf('Shutter %d: set to trigger control failed!', i);
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                end


            end

            % Change status
            set(handles.figGUI_panShutters_COMStatus(i), 'String', 'O');
            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'green');

            % Enable control buttons
            set(hObject, 'Enable', 'on');
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'on');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'on');

        case('reset c')

            % Get shutter name
            shutterName = label; %get(hObject, 'Label');
            i = str2num(shutterName(end));

            eval(sprintf('hObject = handles.figGUI_menuShutters_menuTrigger_shutterList(%d);',i));
                        
            % Change COM status box
            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panShutters_COMStatus(i), 'String', '!');

            % Disable control buttons
            set(hObject, 'Enable', 'off');
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'off');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'off');
            

            % Do only if connected
            if((strcmp(get(handles.figGUI_panShutters_COMStatus(i), 'String'), '!') > 0))

                % Send open shutter command
                serverCmd = sprintf('sendrcv %s %s', handles.shutters_comTermChar{i}, handles.shutters_cmd.Reset);
                [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.shutters_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;
                    
                % Change status
                if(strcmp(serverAns, handles.shutters_cmd.Reset) > 0)

                    handles.shutters_comStatus = sprintf('Shutter %d: set to trigger control successfully', i);
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);

                    set(handles.figGUI_panShutters_ShutStatus(i), 'String', 'R');
                    set(handles.figGUI_panShutters_ShutStatus(i), 'BackgroundColor', 'magenta');
                else

                    handles.shutters_comStatus = sprintf('Shutter %d: set to trigger control failed!', i);
                    set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);
                end


            end

            % Change status
            set(handles.figGUI_panShutters_COMStatus(i), 'String', 'O');
            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'green');

            % Enable control buttons
            set(hObject, 'Enable', 'on');
            set(handles.figGUI_panShutters_buttO(i), 'Enable', 'on');
            set(handles.figGUI_panShutters_buttX(i), 'Enable', 'on');

    end

    % Restart timer
    if(strcmp(handles.timer_status, 'on') > 0)
        start(handles.timer_obj);
        disp('Timer restarted')
    end

	% Save handles in base workspace
    assignin('base','handles',handles)
    
end
