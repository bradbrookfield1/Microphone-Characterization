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
    - Note: The rated frequency range of this meter is 31.5 Hz - 8 kHz. The dB(C) filter weighting is near flat within that range while the dB(A) filters out the low end much more, so be sure to use the dB(C) weighting. If you go beyond this frequency range, note that the filters cannot be trusted to be flat.
    - Data-logging app installation is on the flash drive that is included with the level meter. Installation details are given with its documentation.

5. MATLAB Version: 2021b Update 2 (9.11.0.1837725)
    - Instrument Control is a supplemental MATLAB app that is also required.

An additional necessary tool is a set of speakers that the audio analyzer is able to connect to. It does not matter too much what speakers are used. However, if it is crucial for you to observe a wide range of frequencies, it is recommended that ones suitable for that range are used. The speakers that we used were ones we had on hand, which were the Altec Lansing ACS90 Multimedia Computer Speakers, along with the ACS160 Subwoofer. The frequency range of the stereo speakers is 90 Hz - 20 kHz, but then with the subwoofer, frequencies as low as 30 Hz can be reached, and this was more than enough for our purposes. These speakers connect via 3.5mm jacks, and the audio analyzer can ruggedly be connected to this with an SDI to alligator clips adapter that tightly clips onto the 3.5mm cable. Eventually, we ended up using this enough that we soldered our own SDI to 3.5mm adapter for easier setup. For whatever speakers decided for use, if ones with a flatter frequency response are chosen, this may make the data ever so slightly more accurate. All audio systems will be accounted for and normalized in this program though, so having top quality speakers is not an incredible issue. Now that all of the tools are accounted for, let's break down how to apply this program.

## Data Retrieval
### Setup
Assuming everything is properly installed, the first step is to connect the GPIB adapter to the back of the audio analyzer, turn on the device, and on the computer open the Keysight VEE Pro Runtime app. In the Instrument Manager window, click "Find" to prompt and establish connection with the GPIB adapter. (If you get a warning and connection is not clearly established, make sure that everything is plugged in properly and that the audio analyzer is turned on, or else it will not connect.) Then, leave that app running the entire time that the MATLAB Data Retrieval program is being run. Ensure that the microphone of interest and the signal generation speaker(s) are properly connected to the audio analyzer, and be sure to turn on the speaker(s) last to avoid any speaker damage from connecting them or from powering on the audio analyzer. The recommended microphone location placement is towards the center of the source, and this matters more for the higher frequencies than the lower frequencies as the audio is both focused more from the speaker cone and does not travel through solid objects and dense mediums as easily as the lower frequencies. Distance from the source is more forgiving as long as the same distance is used for both the microphone procedure and the level meter procedure. However, for most US based audio devices, it is standard for all dB sound pressure level specifications to imply a distance of 1 meter, so to properly compare your measured specifications to other devices, 1 meter away from the generation is recommended.

### Microphone Procedure
In MATLAB, open the file InstrumentControlProgram.m and edit the variables at the top of the Insturment Configuration and Control section to best suit your frequency range, measurement accuracy, and desired data file name to save it to. Next, the speaker levels need to be set. Temporarily replace the microphone with the level meter. Make sure that all room conditions are as quiet as can be, then hit run (note that the program will start cycling through the frequencies and that levels will likely differ for each frequency) and adjust your speaker output to as loud of a level as you can provide for your setting. Note that levels will likely differ for each frequency, so let it play through all of them to make sure that your speaker levels are set based on your highest peak. Personally, the lab I did this in is away from other important administrative offices, so I let my peak sound pressure levels get up to about 95 dB and put on some protective ear muffs. The loudness does not have to be perfect; the idea though is that it is loud enough where signal to noise ratio is optimal and should not be an issue.

Put back the microphone where the level meter was, and now it is time to run the program and collect the data. Hit run, and if the system is not acoustically isolated, walk away so that your movement does not affect the data, and do not walk back until it has cycled through all the frequencies and the speaker is silent again. You now have the data you need for the microphone saved in the .mat file name as specified in the program.

### Level Meter Procedure
Now navigate to the Tools folder and open FrequencyTool.m. Run the program to find out what frequencies you will need to test upon for your desired frequency range. Be sure that its variables at the top match the same arguments that you specified in InstrumentControlProgram.m, or else you will get errors when you run the Data Visualization program. Record those frequencies at a place where you can quickly access them because this procedure will get much more repetitive than the microphone procedure.

Then replace the microphone with the level meter, plug its USB up to the computer, and open the level meter datalogging app and establish connection with the level meter. Meanwhile, in MATLAB open the Instrument Control App from the Apps tab...

FIX ME: ...and click on the the GPIB object in the left panel and connect the device.

Then paste the command FR1000.0HZAP0.1VLM1L0LNT3 in and adjust the frequencies and amplitude voltage accordingly. This example indicates a frequency of 1000.0 Hz and voltage of 0.1 V; use caution adjusting the voltage because if too large of a signal is sent, it could damage your speaker(s). Once all applications are ready, start with your first frequency, hit the "Write" button on Instrument Control, and the audio analyzer will begin sending the sine wave to your speakers. Then in the level meter app, be sure to have the dB(C) filter engaged before recording. Taking points every half second seemed to work best in doing it quickly while still having enough time to stop the recording after so many points. I usually take about 10 points, but the number does not really matter. It is just an arbitrary array size of points that will all end up being averaged together. Record as many points as you want, stop and save the file, and then edit the Instrument Control command for the next frequency. Repeat this until all frequencies have been met.

There are some important things to be aware of in taking this data. Be sure that if multiple data files are taken for one frequency that the unwanted ones are deleted; there can only be one file per frequency. The files are generally saved with the timestamp as the default name, but it is a good idea to rename the files anyway in a numerical order to avoid issues with data being taken out of order or from files having duplicate names if two files were saved in the same minute. One will need to do this procedure twice to cover both the logarithmic and linearly spaced arrays of frequencies as well. After all data is gathered, put them in their corresponding folders as shown in the GitHub example. This is all the data that needs to be collected for the plotting program.

## Data Visualization
### Procedure
The
