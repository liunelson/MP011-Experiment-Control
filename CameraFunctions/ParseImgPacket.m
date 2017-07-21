% Parse received image packet
% packetRet: packet received from camera server
% data: structure containing parsed image
function [packetImg, imgType] = ParseImgPacket(packetRet)
    
    packLen = typecast(fliplr(packetRet(1:4)), 'uint32')
    packID = typecast(fliplr(packetRet(5)), 'uint8')
    camID = typecast(fliplr(packetRet(6)), 'uint8')
    errID = typecast(fliplr(packetRet(7:10)), 'int32')
    imgID = typecast(fliplr(packetRet(11:12)), 'uint16')
    imgType = typecast(fliplr(packetRet(13:14)), 'uint16')
    serialLen = typecast(fliplr(packetRet(15:16)), 'uint16')
    paraLen = typecast(fliplr(packetRet(17:18)), 'uint16') 
    totNumPack = typecast(fliplr(packetRet(19:20)), 'uint16')
    currPackNum = typecast(fliplr(packetRet(21:22)), 'uint16')
    offset = typecast(fliplr(packetRet(23:26)), 'uint32')
    imgLen = typecast(fliplr(packetRet(27:30)), 'uint32') 

    % Get data structure
    packetImg = packetRet(31:end);
    
end
