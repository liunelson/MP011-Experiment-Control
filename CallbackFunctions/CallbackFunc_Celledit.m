

% Callback function for time stage control
function CallbackFunc_Celledit(hObject, eventdata, funcName)

    handles = evalin('base','handles');
    
    row = eventdata.Indices(1);
    column = eventdata.Indices(2);
    
    switch(funcName)

        case {'stages config 1', 'stages config 2', 'stages config 3'}
            
            i = str2double(funcName(end));

            data = get(hObject,'Data');

            if (~isempty(data(row,column)))
                newdata = char(data(row,column));
                serverAns = [];
                err = [];
                serverCmd = sprintf('sendrcv %s %s%s', handles.stages_comTermChar{i},char(handles.stages_configcommand{1}(row)), newdata);
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                
                serverAns = [];
                err = [];
                serverCmd = sprintf('sendrcv %s %s', handles.stages_comTermChar{i},char(handles.stages_configcommand{1}(row)));
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                
                temp = textscan(serverAns,'%s ','Delimiter','>');
                newdata = regexprep(temp{1},'[^\d.-]','');
                
                pause(0.2)

                data(row,column-1) = newdata;
                data(row,column) = {''};
                
                set(hObject,'Data',data);
            end
            
        case('stages config 4')
            
            i = str2double(funcName(end));

            data = get(hObject,'Data');
            
            if (~isempty(data(row,column)))
                newdata = char(data(row,column));

                rowName = get(hObject,'RowName');
                serverAns = [];
                err = [];
                serverCmd = sprintf('sendrcv %s 1%s%s', handles.stages_comTermChar{i},char(rowName(row)), newdata);
                [handles.shutters_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                
                serverAns = [];
                err = [];
                serverCmd = sprintf('sendrcv %s 1%s%s', handles.stages_comTermChar{i},char(rowName(row)),'?');
                [handles.stages_serverObj{i}, serverAns, err] = SendReceiveSerial(...
                    'send_receive', ...
                    handles.stages_serverObj{i}, ...
                    serverCmd, ...
                    handles.com_waitTime.client_server, ...
                    handles.com_numTry...
                    );
                

                newdata = serverAns(4:end);
                
                pause(0.2)

                data(row,column-1) = {newdata};
                data(row,column) = {''};
                
                set(hObject,'Data',data);
            end      
            
        case('HV config')
            
            pause(1)
            CallbackFunc_Pressbutton(hObject, [], {'HV', 'status'} , [row column])

            
        case('micra config')
            
            data = get(hObject,'Data');
            
            if (~isempty(data(row,column)))
                temp = data(row,column);
                numConfigParam = numel(handles.micra.cmdList)/2;
                serverAns = [];
                err = [];
                
                switch row
                    case {2, 4, 7, 9, 13}
                        newdata = num2str(temp{1});
                        if(row==9)
                            serverCmd = sprintf('sendrcv %s A%s=%s', handles.micra_comTermChar, char(handles.micra.cmdList{numConfigParam+row}(2:end)), newdata);
                        else
                            serverCmd = sprintf('sendrcv %s %s=%s', handles.micra_comTermChar, char(handles.micra.cmdList{numConfigParam+row}(2:end)), newdata);
                        end
                        
                        [handles.micra_serverObj, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.micra_serverObj, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                        serverAns = [];
                        err = [];
                        serverCmd = sprintf('sendrcv %s %s', handles.micra_comTermChar, char(handles.micra.cmdList{numConfigParam+row}));
                        [handles.micra_serverObj, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.micra_serverObj, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                        pause(0.5)
                        
                    case {5, 6}
                        newdata = char(temp);
                        serverCmd = sprintf('sendrcv %s %s=%s', handles.micra_comTermChar, char(handles.micra.cmdList{numConfigParam+row}(2:end)), newdata);
                        
                        [handles.shutters_serverObj, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.micra_serverObj, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                        serverAns = [];
                        err = [];
                        serverCmd = sprintf('sendrcv %s %s', handles.micra_comTermChar, char(handles.micra.cmdList{numConfigParam+row}));
                        [handles.micra_serverObj, serverAns, err] = SendReceiveSerial(...
                            'send_receive', ...
                            handles.micra_serverObj, ...
                            serverCmd, ...
                            handles.com_waitTime.client_server, ...
                            handles.com_numTry...
                            );

                        pause(0.5)
                end
                
                newdata = serverAns;

                data(row,column-1) = newdata;
                data(row,column) = {''};
                
                set(hObject,'Data',data);
            end
            
    end
    
end