# Documentation

`MP011-Experimental-Control` is a MATLAB application for instrument control and data acquisition. It is meant for users of the ultrafast electron diffraction experimental lab in MP011 of the [R. J. Dwayne Miller group](http://lphys.chem.utoronto.ca/) at the University of Toronto. This app is designed to interface with multiple scientific instruments over TCP/IP ethernet and RS232 serial communication while being portable to any recent version of MATLAB (from R2014a to R2017a) and Microsoft Windows (from WinXP to Win10). It is also structured to be modular, such that device interfaces can be easily added, removed, or changed. The interface between the app and hardware layers is handled by device-specific instances of `MP011-Server` ([link](https://github.com/liunelson/MP011-Server)), an in-house server program that receives commands from the client over TCP/IP and then sends appropriate command packets (and receives data packets) to the device through a serial COM port.

![Screenshot of MP011-Experiment-Control app.](MP011-app.png)

The app can currently interface with the following devices:
- Matsusada Precision AF series HV power supply ([link](https://www.matsusada.com/product/psel/hvps1/rack/000042/)) controlled via a Stanford Research Systems (SRS) SR245 computer interface module ([link](http://www.thinksrs.com/products/SR245.htm))
- Spectral Instrument (SI) 800 series cooled CCD camera ([link](http://www.specinst.com/Brochures%20Rev%20B/800S-camera-broch_revB.pdf))
- Vincent Associates (VA) Uniblitz VMM-T1 optical shutter drivers ([link](https://www.uniblitz.com/product-category/shutter-drivers/))
- Newport ILS200PP motorized linear translation stage ([link](https://www.newport.com/p/ILS200PP)) via a Newport SMC100CC single-axis motion controller ([link](https://www.newport.com/p/SMC100PP))
- X, Y, Z motorized linear translation stages via Parker Automation 6K series motion controllers ([link](http://www.parkermotion.com/products/Controllers__1745__30_32_80_567_29.html))
- miCos RS40 compact rotation stage ([link](https://www.physikinstrumente.com/en/products/rotation-stages/stages-with-worm-gear-drives/rs-40-compact-rotation-stage-1204000/)) via a miCos SMC Pollux stepper controller ([link](http://www.micosusa.com/product/prodDetail.cfm_firstlevel=2&sublevel=45&prodid=167.htm))
- Coherent Micra-5 laser oscillator ([link](https://www.coherent.com/lasers/main/ultrafast-laser-oscillators-and-amplifiers/ultrafast-oscillators/))
- Thermo Electron Neslab RTE7 circulating chiller ([link](https://www.nist.gov/laboratories/tools-instruments/thermo-scientific-neslab-rte-7-circulating-bath))
- Tektronix DPO2024 oscilloscope ([link](http://www.tek.com/oscilloscope/mso2000-dpo2000))

## Quick Start

To launch the app, clone this repository, place it somewhere in MATLAB's search path, and simply run `MP011_Experimental_Control.m`.

## Directory Layout

- `BuildFunctions` contains the functions that create and customize the different figure windows, panels, and UI elements of the GUI. Code that determine the physical dimensions, positioning, and visual appearance of the GUI go here.

- `CallbackFunctions` holds the callback functions that are executed for each UI interaction. Actions include changes to the properties of the UI elements, updates to the global variable `handles`, and communication with hardware.

- `CameraFunctions` contains the specialized MATLAB code for handling the communication with the CCD camera. 

- `HelperFunctions` is the folder where functional code that are commonly called back those in `BuildFunctions` and `CallbackFunctions` go, e.g. initialization of the global variable `handles`, communication with the TCP/IP servers, and updates to editable fields.

- `mksqlite` contains the code that allows the logging of experiment metadata in a SQLite database. It was cloned from the [mksqlite](https://github.com/AndreasMartin72/mksqlite) project.

- `Drivers and Documentation` contains relevant files such driver installers and operator's manual for the different devices. These are included here for reference.

## Remarks

To actually talk to the devices, make sure that the following steps are taken already:
1. Turn on all the hardware and connect them to the appropriate computer.
2. Install the National Instruments (NI) VISA driver on the app computer (necessary for the oscilloscope).
3. Place the MATLAB instrument driver file for the oscilloscope (`tektronix_dpo2024.mdd`) in the subfolder `\toolbox\instrument\instrument\drivers` where MATLAB is installed.
4. Install and run the SI Image SGL camera control program and enable the TCP/IP server.
5. Run the server program associated with each of the devices on the server computer ([link](https://github.com/liunelson/MP011-Server)).
6. Connect the server computer to the same local network as the control computer.

For ease of operation, I would recommend allocating fixed IP addresses to the server computer and any other TCP/IP devices to avoid having to reset too often the default IP addresses on the app. 

When the app is launched for the first time, `mksqlite` may complain about some missing files (`msvcr100.dll` and `msvcp100.dll`). These DLLs are from the Microsoft Visual C++ 2010 Redistributable Package and could be found by copying them over from somewhere else to the MATLAB subfolder `\bin\win64`. A better solution may be to install the appropriate version of MATLAB Compiler Runtime ([link](https://www.mathworks.com/products/compiler/mcr.html)).

For reference, here are the steps to install the SI Image SGL camera control program:
1. Run `setup.bat` in the subfolder `.\Drivers and Documentation\Spectral Instrument Camera\SI Image SGL E Installation Files`.
2. Copy over the configuration files (`*.set`, `*.bin`, `*.cfg`) in the same subfolder to the folder `C:\Users\Public\Public Documents\SI Image SGL Rev E`.

## Co-authorship and Acknowledgment

This experiment control app was developed from scratch by me (liu.nelson _at_ lphys.chem.utoronto.ca) with the help of Dr. Gustavo Moriena (gustavo _at_ lphys.chem.utoronto.ca). It is designed to supersede and replace a Visual Basic 6.0 program developed by Dr. Maher Harb and Dr. Meng Gao. 

I do not claim rights or ownership to any of the material in the `Drivers and Documentation` folder. All rights belong to their respective owners.   
