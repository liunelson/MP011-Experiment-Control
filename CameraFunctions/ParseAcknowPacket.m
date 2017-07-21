% Parse acknowledge packet for accepted flag
% packetRet: return packet received from camera server
% acceptFlag: accepted flag, false if 0, true otherwise
function [acceptFlag] = ParseAcknowPacket(packetRet)
    
    % Recast uint8 into proper precisions
    % Flip byte order (big-endian -> little-endian)
    packLen = typecast(fliplr(packetRet(1:4)), 'uint32');
    packID = packetRet(5);
    cameraID = packetRet(6);
    acceptFlag = typecast(fliplr(packetRet(7:8)), 'uint16');
end
