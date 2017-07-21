
% MP011 Experiment Control GUI
function [] = MP011_Experiment_Control()

    % Add directories to path
    p = [';', ...
        sprintf('%s/BuildFunctions', pwd), ';', ...
        sprintf('%s/CallbackFunctions', pwd), ';', ...
        sprintf('%s/CameraFunctions', pwd), ';', ...
        sprintf('%s/HelperFunctions', pwd), ';', ...
        sprintf('%s/mksqlite', pwd)...
        ];
    path(path, p);

    % Set initial values of all parameters
    DefineInitializeParameters;

    % Build main GUI figure window
    BuildFigureWindows([], [], 'main GUI');

    % Build menu items of main figure window
    BuildMenuItems;

    % Build panel for high voltage power supply, camera, shutters, stages, scan control
    BuildHVPanel;
    BuildCameraPanel;
    BuildShuttersPanel;
    BuildStagesPanel;
    BuildScanPanel;
    
    % Initialize timer
    % ControlTimer([], [], 'initialize');

end
