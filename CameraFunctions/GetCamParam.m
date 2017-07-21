% Get camera readout and configuration parameters
%
% Readout Format Parameters
% data.param1: CCD format serial origin
% data.param2: CCD format serial length
% data.param3: CCD format serial binning
% data.param4: CCD format serial post scan
% data.param5: CCD format parallel origin
% data.param6: CCD format parallel length
% data.param7: CCD format parallel binning
% data.param8: CCD format parallel post scan
% data.param9: exposure time (ms)
% data.param10: "Continuous Clear,3, 0 = Enabled, 1 = Disabled for One Cycle, 2 = Disabled"
% data.param11: DSI sample time (452 for 100 kHz, 207 for 200 kHz, 83 for 400 kHz, 21 for 800 kHz) 
% data.param12: analogue attenuation (0 for low, 1 for medium, 2 for high)
% data.param13: port 1 offset
% data.param14: port 2 offset
% data.param15-16: not used
% data.param17: TDI delay (in microseconds) 
% data.param18-20: not used 
% data.param21: "# Samples/Pixel,0,128"
% data.param22-23: not used
% data.param24: command on trigger (1 for open shutter, 2 for close shutter, 3 for test image, 4 for light exposure, 5 for dark exposure, 26 for TDI exposure)
% data.param25-32: not used
%
% Configuration Parameters
% data.param33: instrument model
% data.param34: instrument serial number
% data.param35: hardware revision
% data.param36: serial phasing (0 for normal, 1 for reversed)
% data.param37: serial split (0 for normal, 1 for split)
% data.param38: serial size
% data.param39: parallel phasing (0 for normal, 1 for reversed)
% data.param40: parallel split (0 for normal, 1 for split)
% data.param41: parallel size
% data.param42: parallel shift delay
% data.param43: number of ports (0 for 1 port, 1 for 2 ports)
% data.param44: shutter close delay (in ms)
% data.param45: CCD temperature setpoint offset (in 0.1 C)
% data.param46: low temperature limit
% data.param47: CCD temperature setpoint
% data.param48: operational temperature
% data.param49: not used
% data.param50: port select (0 = A, 1 = B, 2 = AB)
% data.param51: not used
% data.param52: operational pressure 
% data.param53: high pressure limit
% data.param54-63: not used
% data.param64: "Pixel Clear,1,10000,ns"
function [successFlag, data] = GetCamParam(handles)

    % Command settings
    numParam = 0;
    paramStruct = [];
        
    % Create command packet
    packetCmd = CreateCommandPacket(handles.funcID.GetCamParam, numParam, paramStruct);

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
    if(dataType == handles.dataType.CameraParam)
        successFlag = 1;
        %fprintf(1, 'Command successful!\n');
    end
end
