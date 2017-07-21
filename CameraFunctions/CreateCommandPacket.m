% CreateCommandPacket: Create command packet for binary communication with camera server
% funcID: identifier of function to be executed
% numParam: number of parameters
% paramStruct: command parameters
function [packetCmd] = CreateCommandPacket(funcID, numParam, paramStruct)

    % Build parameter structure subpacket
    paramLen = 0;
    packetParam = uint8([]);
    if(numParam > 0)
        listParams = fieldnames(paramStruct);
        for(i = 1:numParam)
            % Concatenate parameter into command packet
            param = paramStruct.(listParams{i});
            packetParam = [packetParam, fliplr(typecast(param, 'uint8'))];
        end
    end
    w = whos('packetParam');
    paramLen = w.bytes;
    
    % Command packet structure
    packetLen = uint32(10 + paramLen);                  % length of packet in bytes
    packetID = uint8(128);                              % packet identifier = 128
    if(any(funcID == [1019,1024,1031,1041,1048,1049]))
        camID = uint8(0);                               % camera identifier, 0 for server command, 1 otherwise
    else
        camID = uint8(1);                   
    end
    funcID = uint16(funcID);                            % function to be executed (1000..1999)
    paramLen = uint16(paramLen);                        % length of following parameter structure (0 if none) in bytes
    %packetParam                                        % parameter structure 
    
    packetCmd = zeros(1, 10 + paramLen, 'uint8');
    packetCmd = [fliplr(typecast(packetLen, 'uint8')), ...
        fliplr(typecast(packetID, 'uint8')), ...
        fliplr(typecast(camID, 'uint8')), ...
        fliplr(typecast(funcID, 'uint8')), ...
        fliplr(typecast(paramLen,'uint8')), ...
        packetParam];
end
