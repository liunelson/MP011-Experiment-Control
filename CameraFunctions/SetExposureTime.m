% Set exposure time for subsequent acquisitions
%
% handles.camExposureTime: camera exposure time in miliseconds
function [successFlag] = SetExposureTime(handles)
    
    % Command settings
    numParam = 1;
    paramStruct.param1 = uint32(handles.camExposureTime);
    
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SetExposureTime, numParam, paramStruct);
    
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
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SetExposureTime))
        successFlag = 1;
    end
end
