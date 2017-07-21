% Set camera acquisition type
%
% handles.camBuffNum: buffer number (buffer where the image is stored), 1 or 2
% handles.camAcqType: string describing acquisition type
function [successFlag] = SetAcquisitionType(handles)

    % Command settings
    numParam = 2;
    paramStruct.param1 = uint16(handles.camBuffNum);
    if(strcmp(handles.camAcqType, 'Light Exposure') == 1)
        paramStruct.param2 = uint8(0);
    elseif(strcmp(handles.camAcqType, 'Dark Exposure') == 1)
        paramStruct.param2 = uint8(1);
    elseif(strcmp(handles.camAcqType, 'Test Exposure') == 1)
        paramStruct.param2 = uint8(2);
    elseif(strcmp(handles.camAcqType, 'Triggered Exposure') == 1)
        paramStruct.param2 = uint8(3);
    elseif(strcmp(handles.camAcqType, 'TDI Internal Paced Exposure') == 1)
        paramStruct.param2 = uint8(4);
    elseif(strcmp(handles.camAcqType, 'TDI External Paced Exposure') == 1)
        paramStruct.param2 = uint8(5);
    end
    %fprintf(1, 'param1 = %d \t param2 = %d\n', paramStruct.param1, paramStruct.param2);
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SetAcqType, numParam, paramStruct);

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
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SetAcqType))
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
