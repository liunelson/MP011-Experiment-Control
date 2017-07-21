% Get image header from camera
%
% handles.funcID.GetImgHeader = 1024;
% handles.camBuffNum: buffer number of buffer from which to get image header
% data.param1: null-terminated FITS file header string that contains
% required FITS entries, time, data, and all status, readout, format, and
% configuration parameters for image
function [successFlag, data] = GetImgHeader(handles)

    % Command settings
    numParam = 1;
    paramStruct.param1 = uint8(handles.camBuffNum);
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.GetImgHeader, numParam, paramStruct);

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
    if(dataType == handles.dataType.ImgHeader)
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
