% Update handles with editable text box value
function UpdateEditValue(hObject, ~, fieldName)

    % Load handles from workspace
    handles = evalin('base','handles');
    
    style = get(hObject, 'Style');

    switch(style)

        case('edit')

            % Update field
            % Check if field is cell array
            
            handles = evalin('base','handles');
            if(numel(strfind(fieldName, '{')) < 1)

                % Set value
            	handles = setfield(handles, fieldName, get(hObject, 'String'));

                fprintf(1, '%s (%s) = %s\n', fieldName, style, handles.(fieldName));
                
                if(strcmp(fieldName,'scanNum') == 1)
                    temppath = get(handles.figGUI_panCamera_autoSave_path,'String');
                    backslash_pos = regexp(temppath,'\');
                    last_backslash = backslash_pos(end);
                    foldernumindex = regexp(temppath(backslash_pos(end)+1:end),'[0-9]');
                    temppath = sprintf('%s%s',temppath(1:last_backslash+foldernumindex(1)-1),handles.(fieldName));
                    
                    set(handles.figGUI_panCamera_autoSave_path,'String',temppath);
                end

            else

            	% Parse out cell index
            	i = strfind(fieldName, '{');
            	j = strfind(fieldName, '}');
            	fieldName0 = fieldName(1:(i-1));
            	n = str2num(fieldName((i+1):(j-1)));

                % Set value
            	handles.(fieldName0){n} = get(hObject, 'String');

                fprintf(1, '%s (%s) = %s\n', fieldName, style, handles.(fieldName0){n});
                assignin('base','handles',handles)
                handles = evalin('base','handles');
            end

        case('popupmenu')

            % Get pop-up menu value
            str = get(hObject, 'String');
            val = get(hObject, 'Value');
            s = str{val};
            handles = evalin('base','handles');
            if(numel(strfind(fieldName, '{')) < 1)

                % Set value
                handles = setfield(handles, fieldName, s);

                fprintf(1, '%s (%s) = %s\n', fieldName, style, handles.(fieldName));

            else

                % Parse out array index
                i = strfind(fieldName, '{');
                j = strfind(fieldName, '}');
                fieldName0 = fieldName(1:(i-1));
                n = str2num(fieldName((i+1):(j-1)));

                % Set value
                handles.(fieldName0){n} = s;

                fprintf(1, '%s (%s) = %s\n', fieldName, style, handles.(fieldName0){n});
            end

    end
    
%     % Restart timer
%     if(strcmp(handles.timer_status, 'on') > 0)
%         start(handles.timer_obj);
%         disp('Timer restarted')
%     end

	% Save handles in base workspace
    assignin('base','handles',handles)
    
end
