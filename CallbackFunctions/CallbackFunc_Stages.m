

% Callback function for time stage control
function CallbackFunc_Stages(hObject, event, funcName, label)

    % Load handles from base workspace
    handles = evalin('base','handles');
    
    switch(funcName)

        case {'connect 1', 'connect 2', 'connect 3'}
            
            i = str2num(funcName(end));

            % Disable menu item (stage COM settings)
            set(handles.figGUI_menuStages_menuCOM, 'Enable', 'off');

            % Disable connect button
            set(handles.figGUI_panStages_buttConn(i), 'Enable', 'off');

            % Change status
            handles.stages_comStatus{i} = 'Connecting to server...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];
            handles.stages_serverObj{i} = [];

            % Connect to server         
            [handles.stages_serverObj{i}, err] = OpenServerConnection(...
                'open_serial', ...
                handles.stages_serverIP{i}, ...
                handles.stages_serverPort{i}...
                );

            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

            % Wait for server response
            pause(handles.com_waitTime.client_server);

            % Receive answer
            if(numel(err) < 1)
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial('receive', handles.stages_serverObj{i}, [], []);
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
            end

            % Check for connection errors
            if(strcmp(serverAns, 'Connected to server!') > 0)

                % Change COM status
                handles.stages_comStatus{i} = 'Connected to server!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
                set(handles.figGUI_panStages_comStatus(i), 'Enable', 'on');  

                % Enable control buttons
                set(handles.figGUI_panStages_buttDiscon(i), 'Enable', 'on');

                % Open serial COM port to device
                serverCmd = sprintf('open COM%s %s %s', handles.stages_comPort{i}, handles.stages_comBaudRate{i}, handles.stages_comFlowControl{i});
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
                

                if(strcmp(serverAns, 'COM successfully opened') > 0)

                    % Change status
                    handles.stages_comStatus{i} =  'COM successfully opened!';
                    set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                    % Change COM status box
                    set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                    set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

                    % Enable menu item
                    set(handles.figGUI_menuStages_menuReset_stageList(i), 'Enable', 'on');
                    set(handles.figGUI_menuStages_menuHome_stageList(i), 'Enable', 'on');
                    set(handles.figGUI_menuStages_menuConfig_stageList(i), 'Enable' ,'on');

                    % Disable button
                    set(handles.figGUI_panStages_buttConn(i), 'Enable', 'off');

                    % Enable control buttons
                    set(handles.figGUI_panStages_buttGo(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_buttStop(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_opMode(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_value(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_currentPos(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_targetPos(i), 'Enable', 'on');
                    
                    switch i
                        
                        case 1
                            set(handles.figGUI_panScan2_HoriMin, 'Enable', 'on');
                            set(handles.figGUI_panScan2_HoriStep, 'Enable', 'on');
                            set(handles.figGUI_panScan2_HoriMax, 'Enable', 'on');
                            
                        case 2
                            set(handles.figGUI_panScan2_VertMin, 'Enable', 'on');
                            set(handles.figGUI_panScan2_VertStep, 'Enable', 'on');
                            set(handles.figGUI_panScan2_VertMax, 'Enable', 'on');
                    
                        case 3
                            set(handles.figGUI_panScan2_ZMin, 'Enable', 'on');
                            set(handles.figGUI_panScan2_ZStep, 'Enable', 'on');
                            set(handles.figGUI_panScan2_ZMax, 'Enable', 'on');
                            
                    end
                    
                    % Send command
                    serverAns = [];
                    err = [];

                    serverCmd = sprintf('sendrcv %s %s1:%s:%s:%s1', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Operation, handles.stages_cmd{i}.GetConfig, handles.stages_cmd{i}.Operation, handles.stages_cmd{i}.Scale);
                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );
                    
                    temp = textscan(serverAns,'%s ','Delimiter','>');

                    currVal = {};
                    for(j = 1:numel(temp{1}))
                        currVal{j,1} = regexprep(temp{1}{j},'[^\d.-]','');
                    end

                    set(handles.figGUI_panStages_targetPos(i),'String','0.0');

                    currpos = num2str(str2double(char(currVal{2,1}))*handles.stages_scalefactor{i},'%.1f');
                    set(handles.figGUI_panStages_currentPos(i),'String',currpos);
                    currdis = str2double(currVal{5,1})*handles.stages_scalefactor{i};
                    
                    if strcmp(char(currVal{9,1}),'1') == 1
                        set(handles.figGUI_panStages_opMode(i),'Value',1);
                    else
                        set(handles.figGUI_panStages_opMode(i),'Value',2);
                        if (currdis < 0)
                            
                            newval = num2str(-currdis/handles.stages_scalefactor{i});

                            serverAns = [];
                            err = [];
                            serverCmd = sprintf('sendrcv %s %s%s', handles.stages_comTermChar{i},handles.stages_cmd{1}.GetDistance,newval);
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                'send_receive', ...
                                handles.stages_serverObj{i}, ...
                                serverCmd, ...
                                handles.com_waitTime.client_server, ...
                                handles.com_numTry...
                                );
                        end
                        
                    end
                    

                    if get(handles.figGUI_panStages_opMode(i),'Value') ~= 1
                        set(handles.figGUI_panStages_dir(i), 'Enable', 'on');
                    end
                    
                    serverAns = [];
                    err = [];
                    
                    if(i == 3)
                        serverCmd = sprintf('sendrcv %s %s0:%s5', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Encoder, handles.stages_cmd{i}.GetVel);
                        [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );
                    else
                        serverCmd = sprintf('sendrcv %s %s0', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Encoder);
                        [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );
                    end
                    
                        % Update device state
                        handles.com_devState_stages{i} = 1;
                        
                        % Save handles in base workspace
                        assignin('base','handles',handles)

                else
                    
                    % Change COM status box
                    set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'red');
                    set(handles.figGUI_panStages_COMStatus(i), 'String', 'X');

                    % Change status
                    handles.stages_comStatus{i} = 'COM failed to open!';
                    set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                end

            else

                % Change COM status box
                set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'red');
                set(handles.figGUI_panStages_COMStatus(i), 'String', 'X');

                % Change COM status
                handles.stages_comStatus{i} =  'Server connection failed!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                % Re-enable connect button
                set(handles.figGUI_panStages_buttConn, 'Enable', 'on');

                % Re-enable time stage COM sub-menu
                set(handles.figGUI_menuStages_menuCOM, 'Enable', 'on');

            end
            
        case('connect 4')

            i = str2num(funcName(end));

            % Disable menu item (stage COM settings)
            set(handles.figGUI_menuStages_menuCOM, 'Enable', 'off');

            % Disable connect button
            set(handles.figGUI_panStages_buttConn(i), 'Enable', 'off');

            % Change status
            handles.stages_comStatus{i} = 'Connecting to server...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];
            handles.stages_serverObj{i} = [];

            % Connect to server         
            [handles.stages_serverObj{i}, err] = OpenServerConnection(...
                'open_serial', ...
                handles.stages_serverIP{i}, ...
                handles.stages_serverPort{i}...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

            % Wait for server response
            pause(handles.com_waitTime.client_server);

            % Receive answer
            if(numel(err) < 1)
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial('receive', handles.stages_serverObj{i}, [], []);
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
            end

            % Check for connection errors
            if(strcmp(serverAns, 'Connected to server!') > 0)


                % Change COM status
                handles.stages_comStatus{i} = 'Connected to server!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
                set(handles.figGUI_panStages_comStatus(i), 'Enable', 'on');  

                % Enable control buttons
                set(handles.figGUI_panStages_buttDiscon(i), 'Enable', 'on');

                % Open serial COM port to device
                serverCmd = sprintf('open COM%s %s %s', handles.stages_comPort{i}, handles.stages_comBaudRate{i}, handles.stages_comFlowControl{i});
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

                if(strcmp(serverAns, 'COM successfully opened') > 0)

                    % Change status
                    handles.stages_comStatus{i} =  'COM successfully opened!';
                    set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                    % Change COM status box
                    set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                    set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

                    % Enable menu item
                    set(handles.figGUI_menuStages_menuReset_stageList(i), 'Enable', 'on');
                    set(handles.figGUI_menuStages_menuHome_stageList(i), 'Enable', 'on');
                    set(handles.figGUI_menuStages_menuConfig_stageList(i), 'Enable' ,'on');

                    % Disable button
                    set(handles.figGUI_panStages_buttConn(i), 'Enable', 'off');

                    % Enable control buttons
                    set(handles.figGUI_panStages_buttGo(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_buttStop(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_opMode(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_value(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_currentPos(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_targetPos(i), 'Enable', 'on');
                    
                    set(handles.figGUI_panScan3_TimeMin, 'Enable', 'on');
                    set(handles.figGUI_panScan3_TimeStep, 'Enable', 'on');
                    set(handles.figGUI_panScan3_TimeMax, 'Enable', 'on');

                    
                    % Send command
                    serverAns = [];
                    err = [];

                    serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );
                    
                    positionum = num2str(str2double(serverAns(4:end))*1000, '%.1f');
                    set(handles.figGUI_panStages_targetPos(i),'String','0.0');
                    set(handles.figGUI_panStages_currentPos(i),'String',positionum);  
                                        
                    % Update device state
                    handles.com_devState_stages{i} = 1;
                    
                    % Save handles in base workspace
                    assignin('base','handles',handles)

                    if get(handles.figGUI_panStages_opMode(i),'Value') ~= 1
                        set(handles.figGUI_panStages_dir(i), 'Enable', 'on');
                    end

                else
                    
                    % Change COM status box
                    set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'red');
                    set(handles.figGUI_panStages_COMStatus(i), 'String', 'X');

                    % Change status
                    handles.stages_comStatus{i} = 'COM failed to open!';
                    set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                end

            else

                % Change COM status box
                set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'red');
                set(handles.figGUI_panStages_COMStatus(i), 'String', 'X');

                % Change COM status
                handles.stages_comStatus{i} =  'Server connection failed!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                % Re-enable connect button
                set(handles.figGUI_panStages_buttConn, 'Enable', 'on');

                % Re-enable time stage COM sub-menu
                set(handles.figGUI_menuStages_menuCOM, 'Enable', 'on');

            end

        case('connect 5')

            i = str2num(funcName(end));

            % Disable menu item (stage COM settings)
            set(handles.figGUI_menuStages_menuCOM, 'Enable', 'off');

            % Disable connect button
            set(handles.figGUI_panStages_buttConn(i), 'Enable', 'off');

            % Change status
            handles.stages_comStatus{i} = 'Connecting to server...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];
            handles.stages_serverObj{i} = [];

            % Connect to server         
            [handles.stages_serverObj{i}, err] = OpenServerConnection(...
                'open_serial', ...
                handles.stages_serverIP{i}, ...
                handles.stages_serverPort{i}...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

            % Wait for server response
            pause(handles.com_waitTime.client_server);

            % Receive answer
            if(numel(err) < 1)
                serverCmd = 'getversion';
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );

                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
            end

            
            % Check for connection errors
            if(strcmp(serverAns, 'Connected to server!  5.4 (August 2015)') > 0)

                % Change COM status
                handles.stages_comStatus{i} = 'Connected to server!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
                set(handles.figGUI_panStages_comStatus(i), 'Enable', 'on');  

                % Enable control buttons
                set(handles.figGUI_panStages_buttDiscon(i), 'Enable', 'on');

                
                % Initialize and open
                serverCmd = sprintf('open COM%s %s %s ROT', handles.stages_comPort{i}, handles.stages_comBaudRate{i}, handles.stages_comFlowControl{i});
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

                % Change status
                handles.stages_comStatus{i} =  serverAns;
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                serverAns = strrep(serverAns,'RS-40 controller successfully initialized  ','');
                if(strcmp(serverAns, 'RS-40 COM port successfully opened') > 0)

                    % Change status
                    handles.stages_comStatus{i} =  'COM successfully opened!';
                    set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                    % Change COM status box
                    set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                    set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

                    % Enable menu item
                    set(handles.figGUI_menuStages_menuReset_stageList(i), 'Enable', 'on');
                    set(handles.figGUI_menuStages_menuHome_stageList(i), 'Enable', 'on');
                    set(handles.figGUI_menuStages_menuConfig_stageList(i), 'Enable' ,'on');

                    % Disable button
                    set(handles.figGUI_panStages_buttConn(i), 'Enable', 'off');

                    % Enable control buttons
                    set(handles.figGUI_panStages_buttGo(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_buttStop(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_opMode(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_value(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_currentPos(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_targetPos(i), 'Enable', 'on');
                    
                    set(handles.figGUI_panScan4_RotMin, 'Enable', 'on');
                    set(handles.figGUI_panScan4_RotStep, 'Enable', 'on');
                    set(handles.figGUI_panScan4_RotMax, 'Enable', 'on');

                    
                    % Send command
                    serverAns = [];
                    err = [];

                    serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );
                    
                    rotpos = num2str(str2double(serverAns),'%.1f');
                    set(handles.figGUI_panStages_targetPos(i),'String','0.0');
                    set(handles.figGUI_panStages_currentPos(i),'String',rotpos);  
                    
                    pause(0.2)
                    
                    serverAns = [];
                    err = [];
                    
                    serverCmd = sprintf('sendrcv %s 1.5000 %s', handles.stages_comTermChar{5}, handles.stages_cmd{5}.SetVel);
                    [handles.stages_serverObj{5}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{5}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );

                    
                    % Update device state
                    handles.com_devState_stages{i} = 1;
                    
                    % Save handles in base workspace
                    assignin('base','handles',handles)

                    if get(handles.figGUI_panStages_opMode(i),'Value') ~= 1
                        set(handles.figGUI_panStages_dir(i), 'Enable', 'on');
                    end


                else
                    
                    % Enable button
                    set(handles.figGUI_panStages_buttConn(i), 'Enable', 'on');

                    % Change status
                    handles.stages_comStatus{i} = 'COM failed to open!';
                    set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                    % Change COM status box
                    set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
                    set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'red');
                    set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

                end

            else

                % Enable button
                set(handles.figGUI_panStages_buttConn(i), 'Enable', 'on');
            
                % Change COM status box
                set(handles.figGUI_panStages_COMStatus(i), 'Enable', 'on');
                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'red');
                set(handles.figGUI_panStages_COMStatus(i), 'String', 'X');

                % Change status
                handles.stages_comStatus{i} = 'Failed to initialized!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            end

        case {'disconnect 1', 'disconnect 2', 'disconnect 3', 'disconnect 4', 'disconnect 5'}

            i = str2num(funcName(end));

            % Disable button
            set(handles.figGUI_panStages_buttDiscon(i), 'Enable', 'off');

            % Disable menu item
            set(handles.figGUI_menuStages_menuReset_stageList(i), 'Enable', 'off');
            set(handles.figGUI_menuStages_menuHome_stageList(i), 'Enable', 'off');
            set(handles.figGUI_menuStages_menuConfig_stageList(i), 'Enable' ,'off');

            % Change status
            handles.stages_comStatus{i} = 'Disconnecting from server...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];

            % Close serial COM port
            serverCmd = 'close';
            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.stages_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

            % Change status
            if(strcmp(serverAns, 'COM successfully closed') == 1 || strcmp(serverAns, 'RS-40 COM port successfully closed') == 1)

                % Update device state
                handles.com_devState_stages{i} = 0;
                
                % Save handles in base workspace
                assignin('base','handles',handles)
                
                handles.stages_comStatus{i} = sprintf('COM successfully closed!');
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            else

                handles.stage_comStatus{i} = sprintf('COM failed to close!');
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            end

            % Disconnect from server
            serverCmd = 'close_serial';
            CloseServerConnection(handles.stages_serverObj{i}, serverCmd);
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

            if(numel(err) < 1)

                % Disable control buttons
                set(handles.figGUI_panStages_buttGo(i), 'Enable', 'off');
                set(handles.figGUI_panStages_buttStop(i), 'Enable', 'off');
                set(handles.figGUI_panStages_opMode(i), 'Enable', 'off');
                set(handles.figGUI_panStages_dir(i), 'Enable', 'off');
                set(handles.figGUI_panStages_value(i), 'Enable', 'off');
                set(handles.figGUI_panStages_currentPos(i), 'Enable', 'off');
                set(handles.figGUI_panStages_targetPos(i), 'Enable', 'off');

                switch i

                    case 1
                        set(handles.figGUI_panScan2_HoriMin, 'Enable', 'off');
                        set(handles.figGUI_panScan2_HoriStep, 'Enable', 'off');
                        set(handles.figGUI_panScan2_HoriMax, 'Enable', 'off');

                    case 2
                        set(handles.figGUI_panScan2_VertMin, 'Enable', 'off');
                        set(handles.figGUI_panScan2_VertStep, 'Enable', 'off');
                        set(handles.figGUI_panScan2_VertMax, 'Enable', 'off');

                    case 3
                        set(handles.figGUI_panScan2_ZMin, 'Enable', 'off');
                        set(handles.figGUI_panScan2_ZStep, 'Enable', 'off');
                        set(handles.figGUI_panScan2_ZMax, 'Enable', 'off');
                        
                    case 4
                        set(handles.figGUI_panScan3_TimeMin, 'Enable', 'off');
                        set(handles.figGUI_panScan3_TimeStep, 'Enable', 'off');
                        set(handles.figGUI_panScan3_TimeMax, 'Enable', 'off');
                        
                    case 5
                        set(handles.figGUI_panScan4_RotMin, 'Enable', 'off');
                        set(handles.figGUI_panScan4_RotStep, 'Enable', 'off');
                        set(handles.figGUI_panScan4_RotMax, 'Enable', 'off');
                        
                end


            end

            handles.stages_serverObj{i} = [];

            % Change status
            handles.stage_comStatus{i} = 'Disconnected from server!';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            set(handles.figGUI_panStages_comStatus(i), 'Enable', 'off');

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'red');
            set(handles.figGUI_panStages_COMStatus(i), 'String', 'X');

            % Change COM button
            set(handles.figGUI_panStages_buttConn(i), 'Enable', 'on');

            % Re-enable menu item (stages COM settings)
            set(handles.figGUI_menuStages_menuCOM, 'Enable', 'on');
            set(handles.figGUI_menuStages_menuReset_stageList(i), 'Enable', 'off');
            set(handles.figGUI_menuStages_menuHome_stageList(i), 'Enable', 'off');
            
            
        case {'set operation 1', 'set operation 2', 'set operation 3'}
            
            i = str2num(funcName(end));
            
            UpdateEditValue(handles.figGUI_panStages_opMode(i),[],sprintf('stages_opMode{%d}', i))
            handles = evalin('base','handles');
            val = get(handles.figGUI_panStages_opMode(i),'Value');
            
            % Send command
            serverAns = [];
            err = [];
            serverCmd = sprintf('sendrcv %s %s%d', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Operation,2-val);
            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.stages_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
            
            if(numel(serverAns) > 1)
                if(strcmp(regexprep(serverAns,'[ >]',''),sprintf('%s%d', handles.stages_cmd{i}.Operation,2-val)) == 1)
                    handles.stages_comStatus{i} = 'Operation succeed!';
                    if(get(handles.figGUI_panStages_opMode(i),'Value') == 1)
                        set(handles.figGUI_panStages_dir(i),'Enable','off');
                    else
                        set(handles.figGUI_panStages_dir(i),'Enable','on');
                        serverAns = [];
                        err = [];
                        serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{1}.GetDistance);
                        [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );
                        distance = str2double(regexprep(serverAns,'[*D >]',''))*handles.stages_scalefactor{i};
                        if(distance < 0)
                            newdistance = -1*distance/handles.stages_scalefactor{i};
                            serverAns = [];
                            err = [];
                            serverCmd = sprintf('sendrcv %s %s%s', handles.stages_comTermChar{i}, handles.stages_cmd{1}.GetDistance,num2str(newdistance));
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                'send_receive', ...
                                handles.stages_serverObj{i}, ...
                                serverCmd, ...
                                handles.com_waitTime.client_server, ...
                                handles.com_numTry...
                                );
                            set(handles.figGUI_panStages_value(i),'String',regexprep(serverAns,'[*D >]',''))
                        end
                    end
                else
                    handles.stages_comStatus{i} = 'Operation failed!';
                end
            else
                handles.stages_comStatus{i} = 'Failed to send the command!';
            end
            
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

        case {'set operation 4', 'set operation 5'}
            
            i = str2num(funcName(end));
            
            UpdateEditValue(handles.figGUI_panStages_opMode(i),[],sprintf('stages_opMode{%d}', i))
            handles = evalin('base','handles');
            
            if(get(handles.figGUI_panStages_opMode(i),'Value') == 1)
                UpdateEditValue(handles.figGUI_panStages_value(i),[],sprintf('stages_value{%d}', i))
                handles = evalin('base','handles');
                set(handles.figGUI_panStages_dir(i),'Enable','off');
            else
                set(handles.figGUI_panStages_dir(i),'Enable','on');
                val = get(handles.figGUI_panStages_value(i),'String');
                if(str2double(val)>0)
                    set(handles.figGUI_panStages_dir(i),'Value',1)
                    UpdateEditValue(handles.figGUI_panStages_value(i),[],sprintf('stages_value{%d}', i))
                    handles = evalin('base','handles');
                else
                    set(handles.figGUI_panStages_dir(i),'Value',2)
                    val = num2str(abs(str2double(val)));
                    set(handles.figGUI_panStages_value(i),'String',val);
                    UpdateEditValue(handles.figGUI_panStages_value(i),[],sprintf('stages_value{%d}', i))
                    handles = evalin('base','handles');
                end
            end
            
        case {'set distance 1', 'set distance 2', 'set distance 3', 'set distance 4', 'set distance 5'}
            
            i = str2num(funcName(end));
            
            handles = evalin('base','handles');
            val = get(handles.figGUI_panStages_value(i),'String');

            if(get(handles.figGUI_panStages_opMode(i),'Value') == 2)
                val = num2str(abs(str2double(val)),'%.1f');
                set(handles.figGUI_panStages_value(i),'String',val);
            else
                val = num2str(str2double(val),'%.1f');
                set(handles.figGUI_panStages_value(i),'String',val);
            end
            
            if(i<=3)
                % Send command
                serverAns = [];
                err = [];
                serverCmd = sprintf('sendrcv %s %s%s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetDistance, num2str(str2double(val)/handles.stages_scalefactor{i}));
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

                if(numel(serverAns) > 1)
                    handles.stages_comStatus{i} = 'Succeed to send the command!';
                else
                    handles.stages_comStatus{i} = 'Failed to send the command!';
                end

                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            end
            
            
            UpdateEditValue(handles.figGUI_panStages_value(i),[],sprintf('stages_value{%d}', i))
            handles = evalin('base','handles');
            
            pause(1)
            
        case {'set direction 1', 'set direction 2', 'set direction 3', 'set direction 4', 'set direction 5'}
            
            i = str2num(funcName(end));
            
            UpdateEditValue(handles.figGUI_panStages_dir(i),[],sprintf('stages_dir{%d}', i))
            handles = evalin('base','handles');
            val = get(handles.figGUI_panStages_dir(i),'Value');
            if(i<=3)
                % Send command
                serverAns = [];
                err = [];
                serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetDistance);
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

                if(numel(serverAns) > 1)
                    if(str2double(regexprep(serverAns,'[*D >]','')) > 0 && val == 2) || (str2double(regexprep(serverAns,'[*D >]','')) < 0 && val == 1)
                        newdistance = -1*str2double(regexprep(serverAns,'[*D >]',''));
                        serverAns = [];
                        err = [];
                        serverCmd = sprintf('sendrcv %s %s%6.2f', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetDistance,newdistance);
                        [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                        if(strcmp(regexprep(serverAns,'[ >]',''),sprintf('%s%6.2f', handles.stages_cmd{i}.GetDistance,newdistance)) == 1)
                            handles.stages_comStatus{i} = 'Operation succeed!';
                        else
                            handles.stages_comStatus{i} = 'Operation failed!';
                        end

                    end
                else
                    handles.stages_comStatus{i} = 'Failed to send the command!';
                end
            end
            
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            

        case {'get config 1', 'get config 2', 'get config 3'}

            i = str2num(funcName(end));
            
            hObject = handles.figGUI_menuStages_menuConfig_fig_table;

            % Change status
            handles.stages_comStatus{i} = 'Getting configuration parameters...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Send command
            serverAns = [];
            err = [];
            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetConfig);
            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.stages_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

            if(numel(serverAns) > 1)

                % Parse 1ZT reply
                numConfigParam = numel(handles.stages_configName{i});
                temp = textscan(serverAns,'%s ','Delimiter','>');
                currVal = {};
                setVal = {};
                for(j = 2:numConfigParam)
                    descrip{j-1,1} = handles.stages_configName{i}{j};
                    currVal{j-1,1} = regexprep(temp{1}{j},'[^\d.-]','');
                    setVal{j-1,1} = '';
                end

                % Set data in configuration parameter table
                
                set(hObject, 'Data', [descrip, currVal, setVal]);

                % Adjust column width
                set(hObject, 'ColumnWidth', {180, 100, 100})

                % Adjust table size
                p = get(hObject, 'Parent');
                posFig = get(p, 'Position');
                pos = get(hObject, 'Position');
                ext = get(hObject, 'Extent');
                screen = get(0, 'Screensize');
                if(ext(3) < screen(3))
                    set(hObject, 'Position', [pos(1), pos(2), ext(3)+15, pos(4)]);

                    % Adjust figure window size
                    set(p, 'Position', [posFig(1), posFig(2), ext(3)+15+20, pos(4)+20]);
                end

                % Change status
                handles.stages_comStatus{i} = 'Stage ready!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            else

                % Change status
                handles.stages_comStatus{i} = 'Failed to get configuration parameters!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});                
            end

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
            set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');
            
        case('get config 4')

            i = str2num(funcName(end));
            
            hObject = handles.figGUI_menuStages_menuConfig_fig_table;

            % Change status
            handles.stages_comStatus{i} = 'Getting configuration parameters...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');
            
            msg = {...
                '1ID?', ...
                '1AC?', ...
                '1BA?', ...
                '1BH?', ...
                '1HT?', ...
                '1JR?', ...
                '1OH?', ...
                '1OT?', ...
                '1SA?', ...
                '1SL?', ...
                '1SR?', ...
                '1VA?', ...
                '1VB?', ...
                '1ZX?', ...
                };
 
            temp = {};
            for(j = 1:numel(msg))
            % Send command
            serverAns = [];
            err = [];
            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, char(msg{j}));

%             serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetConfig);
            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.stages_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
            
            temp{j,1} = serverAns;
            pause(0.1)
            end
            

            if(numel(temp) > 1)

                % Parse 1ZT reply
                numConfigParam = 14;
                rowName = {};
                currVal = {};
                setVal = {};
                for(j = 1:numConfigParam)
                    rowName{j,1} = temp{j}(2:3);
                    descrip{j,1} = handles.stages_configName{i}{j};
                    currVal{j,1} = temp{j}(4:end);
                    setVal{j,1} = '';
                end

                % Set data in configuration parameter table
                set(hObject, 'RowName', rowName);
                set(hObject, 'Data', [descrip, currVal, setVal]);

                % Adjust column width
                set(hObject, 'ColumnWidth', {180, 100, 100})

                % Adjust table size
                p = get(hObject, 'Parent');
                posFig = get(p, 'Position');
                pos = get(hObject, 'Position');
                ext = get(hObject, 'Extent');
                screen = get(0, 'Screensize');
                if(ext(3) < screen(3))
                    set(hObject, 'Position', [pos(1), pos(2), ext(3)+15, pos(4)]);

                    % Adjust figure window size
                    set(p, 'Position', [posFig(1), posFig(2), ext(3)+15+20, pos(4)+20]);
                end

                % Change status
                handles.stages_comStatus{i} = 'Stage ready!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            else

                % Change status
                handles.stages_comStatus{i} = 'Failed to get configuration parameters!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            end


            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
            set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

        case('get config 5')

            i = str2num(funcName(end));
            
            hObject = handles.figGUI_menuStages_menuConfig_fig_table;

            % Change status
            handles.stages_comStatus{i} = 'Getting configuration parameters...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');
            
            msg = {...
                '1 NIDENTIFY', ...
                '1 GETNACCEL', ...
                '1 GETNVEL' ...
                };
            
            rotstage = 1;
            temp = {};
            for(j = 1:numel(msg))
            % Send command
            serverAns = [];
            err = [];
            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, char(msg{j}));

            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.stages_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
            
            temp{j,1} = serverAns;
            pause(0.1)
            end

            if(numel(temp) > 1)

                numConfigParam = 3;
                currVal = {};
                setVal = {};
                for(j = 1:numConfigParam)
                    descrip{j,1} = handles.stages_configName{i}{j};
                    currVal{j,1} = temp{j};
                    setVal{j,1} = '';
                end

                % Set data in configuration parameter table
                set(hObject, 'Data', [descrip, currVal, setVal]);

                % Adjust column width
                set(hObject, 'ColumnWidth', {180, 100, 100})

                % Adjust table size
                p = get(hObject, 'Parent');
                posFig = get(p, 'Position');
                pos = get(hObject, 'Position');
                ext = get(hObject, 'Extent');
                screen = get(0, 'Screensize');
                if(ext(3) < screen(3))
                    set(hObject, 'Position', [pos(1), pos(2), ext(3)+15, pos(4)]);

                    % Adjust figure window size
                    set(p, 'Position', [posFig(1), posFig(2), ext(3)+15+20, pos(4)+20]);
                end

                % Change status
                handles.stages_comStatus{i} = 'Stage ready!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            else

                % Change status
                handles.stages_comStatus{i} = 'Failed to get configuration parameters!';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
            end


            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
            set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');
            
        case {'start motion 1', 'start motion 2', 'start motion 3'}

            i = str2num(funcName(end));

            % Change status
            handles.stages_comStatus{i} = 'Starting motion...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Send command
            
            serverAns = [];
            err = [];
            value = num2str(str2double(get(handles.figGUI_panStages_value(i),'String'))/handles.stages_scalefactor{i});
            serverCmd = sprintf('sendrcv %s %s%s', handles.stages_comTermChar{i}, handles.stages_cmd{1}.GetDistance, value);
            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.stages_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            
            if(~isnan(str2double(get(handles.figGUI_panStages_value(i),'String'))))
                if(get(handles.figGUI_panStages_opMode(i),'Value') == 1)
                    set(handles.figGUI_panStages_targetPos(i),'String',get(handles.figGUI_panStages_value(i),'String'))
                    serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Go);
                else
                    if(str2double(get(handles.figGUI_panStages_value(i),'String')) ~= 0)
                        dirsign = -2*get(handles.figGUI_panStages_dir(i),'Value')+3;
                        if(dirsign < 0)
                            dirsignstr = '-';
                        else
                            dirsignstr = '';
                        end
                        target = num2str(dirsign*str2double(get(handles.figGUI_panStages_value(i),'String')) + str2double(get(handles.figGUI_panStages_currentPos(i),'String')));
                        set(handles.figGUI_panStages_targetPos(i),'String',target);
                        value = num2str(str2double(get(handles.figGUI_panStages_value(i),'String'))/handles.stages_scalefactor{i});
                        serverCmd = sprintf('sendrcv %s %s%s%s', handles.stages_comTermChar{i}, handles.stages_cmd{1}.GetDistance, dirsignstr, value);
                        [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );
                    end
                end
                
                serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Go);
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;


                % Change status
                handles.stages_comStatus{i} = 'Moving...';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
                
                k = 0;
                movestate = 'Moving';
                numberofloops = 10; % Change this number for long displacement. It is there to avoid infinite loops
                while(k < numberofloops && strcmp(movestate, 'Moving') == 1)
                    serverCmd = sprintf('sendrcv %s %s:%s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos, handles.stages_cmd{i}.GetState);
                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );

                    temp = textscan(serverAns, '%s ','Delimiter','>');
                    try
                        currVal = {};
                        for(j = 1:numel(temp{1}))
                            currVal{j,1} = regexprep(temp{1}{j},'[^\d.-]','');
                        end
                        currval = str2double(char(currVal{1,1}))*handles.stages_scalefactor{i};

                        set(handles.figGUI_panStages_currentPos(i),'String', sprintf('%0.1f', currval));

                        status = char(currVal{3,1});

                        if(strcmp(status(1),'0') == 1)
                            movestate = 'In position';
                        else
                            movestate = 'Moving';
                        end
                        set(handles.figGUI_panStages_comStatus(i),'String', movestate);
                    catch
                    end
                    k = k + 1;
                    pause(0.5)
                end            

            end
            
            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
            set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');
            
        case {'start motion 4', 'start motion 5'}

            i = str2num(funcName(end));

            % Change status
            handles.stages_comStatus{i} = 'Starting motion...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Send command
            
            serverAns = [];
            err = [];
            
            if(get(handles.figGUI_panStages_opMode(i),'Value') == 1)
                movecmd = handles.stages_cmd{i}.MoveAbs;
            else
                movecmd = handles.stages_cmd{i}.MoveRel;
            end
            
            if(~isnan(str2double(get(handles.figGUI_panStages_value(i),'String'))))
                if(get(handles.figGUI_panStages_opMode(i),'Value') == 1)
                    set(handles.figGUI_panStages_targetPos(i),'String',get(handles.figGUI_panStages_value(i),'String'))
                    positionmm = num2str(str2double(get(handles.figGUI_panStages_targetPos(i),'String'))/1000, '%.4f');
                    
                    switch i
                        case 4
                            serverCmd = sprintf('sendrcv %s %s%s', handles.stages_comTermChar{i}, movecmd, positionmm);
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                'send_receive', ...
                                handles.stages_serverObj{i}, ...
                                serverCmd, ...
                                handles.com_waitTime.client_server, ...
                                handles.com_numTry...
                                );
                            
                        case 5
                            serverCmd = sprintf('sendrcv %s %s %s', handles.stages_comTermChar{i}, get(handles.figGUI_panStages_value(i),'String'), movecmd);
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                'send_receive', ...
                                handles.stages_serverObj{i}, ...
                                serverCmd, ...
                                handles.com_waitTime.client_server, ...
                                handles.com_numTry...
                                );

                    end
                else
                    if(str2double(get(handles.figGUI_panStages_value(i),'String')) ~= 0)
                        dirsign = -2*get(handles.figGUI_panStages_dir(i),'Value')+3;
                        if(dirsign < 0)
                            dirsignstr = '-';
                        else
                            dirsignstr = '';
                        end
                        target = num2str(dirsign*str2double(get(handles.figGUI_panStages_value(i),'String')) + str2double(get(handles.figGUI_panStages_currentPos(i),'String')));
                        set(handles.figGUI_panStages_targetPos(i),'String',target);
                        
                        targetmm = num2str(str2double(get(handles.figGUI_panStages_value(i),'String'))/1000,'%.1f');
                        
                        switch i
                            case 4
                                serverCmd = sprintf('sendrcv %s %s%s%s', handles.stages_comTermChar{i}, movecmd, dirsignstr, targetmm);
                                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                    'send_receive', ...
                                    handles.stages_serverObj{i}, ...
                                    serverCmd, ...
                                    handles.com_waitTime.client_server, ...
                                    handles.com_numTry...
                                    );
                        
                            case 5
                                serverCmd = sprintf('sendrcv %s %s%s %s', handles.stages_comTermChar{i}, dirsignstr, get(handles.figGUI_panStages_value(i),'String'), movecmd);
                                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                    'send_receive', ...
                                    handles.stages_serverObj{i}, ...
                                    serverCmd, ...
                                    handles.com_waitTime.client_server, ...
                                    handles.com_numTry...
                                    );
                        end
                    end
                end
                
                switch i
                    case 4
                        k = 0;
                        movestate = 'Moving';
                        handles.stages_comStatus{i} = 'Moving...';
                        set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
                        numberofloops = 10; % Change this number for long displacement. It is there to avoid infinite loops
                        while(k < numberofloops && strcmp(movestate, 'Moving') == 1)

                            serverAns = [];
                            err = [];

                            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetState);
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                            for(j = 1:numel(handles.stages_stateCode{4}))
                                if(strcmp(char(handles.stages_stateCode{4}(j)),serverAns(8:end)) == 1)
                                    movestate = 'In Position';
                                    pause(1.2)
                                    break
                                end
                            end
                            set(handles.figGUI_panStages_comStatus(i),'String', handles.stages_stateString{i}(j));
                            
                            pause(0.6)
                            
                            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{i}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                            positionum = num2str(str2double(serverAns(4:end))*1000,'%.1f');
                            set(handles.figGUI_panStages_currentPos(i),'String', positionum);

                            k = k + 1;
                            pause(0.5)
                        end
                        
                    case 5
                        k = 0;
                        movestate = 'Moving';
                        numberofloops = 10; % Change this number for long displacement. It is there to avoid infinite loops
                        while(k < numberofloops && strcmp(movestate, 'Moving') == 1)

                            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetState);
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                'send_receive', ...
                                handles.stages_serverObj{i}, ...
                                serverCmd, ...
                                handles.com_waitTime.client_server, ...
                                handles.com_numTry...
                                );

                            if(strcmp(serverAns(1),'0') == 1)
                                set(handles.figGUI_panStages_comStatus(i),'String', 'In position');
                                movestate = 'In position';
                            else
                                set(handles.figGUI_panStages_comStatus(i),'String', 'Moving');
                                movestate = 'Moving';
                            end

                            pause(0.5)

                            serverAns = [];
                            err = [];

                            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                'send_receive', ...
                                handles.stages_serverObj{i}, ...
                                serverCmd, ...
                                handles.com_waitTime.client_server, ...
                                handles.com_numTry...
                                );

                            set(handles.figGUI_panStages_currentPos(i),'String', sprintf('%0.1f', str2double(serverAns)));
                            
                            
                            k = k + 1;
                        end
                        
                end
        
%                 handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;


                % Change status
                handles.stages_comStatus{i} = 'In Position';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            end
            
            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
            set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');
            
        case {'stop motion 1', 'stop motion 2', 'stop motion 3', 'stop motion 4', 'stop motion 5'}

            i = str2num(funcName(end));

            % Change status
            handles.stages_comStatus{i} = 'Stopping motion...';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

            % Send command
            serverAns = [];
            err = [];
            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Stop);
            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.stages_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;
            pause(1.0);

            % Change status
            handles.stages_comStatus{i} = 'Motion stopped!';
            set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
 
            % Change COM status box
            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
            set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

        case('reset')

            % Get stage name
            stageName = label; %stageName = get(hObject, 'Label');
            i = 1;
            while(strcmp(stageName, handles.stages_name{i}) < 1)
                i = i + 1;
            end

            if(strcmp(get(handles.figGUI_panStages_COMStatus(i), 'String'), 'O') > 0)

                % Change status
                handles.stages_comStatus{i} = 'Send Reset command...';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                % Change COM status box
                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
                set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

                % Send reset command
                serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.ResetEncoder);
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );
                    
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

                % Change status
                handles.stages_comStatus{i} = 'Resetting...';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                % Change COM status box
                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');
            end

        case('home')

            % Get stage name
            stageName = label; %stageName = get(hObject, 'Label');
            i = 1;
            while(strcmp(stageName, handles.stages_name{i}) < 1)
                i = i + 1;
            end

            if(strcmp(get(handles.figGUI_panStages_COMStatus(i), 'String'), 'O') > 0)

                % Change status
                handles.stages_comStatus{i} = 'Send Home command...';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                % Change COM status box
                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'yellow');
                set(handles.figGUI_panStages_COMStatus(i), 'String', '!');

                % Send home command
                serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.Home);
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );
                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;

                % Change status
                handles.stages_comStatus{i} = 'Homing...';
                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                % Change COM status box
                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

            end      
    end
    
    % Restart timer    
    if(strcmp(handles.timer_status, 'on') > 0)
        start(handles.timer_obj);
        disp('Timer restarted')
    end

    % Save handles in base workspace
    assignin('base','handles',handles)
    
end


