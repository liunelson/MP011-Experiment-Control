function [plotTicks] = GeneratePlotTicks(minDivision,plotArray)

    M = max(plotArray);
    m = min(plotArray);

    if(M ~= m)
        while((M - m)/minDivision <= 2)
            minDivision = minDivision/2;
        end
    end
    
    N = floor((M + minDivision)/minDivision);
    n = ceil((m - minDivision)/minDivision);
    plotTicks = minDivision*(n:1:N);
end