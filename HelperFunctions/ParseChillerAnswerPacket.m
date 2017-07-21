
% Parse answer packet from chiller
function [data, err] = ParseChillerAnswerPacket(cmdList, packetAns)

    % Parse preamble
    cmdByte = packetAns(7:8);
    numDataByte = packetAns(9:10);
    checkSum = packetAns(end-1:end);

    % Parse data
    temp = '';
    for(i = 1:str2double(numDataByte))
        temp.(sprintf('param%d', i)) = packetAns(2*(i+5)-1:2*(i+5));
    end

    data = '';
    err = '';
    switch(cmdByte)

        % Read Acknowledge
        case('00')

            % Protocol number
            data.param1 = dec2hex([temp.param1, temp.param2]);

        % Read Status
        case('09')

            % Binary string
            strBin  = '';
            for(i = 1:5)
                strBin = [strBin, dec2bin(hex2dec(temp.(sprintf('param%d', i))), 8)];
            end

            % Parse status
            for(i = 1:numel(strBin))
                data.(sprintf('param%d', i)) = logical(str2num(strBin(i)));
            end

        % Turn On/Off Array
        case('81')

            % Parse on/off settings
            for(i = 1:8)

                if(strcmp(temp.(sprintf('param%d', i)), '00') == 1)
                    data.(sprintf('param%d', i)) = 'off';
                elseif(strcmp(temp.(sprintf('param%d', i)), '01') == 1)
                    data.(sprintf('param%d', i)) = 'on';
                elseif(strcmp(temp.(sprintf('param%d', i)), '02') == 1)
                    data.(sprintf('param%d', i)) = 'no change';
                end
            end
            

        % Bath Error
        case('0F')

            if(strcmp(temp.param1, '01') > 0)
                err = 'bad command'
            elseif(strcmp(temp.param1, '03') > 0)
                err = 'bad checksum'
            end


        % Else
        otherwise

            % Qualifier byte
            precision = 1;
            qualByte = temp.param1;
            switch(qualByte)

                case('10')
                    precision = 0.1;

                case('20')
                    precision = 0.01;

                case('11')
                    precision = 0.1;

                case('21')
                    precision = 0.01;
            end

            % 16-bit signed integer -> value
            data.param1 = precision * hex2dec([temp.param2, temp.param3]);
    end
end
