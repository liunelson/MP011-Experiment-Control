% Parse received data packet
% packetData: data packet received from camera server
% data: structure containing parsed data
function [data, dataType] = ParseDataPacket(packetRet)

    packLen = typecast(fliplr(packetRet(1:4)), 'uint32');
    packID = typecast(fliplr(packetRet(5)), 'uint8');
    camID = typecast(fliplr(packetRet(6)), 'uint8');
    errID = typecast(fliplr(packetRet(7:10)), 'int32');
    dataType = typecast(fliplr(packetRet(11:12)), 'uint16');
    dataLen = typecast(fliplr(packetRet(13:14)), 'uint16');
    
    % Get data structure
    packetData = packetRet(15:end);
    
    % handles.dataType.Status
    if(dataType == 2002)
        for(i = 1:(dataLen)/4)
            data.(sprintf('param%d',i)) = typecast(fliplr(packetData((4*i-3):(4*i))), 'single');
        end
    end
    
    % handles.dataType.Arbitrary
    if(dataType == 2003)
        data.param1 = zeros(1, dataLen, 'uint8');
        data.param1 = typecast(fliplr(packetData), 'uint8');
    end
    
    % handles.dataType.AcqStatus
    if(dataType == 2004)
        data.param1 = typecast(fliplr(packetData(1:2)), 'uint16');
        data.param2 = typecast(fliplr(packetData(3:4)), 'uint16');
        data.param3 = typecast(fliplr(packetData(5:8)), 'uint32');
    end
    
    % handles.dataType.ImgHeader
    if(dataType == 2006)
        data.param1 = char(packetData);
    end
    
    % handles.dataType.CommandDone 
    if(dataType == 2007)
        data.param1 = typecast(fliplr(packetData(1:2)), 'uint16');
    end
    
    % handles.dataType.ImgSettings
    if(dataType == 2008)
        data.param1 = typecast(fliplr(packetData(1:4)), 'uint32');
        data.param2 = typecast(fliplr(packetData(5)), 'uint8');
        data.param3 = typecast(fliplr(packetData(6)), 'uint8');
        data.param4 = typecast(fliplr(packetData(7:10)), 'uint32');
        data.param5 = typecast(fliplr(packetData(11:14)), 'uint32');
        data.param6 = typecast(fliplr(packetData(15:16)), 'uint16');
        data.param7 = typecast(fliplr(packetData(17:18)), 'uint16');
        data.param8 = typecast(fliplr(packetData(19:22)), 'int32');
        data.param9 = typecast(fliplr(packetData(23:26)), 'int32');
        data.param10 = typecast(fliplr(packetData(27:30)), 'int32');
        data.param11 = typecast(fliplr(packetData(31:34)), 'int32');
        data.param12 = typecast(fliplr(packetData(35:38)), 'int32');
        data.param13 = typecast(fliplr(packetData(39:42)), 'int32');
    end
    
    % handles.dataType.CameraParam
    if(dataType == 2009)
        for(i = 1:(dataLen)/4)
            data.(sprintf('param%d',i)) = typecast(fliplr(packetData((4*i-3):(4*i))), 'int32');
        end
    end

end
