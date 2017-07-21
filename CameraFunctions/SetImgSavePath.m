% Set save folder path for acquired image
%
% handles.camImgSaveFolderPath: string for save folder path
function [successFlag] = SetImgSavePath(handles)

    % Command settings
    numParam = numel(handles.camImgSaveFolderPath) + 1;
    for(i = 1:(numParam - 1))
        paramStruct.(sprintf('param%d', i)) = uint8(handles.camImgSaveFolderPath(i));
    end
    paramStruct.(sprintf('param%d', numParam)) = uint8(char(0)); % null-termination character
    
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SetImgSavePath, numParam, paramStruct);

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
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SetImgSavePath))
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
