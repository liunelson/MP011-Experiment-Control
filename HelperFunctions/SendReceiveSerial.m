% Communicate with serial server
%
% serverAction: 'send' or 'receive'
% serverObj: Java.net.Socket or Matlab TCP/IP object
% serverCmd: string containing command for server
%
function [serverObj, serverAns, err] = SendReceiveSerial(serverAction, serverObj, serverCmd, serverWaitTime, serverNumTry)

	% Initialize variables
	serverAns = [];
	err = [];


    % Import Java communication packages
	import java.net.Socket;
    import java.io.*;

    % Check connection
    if(serverObj.isConnected > 0)

        % Send or receive data
        switch(serverAction)

            case('send')

                try
                    % Add termination characters
                    message = sprintf('%s\r\n', serverCmd);
                    
                    % Get stream to send data
                    output_stream = serverObj.getOutputStream;
                    data_output_stream = DataOutputStream(output_stream);
                    
                    % Convert to stream of bytes and send data to output stream
                    data_output_stream.writeBytes(char(message));
                    
                    % Flush data output stream
                    data_output_stream.flush;

                catch err

                    if(strcmpi(err.identifier,'MATLAB:Java:GenericException'))
                        errordlg('Matlab could not send or receive data to server.','Server Connection Error');
                    else
                        rethrow(err);
                    end
                end

            case('receive')

                try

                    % Get stream to receive data
                    input_stream   = serverObj.getInputStream;

                    % Convert received byte stream to character stream
                    input_read = InputStreamReader(input_stream);

                    % Get data from charactere stream
                    data = BufferedReader(input_read);

                    % Get total number of bytes in received stream
                    numBytes = input_stream.available;
                    %bytes_available = input_stream.available;

                    % Read data
                    response = [];
                    if(numBytes > 0)
                        for(j = 1:numBytes)
                            response(j) = data.read;
                        end
                    end

                    % Return answer
                    serverAns = char(response(1:numBytes));

                    % Remove leading and trailing whitespaces
                    serverAns = strtrim(serverAns);

                    % Convert embedded CRLF into spaces
                    serverAns(isspace(serverAns)) = ' ';
                     
                    catch err
                        if(strcmpi(err.identifier,'MATLAB:Java:GenericException'))
                            errordlg('Matlab could not send or receive data to server.','Server Connection Error');
                        else
                            rethrow(err);
                        end
                end

            case('send_receive')

                try
                    % Add termination characters
                    message = sprintf('%s\r\n', serverCmd);
                    
                    % Get stream to send data
                    output_stream = serverObj.getOutputStream;
                    data_output_stream = DataOutputStream(output_stream);
                    
                    % Convert to stream of bytes and send data to output stream
                    data_output_stream.writeBytes(char(message));
                    
                    % Flush data output stream
                    data_output_stream.flush;

                    i = 0;
                    while((numel(serverAns) < 1) || (i < serverNumTry))

                        if(numel(serverAns) > 0)
                            break;
                        else
                            i = i + 1;
                        end

                        pause(serverWaitTime);

                        % Get stream to receive data
                        input_stream   = serverObj.getInputStream;

                        % Convert received byte stream to character stream
                        input_read = InputStreamReader(input_stream);

                        % Get data from charactere stream
                        data = BufferedReader(input_read);

                        % Get total number of bytes in received stream
                        numBytes = input_stream.available;
                        %bytes_available = input_stream.available;

                        % Read data
                        response = [];
                        if(numBytes > 0)
                            for(j = 1:numBytes)
                                response(j) = data.read;
                            end
                        end

                        % Return answer
                        serverAns = char(response(1:numBytes));
                    end

                    % Remove leading and trailing whitespaces
                    serverAns = strtrim(serverAns);

                    % Convert embedded CRLF into spaces
                    serverAns(isspace(serverAns)) = ' ';
                     
                catch err

                    if(strcmpi(err.identifier,'MATLAB:Java:GenericException'))
                        errordlg('Matlab could not send or receive data to server.','Server Connection Error');
                    else
                        rethrow(err);
                    end
                end
                
        end

    else
        err = 'serverObj.isConnected ~= 1';
    end
end
