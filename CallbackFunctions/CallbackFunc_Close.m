

% Callback function for all GUI close requests
function CallbackFunc_Close(hObject, event, funcName)

    % Load handles from base workspace
    try
        handles = evalin('base','handles');
        
        % Stop timer
        global whostopped
        
        switch(funcName)
            
            % For main GUI figure
            case('main GUI')
                
                if(1)
                    choice = questdlg('Close application?', 'GUI Closure', ...
                        'Confirm', 'Cancel', 'Confirm');
                end
                
                switch choice
                    case 'Cancel'
                        
                        
                    case 'Confirm'
                        
                        if(strcmp(get(handles.timer_obj,'Running'), 'on') > 0)
                            timer_status = 'on';
                            whostopped = '';
                            
                            stop(handles.timer_obj);
                        else
                            timer_status = 'off';
                        end
                        
                        % Disconnect oscilloscope
                        if(~isempty(handles.deviceOscilloscope) & strcmp(handles.deviceOscilloscope.Status, 'open'))

                            try
                                disconnect(handles.deviceOscilloscope);
                                handles.com_devState_oscilloscope = 0;
                            catch ME
                                disp(ME);
                            end
                        end

                        % Close and delete interface/device objects
                        if(~isempty(handles.interfaceOscilloscope))
                            fclose(handles.interfaceOscilloscope);
                            delete(handles.deviceOscilloscope);
                            delete(handles.interfaceOscilloscope);
                        end
                        
                        % Stop all timers
                        stop(timerfindall);
                        
                        % Delete all timers
                        delete(timerfindall);
                        
                        % Close database
                        mksqlite(0, 'close')
                        
                        % Delete figure figure
                        delete(handles.figGUI);
                        
                        evalin('base','clear handles')
                end
                
                
                % Camera custom ROI figure
            case('camera custom ROI')
                
                if(strcmp(get(handles.timer_obj,'Running'), 'on') > 0)
                    timer_status = 'on';
                    whostopped = '';
                    
                    stop(handles.timer_obj);
                else
                    timer_status = 'off';
                end
                
                
                % Send command to server
                CallbackFunc_Camera([], [], 'custom ROI');
                
                % Delete figure
                delete(hObject);
                
                % Restart timer
                if(strcmp(timer_status, 'on') > 0)
                    start(handles.timer_obj);
                end
                
                % For all other figures (e.g. com settings)
                
            case('oscilloscope')
                
                if(strcmp(get(handles.timer_obj,'Running'), 'on') > 0)
                    timer_status = 'on';
                    whostopped = '';
                    
                    stop(handles.timer_obj);
                else
                    timer_status = 'off';
                end
               
                handles.oscilloscope.active_measurement = [];
                handles.oscilloscope.active_source = [];
                
                assignin('base','handles',handles)
                
                % Delete figure
                delete(hObject);
                
                % Restart timer
                if(strcmp(timer_status, 'on') > 0)
                    start(handles.timer_obj);
                end
            
            case('oscilloscope com') % For closing of oscilloscope IP window
                
                % Delete figure
                delete(hObject);
                
            case('chiller status')
                
                % Delete figure
                delete(hObject);
                
                
            case('chiller ctrl')
                
                % Delete figure
                delete(hObject);
                
            case('micra status')
                
                % Delete figure
                delete(hObject);
                
                
            otherwise
                
                % Delete figure
                delete(hObject);
                
                % Restart timer
                % 		    if(strcmp(timer_status, 'on') > 0)
                % 		        start(handles.timer_obj);
                % 		    end
                
        end
        
    catch
        
        % Close database
        mksqlite(0, 'close')
        
        % Delete figure figure
        delete(gcf);

    end

end
