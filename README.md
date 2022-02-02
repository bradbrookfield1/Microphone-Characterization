# Microphone-Characterization (Incomplete)
Obtain frequency response and power spectral density plots from microphone voltage data using MATLAB.

# Contents
- Introduction
- Data Retrieval
- Data Visualization

# Introduction
This program gives engineers and scientists the capability of characterizing microphones (and other input audio devices) with principles including frequency response, sensitivity, and power spectral density analysis. Tools that are necessary for this program to function properly without any changes include:
1. Hewlett Packard 8903A Audio Analyzer
- Operating and Service Manual: https://www.waynekirkwood.com/images/pdf/HP_8903A_Audio_Analyzer-Service.pdf
2. National Instruments GPIB-USB-B Adapter
- FIX ME!!! and proper drivers and Keysight software connection interface
3. ExTech HD600: Datalogging Sound Level Meter
- English User's Manual: http://www.extech.com/products/resources/HD600_UM-en.pdf
- Data-logging app installation is on the flash drive that is included with the level meter. Installation details are given with its documentation.
4. MATLAB Version: 2021b Update 2 (9.11.0.1837725)
- Instrument Control is a supplemental MATLAB app that is also required.

There are two main divisions to this program; one is the data retrieval portion, and the other is the data visualization portion. All of the tools mentioned above are mainly required for the data retrieval part of the program, but if these tools and methods are not used to obtain the voltage data of the microphone and the obtained data is not corrected to match the data types and format of the data visualization program, then the plotting program will not work either. With all of that said, let's break down how to apply this program.

# Data Retrieval
Before following this procedure, make sure that the necessary equipment listed in the introduction has been accounted for and that all necessary software drivers have been installed.

# Data Visualization
The
