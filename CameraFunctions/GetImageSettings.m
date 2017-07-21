% Get camera image settings
%
% data.param1: exposure time (ms)
% data.param2: number of readout modes defined for the camera
% data.param3: readout mode
% data.param4: camera average-image-acquisition number
% data.param5: number of frames to acquire
% data.param6: camera acquisition mode
% data.param7: camera acquisition type
% data.param8: CCD format serial origin
% data.param9: CCD format serial length
% data.param10: CCD format serial binning
% data.param11: CCD format parallel origin
% data.param12: CCD format parallel length
% data.param13: CCD format parallel binning
function [successFlag, data] = GetImageSettings(handles)

    % Command settings
    numParam = 0;
    paramStruct = [];
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.GetImgSettings, numParam, paramStruct);

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
    if(dataType == handles.dataType.ImgSettings)
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
