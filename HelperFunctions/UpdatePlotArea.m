function UpdatePlotArea

    % Load handles from base workspace
    handles = evalin('base','handles');

    TempCurrent = sortrows(handles.Current,1);
    TempVoltage = sortrows(handles.Voltage,1);
    
    set(handles.GraphCurrent,...
        'XData',TempCurrent(:,1),...
        'YData',TempCurrent(:,3));
    set(handles.GraphVoltage,...
        'XData',TempVoltage(:,1),...
    	'YData',TempVoltage(:,3));
    set(handles.GraphNominalCurrent,...
        'XData',TempCurrent(:,1),...
        'YData',TempCurrent(:,2));
    set(handles.GraphNominalVoltage,...
        'XData',TempVoltage(:,1),...
        'YData',TempVoltage(:,2));
    
    [plotTicksCurrent] = GeneratePlotTicks(handles.minCurrentDivision,...
        reshape(handles.Current(:,2:3),2*handles.numTimePointsPlot,1));
    [plotTicksVoltage] = GeneratePlotTicks(handles.minVoltageDivision,...
        reshape(handles.Voltage(:,2:3),2*handles.numTimePointsPlot,1));
    
    % Modify axis limits
    set(handles.Axes(1),'XLim',[min(handles.Current(:,1)),handles.Current(handles.CurrTimePoint)]);
    set(handles.Axes(1),'YLim',[plotTicksCurrent(1),plotTicksCurrent(end)]);
    set(handles.Axes(1),'XTick',linspace(min(handles.Current(:,1)),handles.Current(handles.CurrTimePoint),10));
    set(handles.Axes(1),'YTick',plotTicksCurrent);
    set(handles.Axes(1),'YTickLabel',sprintf('%4.1f\n',plotTicksCurrent));
    
    set(handles.Axes(2),'XLim',[min(handles.Voltage(:,1)),handles.Voltage(handles.CurrTimePoint)]);
    set(handles.Axes(2),'YLim',[plotTicksVoltage(1),plotTicksVoltage(end)]);
    set(handles.Axes(2),'XTick',linspace(min(handles.Voltage(:,1)),handles.Voltage(handles.CurrTimePoint),10));
    set(handles.Axes(2),'YTick',plotTicksVoltage);
    set(handles.Axes(2),'YTickLabel',sprintf('%4.2f\n',plotTicksVoltage));
    
    datetick(handles.Axes(1),'x','MM:SS','keepticks');
    datetick(handles.Axes(2),'x','MM:SS','keepticks');
    
    % Update time point
    if(handles.CurrTimePoint < handles.numTimePoints)
        handles.CurrTimePoint = handles.CurrTimePoint + 1;
    elseif(handles.CurrTimePoint == handles.numTimePoints)
        handles.CurrTimePoint = 1;
    end
    
    % Save handles in base workspace
    assignin('base','handles',handles)
    
end