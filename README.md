# Microphone-Characterization (Incomplete)
Obtain frequency response and power spectral density plots from microphone voltage data using MATLAB.

### Contents
- Introduction
- Data Retrieval
- Data Visualization

## Introduction
This program gives engineers and scientists the capability of characterizing microphones (and other input audio devices) with principles including frequency response, sensitivity, and power spectral density analysis. There are two main divisions to this program; one is the Data Retrieval portion, and the other is the Data Visualization portion. All of the tools mentioned below are mainly required for the Data Retrieval part of the program, but if these tools and methods are not used to obtain the voltage data of the microphone and the obtained data is not corrected to match the data types and format of the Data Visualization program, then the plotting program will not work. Tools that are necessary for this program to function properly without any changes include:
1. Hewlett Packard 8903A Audio Analyzer
    - Operating and Service Manual: https://www.waynekirkwood.com/images/pdf/HP_8903A_Audio_Analyzer-Service.pdf

2. National Instruments GPIB-USB-B Adapter
    - GPIB-USB-B Drivers: http://www.ni.com/en-us/support/downloads/drivers/download.ni-488-2.html#306147
      - As of 2-2-2022, I have been using NI-488.2 17.6 Windows, but there are lots more drivers available for Windows, macOS, and Linux systems.
      - Further GPIB-USB-B compatibility documentation: http://www.ni.com/product-documentation/5458/en/
      - Disclaimer: If you are a fellow Mac lover like me but are using a GPIB-USB-B interface, as disappointing as it may be, the necessary drivers are not available for macOS to my knowledge (I think they are available for Linux OS's, but I have not looked into it much). I have been using Windows bootcamp on my Macbook to pull up the necessary software and run the program. I am sorry to be the bearer of bad news, but feel free to search for another GPIB device that will work with macOS if it better suits your needs. Also, if one does find working drivers for the GPIB-USB-B on macOS systems, please enlighten me.

3. Keysight VEE Pro Runtime 9.33
    - Installer Download: https://www.keysight.com/us/en/lib/software-detail/computer-software/vee-runtime-2213956.html
      - This application is crucial because it runs in the background so that the GPIB is able to communicate with the audio analyzer in real time as the Data Retrieval program is being run. Details in using this will be included in the Data Retrieval section.
      - Again, this is a Windows (7, 8, and 10) based application. My apologies for any inconvenience.

4. ExTech HD600: Datalogging Sound Level Meter
    - English User's Manual: http://www.extech.com/products/resources/HD600_UM-en.pdf
    - Data-logging app installation is on the flash drive that is included with the level meter. Installation details are given with its documentation.

5. MATLAB Version: 2021b Update 2 (9.11.0.1837725)
    - Instrument Control is a supplemental MATLAB app that is also required.

Now that all of the tools are accounted for, let's break down how to apply this program.

## Data Retrieval
Assuming everything is properly installed, the first step is to connect the GPIB to the back of the audio analyzer, turn on the device, and the computer open the Keysight VEE Pro Runtime app.

## Data Visualization
The
