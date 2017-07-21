% Close connection to servers (serial, TCP/IP)
function CloseServerConnection(serverObj, serverCmd)

	switch(serverCmd)
	
    	% Disconnect from shutters, time stage servers
    	case('close_serial')

    		% Import Java communication packages
    		import java.net.Socket;
    		import java.io.*;

    		% Close connection
    		serverObj.close();

    	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% Disconnect from camera server
		case('close_TCPIP')

			fclose(serverObj);
			delete(serverObj);
	end
end
