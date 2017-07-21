
% Callback function for experiment control timer
function [] = CallbackFunc_Timer(hObject, event)

    % Load handles from base workspace
    handles = evalin('base','handles');
    
    % Get current cpu time
	handles.timer_timeLastCall = now - handles.timer_timeNow;
    set(handles.figGUI_menuHV, 'Enable', 'on');
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Check shutter COM status
    for(i = 1:3)

    	% Keep connection alive when client-server timeout imminent
        if((strcmp(get(handles.figGUI_panShutters_COMStatus(i), 'String'), 'O') > 0) && ...
    		(24*3600*(handles.timer_timeLastCall - handles.com_timeLastCOM.shutters{i}) > handles.com_timeOut))

            % Change COM status box
            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'yellow');
            set(handles.figGUI_panShutters_COMStatus(i), 'String', '!');

    		% Ping server
    		serverAns = [];
    		err = [];
    		serverCmd = 'ping';
    		[handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
    			'send_receive', ...
                handles.shutters_serverObj{i}, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
    		handles.com_timeLastCOM.shutters{i} = now - handles.timer_timeNow;

            % Change COM status box
            set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'green');
            set(handles.figGUI_panShutters_COMStatus(i), 'String', 'O');

    		% If wrong answer, throw error
    		if(strcmp(serverAns, 'I am here!') < 1)
    			handles.com_devState_shutters{i} = -1;

                % Re-enable connect button
                set(handles.figGUI_panShutters_buttConn, 'Enable', 'on');
                set(handles.figGUI_panShutters_buttDiscon, 'Enable', 'off');
				set(handles.figGUI_panShutters_buttO(i), 'Enable', 'off');
                set(handles.figGUI_panShutters_buttX(i), 'Enable', 'off');

                % Re-enable shutters COM sub-menu
                set(handles.figGUI_menuShutters_menuCOM, 'Enable', 'on');
				set(handles.figGUI_menuShutters_menuTrigger_shutterList(i), 'Enable', 'off');
				set(handles.figGUI_menuShutters_menuReset_shutterList(i), 'Enable', 'off');

                % Change COM status
                set(handles.figGUI_panShutters_COMStatus(i), 'String', 'X');
                set(handles.figGUI_panShutters_COMStatus(i), 'BackgroundColor', 'red');

                handles.shutters_comStatus = sprintf('Shutter %d: Server connection failed!', i);
                set(handles.figGUI_panShutters_shuttersCOMStatus, 'String', handles.shutters_comStatus);


                        
    		end
    	end
    end


    for(i = 1:5)


        if(handles.com_devState_stages{i} ~= 0);

            serverAns = [];
            err = [];

            switch i
                case{1, 2, 3}

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

                case 4
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

                    pause(0.6)

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
                        break
                    end
                end
                set(handles.figGUI_panStages_comStatus(i),'String', handles.stages_stateString{i}(j));

                case 5
                    serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                        'send_receive', ...
                        handles.stages_serverObj{i}, ...
                        serverCmd, ...
                        handles.com_waitTime.client_server, ...
                        handles.com_numTry...
                        );

                    set(handles.figGUI_panStages_currentPos(i),'String', sprintf('%0.1f', str2double(serverAns)));

                    pause(0.6)

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

                    if(strcmp(serverAns(1),'0') == 1)
                        set(handles.figGUI_panStages_comStatus(i),'String', 'In position');
                    else
                        set(handles.figGUI_panStages_comStatus(i),'String', 'Moving');
                    end

            end

        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Oscilloscope
    if(handles.com_devState_oscilloscope == 1)
        
        if(~isempty(handles.oscilloscope.lastselected_measurement) && ~isempty(handles.oscilloscope.lastselected_source))
            value = get(handles.deviceOscilloscope.Measurement(1), 'Value');
            units = get(handles.deviceOscilloscope.Measurement(1), 'Units');

            sprintf('Oscilloscope measurement: %5.3e %s\n', value, units)
            
            if(strcmp(handles.oscilloscope.lastselected_measurement, 'amplitude') == 1 && strcmp(handles.oscilloscope.lastselected_source, 'channel1') == 1)
                
                RFpower = (value-0.4257)/0.0021; % Coefficient valid for 100 Hz rep rate
                
            else

                RFpower = NaN;
            
            end
        else
            
            set(handles.deviceOscilloscope.Measurement(1), 'MeasurementType', 'amplitude');
            set(handles.deviceOscilloscope.Measurement(1), 'Source', 'channel1');
            set(handles.deviceOscilloscope.Measurement(1), 'State', 'ON');
            
            value = get(handles.deviceOscilloscope.Measurement(1), 'Value');
            units = get(handles.deviceOscilloscope.Measurement(1), 'Units');
            RFpower = (value-0.4257)/0.0021; % Coefficient valid for 100 Hz rep rate
        end
    end
% disp('timer')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Micra
    if(handles.com_devState_micra == 1)
        numConfigParam = numel(handles.micra.cmdList)/2;

       % Send command
        serverAns = cell(2,1);
        err = [];


        for(j=1:2)
            serverCmd = sprintf('sendrcv %s %s', handles.micra_comTermChar, handles.micra.cmdList{numConfigParam+j+4});
            [handles.micra_serverObj, serverAns{j}, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.micra_serverObj, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );
        end

        Laserpower{1} = str2double(char(serverAns{1}));
        Laserpower{2} = str2double(char(serverAns{2}));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Chiller

    if(handles.com_devState_chiller == 1)

       % Send command
        err = [];

        Chiller = cell(2,1);
        
        try

        for(j=1:2)
            if(j==1)
                command = CreateChillerCOMPacket(handles.chiller.cmdList, 'Read Internal Temperature', {});
            else
                command = CreateChillerCOMPacket(handles.chiller.cmdList, 'Read External Sensor', {});
            end
            serverCmd = sprintf('sendrcv_hex %s', command);
            [handles.chiller_serverObj, serverAns, err] = SendReceiveSerial(...
                'send_receive', ...
                handles.chiller_serverObj, ...
                serverCmd, ...
                handles.com_waitTime.client_server, ...
                handles.com_numTry...
                );

                % Parse data
                [data, err] = ParseChillerAnswerPacket(handles.chiller.cmdList, serverAns);
                Chiller{j} = data.param1;
        end
        catch
        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HV
    
    if(strcmp(get(handles.figGUI_menuHV_menuDiscon,'Enable'),'on'))

        if(handles.com_devState_HV_start == 1 || handles.com_devState_HV_start == 2)
            try
                % Get time

                handles.Current(handles.CurrTimePoint,1) = datenum(clock);
                handles.Voltage(handles.CurrTimePoint,1) = handles.Current(handles.CurrTimePoint,1);

                % Auto-save data
                if(handles.CurrTimePoint == handles.numTimePoints)
                    for(i = 1:(handles.numTimePoints-1))
    %                     fprintf(handles.fileID,'%f \t %f \t %f \t %f \t %f\n',handles.Voltage(i,1),handles.Voltage(i,2),handles.Voltage(i,3),handles.Current(i,2),handles.Current(i,3));
                    end
                end

                % Get previous time point
                if(handles.CurrTimePoint == 1)
                    i = handles.numTimePoints;
                elseif(handles.CurrTimePoint > 1)
                    i = handles.CurrTimePoint - 1;
                end


                % Update nominal values
                handles.Current(handles.CurrTimePoint,2) = handles.nominalCurrent;
                handles.Voltage(handles.CurrTimePoint,2) = handles.nominalVoltage;

                % Save handles in base workspace
                assignin('base','handles',handles)

                handles.StatusAutoCondition = get(handles.figGUI_panHV_AutoStatus,'Value');

                % Auto-conditioning
                if(handles.StatusAutoCondition == 1)
                    AutoConditionControl;
                end

                SetNominalDeviceOutput;

                QueryEffectiveDeviceOutput;

                CheckArcThreshold;

                UpdatePlotArea;

                HV{1} = handles.nominalVoltage;

                HV{2} = handles.nominalCurrent;

            catch err
                rethrow(err);
            end

        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    datab = cell(1,numel(handles.logtimer_columnnames)/2);
    datab{1} = now;
    datab{2} = datestr(now);

    try
        datab{3} = RFpower;
    catch
        datab{3} = NaN;
    end

    try
        datab{4} = Laserpower{1};
    catch
        datab{4} = NaN;
    end

    try
        datab{5} = Laserpower{2};
    catch
        datab{5} = NaN;
    end

    try
        datab{6} = Chiller{1};
    catch
        datab{6} = NaN;
    end

    try
        datab{7} = Chiller{2};
    catch
        datab{7} = NaN;
    end

    try
        datab{8} = HV{1};
    catch
        datab{8} = NaN;
    end
    
    try
        datab{9} = HV{2};
    catch
        datab{9} = NaN;
    end


    mksqlite(handles.dbidtimer, ['INSERT INTO ' handles.logtimer_tablename ' VALUES (?,?,?,?,?,?,?,?,?)'], datab{1,:} );
    
end


