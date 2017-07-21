
% Callback function for chiller
function [] = CallbackFunc_Chiller(hObject, event, funcName)

    % Load handles from base workspace
    handles = evalin('base','handles');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch(funcName)

    	case('connect chiller')

            % Disable menu item (COM settings)
            set(handles.figGUI_menuChiller_menuCOM, 'Enable', 'off');

            % Disable connect button
            set(handles.figGUI_menuChiller_menuConnect, 'Enable', 'off');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];
            handles.chiller_serverObj = [];     

            % Connect to server   
            [handles.chiller_serverObj, err] = OpenServerConnection(...
                'open_serial', ...
                handles.chiller_serverIP, ...
                handles.chiller_serverPort...
                );
            handles.com_timeLastCOM.chiller = now - handles.timer_timeNow;
            
            % Wait for server response
            pause(handles.com_waitTime.client_server);
            
            % Receive answer
            if(numel(err) < 1)
                [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial('receive', handles.chiller_serverObj, [], []);
                handles.com_timeLastCOM.chiller = now - handles.timer_timeNow;
            end

            % Check for connection errors
            if(strcmp(serverAns, 'Connected to server!') > 0)

                % Update device state
                handles.com_devState_chiller = 1;

                % Enable control buttons
                set(handles.figGUI_menuChiller_menuDisconnect, 'Enable', 'on');
                set(handles.figGUI_menuChiller_menuControl, 'Enable', 'on');
                set(handles.figGUI_menuChiller_menuStatus, 'Enable', 'on');

                % Open serial COM port to device
                serverCmd = sprintf('open COM%s %s %s', handles.chiller_comPort, handles.chiller_comBaudRate, handles.chiller_comFlowControl);
                [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.chiller_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                handles.com_timeLastCOM.chiller = now - handles.timer_timeNow;

                if(strcmp(serverAns, 'COM successfully opened') > 0)

                    % Change status
                    handles.chiller_comStatus =  'COM successfully opened!';

                    % Disable button connect button
                    set(handles.figGUI_menuChiller_menuConnect, 'Enable', 'off');

                else
                    
                    % Change status
                    handles.chiller_comStatus = 'COM failed to open!';

                end

            else

                % Change COM status
                handles.chiller_comStatus =  'Server connection failed!';

                % Re-enable connect button
                set(handles.figGUI_menuChiller_menuConnect, 'Enable', 'on');

                
                % Disable button connect button
                set(handles.figGUI_menuChiller_menuDisconnect, 'Enable', 'off');
                set(handles.figGUI_menuChiller_menuControl, 'Enable', 'on');
                set(handles.figGUI_menuChiller_menuStatus, 'Enable', 'on');

            end            


    	case('disconnect chiller')

           % Disable button
            set(handles.figGUI_menuChiller_menuDisconnect, 'Enable', 'off');

            % Disable menu item
            set(handles.figGUI_menuChiller_menuCOM, 'Enable', 'off');

            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];

            % Close serial COM port
            serverCmd = 'close';
            [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.chiller_serverObj, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.chiller = now - handles.timer_timeNow;

            handles.chiller_comStatus = serverAns;

            % Change status
            if(strcmp(serverAns, 'COM successfully closed') > 0)

                % Update device state
                handles.com_devState_chiller = 0;

                handles.chiller_comStatus = sprintf('COM successfully closed!');
            else
                handles.stage_comStatus = sprintf('COM failed to close!');
            end

            % Disconnect from server
            serverCmd = 'close_serial';
            CloseServerConnection(handles.chiller_serverObj, serverCmd);
            handles.com_timeLastCOM.chiller = now - handles.timer_timeNow;

            handles.chiller_serverObj = [];

            % Change status
            handles.chiller_comStatus = 'Disconnected from server!';

            % Change COM button
            set(handles.figGUI_menuChiller_menuConnect, 'Enable', 'on');
            set(handles.figGUI_menuChiller_menuControl, 'Enable', 'off');
            set(handles.figGUI_menuChiller_menuStatus, 'Enable', 'off');

        case('turn on')
            
            hchildren = get(handles.figGUI_menuChiller_menuControl_fig,'Children');
            
            for(i=1:numel(hchildren))
                switch get(hchildren(i),'Tag')
                    
                    case 'Status Table title'
                        continue
                        
                    case 'Status Table'
                        continue
                        
                    case 'Configuration Table title'
                        continue
                        
                    case 'Configuration Table'
                        continue
                        
                    case 'Power Status text'
                        continue
                        
                    case 'Power Status mark'
                        handles.figGUI_panChiller_POWStatus = hchildren(i);
                        continue
                        
                    case 'On Button'
                        handles.figGUI_panChiller_buttTurnOn = hchildren(i);
                        continue
                        
                    case 'Off Button'
                        handles.figGUI_panChiller_buttTurnOff = hchildren(i);
                        continue
                        
                    case 'Com Status'
                        handles.figGUI_panChiller_comStatus = hchildren(i);
                        continue
                        
                end
            end
   
            % Check device COM status
            if(handles.com_devState_chiller > 0)

                % Disable button
                set(handles.figGUI_panChiller_buttTurnOn, 'Enable', 'off');

                % Change status
                handles.chiller_comStatus = 'Turning on chiller...';
                set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);

                % Change POW status box
                set(handles.figGUI_panChiller_POWStatus, 'BackgroundColor', 'yellow');
                set(handles.figGUI_panChiller_POWStatus, 'String', '!');

                % Build command
                command = CreateChillerCOMPacket(handles.chiller.cmdList, 'Set On/Off Array', {'01', '01', '02', '02', '02', '02', '02', '02'});

                serverCmd = sprintf('sendrcv_hex %s', command);
                [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.chiller_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );

                pause(0.1);

                % Parse data
                [data, err] = ParseChillerAnswerPacket(handles.chiller.cmdList, serverAns);

                if(numel(err) < 1)

                    % Change status
                    handles.chiller_comStatus = 'Chiller turned on successfully!';
                    set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);

                    % Change COM status box
                    set(handles.figGUI_panChiller_POWStatus, 'BackgroundColor', 'green');
                    set(handles.figGUI_panChiller_POWStatus, 'String', 'O');

                    % Enable turn on button
                    set(handles.figGUI_panChiller_buttTurnOn, 'Enable', 'off');
                    set(handles.figGUI_panChiller_buttTurnOff, 'Enable', 'on');

                else
                    % Change status
                    handles.chiller_comStatus = err;
                    set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);

                    % Re-enable turn off button
                    set(handles.figGUI_panChiller_buttTurnOn, 'Enable', 'on');
                end

            else

                % Change status
                handles.chiller_comStatus = 'Not connected yet!';
                set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);
            end

        case('turn off')
            
            hchildren = get(handles.figGUI_menuChiller_menuControl_fig,'Children');
            
            for(i=1:numel(hchildren))
                switch get(hchildren(i),'Tag')
                    
                    case 'Status Table title'
                        continue
                        
                    case 'Status Table'
                        continue
                        
                    case 'Configuration Table title'
                        continue
                        
                    case 'Configuration Table'
                        continue
                        
                    case 'Power Status text'
                        continue
                        
                    case 'Power Status mark'
                        handles.figGUI_panChiller_POWStatus = hchildren(i);
                        continue
                        
                    case 'On Button'
                        handles.figGUI_panChiller_buttTurnOn = hchildren(i);
                        continue
                        
                    case 'Off Button'
                        handles.figGUI_panChiller_buttTurnOff = hchildren(i);
                        continue
                        
                    case 'Com Status'
                        handles.figGUI_panChiller_comStatus = hchildren(i);
                        continue
                        
                end
            end
            

            % Check device COM status
            if(handles.com_devState_chiller > 0)

                % Disable button
                set(handles.figGUI_panChiller_buttTurnOff, 'Enable', 'off');

                % Change status
                handles.chiller_comStatus = 'Turning off chiller...';
                set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);

                % Change COM status box
                set(handles.figGUI_panChiller_POWStatus, 'BackgroundColor', 'yellow');
                set(handles.figGUI_panChiller_POWStatus, 'String', '!');

                % Build command
                command = CreateChillerCOMPacket(handles.chiller.cmdList, 'Set On/Off Array', {'00', '02', '02', '02', '02', '02', '02', '02'});

                % Send command to chiller

                serverCmd = sprintf('sendrcv_hex %s', command);
                [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.chiller_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );


                pause(0.1);

                % Parse data
                [data, err] = ParseChillerAnswerPacket(handles.chiller.cmdList, serverAns);

                if(numel(err) < 1)

                    % Change status
                    handles.chiller_comStatus = 'Chiller turned off successfully!';
                    set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);

                    % Change COM status box
                    set(handles.figGUI_panChiller_POWStatus, 'BackgroundColor', 'red');
                    set(handles.figGUI_panChiller_POWStatus, 'String', 'X');

                    % Enable turn on button
                    set(handles.figGUI_panChiller_buttTurnOn, 'Enable', 'on');

                else
                    % Change status
                    handles.chiller_comStatus = err;
                    set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);

                    % Re-enable turn off button
                    set(handles.figGUI_panChiller_buttTurnOff, 'Enable', 'on');
                end

                
            else

                % Change status
                handles.chiller_comStatus = 'Not connected yet!';
                set(handles.figGUI_panChiller_comStatus, 'String', handles.chiller_comStatus);
            end

    	case('get status')

            % Check device COM status
            if(handles.com_devState_chiller > 0)

                % Build command
                command = CreateChillerCOMPacket(handles.chiller.cmdList, 'Read Status', {});

                serverCmd = sprintf('sendrcv_hex %s', command);
                [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.chiller_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );

                pause(0.4);
                
                serverAns = serverAns(end-21:end);

                % Parse data
                [handles.data, err] = ParseChillerAnswerPacket(handles.chiller.cmdList, serverAns);

                % Parse values
                for(i = 1:size(handles.chiller.statusList,1))
                    handles.chiller.statusList{i, 2} = handles.data.(sprintf('param%d', i));
                end
            end

            % Parse values
            for(i = 1:size(handles.chiller.statusList,1))

                rowName{i, 1} = sprintf('%d', i);
                descrip{i, 1} = handles.chiller.statusList{i, 1};
                currVal{i, 1} = handles.chiller.statusList{i, 2};
            end
            
            if(strcmp(get(get(hObject,'Parent'),'Name'),'Chiller Status')==1)

            % Set data
                set(hObject, 'RowName', rowName);
                set(hObject, 'Data', [descrip, currVal]);
                
            elseif(isempty(hObject)==1)
                
                try

                    % Set data
                    set(handles.figGUI_menuChiller_menuStatus_fig_table, 'RowName', rowName);
                    set(handles.figGUI_menuChiller_menuStatus_fig_table, 'Data', [descrip, currVal]);

                catch
                    
                    % Set data
                    set(handles.figGUI_panChiller_tableStatus, 'RowName', rowName);
                    set(handles.figGUI_panChiller_tableStatus, 'Data', [descrip, currVal]);
                
                end


            else
            % Set data
                set(handles.figGUI_panChiller_tableStatus, 'RowName', rowName);
                set(handles.figGUI_panChiller_tableStatus, 'Data', [descrip, currVal]);
                
            end



        case('get control')

            % Check device COM status
            if(handles.com_devState_chiller > 0)
                j = 0;
                for(i = 3:11)

                    j = j + 1;

                    % Build command
                    command = CreateChillerCOMPacket(handles.chiller.cmdList, handles.chiller.cmdList{i, 1}, {});

                    serverCmd = sprintf('sendrcv_hex %s', command);
                    [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.chiller_serverObj, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );


                    pause(0.1);

                    % Parse data
                    [data, err] = ParseChillerAnswerPacket(handles.chiller.cmdList, serverAns);           

                    % Transfer data to handles
                    handles.chiller.configList{j, 2} = data.param1;
                end
            end


            % Parse values
            for(i = 1:size(handles.chiller.configList, 1))

                rowName{i, 1} = sprintf('%d', i);
                descrip{i, 1} = handles.chiller.configList{i, 1};
                currVal{i, 1} = handles.chiller.configList{i, 2};
                setVal{i,1} = '';
            end

            % Set data
            set(handles.figGUI_panChiller_tableConfig, 'RowName', rowName);
            set(handles.figGUI_panChiller_tableConfig, 'Data', [descrip, currVal, setVal]);
            
            % Check device COM status
            if(handles.com_devState_chiller > 0)
                
                if(handles.data.param29 == 1)
                    set(handles.figGUI_panChiller_buttTurnOn, 'Enable', 'off');
                    set(handles.figGUI_panChiller_buttTurnOff, 'Enable', 'on');
                    set(handles.figGUI_panChiller_POWStatus, 'BackgroundColor', 'green');
                    set(handles.figGUI_panChiller_POWStatus, 'String', 'O');
                else
                    set(handles.figGUI_panChiller_buttTurnOn, 'Enable', 'on');
                    set(handles.figGUI_panChiller_buttTurnOff, 'Enable', 'off');
                    set(handles.figGUI_panChiller_POWStatus, 'BackgroundColor', 'yellow');
                    set(handles.figGUI_panChiller_POWStatus, 'String', '!');
                end
            else
            end


    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Restart timer
    if(strcmp(handles.timer_status, 'on') > 0)
        start(handles.timer_obj);
    end

	% Save handles in base workspace
    assignin('base','handles',handles)

end

