

% Callback function for micra
function [] = CallbackFunc_Micra(hObject, event, funcName)

    % Load handles from base workspace
    handles = evalin('base','handles');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    switch(funcName)

        case('connect micra')
            
            % Connect to server         
            [handles.micra_serverObj, err] = OpenServerConnection(...
                'open_serial', ...
                handles.micra_serverIP, ...
                handles.micra_serverPort...
                );
            
            handles.com_timeLastCOM.micra = now - handles.timer_timeNow;

            % Wait for server response
            pause(handles.com_waitTime.client_server);

            % Receive answer
            if(numel(err) < 1)
                [handles.micra_serverObj, serverAns, err] = SendReceiveSerial('receive', handles.micra_serverObj, [], []);
                 handles.com_timeLastCOM.micra = now - handles.timer_timeNow;
            end

            % Check for connection errors
            if(strcmp(serverAns, 'Connected to server!') > 0)

                % Update device state
                handles.com_devState_micra = 1;

                % Open serial COM port to device
                serverCmd = sprintf('open COM%s %s %s', handles.micra_comPort, handles.micra_comBaudRate, handles.micra_comFlowControl);
                [handles.micra_serverObj, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.micra_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                
                handles.com_timeLastCOM.micra = now - handles.timer_timeNow;

                if(strcmp(serverAns, 'COM successfully opened') > 0)

                    % Enable menu item
                    set(handles.figGUI_menuMicra_menuStatus,'Enable','on');
                    set(handles.figGUI_menuMicra_menuDisconnect,'Enable','on');

                    % Disable button
                    set(handles.figGUI_menuMicra_menuConnect,'Enable','off');

                    
                    % Send command
                    serverAns = [];
                    err = [];

                else
                    
                    % Disnable menu item
                    set(handles.figGUI_menuMicra_menuStatus,'Enable','off');
                    set(handles.figGUI_menuMicra_menuDisconnect,'Enable','off');

                    % Enable button
                    set(handles.figGUI_menuMicra_menuConnect,'Enable','on');

                end

            else

                % Disnable menu item
                set(handles.figGUI_menuMicra_menuStatus,'Enable','off');
                set(handles.figGUI_menuMicra_menuDisconnect,'Enable','off');

                % Enable button
                set(handles.figGUI_menuMicra_menuConnect,'Enable','on');


            end

        case('disconnect micra')
            
            % Initialize variables
            serverCmd = [];
            serverAns = [];
            err = [];

            % Close serial COM port
            serverCmd = 'close';
            [handles.micra_serverObj, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.micra_serverObj, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
            handles.com_timeLastCOM.micra = now - handles.timer_timeNow;
            

            % Disconnect from server
            serverCmd = 'close_serial';
            CloseServerConnection(handles.micra_serverObj, serverCmd);
            handles.com_timeLastCOM.micra = now - handles.timer_timeNow;

            if(numel(err) < 1)
            % Enable menu item
                set(handles.figGUI_menuMicra_menuConnect,'Enable','on');
                
            % Disable menu item
                set(handles.figGUI_menuMicra_menuDisconnect,'Enable','off');
                set(handles.figGUI_menuMicra_menuStatus,'Enable','off');
                handles.micra_serverObj = [];
                
            % Update device state
                handles.com_devState_micra = 0;
            end

        case('get status')
            
            numConfigParam = numel(handles.micra.cmdList)/2;
            
           % Send command
            serverAns = cell(numConfigParam,1);
            err = [];
            
            for(j=1:numConfigParam)
                serverCmd = sprintf('sendrcv %s %s', handles.micra_comTermChar, handles.micra.cmdList{numConfigParam+j});
                [handles.micra_serverObj, serverAns{j}, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.micra_serverObj, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
            end

            handles.com_timeLastCOM.micra = now - handles.timer_timeNow;

            if(numel(serverAns) > 1)

                rowName = {};
                currVal = {};
                setVal = {};
                for(j = 1:numConfigParam)
                    rowName{j,1} = handles.micra.cmdList{numConfigParam+j};
                    descrip{j,1} = handles.micra.cmdList{j};
                    currVal{j,1} = serverAns{j};
                    setVal{j,1} = '';
                end

                % Set data in configuration parameter table
                set(handles.figGUI_menuMicra_menuConfig_fig_table, 'RowName', rowName);
                set(handles.figGUI_menuMicra_menuConfig_fig_table, 'Data', [descrip, currVal, setVal]);

                % Adjust column width
                set(handles.figGUI_menuMicra_menuConfig_fig_table, 'ColumnWidth', {190, 120, 100})

                % Adjust table size
                p = get(handles.figGUI_menuMicra_menuConfig_fig_table, 'Parent');
                posFig = get(p, 'Position');
                pos = get(handles.figGUI_menuMicra_menuConfig_fig_table, 'Position');
                ext = get(handles.figGUI_menuMicra_menuConfig_fig_table, 'Extent');
                screen = get(0, 'Screensize');
                if(ext(3) < screen(3))
                    set(handles.figGUI_menuMicra_menuConfig_fig_table, 'Position', [pos(1), pos(2), ext(3)+120, pos(4)]);

                    % Adjust figure window size
                    set(p, 'Position', [posFig(1), posFig(2), ext(3)+120+20, pos(4)+20]);
                end
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
