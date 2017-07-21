% Acquire image
%
% handles.camAcqImgMode: acquire-image mode
%   1 = acquire and transmit to client,
%   2 = acquire and hold in server image buffer
%   3 = acquire, transmit to client, and save to server's disk
%   4 = acquire, save to server's disk, and hold in server image buffer
% handles.camAcqImgBufferNum: buffer number for acquisition
% handles.camAcqImgSaveFormat: image file format
% handles.camAcqImgFilename = string for image filename
function [successFlag, data] = AcquireImage(handles)
    % Command settings
    numParam = 3 + numel(handles.camAcqImgFilename) + 1;
    paramStruct.param1 = uint16(handles.camAcqImgMode);
    paramStruct.param2 = uint16(handles.camAcqImgBufferNum);
    
    if(strcmp(handles.camAcqImgSaveFormat, 'U16 FITS') == 1)
        paramStruct.param3 = uint16(0);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I16 FITS') == 1)
        paramStruct.param3 = uint16(1);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I32 FITS') == 1)
        paramStruct.param3 = uint16(2);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'SGL FITS') == 1)
        paramStruct.param3 = uint16(3);        
    elseif(strcmp(handles.camAcqImgSaveFormat, 'U16 TIFF') == 1)
        paramStruct.param3 = uint16(4);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I16 TIFF') == 1)
        paramStruct.param3 = uint16(5);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I32 TIFF') == 1)
        paramStruct.param3 = uint16(6);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'SGL TIFF') == 1)
        paramStruct.param3 = uint16(7);
    end

    for(i = 4:(numParam - 1))
        %paramStruct.(sprintf('param%d', i)) = uint8(handles.camImgSavePath(i-3));
        paramStruct.(sprintf('param%d', i)) = uint8(handles.camAcqImgFilename(i-3));
    end
    paramStruct.(sprintf('param%d', numParam)) = uint8(char(0)); % null-termination character    

    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.AcquireImg, numParam, paramStruct);

    % Send command packet to camera server
    fwrite(handles.camObj, packetCmd, 'uint8');

    
    % Receive acknowledge packet
    [packetAck] = ReceiveCamServer(handles, handles.packLenAck);
    
    % Read returned acknowledge packet
    acceptFlag = ParseAcknowPacket(packetAck);
    if(acceptFlag > 0)
        %fprintf(1, 'Command acknowledged!\n');
    end

    % Receive packet
    if((handles.camAcqImgMode == 2) || (handles.camAcqImgMode == 4))
        
        % Receive data packet
        [packetRet] = ReceiveCamServer(handles, 16);

        % Read returned data packet
        [data, dataType] = ParseDataPacket(packetRet);

        successFlag = 0;
        if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.AcquireImg))
            successFlag = 1;
            %fprintf(1, 'Command successful!\n');
        end
    elseif((handles.camAcqImgMode == 1) || (handles.camAcqImgMode == 3))
        
        handles.camObj.BytesAvailable
        
        % Receive image packet
        [packetRet] = ReceiveCamServer(handles, -1);

        % Read returned image packet
        [data, dataType] = ParseImgPacket(packetRet);
        data = packetRet;
        successFlag = 0;
        if(any(dataType == [0,1,2,3,4,5]) == 1)
            successFlag = 1;
            %fprintf(1, 'Command successful!\n');
        end
    end

    
end
