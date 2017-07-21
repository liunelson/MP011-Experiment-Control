
% Callback function for camera control
function CallbackFunc_Camera(hObject, event, funcName)

    % Load handles from base workspace
    handles = evalin('base','handles');

    switch(funcName)

        case('connect camera')

            % Change status
            handles.camera_comStatus = 'Connecting to server...';
            set(handles.figGUI_panCamera_camera_comStatus, 'String', handles.camera_comStatus);

            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disable camera COM sub-menu
            set(handles.figGUI_menuCamera_menuCOM, 'Enable', 'off');

            % Disable connect button
            set(handles.figGUI_panCamera_buttConn, 'Enable', 'off');

            % Connect to server
            
            err = [];
            serverCmd = 'open_TCPIP';
            [handles.camera_serverObj, err] = OpenServerConnection(serverCmd, handles.camera_serverIP, handles.camera_serverPort);

            % Interface variable
            handles.camera.camObj = handles.camera_serverObj;

            if(numel(err) < 1)

                % Update device state
                handles.com_devState_camera = 1;

                % Change status
                handles.camera_comStatus = 'Connected to server!';
                set(handles.figGUI_panCamera_camera_comStatus, 'String', handles.camera_comStatus);
                set(handles.figGUI_panCamera_camera_comStatus, 'Enable', 'on');
                set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
                set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

                handles.camera_acqStatus = 'Initializing camera...';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

                % Send initial parameters to camera

                % Change status
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', 'Camera ready!');
                set(handles.figGUI_panCamera_camera_acqStatus, 'Enable', 'on');  

                % Change buttons
                set(handles.figGUI_panCamera_buttConn, 'Enable', 'off');
                set(handles.figGUI_panCamera_buttDiscon, 'Enable', 'on');
                set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');    

                set(handles.figGUI_panCamera_AcqMode, 'Enable', 'on');
                set(handles.figGUI_panCamera_AcqType, 'Enable', 'on');
                set(handles.figGUI_panCamera_ROI, 'Enable', 'on');
                set(handles.figGUI_panCamera_ExposureTime, 'Enable', 'on');
                set(handles.figGUI_panCamera_ExposureTime, 'Enable', 'on');

                % Enable menu items
                set(handles.figGUI_menuCamera_menuStatus, 'Enable', 'on');
                set(handles.figGUI_menuCamera_menuImgSettings, 'Enable', 'on');
                set(handles.figGUI_menuCamera_menuConfig, 'Enable', 'on');
                set(handles.figGUI_menuCamera_electronint, 'Enable', 'on');

            else

                % Re-enable camera COM sub-menu
                set(handles.figGUI_menuCamera_menuCOM, 'Enable', 'on');
                set(handles.figGUI_panCamera_buttConn, 'Enable', 'on');
                set(handles.figGUI_panCamera_COMStatus, 'String', 'X');
                set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'red');
            end

        case('disconnect camera')

            % Change status
            handles.camera_comStatus = 'Disconnecting from server...';
            set(handles.figGUI_panCamera_camera_comStatus, 'String', handles.camera_comStatus);

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disconnect from server
            serverCmd = 'close_TCPIP';
            CloseServerConnection(handles.camera_serverObj, serverCmd);

            % Update device state
            handles.com_devState_camera = 0;

            % Change status
            handles.camera_acqStatus = 'Camera disconnected!';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
            set(handles.figGUI_panCamera_camera_acqStatus, 'Enable', 'off');

            handles.camera_comStatus = 'Disconnected from server!';
            set(handles.figGUI_panCamera_camera_comStatus, 'String', handles.camera_comStatus);
            set(handles.figGUI_panCamera_camera_comStatus, 'Enable', 'off');

            set(handles.figGUI_panCamera_COMStatus, 'String', 'X');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'red');

            % Change buttons
            set(handles.figGUI_panCamera_buttConn, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttDiscon, 'Enable', 'off');
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
            set(handles.figGUI_panCamera_buttAbort, 'Enable', 'off');

            set(handles.figGUI_panCamera_AcqMode, 'Enable', 'off');
            set(handles.figGUI_panCamera_AcqType, 'Enable', 'off');
            set(handles.figGUI_panCamera_ROI, 'Enable', 'off');
            set(handles.figGUI_panCamera_ExposureTime, 'Enable', 'off');
            set(handles.figGUI_panCamera_ExposureTime, 'Enable', 'off');

            % Enable/disable camera COM sub-menu
            set(handles.figGUI_menuCamera_menuCOM, 'Enable', 'on');  
            set(handles.figGUI_menuCamera_menuStatus, 'Enable', 'off');
            set(handles.figGUI_menuCamera_menuImgSettings, 'Enable', 'off');
            set(handles.figGUI_menuCamera_menuConfig, 'Enable', 'off');
            set(handles.figGUI_menuCamera_electronint, 'Enable', 'off');

        case('acquisition mode')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disable menu
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
            set(handles.figGUI_panCamera_AcqMode, 'Enable', 'off');

            % Change status
            handles.camera_acqStatus = 'Setting acquisition mode...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
           
            % Update handle value
            UpdateEditValue(hObject, [], 'cameraAcqMode');

            % Get value
            str = get(hObject, 'String');
            val = get(hObject, 'Value');
            handles.cameraAcqMode = str{val};
            
            % Interface variables
            if(strcmp(handles.cameraAcqMode, 'Continuous') < 1)

                handles.camera.camAcqMode = handles.cameraAcqMode;

            else

                % 'Continuous' mode = 'Single Image' mode with consecutive acquisition
                handles.camera.camAcqMode = 'Single Image';
            end

            % Send command to camera
            successFlag = 0;
            [successFlag] = SetAcquisitionMode(handles.camera);

            if(successFlag > 0)

                handles.camera_acqStatus = 'Acquisition mode set successfully!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
            else

                handles.camera_acqStatus = 'Acquisition mode set failed!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 
            end

            % Re-enable menu
            set(handles.figGUI_panCamera_AcqMode, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

        case('acquisition type')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disable menu
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
            set(handles.figGUI_panCamera_AcqType, 'Enable', 'off');

            % Change status
            handles.camera_acqStatus = 'Setting acquisition type...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
           
            % Update handle value
            UpdateEditValue(hObject, [], 'cameraAcqMode');

            % Get value
            str = get(hObject, 'String');
            val = get(hObject, 'Value');
            handles.cameraAcqType = str{val};

            % Interface variables
            handles.camera.camAcqType = handles.cameraAcqType;
            handles.camera.camBuffNum = 1;

            % Send command to camera
            successFlag = 0;
            [successFlag] = SetAcquisitionType(handles.camera);

            if(successFlag > 0)

                handles.camera_acqStatus = 'Acquisition type set successfully!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
            else

                handles.camera_acqStatus = 'Acquisition type set failed!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 
            end

            % Re-enable menu
            set(handles.figGUI_panCamera_AcqType, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

        case('ROI')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disable menu
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
            set(handles.figGUI_panCamera_ROI, 'Enable', 'off');

            % Change status
            handles.camera_acqStatus = 'Setting ROI...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
           
            % Update handle value
            UpdateEditValue(hObject, [], 'cameraROI');

            % Get value
            str = get(hObject, 'String');
            val = get(hObject, 'Value');
            handles.cameraROI = str{val};

            % Get custom ROI parameters from user
            if(strcmp(handles.cameraROI, 'Custom') > 0)

                % Build custom ROI figure
                BuildFigureWindows([], [], 'camera custom ROI');

            else
                % For other ROI settings

                % Interface variables
                handles.camera.camROI = handles.cameraROI;
                handles.camera.cameraROI_custom.serialOri = handles.cameraROI_customSerialOri;
                handles.camera.cameraROI_custom.serialLen = handles.cameraROI_customSerialLen;
                handles.camera.cameraROI_custom.serialBin = handles.cameraROI_customSerialBin;
                handles.camera.cameraROI_custom.paraOri = handles.cameraROI_customParaOri;
                handles.camera.cameraROI_custom.paraLen = handles.cameraROI_customParaLen;
                handles.camera.cameraROI_custom.paraBin = handles.cameraROI_customParaBin;

                % Send command to camera
                successFlag = 0;
                [successFlag] = SetCamROI(handles.camera);

                if(successFlag > 0)

                    handles.camera_acqStatus = 'ROI set successfully!';
                    set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
                else

                    handles.camera_acqStatus = 'ROI set failed!';
                    set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 
                end

            end

            % Re-enable menu
            set(handles.figGUI_panCamera_ROI, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

        case('custom ROI')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disable menu
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
            set(handles.figGUI_panCamera_ROI, 'Enable', 'off');

            % Change status
            handles.camera_acqStatus = 'Setting ROI...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
            
            if(~isempty(hObject)==1)
                % Update handle value
                UpdateEditValue(hObject, [], 'cameraROI');
            end
            

            % Interface variables
            handles.camera.camROI = handles.cameraROI;
            handles.camera.cameraROI_custom.serialOri = str2double(handles.cameraROI_customSerialOri);
            handles.camera.cameraROI_custom.serialLen = str2double(handles.cameraROI_customSerialLen);
            handles.camera.cameraROI_custom.serialBin = str2double(handles.cameraROI_customSerialBin);
            handles.camera.cameraROI_custom.paraOri = str2double(handles.cameraROI_customParaOri);
            handles.camera.cameraROI_custom.paraLen = str2double(handles.cameraROI_customParaLen);
            handles.camera.cameraROI_custom.paraBin = str2double(handles.cameraROI_customParaBin);
            

            % Send command to camera
            successFlag = 0;
            [successFlag] = SetCamROI(handles.camera);
            successFlag = 1;
            fprintf(1, 'cameraROI = %s (%s)\n', handles.cameraROI, handles.cameraROI_customSerialLen);

            if(successFlag > 0)

                handles.camera_acqStatus = 'ROI set successfully!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
            else

                handles.camera_acqStatus = 'ROI set failed!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 
            end

            % Re-enable menu
            set(handles.figGUI_panCamera_ROI, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');


        case('exposure time')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disable box and change status
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
            set(handles.figGUI_panCamera_ExposureTime, 'Enable', 'off');

            % Change status
            handles.camera_acqStatus = 'Setting exposure time...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            % Update handle value
            UpdateEditValue(hObject, [], 'cameraExposureTime');

            % Get Value
            handles.cameraExposureTime = str2num(get(hObject, 'String'));

            % Interface variables
            handles.camera.camExposureTime = handles.cameraExposureTime;

            % Send command to camera
            successFlag = 0;
            [successFlag] = SetExposureTime(handles.camera);

            % Change status
            if(successFlag > 0)

                handles.camera_acqStatus = 'Exposure time set successfully!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
            else

                handles.camera_acqStatus = 'Exposure time set failed!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 
            end

            % Re-enable menu
            set(handles.figGUI_panCamera_ExposureTime, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

        case('auto-save check')

            % Get value
            if(get(hObject,'Value') > 0);

                % Change status
                handles.camera_acqStatus = 'Enabled auto-save';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            elseif(get(hObject,'Value') < 1);

                % Change status
                handles.camera_acqStatus = 'Disabled auto-save';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            end

        case('auto-save path')
        
            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Disable box and change status
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
            set(handles.figGUI_panCamera_autoSave_path, 'Enable', 'off');

            % Change status
            handles.camera_acqStatus = 'Setting auto-save path...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            % Update handle value
            UpdateEditValue(hObject, [], 'cameraAutoSave_path');

            % Get value
            handles.cameraAutoSave_path = get(handles.figGUI_panCamera_autoSave_path, 'String');

            % Interface variables
            handles.camera.camImgSaveFolderPath = handles.cameraAutoSave_path;

            % Send command to camera
            successFlag = 0;
            [successFlag] = SetImgSavePath(handles.camera); 

            if(successFlag > 0)
                handles.camera_acqStatus = 'Auto-save path set successfully!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
            else
                handles.camera_acqStatus = 'Auto-save path set failed!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 
            end

            % Re-enable menu
            set(handles.figGUI_panCamera_autoSave_path, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

        case('start acquisition')
            
            single = 1;
            if(strcmp(handles.cameraAcqMode,'Continuous') == 1)
                set(handles.figGUI_panCamera_buttAbort, 'Enable', 'off');
            end
            
            while(strcmp(handles.cameraAcqMode,'Continuous') == 1 || single <= 1)
                    single = single + 1;
                    str = get(handles.figGUI_panCamera_AcqMode, 'String');
                    val = get(handles.figGUI_panCamera_AcqMode, 'Value');
                    handles.cameraAcqMode = str{val};


                % Get value
                handles.cameraAutoSave_path = get(handles.figGUI_panCamera_autoSave_path, 'String');

                % Interface variables
                handles.camera.camImgSaveFolderPath = handles.cameraAutoSave_path;

                successFlag = 0;
                [successFlag] = SetImgSavePath(handles.camera);

                if(successFlag > 0)
                    handles.camera_acqStatus = 'Auto-save path set successfully!';
                    set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);
                else
                    handles.camera_acqStatus = 'Auto-save path set failed!';
                    set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 
                end


                % Change COM status
                set(handles.figGUI_panCamera_COMStatus, 'String', '!');
                set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

                % Change status
                set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
                handles.camera_acqStatus = 'Starting acquisition...';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);      

                % Get value (auto-save format)
                str = get(handles.figGUI_panCamera_autoSave_format, 'String');
                val = get(handles.figGUI_panCamera_autoSave_format, 'Value');
                handles.cameraAutoSave_format = str{val};

                % Reformat string
                f = handles.cameraAutoSave_format(1:4);
                n = handles.cameraAutoSave_format((end-2):(end-1));
                s = handles.cameraAutoSave_format(7);
                if(strcmp(s, 'f') > 0)
                    s = 'sgl';
                    n = '';
                end
                handles.camera.camAcqImgSaveFormat = upper(sprintf('%s%s %s', s, n, f));

                delayps = (str2double(get(handles.figGUI_panStages_currentPos(4), 'String'))- str2double(get(handles.figGUI_panScan3_Time_timeZero,'String')))/1e-12/299792458*(1e-6)*2;
                ROIVal = get(handles.figGUI_panCamera_ROI,'Value');
                ROIStr = get(handles.figGUI_panCamera_ROI,'String');
                AcqmodVal = get(handles.figGUI_panCamera_AcqMode,'Value');
                AcqmodStr = get(handles.figGUI_panCamera_AcqMode,'String');
                AcqtypVal = get(handles.figGUI_panCamera_AcqType,'Value');
                AcqtypStr = get(handles.figGUI_panCamera_AcqType,'String');
                ImextVal = get(handles.figGUI_panCamera_autoSave_format,'Value');
                ImextStr = get(handles.figGUI_panCamera_autoSave_format,'String');
                Extension = ImextStr{ImextVal};
                Extension = Extension(1:4);
                savingfolder = get(handles.figGUI_panCamera_autoSave_path,'String');
                imageroot = get(handles.figGUI_panCamera_autoSave_filename, 'String');
                foldercontent = dir(get(handles.figGUI_panCamera_autoSave_path,'String'));
                
                if(strcmp(get(handles.figGUI_panScan1_ImgPumpOff_edit_stat, 'Visible'),'on')==1)
                    shutstat = 'Off';
                elseif(strcmp(get(handles.figGUI_panScan1_ImgPumpOn_edit_stat, 'Visible'),'on')==1)
                    shutstat = 'On';
                elseif(strcmp(get(handles.figGUI_panScan1_ImgPumpAfter_edit_stat, 'Visible'),'on')==1)
                    shutstat = 'After';
                else
                    shutstat = '';
                end

                if(numel(foldercontent) == 0)
                    mkdir(get(handles.figGUI_panCamera_autoSave_path,'String'))
                    imagenumber = 1;
                    scanebeam = savingfolder(end-4:end);
                    filename = sprintf('%s_%06.0f_GL-%s_%06.0f_fs_%s_%06.0f_md_', ...
                        scanebeam, ...
                        imagenumber, ...
                        get(handles.figGUI_panScan5_numGrandLoops_curr,'String'), ...
                        round(delayps*1000), ...
                        shutstat, ...
                        str2double(get(handles.figGUI_panStages_currentPos(5), 'String'))*1000 ...
                    );
                    if(strcmp(filename(1),'\')==1)
                        filename(1) = '';
                    end
                    set(handles.figGUI_panCamera_autoSave_filename, 'String', filename);

                elseif(numel(foldercontent) <= 2)

                    imagenumber = 1;
                    scanebeam = savingfolder(end-5:end);
                    filename = sprintf('%s_%06.0f_GL-%s_%06.0f_fs_%s_%06.0f_md_', ...
                        scanebeam, ...
                        imagenumber, ...
                        get(handles.figGUI_panScan5_numGrandLoops_curr,'String'), ...
                        round(delayps*1000), ...
                        shutstat, ...
                        str2double(get(handles.figGUI_panStages_currentPos(5), 'String'))*1000 ...
                    );

                    if(strcmp(filename(1),'\')==1)
                        filename(1) = '';
                    end

                    set(handles.figGUI_panCamera_autoSave_filename, 'String', filename);

                else
                    foldercontentcell = struct2cell(foldercontent);
                    for(m = 3:numel(foldercontent))
                        file = char(foldercontentcell(1,m));
                        scanebeamindex = regexp(file, '[_]');
                        scanebeam = file(1:scanebeamindex(1)-1);
                        try
                            imagenumber = str2double(file(scanebeamindex(1)+1:scanebeamindex(2)-1));
                        catch
                            imagenumber = str2double(file(scanebeamindex(1)+1:end));
                        end
                    end

                    imagenumber = imagenumber + 1;

                    filename = sprintf('%s_%06.0f_GL-%s_%06.0f_fs_%s_%06.0f_md_', ...
                        scanebeam, ...
                        imagenumber, ...
                        get(handles.figGUI_panScan5_numGrandLoops_curr,'String'), ...
                        round(delayps*1000), ...
                        shutstat, ...
                        str2double(get(handles.figGUI_panStages_currentPos(5), 'String'))*1000 ...
                    );

                    if(strcmp(filename(1),'\')==1)
                        filename(1) = '';
                    end

                        set(handles.figGUI_panCamera_autoSave_filename, 'String', filename);

                end

                datab = cell(1,numel(handles.logscan_columnnames)/2);
                datab{1} = sprintf('%s.%s', filename, Extension);
                datab{2} = datestr(now,29);
                datab{3} = datestr(now,13);
                datab{4} = sprintf('%s/%s', get(handles.figGUI_panScan5_numGrandLoops_curr, 'String'), get(handles.figGUI_panScan5_numGrandLoops, 'String'));
                datab{5} = delayps;
                datab{6} = str2double(get(handles.figGUI_panStages_currentPos(1), 'String'));
                datab{7} = str2double(get(handles.figGUI_panStages_currentPos(2), 'String'));
                datab{8} = str2double(get(handles.figGUI_panStages_currentPos(3), 'String'));
                datab{9} = str2double(get(handles.figGUI_panStages_currentPos(5), 'String'));
                datab{10} = str2double(get(handles.figGUI_panCamera_ExposureTime, 'String'));
                datab{11} = shutstat;
                datab{12} = ROIStr{ROIVal};
                datab{13} = AcqmodStr{AcqmodVal};
                datab{14} = AcqtypStr{AcqtypVal};
                datab{15} = get(handles.figGUI_panShutters_COMStatus(1), 'String');
                datab{16} = get(handles.figGUI_panShutters_COMStatus(2), 'String');
                datab{17} = get(handles.figGUI_panShutters_COMStatus(3), 'String');



                % Get value (auto-save filename)
                handles.camera.camAcqImgFilename = get(handles.figGUI_panCamera_autoSave_filename, 'String');

                % Camera acquisition image mode
                handles.camera.camAcqImgMode = 2;  

                % Camera acquisition buffer number
                handles.camera.camAcqImgBufferNum = 1;

                % Send command to camera
                successFlag1 = 0;
                [successFlag1, data] = AcquireImage(handles.camera);

                % Change status
                handles.camera_acqStatus = 'Acquiring image...';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);  

                % Enable abort button
                if(strcmp(handles.cameraAcqMode,'Continuous') ~= 1)
                    set(handles.figGUI_panCamera_buttAbort, 'Enable', 'on');
                end

                if(successFlag1 > 0)

                    % Change status
                    handles.camera_acqStatus = 'Acquisition complete!';
                    set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);                 

                    % Option to save acquired image
                    if(get(handles.figGUI_panCamera_autoSave_check, 'Value') > 0)

                        % Send save command to camera
                        successFlag3 = 0;
                        handles.camera.camBuffNum = 1;
                        handles.camera.camImgSaveName = sprintf('%s.%s', get(handles.figGUI_panCamera_autoSave_filename, 'String'), handles.cameraAutoSave_format(1:4));
                        [successFlag3] = SaveImgOnServer(handles.camera);

                        imagenumber = imagenumber + 1;

                        filename = sprintf('%s_%06.0f_GL-%s_%06.0f_fs_%s_%06.0f_md_', ...
                            scanebeam, ...
                            imagenumber, ...
                            get(handles.figGUI_panScan5_numGrandLoops_curr,'String'), ...
                            delayps*1000, ...
                            shutstat, ...
                            str2double(get(handles.figGUI_panStages_currentPos(5), 'String'))*1000 ...
                        );
                        if(strcmp(filename(1),'\')==1)
                            filename(1) = '';
                        end

                        set(handles.figGUI_panCamera_autoSave_filename, 'String', filename);

                        if(successFlag3 > 0)

                            handles.camera_acqStatus = 'Save successful!';
                            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

                            mksqlite(handles.dbidscan, ['INSERT INTO ' handles.logscan_tablename ' VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'], datab{1,:} );

                        else

                            handles.camera_acqStatus = 'Save failed!';
                            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

                        end

                    end

                else

                    % Change status
                    handles.camera_acqStatus = 'Acquisition failed!';
                    set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

                end
            end

            % Change acquisition buttons
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAbort, 'Enable', 'off');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

        case('abort acquisition')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Change status
            set(handles.figGUI_panCamera_buttAbort, 'Enable', 'off');

            handles.camera_acqStatus = 'Aborting acquisition...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            % Send command to camera
            successFlag = 0;
            [successFlag, data] = TerminateAcquisition(handles.camera);

            % Change status
            handles.camera_acqStatus = 'Acquisition aborted!';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            % Change acquisition buttons
            set(handles.figGUI_panCamera_buttAcq, 'Enable', 'on');
            set(handles.figGUI_panCamera_buttAbort, 'Enable', 'off');

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

        case('get status')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Change status
            handles.camera_acqStatus = 'Getting camera status...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            % Send command to camera
            successFlag = 0;
            data = [];
            [successFlag, data] = GetCamStatus(handles.camera);

            if(successFlag > 0)

                % Change status
                handles.camera_acqStatus = 'Camera ready!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 

                % Parse values
                for(i = 1:3)
                    rowName{i,1} = sprintf('%d', i);
                    descrip{i,1} = handles.camera_statusName{i};
                    currVal{i,1} = sprintf('%f', data.(sprintf('param%d',i)));
                end
                for(i = 4:6)
                    rowName{i,1} = sprintf('%d', i+5);
                    descrip{i,1} = handles.camera_statusName{i};
                    currVal{i,1} = data.(sprintf('param%d',i+5));
                end

                if(logical(currVal{4}) == 0)
                    currVal{4} = 'closed';
                else
                    currVal{4} = 'open';
                end

                if(logical(currVal{5}) == 0)
                    currVal{5} = 'none';
                else
                    currVal{5} = 'occurred';
                end

                if(logical(currVal{6}) == 0)
                    currVal{6} = 'off';
                else
                    currVal{6} = 'on';
                end

                % Set data in configuration parameter table
                set(hObject, 'RowName', rowName);
                set(hObject, 'Data', [descrip, currVal]);

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

            else
                % Change status
                handles.camera_acqStatus = 'Failed to get camera status!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);            
            end
      
            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case('get image settings')

            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Change status
            handles.camera_acqStatus = 'Getting image settings...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            % Send command to camera
            successFlag = 0;
            data = [];
            [successFlag, data] = GetImageSettings(handles.camera);

            if(successFlag > 0)

                % Change status
                handles.camera_acqStatus = 'Camera ready!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 

                % Parse values
                for(i = 1:13)
                    rowName{i, 1} = sprintf('%d', i);
                    descrip{i, 1} = handles.camera_imgSettingsName{i};
                    currVal{i, 1} = data.(sprintf('param%d',i));
                end

                % Readout mode
                currVal{3, 1} = handles.camera_readoutModeList{currVal{3, 1}+1};

                % Acquisition mode
                currVal{6, 1} = handles.camera_acqModeList{currVal{6, 1}+1};

                % Acquisition type
                currVal{7, 1} = handles.camera_acqTypeList{currVal{7, 1}+1};

                % Set data in configuration parameter table
                set(hObject, 'RowName', rowName);
                set(hObject, 'Data', [descrip, currVal]);

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

            else
                % Change status
                handles.camera_acqStatus = 'Failed to get image settings!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);            
            end
      
            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case('get config')


            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', '!');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'yellow');

            % Change status
            handles.camera_acqStatus = 'Getting image settings...';
            set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);

            % Send command to camera
            successFlag = 0;
            data = [];
            [successFlag, data] = GetCamParam(handles.camera);

            if(successFlag > 0)

                % Change status
                handles.camera_acqStatus = 'Camera ready!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus); 

                % Parse values
                j = 1;
                for(i = [1:14,17,21,24,33:48,50,52,53,64])
                    rowName{j, 1} = sprintf('%d', i);
                    descrip{j, 1} = handles.camera_configName{j};
                    currVal{j, 1} = data.(sprintf('param%d',i));
                    j = j + 1;
                end

                list_ContinuousClear = {'enabled', 'disabled for one cycle', 'disabled'};
                currVal{10, 1} = list_ContinuousClear{currVal{10, 1}+1};

                list_CommandOnTrigger = {'open shutter', 'close shutter', 'test image', 'light exposure', 'dark exposure', 'TDI exposure'};
                currVal{17, 1} = list_CommandOnTrigger{currVal{17, 1}+1};

                list_Phasing = {'normal', 'reversed'};
                currVal{21, 1} = list_Phasing{currVal{21, 1}+1};
                currVal{24, 1} = list_Phasing{currVal{24, 1}+1};

                list_Split = {'normal', 'split'};
                currVal{22, 1} = list_Split{currVal{22, 1}+1};
                currVal{25, 1} = list_Split{currVal{25, 1}+1};

                list_NumberOfPort = {'1 port', '2 ports'};
                currVal{28, 1} = list_NumberOfPort{currVal{28, 1}+1};

                list_PortSelect = {'A', 'B', 'AB'};
                currVal{34, 1} = list_PortSelect{currVal{34, 1}+1};


                % Set data in configuration parameter table
                set(hObject, 'RowName', rowName);
                set(hObject, 'Data', [descrip, currVal]);

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

            else
                % Change status
                handles.camera_acqStatus = 'Failed to get image settings!';
                set(handles.figGUI_panCamera_camera_acqStatus, 'String', handles.camera_acqStatus);            
            end
      
            % Change COM status
            set(handles.figGUI_panCamera_COMStatus, 'String', 'O');
            set(handles.figGUI_panCamera_COMStatus, 'BackgroundColor', 'green');

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    try
        % Restart timer
        if(strcmp(handles.timer_status, 'on') > 0 && handles.scanrunning == 0)
            start(handles.timer_obj);
            disp('Timer restarted')
        end
    catch
    end

	% Save handles in base workspace
    assignin('base','handles',handles)

end
