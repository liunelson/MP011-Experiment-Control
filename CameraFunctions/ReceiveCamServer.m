% Communicate with camera server
% handles.camObj: TCP object for camera server
% handles.waitTimeInc: increment of time to wait for server reply
% handles.waitTimeOut: timeout for server reply
% packetCmd: command packet to be sent
% packetRet: return packet received
function [packetRet] = ReceiveCamServer(handles, numBytesToRead)

    % Wait for server reply
    if(numBytesToRead ~= 0)
        camWaitTime = handles.camWaitTimeInc;
        while((handles.camObj.BytesAvailable < 1) && (camWaitTime < handles.camWaitTimeOut))        
            pause(camWaitTime);
            camWaitTime = camWaitTime + handles.camWaitTimeInc;
        end
    end
    %fprintf(1, 'BytesAvailable = %d \t camWaitTime = %f s\n', handles.camObj.BytesAvailable, camWaitTime);
    
    % Receive return packet
    if((numBytesToRead == 0) || (handles.camObj.BytesAvailable < 1))
        
        % Nothing to read
        packetRet = uint8([]);
        
    elseif(numBytesToRead == -1)
        
        % Read all
        packetRet = zeros(1, handles.camObj.BytesAvailable, 'uint8');
        packetRet = transpose(uint8(fread(handles.camObj, handles.camObj.BytesAvailable, 'uint8')));
        
        % Keep reading until input buffer is empty
        if(handles.camObj.BytesAvailable > 0)
            while(handles.camObj.BytesAvailable > 0)
                packetRet = [packetRet, transpose(uint8(fread(handles.camObj, handles.camObj.BytesAvailable, 'uint8')))];
            end
        end
        
    elseif(numBytesToRead > 0)
        
        % Read only numBytesToRead
        packetRet = zeros(1, numBytesToRead, 'uint8');
        packetRet = transpose(uint8(fread(handles.camObj, numBytesToRead, 'uint8')));
        
    end
    
    if(numel(packetRet) > 0)
        packetRet = (packetRet);
    end
end

