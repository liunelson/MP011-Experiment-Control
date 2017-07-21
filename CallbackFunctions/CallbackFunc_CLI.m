% Callback function for command line interface objects
function [] = CallbackFunc_CLI(hObject, event, funcName, param1)

    % Load handles from base workspace
    handles = evalin('base','handles');

    switch(funcName)

    	% Pass COM object of selected device server
    	case('select device')

    		% Get device name
    		str = get(hObject, 'String');
    		val = get(hObject, 'Value');
    		handles.cli_devName = str{val};

    		if(numel(handles.cli_devName) < 1)

    			% Do nothing

    		elseif(strcmp(handles.cli_devName(1:4), 'Shut') > 0)

    			i = str2num(handles.cli_devName(9));
    			handles.cli_serverObj = handles.shutters_serverObj{i};

    		elseif(strcmp(handles.cli_devName, 'Camera') > 0)

    			warndlg('Direct communication with camera via CLI is not configured yet!', 'App Limitation');

    		elseif(strcmp(handles.cli_devName((end-4):end), 'Stage') > 0)



                % Find stage number
                i = 0; j = 0;
                while((j < 1) && (i < 5))
                    i = i + 1;
                    j = strcmp(handles.cli_devName, [handles.stages_name{i}, ' Stage']);
                end

%                 [i,j]

                % Get server object
                if(j > 0)
                    handles.cli_serverObj = handles.stages_serverObj{i};
                end
    		end
    		
    	% Send command to selected server
    	case('send command')

            % Get command
            handles.cli_cmd = get(hObject, 'String');

    		if(numel(handles.cli_devName) < 1)

    			errordlg('Select a valid device first!', 'User Error');

    		elseif(numel(handles.cli_cmd) > 1)

                % Send command
	            [handles.cli_serverObj, handles.cli_reply, err] = SendReceiveSerial(...
	                'send_receive', ...
	                handles.cli_serverObj, ...
	                handles.cli_cmd, ...
	                handles.com_waitTime.client_server, ...
	                handles.com_numTry...
	                );

                handles.figGUI_menuShutters_menuCLI_fig_reply = param1;
                
	    		% Post server answer in text box
	    		set(handles.figGUI_menuShutters_menuCLI_fig_reply, 'String', sprintf('%s', handles.cli_reply));

                % Empty command box
                set(hObject, 'String', '');

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
