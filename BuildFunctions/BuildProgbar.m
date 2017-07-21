function hScanProgbar = BuildProgbar(hpanel)

    position = [10 10 180 20];

    jPb = javax.swing.JProgressBar;
    set(jPb,'Value', 0);
    [hScanProgbar, hContainer] = javacomponent(jPb, position, hpanel);

end



