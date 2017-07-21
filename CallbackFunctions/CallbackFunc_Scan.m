% Callback function for scan panel
function CallbackFunc_Scan(hObject, event, funcName)

    % Load handles from base workspace
    handles = evalin('base','handles');

    switch(funcName)

        case('update pump check')

            handles = Update_numImgsTotal(handles);

        case('update pump-off images per set')

            handles = Update_numImgsTotal(handles);

        case('update pump-on images per set')

            handles = Update_numImgsTotal(handles);

        case('update after-pump images per set')

            handles = Update_numImgsTotal(handles);

        case('check sample translation')

            if(get(hObject, 'Value') > 0)
                
                totstages = {'Horizontal', 'Vertical', 'Z'};
                samplestages = {};

                for(i = 1:numel(handles.com_devState_stages(1:3)))
                    if handles.com_devState_stages{i} == 0
                        samplestages = [samplestages totstages(i)];
                    end
                end

                if(~isempty(samplestages))
                    [s, OK] = listdlg('Name', 'Sample Server', 'PromptString', 'Select Server', 'SelectionMode', 'multiple', 'ListSize', [150 50], 'ListString', samplestages);
                    

                    for(j = 1:numel(s))

                        switch char(samplestages(s(j)))
                            case 'Horizontal'
                                CallbackFunc_Stages([], [], 'connect 1', []);
                                handles = evalin('base','handles');

                            case 'Vertical'
                                CallbackFunc_Stages([], [], 'connect 2', []);
                                handles = evalin('base','handles');                            

                            case 'Z'
                                CallbackFunc_Stages([], [], 'connect 3', []);
                                handles = evalin('base','handles');

                        end
                        pause(0.2)
                    end
                    
                    if(numel(s)==3 && OK == 0)
                        set(handles.figGUI_panScan2_transl_check, 'Value', 0);
                    end
                end
                
                % Generate horizontal/vertical/longitudinal points                    
                if(isempty(get(handles.figGUI_panScan2_HoriMin,'String')) == 1)
                    handles.scanHoriMin = get(handles.figGUI_panStages_currentPos(1), 'String');
                    set(handles.figGUI_panScan2_HoriMin,'String',handles.scanHoriMin);
                end
                
                if(isempty(get(handles.figGUI_panScan2_HoriStep,'String')) == 1)
                    handles.scanHoriStep = '1';
                    set(handles.figGUI_panScan2_HoriStep,'String',handles.scanHoriStep);
                end

                if(isempty(get(handles.figGUI_panScan2_HoriMax,'String')) == 1)
                    handles.scanHoriMax = handles.scanHoriMin;
                    set(handles.figGUI_panScan2_HoriMax,'String',handles.scanHoriMax);
                end

                if(isempty(get(handles.figGUI_panScan2_VertMin,'String')) == 1)
                    handles.scanVertMin = get(handles.figGUI_panStages_currentPos(2), 'String');
                    set(handles.figGUI_panScan2_VertMin,'String',handles.scanVertMin);
                end
                
                if(isempty(get(handles.figGUI_panScan2_VertStep,'String')) == 1)
                    handles.scanVertStep = '1';
                    set(handles.figGUI_panScan2_VertStep,'String',handles.scanVertStep);
                end

                if(isempty(get(handles.figGUI_panScan2_VertMax,'String')) == 1)
                    handles.scanVertMax = handles.scanVertMin;
                    set(handles.figGUI_panScan2_VertMax,'String',handles.scanVertMax);
                end
                
                if(isempty(get(handles.figGUI_panScan2_ZMin,'String')) == 1)
                    handles.scanZMin = get(handles.figGUI_panStages_currentPos(3), 'String');
                    set(handles.figGUI_panScan2_ZMin,'String',handles.scanZMin);
                end
                
                if(isempty(get(handles.figGUI_panScan2_ZStep,'String')) == 1)
                    handles.scanZStep = '1';
                    set(handles.figGUI_panScan2_ZStep,'String',handles.scanZStep);
                end

                if(isempty(get(handles.figGUI_panScan2_ZMax,'String')) == 1)
                    handles.scanZMax = handles.scanZMin;
                    set(handles.figGUI_panScan2_ZMax,'String',handles.scanZMax);
                end                


                if(abs(str2num(handles.scanHoriMin) - str2num(handles.scanHoriMax)) == 0)
                    handles.scanHoriPoints = [str2num(handles.scanHoriMin)];
                else
                    handles.scanHoriPoints = [str2num(handles.scanHoriMin):str2num(handles.scanHoriStep):str2num(handles.scanHoriMax)];
                end

                if(abs(str2num(handles.scanVertMin) - str2num(handles.scanVertMax)) == 0)
                    handles.scanVertPoints = [str2num(handles.scanVertMin)];
                else
                    handles.scanVertPoints = [str2num(handles.scanVertMin):str2num(handles.scanVertStep):str2num(handles.scanVertMax)];
                end
                
                if(abs(str2num(handles.scanZMin) - str2num(handles.scanZMax)) == 0)
                    handles.scanZPoints = [str2num(handles.scanZMin)];
                else
                    handles.scanZPoints = [str2num(handles.scanZMin):str2num(handles.scanZStep):str2num(handles.scanZMax)];
                end
                
                if(numel(handles.scanHoriPoints) == 0)
                    handles.scanHoriPoints = 1;
                end

                if(numel(handles.scanVertPoints) == 0)
                    handles.scanVertPoints = 1;
                end
                
                if(numel(handles.scanZPoints) == 0)
                    handles.scanZPoints = 1;
                end


                % Number of sample points
                handles.numSamplePoints = num2str(numel(handles.scanHoriPoints)*numel(handles.scanVertPoints)*numel(handles.scanZPoints));
                
                % Generate sample points 
                [a, b, c] = meshgrid(handles.scanHoriPoints, handles.scanVertPoints, handles.scanZPoints);
                handles.scanHoriPos = reshape(a, str2num(handles.numSamplePoints), 1);
                handles.scanVertPos = reshape(b, str2num(handles.numSamplePoints), 1);
                handles.scanZPos = reshape(c, str2num(handles.numSamplePoints), 1);

                % Update text box
                set(handles.figGUI_panScan5_numSamplePoints, 'String', handles.numSamplePoints);

                % Update total number of images
                handles = Update_numImgsTotal(handles);

            else

                % Update value
                handles.scanHoriPoints = [];
                handles.scanVertPoints = [];
                handles.scanZPoints = [];
                handles.numSamplePoints = '0';

                % Update text box
                set(handles.figGUI_panScan5_numSamplePoints, 'String', handles.numSamplePoints);
                %set(handles.figGUI_panScan2_transl_table, 'Data', [handles.scanHoriPos,handles.scanVertPos]);
                                
                % Update total number of images
                handles = Update_numImgsTotal(handles);
           
            end

            % Update scan comments
            UpdateScanComments;
            
            if(get(handles.figGUI_panScan2_transl_check,'Value') == 1 || ...
                get(handles.figGUI_panScan3_time_check,'Value') == 1 || ...
                get(handles.figGUI_panScan4_rot_check,'Value') == 1)
            
                set(handles.figGUI_panScan5_buttGo, 'Enable', 'on')
                set(handles.figGUI_panScan5_buttAbort, 'Enable', 'off')
            else
                set(handles.figGUI_panScan5_buttGo, 'Enable', 'off')
                set(handles.figGUI_panScan5_buttAbort, 'Enable', 'on')
            end            

        case('check time delay')

            if(get(hObject, 'Value') > 0)
                if(handles.com_devState_stages{4} ~= 1)
                    choice = questdlg('Delay Stage Server is not running. Do you want to start it?', 'Delay Stage', ...
                        'O.K.', 'Cancel', 'O.K.');
                    
                    switch choice
                        case 'O.K.'
                            CallbackFunc_Stages([], [], 'connect 4', []);
                            handles = evalin('base','handles');
                            
                        otherwise
                            set(handles.figGUI_panScan3_time_check, 'Value', 0);
                    end
                end

                % Generate time points
                if(isempty(get(handles.figGUI_panScan3_Time_timeZero,'String')) == 1)
                    set(handles.figGUI_panScan3_Time_timeZero, 'String', '0');
                    handles.scanTimeZeroPos = get(handles.figGUI_panScan3_Time_timeZero,'String');
                end

                if(isempty(get(handles.figGUI_panScan3_TimeMin,'String')) == 1)
                    handles.scanTimeMin = num2str((str2double(get(handles.figGUI_panStages_currentPos(4), 'String'))- str2double(get(handles.figGUI_panScan3_Time_timeZero,'String')))/1e-12/299792458*(1e-6)*2,'%5.0f');
                    set(handles.figGUI_panScan3_TimeMin,'String',handles.scanTimeMin);
                end

                if(isempty(get(handles.figGUI_panScan3_TimeStep,'String')) == 1)
                    handles.scanTimeStep = '1';
                    set(handles.figGUI_panScan3_TimeStep,'String',handles.scanTimeStep);
                end

                if(isempty(get(handles.figGUI_panScan3_TimeMax,'String')) == 1)
                    handles.scanTimeMax = handles.scanTimeMin;
                    set(handles.figGUI_panScan3_TimeMax,'String',handles.scanTimeMax);
                end

                if(abs(str2num(handles.scanTimeMin) - str2num(handles.scanTimeMax)) == 0)
                    handles.scanTimePoints = [str2num(handles.scanTimeMin)];
                else
                    handles.scanTimePoints = [str2num(handles.scanTimeMin):str2num(handles.scanTimeStep):str2num(handles.scanTimeMax)];    
                end
                handles.scanTimePoints_str = sprintf('%g ', handles.scanTimePoints);

                % Calculate time stage positions
                handles.scanTimeStagePos = str2num(handles.scanTimePoints_str)*1e-12*299792458/(1e-6)/2 + str2num(handles.scanTimeZeroPos);
                handles.scanTimeStagePos_str = num2str(round(handles.scanTimeStagePos));

                % Number of time points
                handles.numTimePoints = num2str(numel(handles.scanTimePoints));

                % Update text box
                set(handles.figGUI_panScan3_Time_edit, 'String', handles.scanTimePoints_str);
                set(handles.figGUI_panScan3_TimePos_edit, 'String', handles.scanTimeStagePos_str);
                set(handles.figGUI_panScan5_numTimePoints, 'String', handles.numTimePoints);
                
                % Save handles in base workspace
                assignin('base','handles',handles)

                % Update total number of images
                handles = Update_numImgsTotal(handles);

                % Enable edit text box
                set(handles.figGUI_panScan3_Time_edit, 'Enable', 'on');
                set(handles.figGUI_panScan3_TimePos_edit, 'Enable', 'on');

            else

                % Update value
                handles.numTimePoints = 0;

                % Update text box
                set(handles.figGUI_panScan5_numTimePoints, 'String', handles.numTimePoints);
                %set(handles.figGUI_panScan3_Time_edit, 'String', '');

                % Update total number of images
                handles = Update_numImgsTotal(handles);

                % Disable edit text box
                set(handles.figGUI_panScan3_Time_edit, 'Enable', 'off');
                set(handles.figGUI_panScan3_TimePos_edit, 'Enable', 'off');
                
            end

            % Update scan comment box
            UpdateScanComments;
            
            if(get(handles.figGUI_panScan2_transl_check,'Value') == 1 || ...
                get(handles.figGUI_panScan3_time_check,'Value') == 1 || ...
                get(handles.figGUI_panScan4_rot_check,'Value') == 1)
            
                set(handles.figGUI_panScan5_buttGo, 'Enable', 'on')
                set(handles.figGUI_panScan5_buttAbort, 'Enable', 'off')
            else
                set(handles.figGUI_panScan5_buttGo, 'Enable', 'off')
                set(handles.figGUI_panScan5_buttAbort, 'Enable', 'on')
            end            


        case('update time points and position')

            % Update time points
            handles.scanTimePoints_str = get(handles.figGUI_panScan3_Time_edit, 'String');

            % Calculate time stage positions
            handles.scanTimeStagePos = str2num(handles.scanTimePoints_str)*1e-12*299792458/(1e-6)/2 + str2num(handles.scanTimeZeroPos);
            handles.scanTimeStagePos_str = num2str(round(handles.scanTimeStagePos));

            set(handles.figGUI_panScan3_TimePos_edit, 'String', handles.scanTimeStagePos_str);

            % Update number of time points
            handles.numTimePoints = num2str(numel(handles.scanTimeStagePos));

            set(handles.figGUI_panScan5_numTimePoints, 'String', handles.numTimePoints);

            % Update total number of images
            handles = Update_numImgsTotal(handles);

            % Update scan comments
            UpdateScanComments;

        case('update rotation points and position')

            % Update rotation points
            handles.scanRotPoints_str = get(handles.figGUI_panScan3_Rot_edit, 'String');

            % Calculate rotation stage positions
            handles.scanRotStagePos = str2num(handles.scanRotPoints_str) + str2num(handles.scanRotZeroPos);
            handles.scanRotStagePos_str = num2str(handles.scanRotStagePos);

            set(handles.figGUI_panScan3_RotPos_edit, 'String', handles.scanRotStagePos_str);

            % Update number of rotation points
            handles.numRotPoints = num2str(numel(handles.scanRotStagePos));

            set(handles.figGUI_panScan5_numRotPoints, 'String', handles.numRotPoints);

            % Update total number of images
            handles = Update_numImgsTotal(handles);

            % Update scan comments
            UpdateScanComments;

        case('check sample rotation')

            if(get(hObject, 'Value') > 0)
                
                if(handles.com_devState_stages{5} ~= 1)
                    choice = questdlg('Rotation Stage Server is not running. Do you want to start it?', 'Rotation Stage', ...
                        'O.K.', 'Cancel', 'O.K.');
                    
                    switch choice
                        case 'O.K.'
                            CallbackFunc_Stages([], [], 'connect 5', []);
                            handles = evalin('base','handles');
                            
                        otherwise
                            set(handles.figGUI_panScan4_rot_check, 'Value', 0);
                    end
                end

                % Generate rot points               
                if(isempty(get(handles.figGUI_panScan4_Rot_rotZero,'String')) == 1)
                    set(handles.figGUI_panScan4_Rot_rotZero, 'String', '0');
                    handles.scanRotZeroPos = get(handles.figGUI_panScan4_Rot_rotZero,'String');
                end
                
                if(isempty(get(handles.figGUI_panScan4_RotMin,'String')) == 1)
                    handles.scanRotMin = get(handles.figGUI_panStages_currentPos(5), 'String');
                    set(handles.figGUI_panScan4_RotMin,'String',handles.scanRotMin);
                end
                
                if(isempty(get(handles.figGUI_panScan4_RotStep,'String')) == 1)
                    handles.scanRotStep = '1';
                    set(handles.figGUI_panScan4_RotStep,'String',handles.scanRotStep);
                end

                if(isempty(get(handles.figGUI_panScan4_RotMax,'String')) == 1)
                    handles.scanRotMax = handles.scanRotMin;
                    set(handles.figGUI_panScan4_RotMax,'String',handles.scanRotMax);
                end
                
                if(abs(str2num(handles.scanRotMin) - str2num(handles.scanRotMax)) == 0)
                    handles.scanRotPoints = [str2num(handles.scanRotMin)];
                else
                    handles.scanRotPoints = [str2num(handles.scanRotMin):str2num(handles.scanRotStep):str2num(handles.scanRotMax)];    
                end
                
                if(numel(handles.scanRotPoints) == 0)
                    handles.scanRotPoints = 1;
                end
                
                handles.scanRotPoints_str = sprintf('%g ', handles.scanRotPoints);

                % Number of rotation points
                handles.numRotPoints = num2str(numel(handles.scanRotPoints));

                % Update text box
                set(handles.figGUI_panScan5_numRotPoints, 'String', handles.numRotPoints);
                set(handles.figGUI_panScan4_Rot_edit, 'String', handles.scanRotPoints_str);
                set(handles.figGUI_panScan4_RotPos_edit, 'String', handles.scanRotStagePos_str);
                
                % Save handles in base workspace
                assignin('base','handles',handles)

                % Update total number of images
                handles = Update_numImgsTotal(handles);

                % Enable edit text box
                set(handles.figGUI_panScan4_Rot_edit, 'Enable', 'on');
                set(handles.figGUI_panScan4_RotPos_edit, 'Enable', 'on');

            else

                % Update value
                handles.numRotPoints = 0;

                % Update text box
                set(handles.figGUI_panScan5_numRotPoints, 'String', handles.numRotPoints);

                % Update total number of images
                handles = Update_numImgsTotal(handles);

                % Disable edit text box
                set(handles.figGUI_panScan4_Rot_edit, 'Enable', 'off');
                set(handles.figGUI_panScan4_RotPos_edit, 'Enable', 'off');
            end

            % Update scan comment box
            UpdateScanComments;

            if(get(handles.figGUI_panScan2_transl_check,'Value') == 1 || ...
                get(handles.figGUI_panScan3_time_check,'Value') == 1 || ...
                get(handles.figGUI_panScan4_rot_check,'Value') == 1)
            
                set(handles.figGUI_panScan5_buttGo, 'Enable', 'on')
                set(handles.figGUI_panScan5_buttAbort, 'Enable', 'off')
            else
                set(handles.figGUI_panScan5_buttGo, 'Enable', 'off')
                set(handles.figGUI_panScan5_buttAbort, 'Enable', 'on')
            end            

            
        case('update grand loop')

            % Update total number of images
            handles = Update_numImgsTotal(handles);

        case('update sets per point')

            % Update total number of images
            handles = Update_numImgsTotal(handles);

        case('start scan')

            set(handles.figGUI_panScan5_scanStatus,'String', sprintf('Start scan!'));

            % Disable scan settings
            set(handles.figGUI_panScan5_buttGo, 'Enable', 'off');
            set(handles.figGUI_panScan5_buttAbort, 'Enable', 'on');
            set(handles.figGUI_panScan1_scanNum, 'Enable', 'off');
            set(handles.figGUI_panScan1_scanComment, 'Enable', 'off');
            set(handles.figGUI_panScan1_ImgPumpOff_check, 'Enable', 'off');
            set(handles.figGUI_panScan1_ImgPumpOn_check, 'Enable', 'off');
            set(handles.figGUI_panScan1_ImgAfter_check, 'Enable', 'off');

            set(handles.figGUI_panScan5_numGrandLoops, 'Enable', 'off');
            set(handles.figGUI_panScan5_numImgPerPoint, 'Enable', 'off');

            
            % Disable HV buttons
            set(handles.figGUI_panHV_ArcStatus,'Enable','off');
            set(handles.figGUI_panHV_AutoStatus,'Enable','off');
            set(handles.figGUI_panHV_start,'Enable','off');
            set(handles.figGUI_panHV_shutdown,'Enable','off');
            set(handles.figGUI_panHV_NomVoltage,'Enable','off');
            set(handles.figGUI_panHV_NomVoltageAdd,'Enable','off');
            set(handles.figGUI_panHV_NomVoltageMinus,'Enable','off');
            set(handles.figGUI_menuHV,'Enable','off');

            
            % Disable camera buttons
            set(handles.figGUI_panCamera_AcqMode,'Enable','off');
            set(handles.figGUI_panCamera_ROI,'Enable','off');
            set(handles.figGUI_panCamera_autoSave_check,'Enable','off');
            set(handles.figGUI_panCamera_autoSave_path,'Enable','off');
            set(handles.figGUI_panCamera_AcqMode,'Enable','off');
            set(handles.figGUI_panCamera_autoSave_filename,'Enable','off');
            set(handles.figGUI_panCamera_autoSave_format,'Enable','off');
            set(handles.figGUI_panCamera_AcqType,'Enable','off');
            set(handles.figGUI_panCamera_ExposureTime,'Enable','off');
            set(handles.figGUI_panCamera_autoSave_filename,'Enable','off');
            set(handles.figGUI_panCamera_autoSave_format,'Enable','off');
            set(handles.figGUI_panCamera_buttDiscon,'Enable','off');
            set(handles.figGUI_menuCamera,'Enable','off');
            
            
            % Disable stages buttons
            for(i = 1:5)
                set(handles.figGUI_panStages_opMode(i),'Enable','off');
                set(handles.figGUI_panStages_buttGo(i),'Enable','off');
                set(handles.figGUI_panStages_buttStop(i),'Enable','off');
                set(handles.figGUI_panStages_buttDiscon(i),'Enable','off');
                set(handles.figGUI_panStages_value(i),'Enable','off');
                set(handles.figGUI_panStages_opMode(i),'Value',1);
            end
            
            set(handles.figGUI_menuStages,'Enable','off');
            set(handles.figGUI_panStages_opMode(4),'Value',1);
                        
            % Disable shutters buttons
            for(i = 1:3)
                set(handles.figGUI_panShutters_buttO(i),'Enable','off');
                set(handles.figGUI_panShutters_buttX(i),'Enable','off');
            end
            
            set(handles.figGUI_panShutters_buttDiscon,'Enable','off');
            set(handles.figGUI_menuShutters,'Enable','off');
            
            % Disable Micra menus
            set(handles.figGUI_menuMicra,'Enable','off');

            % Disable Oscilloscope menus
            set(handles.figGUI_menuOscilloscope,'Enable','off');

            % Disable Chiller menus
            set(handles.figGUI_menuChiller,'Enable','off');

            if(get(handles.figGUI_panScan3_time_check,'Value') == 0)
                handles.scanTimeStagePos = 1;
            end

            if(get(handles.figGUI_panScan2_transl_check,'Value') == 0)
                handles.scanZPoints = 1;
                handles.scanHoriPoints = 1;
                handles.scanVertPoints = 1;
            end
            
            if(get(handles.figGUI_panScan4_rot_check,'Value') == 0)
                handles.scanRotPoints = 1;
            end
            
            handles.scanrunning = 1;
            imagenum = 0;
            
            glnum = 0;
            
            totalimages = str2double(get(handles.figGUI_panScan5_numImgsTotal,'String'));
            set(handles.ScanProgbar, 'Value', 0);
            numpumpoff = str2double(get(handles.figGUI_panScan1_ImgPumpOff_edit,'String'));
            numpumpon = str2double(get(handles.figGUI_panScan1_ImgPumpOn_edit,'String'));
            numpumpafter = str2double(get(handles.figGUI_panScan1_ImgAfter_edit,'String'));
            numsetspp = str2double(get(handles.figGUI_panScan5_numImgPerPoint, 'String'));

            for(gl = 1:str2double(handles.numGrandLoops))
                glnum = glnum + 1;
                set(handles.figGUI_panScan5_numGrandLoops_curr,'String',glnum);
                for(d = 1:numel(handles.scanTimeStagePos))
                    set(handles.figGUI_panScan5_numTimePoints_curr,'String',num2str(d))
                    if(get(handles.figGUI_panScan3_time_check,'Value') == 0 || handles.com_devState_stages{4} == 0)
                        set(handles.figGUI_panStages_currentPos(4),'String', 'NaN');
                    else

                        set(handles.figGUI_panStages_value(4),'String',num2str(handles.scanTimeStagePos(d),'%.1f'))

                        % Start Motion

                        i = 4;

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
                            set(handles.figGUI_panStages_targetPos(i),'String',get(handles.figGUI_panStages_value(i),'String'))
                            positionmm = num2str(str2double(get(handles.figGUI_panStages_targetPos(i),'String'))/1000, '%.4f');

                            serverCmd = sprintf('sendrcv %s %s%s', handles.stages_comTermChar{i}, movecmd, positionmm);
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

                        end

                        % Change COM status box
                        set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                        set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

                        status4 = '28';

                        while(strcmp(status4,'28') == 1)

                            % check status
                            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{4}, handles.stages_cmd{4}.GetState);
                            [handles.stages_serverObj{4}, serverAns, err] = SendReceiveSerial(...
                                'send_receive', ...
                                handles.stages_serverObj{4}, ...
                                serverCmd, ...
                                handles.com_waitTime.client_server, ...
                                handles.com_numTry...
                                );

                            status4 = serverAns(end-1:end);
                        end

                        % check position
                        serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{4}, handles.stages_cmd{4}.GetCurrPos);
                        [handles.stages_serverObj{4}, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.stages_serverObj{4}, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                        positionum = num2str(str2double(serverAns(4:end))*1000,'%.1f');
                        set(handles.figGUI_panStages_currentPos(4),'String', positionum);
                    end
                    handles.stages_comStatus{4} = 'In position';
                    set(handles.figGUI_panStages_comStatus(4), 'String', handles.stages_comStatus{4});

                    for(z = 1:numel(handles.scanZPoints))
                        if(get(handles.figGUI_panScan2_transl_check,'Value') == 0 || handles.com_devState_stages{3}==0)
                            set(handles.figGUI_panStages_currentPos(3),'String', 'NaN');
                        else

                            set(handles.figGUI_panStages_value(3),'String',num2str(handles.scanZPoints(z),'%.1f'))

                            if(strcmp(get(handles.figGUI_panStages_currentPos(3),'String'), num2str(handles.scanZPoints(z),'%.1f')) ~= 1)
                                % Start motion 3
                                i = 3;

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
                                    set(handles.figGUI_panStages_targetPos(i),'String',get(handles.figGUI_panStages_value(i),'String'))

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

                                end

                                % Change COM status box
                                set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                                set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

                                status3 = '1';

                                while(strcmp(status3,'1') == 1)

                                    % check status
                                    serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, '!TAS');
                                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                        'send_receive', ...
                                        handles.stages_serverObj{i}, ...
                                        serverCmd, ...
                                        handles.com_waitTime.client_server, ...
                                        handles.com_numTry...
                                        );

                                    status3 = serverAns(11);
                                end

                                % check position
                                serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                    'send_receive', ...
                                    handles.stages_serverObj{i}, ...
                                    serverCmd, ...
                                    handles.com_waitTime.client_server, ...
                                    handles.com_numTry...
                                    );

                                posind = regexp(serverAns,'[-+0-9]');
                                pos = serverAns(posind(1):posind(end));

                                set(handles.figGUI_panStages_currentPos(i),'String', num2str(str2double(pos)*handles.stages_scalefactor{i},'%.1f'));
                                handles.stages_comStatus{i} = 'In position';
                                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
                            end
                        end

                        for(v = 1:numel(handles.scanVertPoints))
                            if(get(handles.figGUI_panScan2_transl_check,'Value') == 0 || handles.com_devState_stages{2} == 0)
                                set(handles.figGUI_panStages_currentPos(2),'String', 'NaN');
                            else

                                set(handles.figGUI_panStages_value(2),'String',num2str(handles.scanVertPoints(v),'%.1f'))
                                if(strcmp(get(handles.figGUI_panStages_currentPos(2),'String'), num2str(handles.scanVertPoints(v),'%.1f')) ~= 1)
                                    % Start motion 2
                                    i = 2;

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

                                        set(handles.figGUI_panStages_targetPos(i),'String',get(handles.figGUI_panStages_value(i),'String'))

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

                                    end

                                    % Change COM status box
                                    set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                                    set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');


                                    status2 = '1';

                                    while(strcmp(status2,'1') == 1)

                                        % check status
                                        serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, '!TAS');
                                        [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                            'send_receive', ...
                                            handles.stages_serverObj{i}, ...
                                            serverCmd, ...
                                            handles.com_waitTime.client_server, ...
                                            handles.com_numTry...
                                            );

                                        status2 = serverAns(11);
                                    end

                                    % check position
                                    serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                        'send_receive', ...
                                        handles.stages_serverObj{i}, ...
                                        serverCmd, ...
                                        handles.com_waitTime.client_server, ...
                                        handles.com_numTry...
                                        );

                                    posind = regexp(serverAns,'[-+0-9]');
                                    pos = serverAns(posind(1):posind(end));

                                    set(handles.figGUI_panStages_currentPos(i),'String', num2str(str2double(pos)*handles.stages_scalefactor{i},'%.1f'));
                                    handles.stages_comStatus{i} = 'In position';
                                    set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});
                                end
                            end

                            for(h = 1:numel(handles.scanHoriPoints))
                                if(get(handles.figGUI_panScan2_transl_check,'Value') == 0 || handles.com_devState_stages{1} == 0)
                                    set(handles.figGUI_panStages_currentPos(1),'String', 'NaN');
                                else

                                    set(handles.figGUI_panStages_value(1),'String',num2str(handles.scanHoriPoints(h),'%.1f'))
                                    if(strcmp(get(handles.figGUI_panStages_currentPos(1),'String'), num2str(handles.scanHoriPoints(h),'%.1f')) ~= 1)
                                        % Start motion 1
                                        i = 1;

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
                                            set(handles.figGUI_panStages_targetPos(i),'String',get(handles.figGUI_panStages_value(i),'String'))

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

                                        end

                                        % Change COM status box
                                        set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                                        set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

                                        status1 = '1';

                                        while(strcmp(status1,'1') == 1)

                                            % check status
                                            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, '!TAS');
                                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                                'send_receive', ...
                                                handles.stages_serverObj{i}, ...
                                                serverCmd, ...
                                                handles.com_waitTime.client_server, ...
                                                handles.com_numTry...
                                                );

                                            status1 = serverAns(11);

                                        end

                                        % check position
                                        serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                                        [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                            'send_receive', ...
                                            handles.stages_serverObj{i}, ...
                                            serverCmd, ...
                                            handles.com_waitTime.client_server, ...
                                            handles.com_numTry...
                                            );

                                        posind = regexp(serverAns,'[-+0-9]');
                                        pos = serverAns(posind(1):posind(end));

                                        set(handles.figGUI_panStages_currentPos(1),'String', num2str(str2double(pos)*handles.stages_scalefactor{i},'%.1f'));
                                        handles.stages_comStatus{i} = 'In position';
                                        set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                                    end
                                end

                                for(r = 1:numel(handles.scanRotPoints))
                                    set(handles.figGUI_panScan5_numRotPoints_curr,'String',num2str(r))
                                    if(get(handles.figGUI_panScan4_rot_check,'Value') == 0 || handles.com_devState_stages{5} == 0)
                                        set(handles.figGUI_panStages_currentPos(5),'String', 'NaN');
                                    else


                                        set(handles.figGUI_panStages_value(5),'String',num2str(handles.scanRotPoints(r),'%.1f'))
                                        if(strcmp(get(handles.figGUI_panStages_currentPos(5),'String'), num2str(handles.scanRotPoints(r),'%.1f')) ~= 1)

                                            % Start motion 5
                                            i = 5;

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

                                                    serverCmd = sprintf('sendrcv %s %s %s', handles.stages_comTermChar{i}, get(handles.figGUI_panStages_value(i),'String'), movecmd);
                                                    [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                                        'send_receive', ...
                                                        handles.stages_serverObj{i}, ...
                                                        serverCmd, ...
                                                        handles.com_waitTime.client_server, ...
                                                        handles.com_numTry...
                                                        );

                                                end

                                                handles.com_timeLastCOM.stages{i} = now - handles.timer_timeNow;


                                                % Change status
                                                handles.stages_comStatus{i} = 'Moving...';
                                                set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                                            end

                                            % Change COM status box
                                            set(handles.figGUI_panStages_COMStatus(i), 'BackgroundColor', 'green');
                                            set(handles.figGUI_panStages_COMStatus(i), 'String', 'O');

                                            %%%%%

                                            status5 = '1';

                                            while(strcmp(status5,'1') == 1)

                                                % check status
                                                serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetState);
                                                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                                    'send_receive', ...
                                                    handles.stages_serverObj{i}, ...
                                                    serverCmd, ...
                                                    handles.com_waitTime.client_server, ...
                                                    handles.com_numTry...
                                                    );

                                                try
                                                    comp_status5 = dec2bin(str2double(serverAns),8);
                                                catch
                                                    comp_status5 =  '000000001';
                                                end

                                                status5 = comp_status5(end);
                                                pause(0.4)
                                            end

                                            % check position
                                            serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i}, handles.stages_cmd{i}.GetCurrPos);
                                            [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                                                'send_receive', ...
                                                handles.stages_serverObj{i}, ...
                                                serverCmd, ...
                                                handles.com_waitTime.client_server, ...
                                                handles.com_numTry...
                                                );

                                            rotpos = num2str(str2double(serverAns),'%.1f');
                                            set(handles.figGUI_panStages_currentPos(i),'String',rotpos);    
                                        end
                                    end
                                        handles.stages_comStatus{i} = 'In position';
                                        set(handles.figGUI_panStages_comStatus(i), 'String', handles.stages_comStatus{i});

                                        for nset = 1:numsetspp
                                            set(handles.figGUI_panScan5_numImgPerPoint_curr, 'String', num2str(nset));
                                            if(get(handles.figGUI_panScan1_ImgPumpOff_check, 'Value') == 1)
                                                % Pump shutter remains off
                                                set(handles.figGUI_panScan1_ImgPumpOff_edit_stat, 'Visible', 'on');
                                                for poff = 1:numpumpoff
                                                    CallbackFunc_Camera([],[],'start acquisition')
                                                    imagenum = imagenum + 1;
                                                    set(handles.ScanProgbar, 'Value', imagenum/totalimages*100);
                                                    set(handles.figGUI_panScan5_numImgsTotal_curr,'String',imagenum);
                                                end
                                                set(handles.figGUI_panScan1_ImgPumpOff_edit_stat, 'Visible', 'off');
                                            end

                                            if(get(handles.figGUI_panScan1_ImgPumpOn_check, 'Value') == 1)
                                                set(handles.figGUI_panScan1_ImgPumpOn_edit_stat, 'Visible', 'on');
                                                for pon = 1:numpumpon
                                                    CallbackFunc_Shutters([], [], 'open shutter 2', [])
                                                    CallbackFunc_Camera([],[],'start acquisition')
                                                    CallbackFunc_Shutters([], [], 'close shutter 2', [])
                                                    imagenum = imagenum + 1;
                                                    set(handles.ScanProgbar, 'Value', imagenum/totalimages*100);
                                                    set(handles.figGUI_panScan5_numImgsTotal_curr,'String',imagenum);
                                                end
                                                set(handles.figGUI_panScan1_ImgPumpOn_edit_stat, 'Visible', 'off');
                                            end

                                            if(get(handles.figGUI_panScan1_ImgAfter_check, 'Value') == 1)
                                                % Pump shutter remains off
                                                set(handles.figGUI_panScan1_ImgPumpAfter_edit_stat, 'Visible', 'on');
                                                for pafter = 1:numpumpafter
                                                    CallbackFunc_Camera([],[],'start acquisition')
                                                    imagenum = imagenum + 1;
                                                    set(handles.ScanProgbar, 'Value', imagenum/totalimages*100);
                                                    set(handles.figGUI_panScan5_numImgsTotal_curr,'String',imagenum);
                                                end
                                                set(handles.figGUI_panScan1_ImgPumpAfter_edit_stat, 'Visible', 'off');
                                            end
                                        end

                                        if(get(handles.figGUI_panScan5_buttAbort,'Value') == 1)
                                            break;
                                        end
                                end

                                if(get(handles.figGUI_panScan5_buttAbort,'Value') == 1)
                                    break;
                                end

                            end

                            if(get(handles.figGUI_panScan5_buttAbort,'Value') == 1)
                                break;
                            end

                        end

                        if(get(handles.figGUI_panScan5_buttAbort,'Value') == 1)
                            break;
                        end

                    end

                    if(get(handles.figGUI_panScan5_buttAbort,'Value') == 1)
                        break;
                    end

                end    
            end
                
% End of Scan

            % Update Scan number
            presentScanNumber = str2double(get(handles.figGUI_panScan1_scanNum,'String'));
            newScanNumber = presentScanNumber + 1;
            set(handles.figGUI_panScan1_scanNum, 'String', num2str(newScanNumber));
            UpdateEditValue(handles.figGUI_panScan1_scanNum, [], 'scanNum');
            
            % Renable HV buttons
            set(handles.figGUI_panHV_ArcStatus,'Enable','on');
            set(handles.figGUI_panHV_AutoStatus,'Enable','on');
            set(handles.figGUI_panHV_start,'Enable','on');
            set(handles.figGUI_panHV_shutdown,'Enable','on');
            set(handles.figGUI_panHV_NomVoltage,'Enable','on');
            set(handles.figGUI_panHV_NomVoltageAdd,'Enable','on');
            set(handles.figGUI_panHV_NomVoltageMinus,'Enable','on');
            set(handles.figGUI_menuHV,'Enable','on');


            % Renable camera buttons
            set(handles.figGUI_panCamera_AcqMode,'Enable','on');
            set(handles.figGUI_panCamera_ROI,'Enable','on');
            set(handles.figGUI_panCamera_autoSave_check,'Enable','on');
            set(handles.figGUI_panCamera_autoSave_path,'Enable','on');
            set(handles.figGUI_panCamera_AcqMode,'Enable','on');
            set(handles.figGUI_panCamera_autoSave_filename,'Enable','on');
            set(handles.figGUI_panCamera_autoSave_format,'Enable','on');
            set(handles.figGUI_panCamera_AcqType,'Enable','on');
            set(handles.figGUI_panCamera_ExposureTime,'Enable','on');
            set(handles.figGUI_panCamera_autoSave_filename,'Enable','on');
            set(handles.figGUI_panCamera_autoSave_format,'Enable','on');
            set(handles.figGUI_panCamera_buttDiscon,'Enable','on');
            set(handles.figGUI_panCamera_buttAcq,'Enable','on');
            set(handles.figGUI_panCamera_buttAbort,'Enable','off');
            set(handles.figGUI_menuCamera,'Enable','on');



            % Renable stages buttons
            for(i = 1:5)
                if(handles.com_devState_stages{i} == 0)
                    set(handles.figGUI_panStages_buttConn(i),'Enable','on');
                else
                    set(handles.figGUI_panStages_opMode(i),'Enable','on');
                    set(handles.figGUI_panStages_buttGo(i),'Enable','on');
                    set(handles.figGUI_panStages_buttStop(i),'Enable','on');
                    set(handles.figGUI_panStages_buttDiscon(i),'Enable','on');
                    set(handles.figGUI_panStages_value(i),'Enable','on');
                    if(get(handles.figGUI_panStages_opMode(i),'Value')==2)
                        set(handles.figGUI_panStages_dir(i),'Enable','on');
                    end
                end
            end
            set(handles.figGUI_menuStages,'Enable','on');
            
            % Renable shutters buttons
            for(i = 1:3)
                set(handles.figGUI_panShutters_buttO(i),'Enable','on');
                set(handles.figGUI_panShutters_buttX(i),'Enable','on');
            end
            
            set(handles.figGUI_panShutters_buttDiscon,'Enable','on');
            set(handles.figGUI_menuShutters,'Enable','on');

            set(handles.figGUI_panScan5_scanStatus,'String', sprintf('Scan finished!'));
            
            % Renable Micra menus
            set(handles.figGUI_menuMicra,'Enable','on');

            % Renable Oscilloscope menus
            set(handles.figGUI_menuOscilloscope,'Enable','on');

            % Renable Chiller menus
            set(handles.figGUI_menuChiller,'Enable','on');


            % Renable scan settings
            set(handles.figGUI_panScan5_buttGo, 'Enable', 'on');
            set(handles.figGUI_panScan5_buttAbort, 'Enable', 'of');
            set(handles.figGUI_panScan1_scanNum, 'Enable', 'on');
            set(handles.figGUI_panScan1_scanComment, 'Enable', 'on');
            set(handles.figGUI_panScan1_ImgPumpOff_check, 'Enable', 'on');
            set(handles.figGUI_panScan1_ImgPumpOn_check, 'Enable', 'on');
            set(handles.figGUI_panScan1_ImgAfter_check, 'Enable', 'on');

            set(handles.figGUI_panScan5_numGrandLoops, 'Enable', 'on');
            set(handles.figGUI_panScan5_numImgPerPoint, 'Enable', 'on');
            
            set(handles.figGUI_panScan5_buttAbort,'Value', 0)
            handles.scanrunning = 0;


        case('abort scan')

            set(handles.figGUI_panScan5_scanStatus,'String', sprintf('Abort scan!'));

            % Enable scan settings
            set(handles.figGUI_panScan5_buttGo, 'Enable', 'on');
            set(handles.figGUI_panScan5_buttAbort, 'Enable', 'off');
            set(handles.figGUI_panScan1_scanNum, 'Enable', 'on');
            set(handles.figGUI_panScan1_scanComment, 'Enable', 'on');
            set(handles.figGUI_panScan1_ImgPumpOff_check, 'Enable', 'on');
            set(handles.figGUI_panScan1_ImgPumpOn_check, 'Enable', 'on');
            set(handles.figGUI_panScan1_ImgAfter_check, 'Enable', 'on');

            set(handles.figGUI_panScan5_numGrandLoops, 'Enable', 'on');
            set(handles.figGUI_panScan5_numImgPerPoint, 'Enable', 'on');

    end

    % Restart timer
    try
        if(strcmp(handles.timer_status, 'on') > 0)
            start(handles.timer_obj);
            disp('Timer restarted')
        end
    catch
    end


	% Save handles in base workspace
    assignin('base','handles',handles)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [handles] = Update_numImgsTotal(handles)

        % Get values
        i1 = get(handles.figGUI_panScan1_ImgPumpOff_check, 'Value');
        i2 = get(handles.figGUI_panScan1_ImgPumpOn_check, 'Value');
        i3 = get(handles.figGUI_panScan1_ImgAfter_check, 'Value');

        handles.scanNumImgPumpOff = get(handles.figGUI_panScan1_ImgPumpOff_edit, 'String');
        handles.scanNumImgPumpOn = get(handles.figGUI_panScan1_ImgPumpOn_edit, 'String');
        handles.scanNumImgAfter = get(handles.figGUI_panScan1_ImgAfter_edit, 'String');

        handles.numGrandLoops = get(handles.figGUI_panScan5_numGrandLoops, 'String');
        handles.numSetPerScan = get(handles.figGUI_panScan5_numImgPerPoint, 'String');

        % Calculate total number of images
        n = i1*str2num(handles.scanNumImgPumpOff) + i2*str2num(handles.scanNumImgPumpOn) + i3*str2num(handles.scanNumImgAfter);
        n = n * str2num(handles.numGrandLoops) * str2num(handles.numSetPerScan);

        if(get(handles.figGUI_panScan2_transl_check, 'Value') > 0)
            n = n*str2num(handles.numSamplePoints);
        end
        if(get(handles.figGUI_panScan3_time_check, 'Value') > 0)
            n = n*str2num(handles.numTimePoints);
        end
        if(get(handles.figGUI_panScan4_rot_check, 'Value') > 0)
            n = n*str2num(handles.numRotPoints);
        end
        handles.numImgsTotal = num2str(n);

        % Update total number of images
        set(handles.figGUI_panScan5_numImgsTotal, 'String', handles.numImgsTotal);

    end


end


