% Inquire acquisition status of camera
%
% data.param1: percent of exposure that has elapsed 
% data.param2: percent of readout that has completed
% data.param3: relative position of readout pointer
function [successFlag, data] = InquireAcquisitionStatus(handles)

    % Command settings
    numParam = 0;
    paramStruct = [];
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.InquireAcqStatus, numParam, paramStruct);

    % Send command packet to camera server
    fwrite(handles.camObj, packetCmd, 'uint8');

    % Receive data packet
    [packetRet] = ReceiveCamServer(handles, -1);    
    
    % Read returned data packet
    [data, dataType] = ParseDataPacket(packetRet);
    
    successFlag = 0;
    if(dataType == handles.dataType.AcqStatus)
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
