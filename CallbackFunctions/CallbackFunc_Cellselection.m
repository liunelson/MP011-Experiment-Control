

% Callback function for time stage control
function CallbackFunc_Cellselection(hObject, eventdata, ~)

    confpanel = get(hObject,'Tag');

    switch confpanel

        case 'HVparam'


        case 'Chillerparam'

            try
                    data = get(hObject,'Data');
                    row = eventdata.Indices(1);
                    column = eventdata.Indices(2);

                    switch row
                        case {2, 4, 7, 9, 13, 22}
                            data(row,column) = {logical(str2double(char(data(row,column-1))))};

                    end

                    set(hObject,'Data',data);
            catch
            end

    end
            
end