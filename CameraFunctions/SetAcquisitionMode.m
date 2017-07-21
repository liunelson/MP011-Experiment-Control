% Set camera acquisition mode
%
% handles.camAcqMode: string describing acquisition type ('Single Image', 'Average', 'Multiple Images', 'Multiple Frames', 'Focus')
function [successFlag] = SetAcquisitionMode(handles)

    % Command settings
    numParam = 1;
    if(strcmp(handles.camAcqMode, 'Single Image') == 1)
        paramStruct.param1 = uint8(0);
    elseif(strcmp(handles.camAcqMode, 'Average') == 1)
        paramStruct.param1 = uint8(1);
    elseif(strcmp(handles.camAcqMode, 'Multiple Images') == 1)
        paramStruct.param1 = uint8(2);
    elseif(strcmp(handles.camAcqMode, 'Multiple Frames') == 1)
        paramStruct.param1 = uint8(3);
    elseif(strcmp(handles.camAcqMode, 'Focus') == 1)
        paramStruct.param1 = uint8(4);
    end
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SetAcqMode, numParam, paramStruct);

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
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SetAcqMode))
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
