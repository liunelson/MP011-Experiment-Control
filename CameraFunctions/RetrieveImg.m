% Retrieve image from server
function [successFlag, packetImg] = RetrieveImg(handles)

    % Command settings
    numParam = 1;
    paramStruct.param1 = uint16(handles.camBuffNum);
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.RetrieveImg, numParam, paramStruct);

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
    
    % Read returned image packet
    [packetImg, imgType] = ParseImgPacket(packetRet);
    
    successFlag = 0;
    if(any(imgType == [0:5]) == 1)
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
