% Set camera cooler state
% handles.camCoolerState: string describing state of camera cooler, 'On' or 'Off'
function [successFlag] = SetCoolerState(handles)
    
    % Command settings
    numParam = 1;
    if(strcmp(handles.camCoolerState, 'Off') == 1)
        paramStruct.param1 = uint8(0);
    elseif(strcmp(handles.camCoolerState, 'On') == 1)
        paramStruct.param1 = uint8(1);
    end
    
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SetCoolerState, numParam, paramStruct);
    
    % Send command packet to camera server
    fwrite(handles.camObj, packetCmd, 'uint8');
    
    % Receive acknowledge packet
    [packetAck] = ReceiveCamServer(handles, handles.packLenAck);
    
    % Read returned acknowledge packet
    acceptFlag = ParseAcknowPacket(packetAck);
    if(acceptFlag > 0)
        %fprintf(1, 'Command acknowledged!\n');
    end
    
    % Receive data packet
    [packetRet] = ReceiveCamServer(handles, -1);

    % Read returned data packet
    [data, dataType] = ParseDataPacket(packetRet);
    
    successFlag = 0;
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SetCoolerState))
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
