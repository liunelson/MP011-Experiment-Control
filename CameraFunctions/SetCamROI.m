% Set camera format parameters (region of interest)
%
% handles.camROI: camera region of interest ('Small', 'Medium', 'Large', 'Full', 'Custom')
function [successFlag] = SetCamROI(handles)

    % Command settings
    numParam = 6;
    if(strcmp(handles.camROI, 'Small') == 1)

        paramStruct.param1 = int32(950);
        paramStruct.param2 = int32(124);
        paramStruct.param3 = int32(1);
        paramStruct.param4 = int32(650);
        paramStruct.param5 = int32(200);
        paramStruct.param6 = int32(1);

    elseif(strcmp(handles.camROI, 'Medium') == 1)

        paramStruct.param1 = int32(750);
        paramStruct.param2 = int32(324);
        paramStruct.param3 = int32(1);
        paramStruct.param4 = int32(425);
        paramStruct.param5 = int32(600);
        paramStruct.param6 = int32(1);

    elseif(strcmp(handles.camROI, 'Large') == 1)

        paramStruct.param1 = int32(500);
        paramStruct.param2 = int32(574);
        paramStruct.param3 = int32(1);
        paramStruct.param4 = int32(200);
        paramStruct.param5 = int32(1000);
        paramStruct.param6 = int32(1);

    elseif(strcmp(handles.camROI, 'Full') == 1)

        paramStruct.param1 = int32(50);
        paramStruct.param2 = int32(1024);
        paramStruct.param3 = int32(1);
        paramStruct.param4 = int32(0);
        paramStruct.param5 = int32(2048);
        paramStruct.param6 = int32(1);

    elseif(strcmp(handles.camROI, 'Custom') == 1)
        
        paramStruct.param1 = int32(handles.cameraROI_custom.serialOri);
        paramStruct.param2 = int32(handles.cameraROI_custom.serialLen);
        paramStruct.param3 = int32(handles.cameraROI_custom.serialBin);
        paramStruct.param4 = int32(handles.cameraROI_custom.paraOri);
        paramStruct.param5 = int32(handles.cameraROI_custom.paraLen);
        paramStruct.param6 = int32(handles.cameraROI_custom.paraBin);

    end

    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SetCamROI, numParam, paramStruct);

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
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SetCamROI))
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
