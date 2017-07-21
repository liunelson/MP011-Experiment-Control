
% Build panel for camera control
function BuildCameraPanel()
    
    % Load handles from base workspace
    handles = evalin('base','handles');

    % Panel 2
    handles.figGUI_panCamera = uipanel(...
        'Title', 'CCD Camera', ...         
        'FontSize',12, ...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...  
        'BorderType', 'line', ...
        'BorderWidth', 1, ...
        'HighlightColor', [0.5 0.5 0.5], ...
        'Units', 'pixels', ...
        'Position',[410-2 480 400 230]...
        );
    % 'Position',[210 480 400 230]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Text (Acquisition Mode)
    handles.figGUI_panCamera_AcqMode_txt = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'FontName', handles.gui_textFontName, ...       
        'String', 'Acquisition Mode:', ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...        
        'Units', 'pixels', ...
        'Position', [10 190 120 15], ...
        'HorizontalAlignment', 'left'...
        );
    
    % Pop-up menu for camera acquisition mode
    handles.figGUI_panCamera_AcqMode = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'popup', ...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'String', handles.camera_acqTypeList, ...
        'Position', [10 175 110 15], ...
        'HorizontalAlignment', 'center', ...
        'Callback', {@CallbackFunc_Camera, 'acquisition mode'}...    
        );

    % Text (Region of Interest)
    handles.figGUI_panCamera_ROI_txt = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'FontName', handles.gui_textFontName, ...        
        'String', 'Region of Interest:', ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'Units', 'pixels', ...
        'Position', [10 140 120 16], ...
        'HorizontalAlignment', 'left'...
        );
    
    % Pop-up menu for camera region of interest
    handles.figGUI_panCamera_ROI = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'popup', ...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'String', handles.camera_ROIList, ...
        'Position', [110 145 70 15], ...
        'HorizontalAlignment', 'center', ...
        'Callback', {@CallbackFunc_Camera, 'ROI'}...    
        );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Checkbox for auto-save image path, filename, and format
    handles.figGUI_panCamera_autoSave_check = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'checkbox', ...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'String', 'Auto-save images as:', ...
        'Position', [10 110 140 15], ...
        'Callback', {@CallbackFunc_Camera, 'auto-save check'}...
        );

    % Edit text box for camera auto-save path
    handles.figGUI_panCamera_autoSave_path = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'edit', ...
        'FontName', 'consolas', ...
        'String', handles.cameraAutoSave_path, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'Units', 'pixels', ...
        'Position', [10 92 188 15], ...
        'HorizontalAlignment', 'left', ...
        'Callback', {@CallbackFunc_Camera, 'auto-save path'}...
        );
    
    handles.figGUI_panCamera_autoSave_txt1 = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'FontName', 'consolas', ...
        'String', '\', ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'Units', 'pixels', ...
        'Position', [198 91 10 15], ...
        'HorizontalAlignment', 'left'...
        );
    
    handles.figGUI_panCamera_autoSave_filename = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'edit', ...
        'FontName', 'consolas', ...        
        'String', handles.cameraAutoSave_filename, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'Units', 'pixels', ...
        'Position', [205 92 82 15], ...
        'HorizontalAlignment', 'center', ...
        'Callback', {@UpdateEditValue, 'cameraAutoSave_filename'}...
        );
    
    handles.figGUI_panCamera_autoSave_txt2 = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'FontName', 'consolas', ...       
        'String', '.', ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...        
        'Units', 'pixels', ...
        'Position', [288 92 5 15], ...
        'HorizontalAlignment', 'left'...
        );

    % Pop-up menu for camera auto-save file format
    handles.figGUI_panCamera_autoSave_format = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'popup', ...
        'FontName', 'consolas', ...        
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'String', handles.camera_formatList, ...
        'Position', [295 95 102 15], ...
        'Callback', {@UpdateEditValue, 'cameraAutoSave_format'}...
        );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Text (Acquisition Type)
    handles.figGUI_panCamera_AcqType_txt = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'FontName', handles.gui_textFontName, ...
        'String', 'Acquisition Type:', ...
        'Units', 'pixels', ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...        
        'Position', [210 190 100 15], ...
        'HorizontalAlignment', 'left'...
        );
    
    % Pop-up menu for camera acquisition type
    handles.figGUI_panCamera_AcqType = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'popup', ...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'String', handles.camera_acqModeList, ...
        'Position', [210 175 110 15], ...
        'HorizontalAlignment', 'center', ...
        'Callback', {@CallbackFunc_Camera, 'acquisition type'}...
        );

    % Text box for camera exposure time
    handles.figGUI_panCamera_ExposureTime_txt1 = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'FontName', handles.gui_textFontName, ...
        'String', 'Exposure Time:', ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...        
        'Units', 'pixels', ...
        'Position', [210 140 95 15], ...
        'HorizontalAlignment', 'left'...
        );
    
    handles.figGUI_panCamera_ExposureTime = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'edit', ...
        'FontName', 'consolas', ...        
        'String', handles.cameraExposureTime, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'Units', 'pixels', ...
        'Position', [303 140 40 15], ...
        'HorizontalAlignment', 'center', ...
        'Callback', {@CallbackFunc_Camera, 'exposure time'}...
        );
    
    handles.figGUI_panCamera_ExposureTime_txt2 = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...                
        'String', 'ms', ...
        'Units', 'pixels', ...
        'Position', [345 140 20 15], ...
        'HorizontalAlignment', 'left'...
        );


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Text (COM)
    handles.figGUI_panCamera_COMStatus_txtCOM = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'text', ...
        'String', 'COM', ...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...  
        'Units', 'pixels', ...
        'Position', [10 60 30 15], ...
        'HorizontalAlignment', 'left'...
        );

    % Edit text box for stage COM status
    handles.figGUI_panCamera_COMStatus = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'edit',...
        'String', '?',...
        'FontName', handles.gui_textFontName, ...
        'BackgroundColor', 'yellow',...
        'Units', 'pixels',...
        'Position', [17 42 15 15],...
        'HorizontalAlignment', 'center'...
        );

    % Push button to connect camera server
    handles.figGUI_panCamera_buttConn = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'pushbutton', ...
        'FontName', handles.gui_textFontName, ...
        'String', 'Connect', ...
        'Position', [40 35 70 30], ...
        'Callback', {@CallbackFunc_Pressbutton, {'Camera', 'connect camera'}, []}...
        );
% 'Callback', {@CallbackFunc_Camera, 'connect camera'}...

    % Push button to disconnect from camera server
    handles.figGUI_panCamera_buttDiscon = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'pushbutton', ...
        'FontName', handles.gui_textFontName, ...
        'String', 'Disconnect', ...
        'Position', [120 35 70 30], ...
        'Callback', {@CallbackFunc_Pressbutton, {'Camera', 'disconnect camera'}, []}...
        );
% 'Callback', {@CallbackFunc_Camera, 'disconnect camera'}...

    % Edit text box for camera COM status
    handles.figGUI_panCamera_camera_comStatus = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'edit', ...
        'FontName', handles.gui_textFontName, ...
        'String', handles.camera_comStatus, ...
        'BackgroundColor', handles.gui_panelBackgroundColor, ...
        'Units', 'pixels', ...
        'Position', [10 10 180 15], ...
        'HorizontalAlignment', 'left'...
        );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Push button to start camera image acquisition
    handles.figGUI_panCamera_buttAcq = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'pushbutton', ...
        'FontName', handles.gui_textFontName, ...
        'String', 'Acquire', ...
        'Position', [210+30 35 70 30], ...
        'Callback', {@CallbackFunc_Camera, 'start acquisition'}...
        );

    % Push button to abort camera image acquisition
    handles.figGUI_panCamera_buttAbort = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'pushbutton', ...
        'FontName', handles.gui_textFontName, ...
        'String', 'Abort', ...
        'Position', [290+30 35 70 30], ...
        'Callback', {@CallbackFunc_Camera, 'abort acquisition'}...
        );

    % Edit text box for camera COM status
    handles.figGUI_panCamera_camera_acqStatus = uicontrol(...
        'Parent', handles.figGUI_panCamera, ...
        'Style', 'edit', ...
        'FontName', handles.gui_textFontName, ...
        'String', handles.camera_acqStatus, ...
        'Units', 'pixels', ...
        'Position', [210 10 180 15], ...
        'HorizontalAlignment', 'left'...
        );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Initialize GUI

    % Permanently disable status edit boxes
    set(handles.figGUI_panCamera_camera_comStatus, 'Enable', 'off');
    set(handles.figGUI_panCamera_camera_acqStatus, 'Enable', 'off');

    % Enable/disable buttons
    set(handles.figGUI_panCamera_buttConn, 'Enable', 'on');
    set(handles.figGUI_panCamera_buttDiscon, 'Enable', 'off');
    set(handles.figGUI_panCamera_camera_comStatus, 'Enable', 'off');
    set(handles.figGUI_panCamera_buttAcq, 'Enable', 'off');
    set(handles.figGUI_panCamera_buttAbort, 'Enable', 'off');
    set(handles.figGUI_panCamera_camera_acqStatus, 'Enable', 'off');

    set(handles.figGUI_panCamera_AcqMode, 'Enable', 'off');
    set(handles.figGUI_panCamera_AcqType, 'Enable', 'off');
    set(handles.figGUI_panCamera_ROI, 'Enable', 'off');
    set(handles.figGUI_panCamera_ExposureTime, 'Enable', 'off');   

    % Save handles in base workspace
    assignin('base','handles',handles)

end





