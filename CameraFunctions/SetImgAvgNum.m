% Set exposure time for subsequent acquisitions
%
% handles.camImgAvgNum: number for average-image acquisition
function [successFlag] = SetImgAvgNum(handles)
    
    % Command settings
    numParam = 1;
    paramStruct.param1 = uint16(handles.camImgAvgNum);
    
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SetImgAvgNum, numParam, paramStruct);
    
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
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SetImgAvgNum))
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
