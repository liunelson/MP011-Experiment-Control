% Function to build communication packet
function [command] = CreateChillerCOMPacket(cmdList, cmdName, cmdData)

	% Lookup command table
	i = 0; j = 0;
	while(j < 1)
		i = i + 1;
		j = strcmp(cmdList{i, 1}, cmdName);
	end

	% Leading characters and command byte
	packetCOM = {'CA', '00', '01', cmdList{i, 2}};

	% Concatenate command data
	packetCOM = [packetCOM, dec2hex(numel(cmdData), 2), cmdData];

	% Checksum
	checksum = 0;
	for(i = 2:numel(packetCOM))
		checksum = checksum + hex2dec(packetCOM{i});
	end
	checksum = dec2hex(checksum, 2);

	% Bitwise inversion with last two least significant bytes
	if(numel(checksum) > 2)
		checksum = checksum((end - 1):end);
	end
	checksum = bitxor(hex2dec(checksum), hex2dec('FF'));
	checksum = dec2hex(checksum, 2);

	% Concatenate checksum
	packetCOM = [packetCOM, checksum];
    
    for(i = 1:numel(packetCOM))
        if(i==1)
            command = packetCOM{i};
        else
            command = sprintf('%s %s', command, packetCOM{i});
        end
    end

end


