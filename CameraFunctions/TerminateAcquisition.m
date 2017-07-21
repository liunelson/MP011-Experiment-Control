% Terminate current camera acquisition
function [successFlag, data] = TerminateAcquisition(handles)

    % Command settings
    numParam = 0;
    paramStruct = [];
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.TerminateAcq, numParam, paramStruct);

    % Send command packet to camera server
    fwrite(handles.camObj, packetCmd, 'uint8');

    % Receive data packet
    [packetRet] = ReceiveCamServer(handles, -1);    
    
    % Read returned data packet
    [data, dataType] = ParseDataPacket(packetRet);
    
    successFlag = 0;
    if(dataType == handles.dataType.CommandDone)
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end

