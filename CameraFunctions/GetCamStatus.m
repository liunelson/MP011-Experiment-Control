% Get camera status
%
% data.param1: CCD temperature (C)
% data.param2: backplate temperature (C)
% data.param3: CCD chamber pressure (Torr)
% data.param4-8: not used
% data.param9: shutter status (0 = closed, 1 = open)
% data.param10: XIRQA status (0 = none, 1 = occured)
% data.param11: cooler status (0 = off, 1 = on)
% data.param12-16: not used
function [successFlag, data] = GetCamStatus(handles)

    % Command settings
    numParam = 0;
    paramStruct = [];
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.GetCamStatus, numParam, paramStruct);

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
    if(dataType == handles.dataType.Status)
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
