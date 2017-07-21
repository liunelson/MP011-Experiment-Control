% Set save folder path for acquired image
% 
% handles.camBuffNum: buffer number
% handles.camAcqImgSaveFormat
% handles.camImgSaveName: string for save filename
function [successFlag] = SaveImgOnServer(handles)

    % Command settings
    numParam = 2 + numel(handles.camImgSaveName) + 1;
    paramStruct.param1 = uint16(handles.camBuffNum);

    if(strcmp(handles.camAcqImgSaveFormat, 'U16 FITS') == 1)
        paramStruct.param2 = uint16(0);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I16 FITS') == 1)
        paramStruct.param2 = uint16(1);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I32 FITS') == 1)
        paramStruct.param2 = uint16(2);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'SGL FITS') == 1)
        paramStruct.param2 = uint16(3);        
    elseif(strcmp(handles.camAcqImgSaveFormat, 'U16 TIFF') == 1)
        paramStruct.param2 = uint16(4);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I16 TIFF') == 1)
        paramStruct.param2 = uint16(5);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'I32 TIFF') == 1)
        paramStruct.param2 = uint16(6);
    elseif(strcmp(handles.camAcqImgSaveFormat, 'SGL TIFF') == 1)
        paramStruct.param2 = uint16(7);
    end


    for(i = 3:(numParam - 1))
        paramStruct.(sprintf('param%d', i)) = uint8(handles.camImgSaveName(i-2));
    end
    paramStruct.(sprintf('param%d', numParam)) = uint8(char(0)); % null-termination character
    
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.SaveImgOnServer, numParam, paramStruct);

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
    if((dataType == handles.dataType.CommandDone) && (data.param1 == handles.funcID.SaveImgOnServer))
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
