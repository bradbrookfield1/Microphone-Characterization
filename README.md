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
    - Note: The rated frequency range of this meter is 31.5 Hz - 8 kHz.
    - Data-logging app installation is on the flash drive that is included with the level meter. Installation details are given with its documentation.

5. MATLAB Version: 2021b Update 2 (9.11.0.1837725)
    - Instrument Control is a supplemental MATLAB app that is also required.

An additional necessary tool is a set of speakers that the audio analyzer is able to connect to. It does not matter too much what speakers are used. However, if it is crucial for you to observe a wide range of frequencies, it is recommended that ones suitable for that range are used. The speakers that we used were ones we had on hand, which were the Altec Lansing ACS90 Multimedia Computer Speakers, along with the ACS160 Subwoofer. The frequency range of the stereo speakers is 90 Hz - 20 kHz, but then with the subwoofer, frequencies as low as 30 Hz can be reached, and this was more than enough for our purposes. These speakers connect via 3.5mm jacks, and the audio analyzer can ruggedly be connected to this with an SDI to alligator clips adapter that tightly clips onto the 3.5mm cable. Eventually, we ended up using this enough that we soldered our own SDI to 3.5mm adapter for easier setup. For whatever speakers decided for use, if ones with a flatter frequency response are chosen, this may make the data ever so slightly more accurate. All audio systems will be accounted for and normalized in this program though, so having top quality speakers is not an incredible issue. Now that all of the tools are accounted for, let's break down how to apply this program.

## Data Retrieval
### Setup
Assuming everything is properly installed, the first step is to connect the GPIB adapter to the back of the audio analyzer, turn on the device, and the computer open the Keysight VEE Pro Runtime app. In the Instrument Manager window, click "Find" to prompt and establish connection with the GPIB adapter. (If you get a warning and connection is not clearly established, make sure that everything is plugged in properly and that the audio analyzer is turned on, or else it will not connect.) Then, leave that app running the entire time that the MATLAB Data Retrieval program is being run.

### Procedure
Now open MATLAB and navigate to the Tools folder and open FrequencyTool.m.

## Data Visualization
### Procedure
The
