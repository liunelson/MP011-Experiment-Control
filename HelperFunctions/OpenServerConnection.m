% Open/close connection to servers (serial, TCP/IP)
function [serverObj, err] = OpenServerConnection(serverCmd, serverIP, serverPort)

	% Initialize variables
	serverObj = [];
	err = [];

    switch(serverCmd)

    	% Serial communication via server (shutter, time delay stage, rotation stage)
    	case('open_serial')

    		% Import Java communication packages
    		import java.net.Socket;
    		import java.io.*;
    		
		    % Make connection to server
		    try
		        serverObj = Socket(serverIP, str2num(serverPort));

		    catch err
		        if(strcmpi(err.identifier,'MATLAB:Java:GenericException'))
		            errordlg('Matlab could not connect to serial server at given address.','Server Connection Error');
		        else
		            rethrow(err);
		        end
		    end

    	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    	% TCPIP communication (camera)
    	case('open_TCPIP')

			% Create TCP/IP object
			serverObj = tcpip(serverIP, str2num(serverPort));

			% Set TCP/IP object properties
			set(serverObj, 'OutputBufferSize', 1024);
			set(serverObj, 'InputBufferSize', 10000000);
			set(serverObj, 'ByteOrder', 'bigEndian');

			% Make connection to server
			try
				fopen(serverObj);

			catch err

				if(strcmpi(err.identifier, 'instrument:fopen:opfailed') > 0)

					errordlg('Matlab could not connect to TCP/IP server at given address.','Server Connection Error');

				else

					rethrow(err);

				end
			end

			% Flush input buffer
			flushinput(serverObj);

	end
end
