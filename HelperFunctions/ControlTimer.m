
% Start or stop control timer (start, stop)
function [] = ControlTimer(hOject, event, funcName)

    % Load handles from base workspace
    handles = evalin('base','handles');
    
    global whostopped

	switch(funcName)

		case('initialize')

			% Define callback
			set(handles.timer_obj, 'TimerFcn', {@CallbackFunc_Timer});
			
		case('start')

			% Start timer
            handles.timer_status = 'on';
            start(handles.timer_obj);

		case('stop')

			% Stop timer
            handles.timer_status = 'off';
            
            whostopped = '';

			stop(handles.timer_obj);

	end

    % Save handles in base workspace
    assignin('base','handles',handles)
    
end 
