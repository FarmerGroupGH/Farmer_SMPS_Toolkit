#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


/////////////////////////
/////////////////////////
//     SMPS Panel      //
/////////////////////////
/////////////////////////
///Done by AJD and LG////
/////////////////////////


////////////////////////////////////////////////////////


Menu "Farmer SMPS Tools"
	"Go to SMPS Panel",   SMPS_Bring_Panel_2_Front()
	"-"
	"Generate SMPS Panel", InitializePanel()
	"-"
	"Kill All Data", KillEverything()
End


Function InitializePanel()
	SetDataFolder root:
	Variable/G density
	density = 1
	Variable/G indivfile_Y
	Variable/G indivfile_Mon
	Variable/G indivfile_D
	Variable/G indivfile_H
	Variable/G indivfile_Min
	Variable/G indivfile_S
	
	Variable/G avg_start_Y
	Variable/G avg_start_Mon
	Variable/G avg_start_D
	Variable/G avg_start_H
	Variable/G avg_start_Min
	Variable/G avg_start_S
	
	Variable/G avg_stop_Y
	Variable/G avg_stop_Mon
	Variable/G avg_stop_D
	Variable/G avg_stop_H
	Variable/G avg_stop_Min
	Variable/G avg_stop_S
	
	Variable/G SoftwareVersion // 0 is 10.3 and from the box (DDMMYY). 1 is from AIM11. 2 is from 10.3 (MMDDYY)
	Make/T/N=3/O VersionNames
	VersionNames = {"AIM 10.3 DDMMYYYY","AIM 11","AIM 10.3 YYYYMMDD"}
	Make/O/N=3 VersionTypes
	VersionTypes = {0,1,2}
	
	
	Variable/G Check_Box_Export_Single_File
	//Slider slider0 variable=SoftwareVersion,userTicks={VersionTypes,VersionNames}
	
	Variable/G Interval =10 //default to plot every 10th scan
	
	If (datafolderexists("root:AllTime") ==0)
		NewDataFolder AllTime
		NewDataFolder ICARTTwaves
		NewDataFolder IrregularTimeAvg
		NewDataFolder Mass_Concentration
		NewDataFolder Number_Concentration
		NewDataFolder Size_Distributions_Numb
		NewDataFolder Size_Distributions_Mass
	Endif
	
	InitializeICARTTsection()
	
	Execute "SMPS_Data_Processor()"
	
End

Window SMPS_Data_Processor() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(755,162,1644,926) as "SMPS_DataViewer_FarmerGroup"
	ModifyPanel cbRGB=(61166,61166,61166), frameStyle=1, frameInset=7
	ShowTools/A
	ShowInfo/W=$WinName(0,64)
	SetDrawLayer UserBack
	DrawPICT 755,84,0.236686,0.236686,PICT_0
	DrawPICT 723,8,0.04329,0.0470085,PICT_1
	SetDrawEnv linethick= 2
	DrawLine 11,345,1113,345
	SetDrawEnv linethick= 2
	DrawLine -13,220,1089,220
	SetDrawEnv linethick= 2
	DrawLine -3,484,1099,484
	SetDrawEnv linethick= 2
	DrawLine 8,628,1110,628
	SetDrawEnv linethick= 0,fillfgc= (49151,53155,65535),fillbgc= (49151,53155,65535)
	DrawRect 228,513,457,617
	DrawText 238,532,"Starting Date and Time of Individual File"
	SetDrawEnv linethick= 0,fillfgc= (49151,65535,65535),fillbgc= (49151,65535,65535)
	DrawRect 34,393,227,477
	DrawText 111,411,"Start Time"
	SetDrawEnv linethick= 0,fillfgc= (49151,65535,65535),fillbgc= (49151,65535,65535)
	DrawRect 259,394,432,478
	DrawText 317,413,"Stop Time"
	SetDrawEnv linethick= 0,fillfgc= (65535,49151,62258),fillbgc= (65535,49151,62258)
	DrawRect 360,643,731,740
	DrawText 419,667,"\\JCICARTT Time Range --- Dates Inclusives"
	SetDrawEnv linethick= 2
	DrawLine 12,753,1114,753
	TitleBox Title01,pos={11.00,9.00},size={309.00,23.00},title="Farmer Lab SMPS Data Processor"
	TitleBox Title01,help={"This Processor can only work with AIM 10.3 Files"}
	TitleBox Title01,fSize=20,frame=0
	TitleBox Title02,pos={397.00,11.00},size={265.00,18.00},title="Adam De Groodt and Lauren Garofalo"
	TitleBox Title02,help={"As this was written Lauren Garfalo was a research scientist in the Farmer lab and Adam De Groodt was a 2nd year Ph.D. Student in the Farmer Lab. "}
	TitleBox Title02,fSize=16,frame=0
	TitleBox Title03,pos={448.00,41.00},size={191.00,45.00},title="Correspondence to\rAdam.De_Groodt@colostate.edu\rOr Lauren.Garofalo@colostate.edu"
	TitleBox Title03,help={"Please do not be afraid to reach out to me for help.\rIf I am gone from the lab when you are looking to use this then ask someone around the lab if they happen to have my information.\rDelphine is the person that is most likley to have it. \r-Adam"}
	TitleBox Title03,fSize=12,frame=0
	Button process_databutt,pos={15.00,127.00},size={262.00,33.00},proc=LoadOneFile_Button,title="Load and Process One File"
	Button process_databutt,help={"This button will allow the user to load in the datafile that will be analyzed."}
	Button process_databutt,fSize=20
	Button help_butt,pos={718.00,173.00},size={105.00,39.00},proc=help_button,title="Help"
	Button help_butt,help={"The Help Button Provides some Instructions as well as errors that could occur within the dataloading and analysis process"}
	Button help_butt,fSize=20
	Button Setup_waves_for_tseries_nconc_butt,pos={26.00,251.00},size={214.00,43.00},proc=Get_Waves_For_Concatenation_numb,title="Set up waves for full time series \r(Number and Mass)"
	Button Setup_waves_for_tseries_nconc_butt,help={"Grabs the nessesary wave from the loaded in Number Concentration data that has been loaded in and puts them into the cummulative number folder\r Then concatenates the waves to prep for the creation of the graph"}
	TitleBox cumulative_title,pos={14.00,223.00},size={183.00,23.00},title="Plot a full time series"
	TitleBox cumulative_title,help={"These buttons perform cummulative work that will be done on the files loaded in thusfar.\rRemmeber to reset the folder anytime that more data is being loaded in and is wanting to be added to to the cummulative work. "}
	TitleBox cumulative_title,fSize=20,frame=0
	Button get_tseries_graph_butt_numb,pos={22.00,295.00},size={219.00,43.00},proc=Make_tseries_graph_button_numb,title="Make Time Series Graphs \r(Integrated Number and Mass Conc.)"
	Button get_tseries_graph_butt_numb,help={"Goes to the Concatenated_Wave_Number folder and creates the time series graph based on the waves that have been loaded in there. "}
	TitleBox ICARTT_title,pos={19.00,653.00},size={179.00,23.00},title="Make ICARTT Table"
	TitleBox ICARTT_title,help={"Buttons that perform Hourly Average concentrations.\rCummulative Work process above must have been preformed in order to perform Houly Average work. \rThe Hourly Average buttons need the first points year, month, day, hour, min, sec to work."}
	TitleBox ICARTT_title,fSize=20,frame=0
	TitleBox SDwork,pos={15.00,490.00},size={159.00,23.00},title="Plot individual files"
	TitleBox SDwork,help={"This section allows the creation of size distribution graphs."}
	TitleBox SDwork,fSize=20,frame=0
	Button getmakesizedistwaves_numb,pos={15.00,527.00},size={198.00,37.00},proc=getsizedistwaves_button,title="Generate Number and \rMass Size Distributions"
	Button getmakesizedistwaves_numb,help={"Gets the waves, organizes them and then generates the size distributions to be viewed with the \"Make Number Size Distribution Graphs\" button. "}
	Button makeSDGraphs,pos={463.00,515.00},size={150.00,40.00},proc=MakeSDGraphs_button_numb,title="Plot All Scans in File\rNumber"
	Button makeSDGraphs,help={"Makes all the SD graphs in individual graphs for a data file loaded in.\rUser must copy the full path and then paste it into the popup generated when the button is pressed. "}
	Button makeSDGraphs,fColor=(49151,53155,65535)
	Button Killallgraphs_butt,pos={587.00,86.00},size={125.00,44.00},proc=Kill_All_Graphs_button,title="Kill All Graphs"
	Button Killallgraphs_butt,help={"Kills All Current Graphs Open within the File"}
	Button MakeMSDGraphs,pos={472.00,563.00},size={150.00,40.00},proc=MakeSDGraphs_button_mass,title="Plot All Scans in File\rMass"
	Button MakeMSDGraphs,help={"Makes a Size Distribution Graph for the Full path to the folder.\rUser must copy the full path and then paste it into the popup generated when the button is pressed. "}
	Button MakeMSDGraphs,fColor=(49151,53155,65535)
	TitleBox expworktitlebox,pos={16.00,356.00},size={227.00,23.00},title="Plot a specific time period"
	TitleBox expworktitlebox,fSize=20,frame=0
	Button Kill_All_Tables_Button,pos={590.00,131.00},size={125.00,44.00},proc=Kill_All_Tables_button,title="Kill All Tables"
	Button Kill_All_Tables_Button,help={"Kills All Current Tables Open within the File "}
	Button Heatmap_Numb_butt,pos={627.00,514.00},size={150.00,40.00},proc=MakeHeatmap_Numb_button,title="Make Heat Map for File\rNumber"
	Button Heatmap_Numb_butt,help={"Make a Heat Map for a specific file in the Size Distribution folder.\rUser will need to provide a full path to the folder desired"}
	Button Heatmap_Numb_butt,fColor=(49151,53155,65535)
	Button Heatmap_Numb_butt1,pos={625.00,568.00},size={150.00,40.00},proc=MakeHeatmap_Mass_button,title="Make Heat Mapfor File \rMass"
	Button Heatmap_Numb_butt1,help={"Make a Heat Map for a specific file in the Size Distribution folder.\rUser will need to provide a full path to the folder desired"}
	Button Heatmap_Numb_butt1,fColor=(49151,53155,65535)
	Button Heatmap_All_Individual,pos={16.00,572.00},size={195.00,50.00},proc=MakeHeatmap_all_individual_button,title="Make \rN = (number of files) \r Heat Maps"
	Button Heatmap_All_Individual,help={"Make a Heat Map for a specific file in the Size Distribution folder.\rUser will need to provide a full path to the folder desired"}
	SetVariable setvar0,pos={18.00,88.00},size={362.00,34.00},title="\\Z20Assumed Density of Aerosol, g cm\\S-3"
	SetVariable setvar0,labelBack=(49151,65535,49151),fSize=20
	SetVariable setvar0,valueBackColor=(49151,65535,49151)
	SetVariable setvar0,limits={-inf,inf,0},value= density
	Button recalc_mass,pos={285.00,144.00},size={267.00,64.00},proc=RecalcMass_Button,title="Recalculate Mass\rIf you change density, you click here \rand \"set up waves for full time series\""
	SetVariable indivfile_Y,pos={265.00,533.00},size={65.00,18.00},title="Year"
	SetVariable indivfile_Y,limits={-inf,inf,0},value= indivfile_Y
	SetVariable indivfile_Y1,pos={269.00,554.00},size={65.00,18.00},title="Month"
	SetVariable indivfile_Y1,limits={-inf,inf,0},value= indivfile_Mon
	SetVariable indivfile_Y2,pos={265.00,575.00},size={65.00,18.00},title="Day"
	SetVariable indivfile_Y2,limits={-inf,inf,0},value= indivfile_D
	SetVariable indivfile_Y3,pos={347.00,557.00},size={65.00,18.00},title="Minute"
	SetVariable indivfile_Y3,limits={-inf,inf,0},value= indivfile_Min
	SetVariable indivfile_Y4,pos={349.00,534.00},size={65.00,18.00},title="Hour"
	SetVariable indivfile_Y4,limits={-inf,inf,0},value= indivfile_H
	SetVariable indivfile_Y5,pos={348.00,578.00},size={65.00,18.00},title="Second"
	SetVariable indivfile_Y5,limits={-inf,inf,0},value= indivfile_S
	Button Heatmap_All,pos={271.00,251.00},size={120.00,37.00},proc=MakeHeatmap_all_Number_button,title="Make Heat Map \r (Number)"
	Button Heatmap_All_Individual2,pos={278.00,296.00},size={113.00,37.00},proc=MakeHeatmap_all_Mass_button,title="Make Heat Map\r (Mass)"
	SetVariable indivfile_Y6,pos={55.00,416.00},size={65.00,18.00},title="Year"
	SetVariable indivfile_Y6,limits={-inf,inf,0},value= avg_start_Y
	SetVariable indivfile_Y7,pos={57.00,436.00},size={65.00,18.00},title="Month"
	SetVariable indivfile_Y7,limits={-inf,inf,0},value= avg_start_Mon
	SetVariable indivfile_Y8,pos={56.00,459.00},size={65.00,18.00},title="Day"
	SetVariable indivfile_Y8,limits={-inf,inf,0},value= avg_start_D
	SetVariable indivfile_Y9,pos={145.00,435.00},size={65.00,18.00},title="Minute"
	SetVariable indivfile_Y9,limits={-inf,inf,0},value= avg_start_Min
	SetVariable indivfile_Y0,pos={145.00,413.00},size={65.00,18.00},title="Hour"
	SetVariable indivfile_Y0,limits={-inf,inf,0},value= avg_start_H
	SetVariable indivfile_Y06,pos={145.00,456.00},size={65.00,18.00},title="Second"
	SetVariable indivfile_Y06,limits={-inf,inf,0},value= avg_start_S
	SetVariable indivfile_Y07,pos={268.00,417.00},size={65.00,18.00},title="Year"
	SetVariable indivfile_Y07,limits={-inf,inf,0},value= avg_stop_Y
	SetVariable indivfile_Y08,pos={273.00,439.00},size={65.00,18.00},title="Month"
	SetVariable indivfile_Y08,limits={-inf,inf,0},value= avg_stop_Mon
	SetVariable indivfile_Y09,pos={271.00,461.00},size={65.00,18.00},title="Day"
	SetVariable indivfile_Y09,limits={-inf,inf,0},value= avg_stop_D
	SetVariable indivfile_Y10,pos={350.00,437.00},size={65.00,18.00},title="Minute"
	SetVariable indivfile_Y10,limits={-inf,inf,0},value= avg_stop_Min
	SetVariable indivfile_Y01,pos={350.00,415.00},size={65.00,18.00},title="Hour"
	SetVariable indivfile_Y01,limits={-inf,inf,0},value= avg_stop_H
	SetVariable indivfile_Y11,pos={350.00,458.00},size={65.00,18.00},title="Second"
	SetVariable indivfile_Y11,limits={-inf,inf,0},value= avg_stop_S
	Button button0,pos={458.00,419.00},size={149.00,53.00},proc=IrregularTime_Avg_button,title="Find Irregular Time \r Average Size Distribution"
	Button button0,labelBack=(49151,65535,65535),fColor=(49151,65535,65535)
	Button button1,pos={629.00,393.00},size={149.00,53.00},proc=IrregularTime_HeatMap_button,title="Make Irregular Time \r Heat Map"
	Button button1,labelBack=(49151,65535,65535),fColor=(49151,65535,65535)
	Button MakeICARTTTable,pos={186.00,685.00},size={150.00,20.00},proc=MakeICARTTTable_button,title="Make ICARTT Table"
	Button process_databutt1,pos={18.00,162.00},size={252.00,48.00},proc=LoadMultipleFiles_Button,title="Load and Process All \rFiles in A Folder"
	Button process_databutt1,help={"This button will allow the user to load in the datafile that will be analyzed."}
	Button process_databutt1,fSize=20
	SetVariable indivfile_Y12,pos={387.00,671.00},size={65.00,18.00},title="Year"
	SetVariable indivfile_Y12,limits={-inf,inf,0},value= root:ICARTTwaves:ICARTTstart_Y
	SetVariable indivfile_Y13,pos={388.00,690.00},size={65.00,18.00},title="Month"
	SetVariable indivfile_Y13,limits={-inf,inf,0},value= root:ICARTTwaves:ICARTTstart_M
	SetVariable indivfile_Y14,pos={387.00,714.00},size={65.00,18.00},title="Day"
	SetVariable indivfile_Y14,limits={-inf,inf,0},value= root:ICARTTwaves:ICARTTstart_D
	SetVariable indivfile_Y15,pos={476.00,690.00},size={65.00,18.00},title="Month"
	SetVariable indivfile_Y15,limits={-inf,inf,0},value= root:ICARTTwaves:ICARTTstop_M
	SetVariable indivfile_Y02,pos={476.00,668.00},size={65.00,18.00},title="Year"
	SetVariable indivfile_Y02,limits={-inf,inf,0},value= root:ICARTTwaves:ICARTTstop_Y
	SetVariable indivfile_Y16,pos={476.00,711.00},size={65.00,18.00},title="Day"
	SetVariable indivfile_Y16,limits={-inf,inf,0},value= root:ICARTTwaves:ICARTTstop_D
	Button TrimTable,pos={578.00,671.00},size={132.00,34.00},proc=TrimTable_Button,title="Trim ICARTT Table"
	Button InitializeICARTT,pos={26.00,683.00},size={150.00,20.00},proc=InitializeICARTT_button,title="Initalize ICARTT section"
	SetVariable Interval,pos={469.00,383.00},size={127.00,33.00},bodyWidth=21,title="\\JRPlot every nth scan\rinterval:"
	SetVariable Interval,limits={-inf,inf,0},value= Interval
	Slider slider0,pos={56.00,37.00},size={157.00,45.00}
	Slider slider0,limits={0,2,1},variable= SoftwareVersion
	Slider slider0,userTicks={VersionTypes,VersionNames}
	Button Kill_All_Data,pos={591.00,174.00},size={125.00,44.00},proc=KillAllData_button,title="Kill All Data"
	Button Kill_All_Data,help={"Kills All Data in the file"}
	ToolsGrid visible=1
EndMacro

//Process_data parameters and function


function LoadOneFile_Button(ba):ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			gdatanumb() 
		case 2:
			break
		endswitch
end

//function process_data_for_button()
//	setdatafolder root:
//	
//	//Delete Previous Graphs and Tables
//	killwindow/Z Exportcsv_Table
//	killwindow/Z Graph1
//	killwindow/Z Graph0
//	killwindow/Z Aim_Igor_Difference
//	killwindow/Z SMPS_TConc_Stats_Table
//
//	//Load and process data	
//	gdatanumb() 
//
//	setdatafolder root:
//		
//end

//Help button

function help_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			help_button_for_button()
		case 2:
			break
		endswitch
end

function help_button_for_button()
	string SMPSBaseName= UniqueName("SMPS_Data_Processor_Help", 10, 0) 
	NewPanel /K=1 /EXT=0 /HOST=SMPS_Data_Processor  /N=SMPS_Data_Processor_Help /W=(0, 0, 0.86, 0.67)
	NewNotebook /HOST=# /N=$SMPSBaseName /F=0 /K=1 /OPTS=(0^1 + 0^2 + 0^3)  /W=(0,0,1,1)
	Notebook # text="This is the window generated by activating the SMPS_Data_Processor help button\r"
	Notebook # text="\r"
	Notebook # text="The SMPS_Data_Processor is able to take a text file that is generated by the\r"
	Notebook # text="	AIM V10.3 software and process it, allowing a time series to be created for the\r"
	Notebook # text="	scans taken within that one .TIM file.\r"
	Notebook # text="\r"
	Notebook # text="There is a couple things that have to be done in order to process this file:\r"
	Notebook # text="1. The exported textfile from the AIM software must be exported with either\r"
	Notebook # text="	mass or number dW/dlogDp, be in the comma delimited format, and be in the\r"
	Notebook # text="	row orientation. The raw data must be unchecked and the date format must\r"
	Notebook # text="	be in YYYY/MM/DD. The exported number format must be in decimal point and\r"
	Notebook # text="	for something with many scans the checkmarked box of 'Export all Channels'\r"
	Notebook # text="	must be checked.\r"
	Notebook # text="\r"
	Notebook # text="2. The generated text file from the AIM software must have the 'date' parameter\r"
	Notebook # text="	changed to be 'date_' as if the parameter is loaded in as 'date' it will conflict\r"
	Notebook # text="	with the date function in igor. // Fixed Feb 2, 2024, by LG \r"
	Notebook # text="\r"
	Notebook # text="To load in data, click on the 'Get Parameters of File' button. This will pop up a\r"
	Notebook # text="	menu for you to input the parameters of the file that you are seeking to analyze\r"
	Notebook # text="\r"
	Notebook # text="Then, click on the 'Process Data' button. This will analzye the file with the given\r"
	Notebook # text="	parameters and generate a couple of tables and graphs. In addition the code will\r"
	Notebook # text="	automatically export an excel csv file of the all of the scans time series in a\r"
	Notebook # text="	date that can be read by excel. The code will also automatically create and export\r"
	Notebook # text="	a picture of the time series.\r"
	Notebook # text="\r"
	Notebook # text="Once the file has been processed a new data folder will be created that holds all of the\r"
	Notebook # text="	waves that pertain to that file. Before processing a new file you must rename that\r"
	Notebook # text="	datafolder with an appropriate name or else the loading in of a new file will result\r"
	Notebook # text="	in an error. Remember to update your parameters as well before you load in a new file.\r"
	Notebook # text="\r"
	Notebook # text="	The tables and graphs that are generated are as follows:\r"
	Notebook # text="	A. Exportcsv_Table\r"
	Notebook # text="		This table contains the datetime that makes sense on excel as well as total conc\r"
	Notebook # text="		whether that be mass or number. This is what is exported to excel.\r"
	Notebook # text="\r"
	Notebook # text="	B. Graph1. NConc_Total vs datetimewave\r"
	Notebook # text="		This graph shows the time series of total number concentration vs time for both\r"
	Notebook # text="		the Igor generated Tseries of the data as well as the SMPS's time series.\r"
	Notebook # text="		Unless there is something wrong, these should both match up pretty well with\r"
	Notebook # text="		each other (within 2% at least)\r"
	Notebook # text="\r"
	Notebook # text="	C. AIM_Igor_Difference\r"
	Notebook # text="		This table shows the waves that are used in Graph1. We have the timeseries of both\r"
	Notebook # text="		Igor and SMPS analzyed data and a wave showing the difference.\r"
	Notebook # text="\r"
	Notebook # text="	D. SMPS_TConc_Stats_Table\r"
	Notebook # text="		This table shows the stats ran on the NConc wave (if you are looking at number conc.\r"
	Notebook # text="\r"
	Notebook # text="	E. Graph0. NConc_Total vs datetimewave\r"
	Notebook # text="		This graph is the one that is exported as a .jpg by the code and it the time series of\r"
	Notebook # text="		The scan that is analzyed by the data processor.\r"
	Notebook # text="\r"
	Notebook # text="	The cummulative work section allows you to click on buttons that do a step by step concatenation\r"
	Notebook # text="		of either number or mass concentration waves. These waves will go to the 'concatenated_wave_mass'\r"
	Notebook # text="		or the 'concatenated_wave_number' folder. Please ensure you do not delete any of the folders\r"
	Notebook # text="		already found in the data browser. The code relies on them being there.\r"
	Notebook # text="		The Hourly Average work section allows you to find the hourly averages of the concatenated\r"
	Notebook # text="		waves that you made previously and then allows you to expoer an excel readable cummulative\r"
	Notebook # text="		and hourly averaged time series.\r"
	Notebook # text="\r"
	Notebook # text="Possible Errors when running the code\r"
	Notebook # text="This code has been changed a bit on account of the SMPS/AIM software naming things differently.\r"
	Notebook # text="	The code operates by identifying the parameters names given by the AIM software.\r"
	Notebook # text="	There was a point at which I had to change the name of a parameter because\r"
	Notebook # text="	it was magically different than before one day. Not sure why, but it is.\r"
	Notebook # text="	In the future maybe I can look at changing the code to help with this. \r"
	Notebook # text="	This is found in the code at the function 'seenumbdiff and I have some lines \r"
	Notebook # text="	explaining my confusion. If given any trouble in the future with this and \r"
	Notebook # text="	the error is here, the solution will be to impliment the correct name throughout the code.\r"
	Notebook # text="	This can be found by searching for the term: CHANGE in the procedure file. Replace as\r"
	Notebook # text="	needed\r"
	Notebook # text="\r"
	Notebook # text="The way that I have the code set up to extract the diameters, there is a limitation on the\r"
	Notebook # text="	max diameter; it can't be in the tens, which shouldnt be a problem but it is technically a\r"
	Notebook # text="	limitation of the code."
	Notebook # text="\r"
	Notebook # text="I am sure there are others that I am missing. Feel free to let me know or fix them yourself\r"
	Notebook # text="and then let me know :)\r"
	Notebook # text="For any additional questions or comments please contact Adam.De_Groodt@colostate.edu\r"
	Notebook # text="\r"
	Notebook # text="A final thing to note is that as I wrote this I am currently very new to coding in general.\r"
	Notebook # text="	If you are an experienced coder and this code seems sloppy or like there is a better\r"
	Notebook # text="	way to write it please feel free to duplicate it and make any tweaks that you want!\r"
	Notebook # text="If you are seeing this, scroll to the top!\r"
	
	
	

end

//////////////////////////////////////////////
//////Functions that get the data/////////////
//////////////////////////////////////////////


// 20240315 AJD: Implimentation of checkboxes to export files and location of exported files


Function Export_CheckProc(cba) : CheckBoxControl
    STRUCT WMCheckboxAction &cba

    switch( cba.eventCode )
        case 2: // mouse up
            Variable checked_CSV_Export_Individual = cba.checked
            if (checked_CSV_Export_Individual)
         			print "Graphs and CSV files will be exported when data is loaded"
            endif
            break
        case -1: // control being killed
        		print "Graphs and CSV files will not be exported when data is loaded"
            break
    endswitch

    return 0
End

Function Create_Symbolic_Path_for_Export_checkboxProc(cba) : CheckBoxControl
    STRUCT WMCheckboxAction &cba

    switch( cba.eventCode )
        case 2: // mouse up
            Variable checked_symbolicpath = cba.checked
            if (checked_symbolicpath)
            endif
            break
        case -1: // control being killed
        		
            break
    endswitch

    return 0
End

function gdatanumb()  // Load onefile files


	//Check to see if checkbox is checked or not

	//Acess the Checkbox for Exportation
	Controlinfo/W=SMPS_Data_Processor Export_Check	

	//Set up a variable to verify at the end of the gdatanumb() function
	variable Export_CSV

	//Check the value of V_Value that controlinfo will generate to see if the checkbox is checked or unchecked
	if(V_Value==1)
		Export_CSV = 1
	elseif(V_Value==0)
		Export_CSV = 0
	Endif
	
	//Make the Symbolic_Path for gdatanumb() always equal to zero 
	variable Symbolic_Path = 0
	string S_Path = "N/A"
	
	variable f=0
   string fname            
       
   variable refNum    

	//Open up the file
	Open/r refnum as ""
	if(refnum == 0) //If nothing is opened then quit out
		return -1
	endif
		
	//Finds and stores date and time of first datapoint. This time and date are used to name the datafolder and otherwise identify the data. 
	
	variable yearv, monthv, dayv, timestartHHv,timestartMMv,timestartSSv, scannum
	string therest
   NVAR densityconv = root:density
	
	//Finds the first line of data (26 for v10.3 Nano and regular SMPS)
	Variable lineNumber = 0
	String firstdataline
	NVAR SoftwareVersion = root:softwareversion
	
	Grep/list/e=("Sample #")  s_Filename //Find the the variable names line in the code
		If (V_startParagraph == -1)
			Grep/list/e=("Scan Number")  s_Filename //AIM 11 variable name
			Grep/e=("Scan Number")  s_Filename //AIM 11 variable name
		Endif
	variable NameLine = V_startParagraph //NameLine is line number of the line containing the variable list
		
	do
		String tmpData
        FReadLine refnum, tmpData
        if (strlen(tmpData) == 0)
            return -1           // Error - end of file
        endif
        
        if (lineNumber == (NameLine+1))  // The first row of data is one line below the name list
            firstdataline = tmpData  	
		   		
            if (softwareversion == 0 || softwareversion == 1) // DDMMYYYY
           		sscanf firstdataline, "%d,%d%*[/]%d%*[/]%d%*[, ]%d%*[:]%d%*[:]%d%*[,]%s", scannum, dayv, monthv,yearv,timestartHHv,timestartMMv,timestartSSv, therest
            elseif (softwareversion == 2) // YYYYMMDD
            		sscanf firstdataline, "%i,%d%*[/]%d%*[/]%d%*[,]%d%*[:]%d%*[:]%d%*[,]%s", scannum, yearv, monthv, dayv,timestartHHv,timestartMMv,timestartSSv, therest
            endif
            
            break  //once we reach line with the first line of data, the dowhile loop stops
        endif
        lineNumber += 1
    while(1)   
   
	//Some of the code needs the date and time information as strings, so we make them here
	string yearstr,monthstr,daystr, timestartstr,datafoldername
	
	yearstr = num2str(yearv)
	monthstr = num2str(monthv)
	daystr = num2str(dayv)
	timestartstr = num2str(timestartHHv)+"_"+num2str(timestartMMv)+"_"+num2str(timestartSSv)
	
	//Set the datafolder name as Y_M_D_H_M_S_Numb. Leading zeros are not included. Should they be?
	datafoldername = num2str(yearv)+"_"+num2str(monthv)+"_"+num2str(dayv)+"_"+num2str(timestartHHv)+"_"+num2str(timestartMMv)+"_"+num2str(timestartSSv)
       
	Close refNum //Closes all files opened
	
	//Fix the variable names strings to play nice with Igor conventions
	String lnames
	lnames = ReplaceString(";",s_Value,"") // AIM 11 has extra semicolons that mess things up!
	lnames = ReplaceString(",",s_Value,";") //Igor functions like working with semicolons (;) but not commas (,) (see help for ItemsInList)
	lnames = replacestring(" ",lnames,"") //remove spaces from variable names; fixes concatenate error we were seeing earlier. 
	lnames = replacestring("date_",lnames,"date") //to handle FROG and FROGSICLE data where an underscore was added by hand
	lnames = replacestring("date",lnames,"DateSMPS") //replace variable name "date" with "DateSMPS" to avoid conflict with Igor date   //This is a problem for AIM 11
	
	
	//Make the string that holds the variable names, so that when the file is loaded, we have specified the names of the waves
	String columninfostring = ""
	int nnames = ItemsInlist(lnames)
	int i
	for (i=0;i<nnames;i+=1) // create a for loop to update the columninfo names
		String name = StringfromList(i,lnames) //Take a string from the list lnames at index i 
		columninfostring += "N='"+name+"';" // Update the name to be N (name) = + the string at that index + a semicolon (;) in order for igor to be kind
	endfor 
	
	//We want to save the data from each file in its own datafolder (named Y_M_D_H_M_S_Numb) Leading zeros are not included. Should they be?
	setdatafolder root:Number_Concentration
	newdataFolder/S $datafoldername+"_Numb"
	
	//Load the data from the file we already found with the dialog
	
	if (softwareversion == 0 || softwareversion == 1) // DDMMYYYY
		Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/V={"\t,"," $",1,0} S_filename
	elseif (softwareversion == 2) // YYYYMMDD
		Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/R={English,2,2,2,2,"Year/Month/DayOfMonth",40}/A s_filename
   endif
	
	//Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/R={English,2,2,2,2,"Year/Month/DayOfMonth",40}/A s_filename
	//Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/P=cgms S_filename  //AIM 10
	//Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/P=cgms/V={"\t,"," $",1,0} S_filename  //AIM 11
	//Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A S_filename
	
	int k
	make/t/n=(nnames) impar
	for (k=0;k<nnames;k+=1) //Create a for loop to zap the incoming waves if they do not have data. AIM generates NaN waves. Is there a way to prevent this? If you dont export all channels, 
		string currwave = stringfromlist(k,lnames)
				
		if (waveexists($currwave) == 1)
			wavetransform zapnans $currwave
			if (dimsize($currwave, 0) == 0)
			Killwaves $currwave
			else
			impar[k] = currwave
			endif
		endif
	endfor
	
	//Convert the text wave to a number wave; retaining all of the numeric values and gettting rid of all the letter values
	//wave Impar_numb
	Tw2Nw(impar)
	wave Impar_numb
	wavetransform zapnans :Impar_Numb
	
	variable maxdia,mindia,maxdiaidx,mindiaidx

	maxdia = wavemax(Impar_Numb)	
	mindia = wavemin(Impar_Numb)
	maxdiaidx = strsearch(lnames,num2str(maxdia),0)
	mindiaidx = strsearch(lnames,num2str(mindia),0)
			
	// The following assumes you have no gaps in data (13.6 is filled for ALL Scans)		
	string binnames
	
	
	//LG. I fixed this so that the code can read nano bins (that end in 68.x nm) or regular bins (that end in 700.x nm). 
	if (maxdia <10)
			binnames = lnames[mindiaidx,maxdiaidx+3]
		elseif (maxdia <100)
			binnames = lnames[mindiaidx,maxdiaidx+4]
		elseif (maxdia <1000)
			binnames = lnames[mindiaidx,maxdiaidx+5] 
		else
		Print "Error: Largest bin too large"
	Endif 
	
	if (stringmatch(binnames[strlen(binnames)-1], "!;"))  // Add for AIM 11 
		binnames = binnames + ";"
	endif
	
	Wave/t w = ListtoTextWave(binnames,";")
	variable numofbins = numpnts(w)
	make/o/n=(numofbins) diam
	
	Variable j
	For(j=0;j<(numofbins);j++)
		diam[j] = str2num(w[j])
	Endfor
	

	Wave NConc
	concatenate binnames, NConc 	//szdata error puts you here to fix; this error id likley due to the 710.5 diameter not having enough points as the rest of the wave
	

	//Get rid of the temporary concatenation list binnames
	
	for(j=0;j<(numofbins);j++)
		String Wvname = stringfromlist(j,binnames)
		Killwaves/Z $Wvname
	Endfor

	//Fix naming for the Total Concentration Variable
	wave  NConc_total,Datetimewave, 'TotalConc.(#/cm)','TotalConc.(#/cm3)',	'TotalConc.(#/cm³)', 'TotalConcentration(#/cmÂ³)'	//Put all here
	if(waveexists('TotalConc.(#/cm)')==1)
		rename 'TotalConc.(#/cm)', 'TotalConc.(#/cm3)'	
	elseif (waveexists('TotalConc.(#/cm³)')==1)
		rename 'TotalConc.(#/cm³)', 'TotalConc.(#/cm3)'
	elseif (waveexists('TotalConcentration(#/cmÂ³)')==1)
		rename 'TotalConcentration(#/cmÂ³)' 'TotalConc.(#/cm3)'
	else
	endif	

	//Adds date and time waves to make one "date and time" wave - LG
	
	Wave StartTime, DateSMPSTimeSampleStart, DateSMPS
	If (waveexists(StartTime)==1)
		Wave DateSMPS, StartTime
		Duplicate/O DateSMPS datetimewave
		datetimewave = DateSMPS + StartTime
	Elseif(waveexists(DateSMPSTimeSampleStart)==1)
		Duplicate/O DateSMPSTimeSampleStart datetimewave
		Killwaves DateSMPSTimeSampleStart
	Endif	
	setscale d, 0,0, "dat", datetimewave
		
	//Impliments the startstopwaves function
	Wave datetimewave,'ScanTime(s)'
		If (waveexists('ScanTime(s)')==1)
			startstopwaves(datetimewave, 'ScanTime(s)')
		Else
			Wave'DMAatHighVoltage(THIGH)(s)','DMAatLowVoltage(TLOW)(s)','DMAVRampingUp(TUP)(s)','DMAVRampingDown(TDOWN)(s)'
			Duplicate/O 'DMAVRampingUp(TUP)(s)' 'ScanTime(s)'
			'ScanTime(s)' = 'DMAatHighVoltage(THIGH)(s)' + 'DMAatLowVoltage(TLOW)(s)' + 'DMAVRampingUp(TUP)(s)' + 'DMAVRampingDown(TDOWN)(s)'
			startstopwaves(datetimewave, 'ScanTime(s)')
		Endif
	
	//Impliments the number binning/dlogdp calculations
	Wave NConc
	Tconc(NConc,mindia,maxdia)
	wave NConc_Total		//AJD 20240315: Putting this here so other functions can call it (Exportation functions) (probably a better way to do this but it works so...)
	//Impliments the transformation of Nconc to Volume and SA
	NconctoVandSA(densityconv)
	
	//Impliments the Mass binning/dlogp calculations
	wave MConc, binwidth,dlogDp, diam
	
	Tconcmass(MConc,mindia,maxdia, diam, binwidth, dlogDp)
	wave MConc_Total

// Ensure that an excel friendly datetimewave is created
	wave Excel_Datetime
	Igor2Excel_DateTime(Datetimewave, NConc_Total,MConc_Total)
// If the Exportation Checkbox is checked, export the desired figures and CSV files

	if(Export_CSV==1)
		//Igor2Excel_DateTime(Datetimewave, NConc_total,MConc_Total)
		exportcsv(yearstr, monthstr,daystr,timestartstr,Symbolic_Path)
	Endif
	//Impliments the graphing for number
	maketseriesgraphnumb(yearstr, monthstr, daystr, timestartstr,datafoldername,Export_CSV,Symbolic_Path)
	seediffnumb(datafoldername)

	//Impliments the graphing for mass; since mass isn't directly being imported there is nothing to compare it to AIM wise so that function is not called here. 
	massmaketseriesgraph(yearstr, monthstr, daystr, timestartstr,Export_CSV,Symbolic_Path)


	
////Move mass information to the Mass folder					
	wave MConc_Total, MConc_Total_Stats, datetimewave, diam
	newdatafolder/S root:Mass_Concentration:$datafoldername+"_Mass"
	DFREF massDF = root:Mass_Concentration:$datafoldername+"_Mass"
	movewave MConc,massDF:MConc
	movewave MConc_Total,massDF:MConc_Total
	movewave MConc_Total_Stats,massDF:MConc_Total_Stats
	duplicate datetimewave, massDF: datetimewave
	duplicate diam, massDF:diam

	Setdatafolder root:
	
	
End


Function LoadMultipleFiles_Button(ba):ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			setdatafolder root:
			gdatanumb1() 
		case 2:
			break
		endswitch
End

Function gdatanumb1()  /// Load multiple files
	NVAR softwareversion = root:softwareversion
	
	string file_ext
	 if (softwareversion == 1) // DDMMYYYY
		file_ext = ".csv" //AIM 11
    elseif (softwareversion ==0 || softwareversion == 2) // YYYYMMDD
		file_ext = ".txt" //AIM 10 and Willis box
    endif
	
	//Check to see if checkbox is checked or not

	//Acess the Checkbox
	Controlinfo/W=SMPS_Data_Processor Export_Check	

	//Set up a variable to verify at the end of the gdatanumb() function
	variable Export_CSV

	//Check the value of V_Value that controlinfo will generate to see if the checkbox is checked or unchecked
	if(V_Value==1)
		Export_CSV = 1
	elseif(V_Value==0)
		Export_CSV = 0
	Endif
	
	//Acess Checkbox for Symbolic Path
	ControlInfo/W=SMPS_Data_Processor Create_Symbolic_Path_for_Export_checkbox
	
	//Setup a variable to determine if the user wants to create a symbolic path
	Variable Symbolic_Path
	String S_Path_Save
	string testpath
	
	//Check the value of V_Value that ControlInfo will generate to see if the checkbox is checked or unchecked
	if(V_Value==1)
		Symbolic_Path = 1
	 	variable pathconfirmation
		prompt  pathconfirmation, "First, you will select a folder to send the data too. Once selected, a second popup will be to select where the data that needs to be processed is., input '1' to continue."
		doprompt "Select Folder to Send Data too.", pathconfirmation
		getfilefolderinfo/D
		newpath/O Put_Data_Here s_path
		S_path_Save = S_Path
	elseif(V_Value==0)
		Symbolic_Path=0	
	endif

	
   variable f=0
   string fname            
       
   //Ask the user to identify a folder on the computer
   getfilefolderinfo/D
   
   //Store the folder that the user has selected as a new symbolic path in IGOR called cgms
   newpath/O cgms S_path

	//Create a list of all files that are .txt files in the folder. -1 parameter addresses all files.
	string filelist= indexedfile(cgms,-1,file_ext)
   
   variable refNum    
    //Begin processing the list
   do
        //store the ith name in the list into wname.
      fname = stringfromlist(f,filelist)

		Open/R/P=cgms/Z refNum as fname
		Variable err = V_flag
			if (err == -1)
			Print "DemoOpen cancelled by user."
			return -1
		endif
	
		if (err != 0)
			DoAlert 0, "Error in DemoOpen"
			return err
		endif
			
	//Finds and stores date and time of first datapoint. This time and date are used to name the datafolder and otherwise identify the data. 
	
	variable yearv, monthv, dayv, timestartHHv,timestartMMv,timestartSSv, scannum
	string therest
   NVAR densityconv = root:density
	
	//Finds the first line of data (26 for v10.3 Nano and regular SMPS)
	Variable lineNumber = 0
	String firstdataline
	
	Grep/list/e=("Sample #")  s_Filename //Find the the variable names line in the code AIM10
		If (V_startParagraph == -1)
			Grep/list/e=("Scan Number")  s_Filename //AIM 11 variable name
			Grep/e=("Scan Number")  s_Filename //AIM 11 variable name
		Endif
	variable NameLine = V_startParagraph //NameLine is line number of the line containing the variable list
		
	do
		String tmpData
        FReadLine refnum, tmpData
        if (strlen(tmpData) == 0)
            return -1           // Error - end of file
        endif
        if (lineNumber == (NameLine+1))  // The first row of data is one line below the name list
            firstdataline = tmpData  	
           
            if (softwareversion == 0 || softwareversion == 1) // DDMMYYYY
           		sscanf firstdataline, "%d,%d%*[/]%d%*[/]%d%*[, ]%d%*[:]%d%*[:]%d%*[,]%s", scannum, dayv, monthv,yearv,timestartHHv,timestartMMv,timestartSSv, therest
            elseif (softwareversion == 2) // YYYYMMDD
            		sscanf firstdataline, "%d,%d%*[/]%d%*[/]%d%*[,]%d%*[:]%d%*[:]%d%*[,]%s", scannum, yearv, monthv, dayv,timestartHHv,timestartMMv,timestartSSv, therest
            endif

            break  //once we reach line with the first line of data, the dowhile loop stops
        endif
        lineNumber += 1
    while(1)   
   
	//Some of the code needs the date and time information as strings, so we make them here
	string yearstr,monthstr,daystr, timestartstr,datafoldername
	
	yearstr = num2str(yearv)
	monthstr = num2str(monthv)
	daystr = num2str(dayv)
	timestartstr = num2str(timestartHHv)+"_"+num2str(timestartMMv)+"_"+num2str(timestartSSv)
	
	//Set the datafolder name as Y_M_D_H_M_S_Numb. Leading zeros are not included. Should they be?
	datafoldername = num2str(yearv)+"_"+num2str(monthv)+"_"+num2str(dayv)+"_"+num2str(timestartHHv)+"_"+num2str(timestartMMv)+"_"+num2str(timestartSSv)
       
	Close refNum //Closes all files opened
	
	//Fix the variable names strings to play nice with Igor conventions
	String lnames
	lnames = ReplaceString(";",s_Value,"") // AIM 11 has extra semicolons that mess things up!
	lnames = ReplaceString(",",s_Value,";") //Igor functions like working with semicolons (;) but not commas (,) (see help for ItemsInList)
	lnames = replacestring(" ",lnames,"") //remove spaces from variable names; fixes concatenate error we were seeing earlier. 
	lnames = replacestring("date",lnames,"DateSMPS") //replace variable name "date" with "DateSMPS" to avoid conflict with Igor date   
		
	//Make the string that holds the variable names, so that when the file is loaded, we have specified the names of the waves
	String columninfostring = ""
	int nnames = ItemsInlist(lnames)
	int i
	for (i=0;i<nnames;i+=1) // create a for loop to update the columninfo names
		String name = StringfromList(i,lnames) //Take a string from the list lnames at index i 
		columninfostring += "N='"+name+"';" // Update the name to be N (name) = + the string at that index + a semicolon (;) in order for igor to be kind
	endfor 
	
	//We want to save the data from each file in its own datafolder (named Y_M_D_H_M_S_Numb) Leading zeros are not included. Should they be?
	setdatafolder root:Number_Concentration
	newdataFolder/S $datafoldername+"_Numb"
	DFREF numdfr = GetDataFolderDFR()
	
	//Load the data from the file we already found with the dialog
	
	if (softwareversion == 0 || softwareversion == 1) // DDMMYYYY
		Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/V={"\t,"," $",1,0} S_filename
	elseif (softwareversion == 2) // YYYYMMDD
		Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/R={English,2,2,2,2,"Year/Month/DayOfMonth",40}/A s_filename
   endif
	
	int k
	make/t/n=(nnames) impar
	for (k=0;k<nnames;k+=1) //Create a for loop to zap the incoming waves if they do not have data. AIM generates NaN waves. Is there a way to prevent this? If you dont export all channels, 
		string currwave = stringfromlist(k,lnames)
				
		if (waveexists($currwave) == 1)
			wavetransform zapnans $currwave
			if (dimsize($currwave, 0) == 0)
			Killwaves $currwave
			else
			impar[k] = currwave
			endif
		endif
	endfor
	
	//Convert the text wave to a number wave; retaining all of the numeric values and gettting rid of all the letter values
	//wave Impar_numb
	Tw2Nw(impar)
	wave Impar_numb
	wavetransform zapnans :Impar_Numb
	
	variable maxdia,mindia,maxdiaidx,mindiaidx

	maxdia = wavemax(Impar_Numb)	
	mindia = wavemin(Impar_Numb)
	maxdiaidx = strsearch(lnames,num2str(maxdia),0)
	mindiaidx = strsearch(lnames,num2str(mindia),0)
			
	// The following assumes you have no gaps in data (13.6 is filled for ALL Scans)		
	string binnames
	
	
	//LG. I fixed this so that the code can read nano bins (that end in 68.x nm) or regular bins (that end in 700.x nm). 
	if (maxdia <10)
			binnames = lnames[mindiaidx,maxdiaidx+3]
		elseif (maxdia <100)
			binnames = lnames[mindiaidx,maxdiaidx+4]
		elseif (maxdia <1000)
			binnames = lnames[mindiaidx,maxdiaidx+5] 
		else
		Print "Error: Largest bin too large"
	Endif 
	
	if (stringmatch(binnames[strlen(binnames)-1], "!;"))  // Add for AIM 11 
		binnames = binnames + ";"
	endif
	
	Wave/t w = ListtoTextWave(binnames,";")
	variable numofbins = numpnts(w)
	make/o/n=(numofbins) diam
	
	Variable j
	For(j=0;j<(numofbins);j++)
		diam[j] = str2num(w[j])
	Endfor
	
	Wave NConc
	concatenate binnames, NConc 
	
	//Get rid of the temporary concatenation list binnames
	
	for(j=0;j<(numofbins);j++)
		String Wvname = stringfromlist(j,binnames)
		Killwaves/Z $Wvname
	Endfor
	
	//Add date and time waves to make one "date and time" wave - LG
	
	Wave StartTime, DateSMPSTimeSampleStart, DateSMPS
	If (waveexists(StartTime)==1) //AIM 10
		Wave DateSMPS, StartTime
		Make/D/N=(numpnts(DateSMPS)) datetimewave
		Wave datetimewave
		datetimewave = DateSMPS + StartTime
	Elseif(waveexists(DateSMPSTimeSampleStart)==1) //AIM 11
		Make/D/N=(numpnts(DateSMPSTimeSampleStart)) datetimewave
		Wave datetimewave
		datetimewave= DateSMPSTimeSampleStart
		Killwaves DateSMPSTimeSampleStart
	Endif
	setscale d, 0,0, "dat", datetimewave
			
	//Make SMPS start and stop times

	Wave'ScanTime(s)'
		If (waveexists('ScanTime(s)')==1) //AIM 10
			startstopwaves(datetimewave, 'ScanTime(s)')
		Else //AIM11
			Wave'DMAatHighVoltage(THIGH)(s)','DMAatLowVoltage(TLOW)(s)','DMAVRampingUp(TUP)(s)','DMAVRampingDown(TDOWN)(s)'
			Make/N=(numpnts('DMAVRampingUp(TUP)(s)')) 'ScanTime(s)'
			'ScanTime(s)' = 'DMAatHighVoltage(THIGH)(s)' + 'DMAatLowVoltage(TLOW)(s)' + 'DMAVRampingUp(TUP)(s)' + 'DMAVRampingDown(TDOWN)(s)'
			startstopwaves(datetimewave, 'ScanTime(s)')
		Endif
	
	//Fix naming for the Total Concentration Variable
	wave  NConc_total,Datetimewave, 'TotalConc.(#/cm)','TotalConc.(#/cm3)',	'TotalConc.(#/cm³)', 'TotalConcentration(#/cmÂ³)'	//Put all here
	if(waveexists('TotalConc.(#/cm)')==1)
		rename 'TotalConc.(#/cm)', 'TotalConc.(#/cm3)'	
	elseif (waveexists('TotalConc.(#/cm³)')==1)
		rename 'TotalConc.(#/cm³)', 'TotalConc.(#/cm3)'
	elseif (waveexists('TotalConcentration(#/cmÂ³)')==1)
		rename 'TotalConcentration(#/cmÂ³)' 'TotalConc.(#/cm3)'
	else
	endif	
	
	//Impliments the number binning/dlogdp calculations
	Wave NConc
	Tconc(NConc,mindia,maxdia)
	wave NConc_Total		//AJD 20240315: Putting this here so other functions can call it (Exportation functions) (probably a better way to do this but it works so...)
	//Impliments the transformation of Nconc to Volume and SA
	NconctoVandSA(densityconv)
	
	//Impliments the Mass binning/dlogp calculations
	wave MConc, binwidth,dlogDp, diam
	
	Tconcmass(MConc,mindia,maxdia, diam, binwidth, dlogDp)
	wave MConc_Total

// Ensure that an excel friendly datetimewave is created
	wave Excel_Datetime
	Igor2Excel_DateTime(Datetimewave, NConc_Total,MConc_Total)
// If the Exportation Checkbox is checked, export the desired figures and CSV files

	if(Export_CSV==1)
		//Igor2Excel_DateTime(Datetimewave, NConc_total,MConc_Total)
		exportcsv(yearstr, monthstr,daystr,timestartstr,Symbolic_Path)
	Endif
	//Impliments the graphing for number
	maketseriesgraphnumb(yearstr, monthstr, daystr, timestartstr,datafoldername,Export_CSV,Symbolic_Path)
	seediffnumb(datafoldername)

	//Impliments the graphing for mass; since mass isn't directly being imported there is nothing to compare it to AIM wise so that function is not called here. 
	massmaketseriesgraph(yearstr, monthstr, daystr, timestartstr,Export_CSV,Symbolic_Path)

	
	//Move mass information to the Mass folder					
	wave MConc_Total, MConc_Total_Stats, datetimewave, diam
	newdatafolder/S root:Mass_Concentration:$datafoldername+"_Mass"
	DFREF massDF = root:Mass_Concentration:$datafoldername+"_Mass"
	movewave MConc,massDF:MConc
	movewave MConc_Total,massDF:MConc_Total
	movewave MConc_Total_Stats,massDF:MConc_Total_Stats
	duplicate datetimewave, massDF: datetimewave
	duplicate diam, massDF:diam

	Setdatafolder root:
	
	f++
	while(f<itemsinlist(filelist))
End



//////////////////////////////////////
///////Exporation Functions///////////
//////////////////////////////////////

function Igor2Excel_DateTime(Datetimewave, NConc_total,MConc_Total)	// This function will take the datetime waves produced, duplicate them and then alter those duplicated waves to a format that excel likes
	wave Datetimewave, NConc_total,MConc_Total
	
	duplicate Datetimewave, Excel_Datetime
	Excel_Datetime += (365.5*4*24*3600) //Fixed single day and 4 year offset
	Excel_Datetime/=(24*3600) //Goes from Igor Time to Excel Time
	
	edit/N=Exportcsv_Table
	appendtotable Excel_Datetime,NConc_Total,MConc_Total	//CHANGE
End

function exportcsv(yearstr, monthstr,daystr,timestartstr,Symbolic_Path)
	string yearstr, monthstr,daystr,timestartstr
	Variable Symbolic_Path
	wave  Datetimewave,Excel_Datetime,NConc_Total,MConc_Total
	
	string savename

	savename =yearstr+monthstr+daystr+"_"+timestartstr+"_Excel_Time_Series"	
	print "Name of exported CSV: "+savename
	if(Symbolic_Path==0)
		Save/J/M="\r\n"/DLIM=","/W Datetimewave,Excel_Datetime,NConc_Total,MConc_Total as savename
	elseif(Symbolic_Path==1)
		Save/P=Put_Data_Here/J/M="\r\n"/DLIM=","/W Datetimewave,Excel_Datetime,NConc_Total,MConc_Total as savename
	endif
End



//Function to go from a Textwave to a Numberwave

Function Tw2Nw(W)
Wave /T W
Variable np = numpnts(W)
Make /O /N=(np) Impar_numb
Variable x
for(x=0;x<np;x+=1)
    Impar_numb[x] = str2num(W[x])
endfor
End

Function Nw2Tw(W)
Wave W
Variable np = numpnts(W)
Make /T /O /N=(np) texttime
Variable x
for(x=0;x<np;x+=1)
    texttime[x] = num2str(W[x])
endfor
End




Function startstopwaves(datetimewave, scantime)  //datetimewave is the start time for an SMPS scan. 
	wave datetimewave, scantime
	//variable scantime //number of seconds for a scan
	Duplicate/O datetimewave SMPS_Start
	Duplicate/O datetimewave SMPS_Stop
	Duplicate/O datetimewave SMPS_MidPoint
	
	SMPS_Stop = datetimewave + scantime
	
	SMPS_MidPoint = SMPS_Start + scantime/2
	
end

Function Tconc(szdata,Dpmin,Dpmax)	//User needs to provide Dpmin and Dpmax ans szdata; for this szdata is the NConc wave created
	wave szdata
	variable Dpmin, Dpmax
	fbwidth()
	wave diam, binwidth
	variable numbins = numpnts(diam)
	
	variable minidx,maxidx
	Findlevel/P/Q diam, Dpmin //Findlevel -> searches named wave to find X value at the Y level is crossed
		if(V_Flag==1)
			minidx = 0
		else
			minidx = ceil(V_LevelX) // ceil -> returns the closest integer >= to num (in this case V_LevelX)
		endif
		
		FindLevel/P/Q diam, Dpmax
		if(v_flag==1)
			maxidx = (numpnts(diam)-1) //Might not need the -1 because I have zapped the waves
		else
			maxidx = floor(V_levelX) // floor -> returns the closest interger <= num (in this case V_levelX)
		endif
	
	//So the purpose of the above section is to scan through diam for dpmax and dpmin and then if V_flag == 1 set the index to the first or last of the wave
	//if v_flag is not 1 set the dpmin to the closest integer that is >= the level found by findlevel; dpmax set to the closest integer <= the level found by findlevel
	
	duplicate diam dlogDp
	dlogDp = NaN //This clears the wave 
	dlogDp = log(diam+0.5*binwidth) - log(diam-0.5*binwidth) // dlogDp calculation; this is expanded upon below for each diameter bin
	// dlogDp = the log value of the diameter + half of the binwidth (the upper; dlogDp,upper) - the log value of the diameter - half of the bindwith(the lower;dlogDp,lower)
	
	variable a,b
	make/FREE/N=(numbins) dL, dU
	
	for(b=0; b<numbins;b+=1)
		if (b==0)
			dL[b] = diam[b]-0.5*binwidth[b]
			dU[b] = diam[b]+0.5*binwidth[b]
		elseif (b ==(numbins-1))
			dL[b] = diam[b]-0.5*binwidth[b-1]
			dU[b] = diam[b]+0.5*binwidth[b-1]
		else
			dL[b] = diam[b]-0.5*binwidth[b-1]
			dU[b] = diam[b]+0.5*binwidth[b]
		endif
	dlogDp[b] = log(dU[b]) - log(dL[b])
	Endfor
	//So the purpose of the above section is to carry out the dlogDp calculation mentioned above but carried for each diameter bin and for
	//different cases (for example if wer are just starting out (first row) then b==0 and we would calculate dL by setting it = to our
	//diameter at [b or 0] - 0.5 * the binwidth [at 0]. We would do the dame thing for dU except +0.5*binwidth
	
	// if we are already going through the diameters then b == numbins -1 and we would do the same thing except the previous bin
	
	// otherwise (and likley for the last row/index in the loop we would only need to go back for dL but not dU
	
	variable ndata = dimsize(szdata,0)
	make/N=(ndata)/O Ctotal
	variable addnum=0, total = 0
	for(a=0;a<ndata;a+=1)
		for(b=minidx;b<=maxidx;b+=1)
			addnum = szdata[a][b]*dlogDp[b]		//If getting out of range error here then the wave is not a matrix (likely error)
			total+=addnum
		Endfor
		Ctotal[a] = total
		total = 0
		addnum = 0
	Endfor

	//So the purpose of this section is to get the total number concentration by taking the dndlogdp and muliplying by dlogp in order to get dn 
	// then you would sum up all of the dNs to get the total #/cm3 (total number concentration)
	
	String totalwavename = nameofWave(szdata)+"_Total"
	Duplicate/o Ctotal $totalwavename
	killwaves ctotal
	//So the purpose of this section is just to rename the total concentration wave to szdata_total which for me is effectivly diam_total
	
End

Function fbwidth()
	Wave diam
	Duplicate/o diam binwidth
	binwidth = NaN
	variable i
	for(i=0; i<(numpnts(binwidth)-1);i+=1)
		binwidth[i] = diam[i+1]-diam[i]
	Endfor
End

function NconctoVandSA(density)			//AJD Change 2023_12_28-> Include parameter for Density converstion (Number to mass)
	variable density
	wave Nconc, Diam
	Duplicate/o Nconc Vconc
	vconc = NaN
	
	Variable g=0, h=0
		For(h=0; h<dimsize(Vconc,0);h+=1)
			For(g=0; g<dimsize(vconc,1);g+=1)
				Vconc[h][g] = Nconc[h][g] * pi/6*diam[g]^3 * 1E-9 // units of um^3/cm^3
				variable check = diam[g]
			endfor
		endfor
		
		Duplicate/o Nconc SAConc
		SAConc = NaN
		
		for(h=0;h<dimsize(SAConc,0);h+=1)
			for(g=0;g<dimsize(SAConc,1);g+=1)
				//SAConc[h][g] = Nconc[h][g]*pi*diam[g]^2*densityconv  //LG- There shouldnt be a density term in the surface area calculation
				SAConc[h][g] = Nconc[h][g]*pi*diam[g]^2*1E-6   //units of um^2/cm^3 
			endfor
		endfor
		
		Duplicate/o Nconc MConc
		MConc = NaN
		
		for(h=0;h<dimsize(MConc,0);h+=1)
			for(g=0;g<dimsize(MConc,1);g+=1)
				MConc[h][g] = Nconc[h][g] * pi/6*diam[g]^3*1E-9*density	  // if density is g/cm, then unit is ug/m3
			endfor
		endfor
End

Function Tconcmass(MConc,Dpmin,Dpmax,diam, binwidth,dlogDp)	//User needs to provide Dpmin and Dpmax. Because this is for mass, szdata (which is number starting out is note used but MConc (with calcualted density is); for this szdata is the MConc wave created
	wave MConc, diam, binwidth,dlogDp	//szdata
	variable Dpmin, Dpmax
//	fbwidth()
//	wave diam, binwidth
	variable numbins = numpnts(diam)
	
	variable minidx,maxidx
	Findlevel/P/Q diam, Dpmin //Findlevel -> searches named wave to find X value at the Y level is crossed
		if(V_Flag==1)
			minidx = 0
		else
			minidx = ceil(V_LevelX) // ceil -> returns the closest integer >= to num (in this case V_LevelX)
		endif
		
		FindLevel/P/Q diam, Dpmax
		if(v_flag==1)
			maxidx = (numpnts(diam)-1) //Might not need the -1 because I have zapped the waves
		else
			maxidx = floor(V_levelX) // floor -> returns the closest interger <= num (in this case V_levelX)
		endif
	
	//So the purpose of the above section is to scan through diam for dpmax and dpmin and then if V_flag == 1 set the index to the first or last of the wave
	//if v_flag is not 1 set the dpmin to the closest integer that is >= the level found by findlevel; dpmax set to the closest integer <= the level found by findlevel
	
//	duplicate diam dlogDp
	dlogDp = NaN //This clears the wave 
	dlogDp = log(diam+0.5*binwidth) - log(diam-0.5*binwidth) // dlogDp calculation; this is expanded upon below for each diameter bin
	// dlogDp = the log value of the diameter + half of the binwidth (the upper; dlogDp,upper) - the log value of the diameter - half of the bindwith(the lower;dlogDp,lower)
	
	variable a,b
	make/FREE/N=(numbins) dL, dU
	
	for(b=0; b<numbins;b+=1)
		if (b==0)
			dL[b] = diam[b]-0.5*binwidth[b]
			dU[b] = diam[b]+0.5*binwidth[b]
		elseif (b ==(numbins-1))
			dL[b] = diam[b]-0.5*binwidth[b-1]
			dU[b] = diam[b]+0.5*binwidth[b-1]
		else
			dL[b] = diam[b]-0.5*binwidth[b-1]
			dU[b] = diam[b]+0.5*binwidth[b]
		endif
	dlogDp[b] = log(dU[b]) - log(dL[b])
	Endfor
	//So the purpose of the above section is to carry out the dlogDp calculation mentioned above but carried for each diameter bin and for
	//different cases (for example if wer are just starting out (first row) then b==0 and we would calculate dL by setting it = to our
	//diameter at [b or 0] - 0.5 * the binwidth [at 0]. We would do the dame thing for dU except +0.5*binwidth
	
	// if we are already going through the diameters then b == numbins -1 and we would do the same thing except the previous bin
	
	// otherwise (and likley for the last row/index in the loop we would only need to go back for dL but not dU
	
	variable ndata = dimsize(MConc,0)
	make/N=(ndata)/O Ctotal
	variable addnum=0, total = 0
	for(a=0;a<ndata;a+=1)
		for(b=minidx;b<=maxidx;b+=1)
			addnum = MConc[a][b]*dlogDp[b]
			total+=addnum
		Endfor
		Ctotal[a] = total
		total = 0
		addnum = 0
	Endfor

	//So the purpose of this section is to get the total number concentration by taking the dndlogdp and muliplying by dlogp in order to get dn 
	// then you would sum up all of the dNs to get the total #/cm3 (total number concentration)
	
	String totalwavename = nameofWave(MConc)+"_Total"
	Duplicate/o Ctotal $totalwavename
	killwaves ctotal
	//So the purpose of this section is just to rename the total concentration wave to szdata_total which for me is effectivly diam_total
END
//END MASS VERSION	

function maketseriesgraphnumb(year, month, day, timestart,datafoldername,Export_CSV,Symbolic_Path) //Generates a timeseries graph of the Aim file loaded in and provides option to save figure

	string year, month, day, timestart,datafoldername
	Variable Export_CSV,Symbolic_Path

	wave Datetimewave, NConc_Total
	
	Display Nconc_total vs Datetimewave
	Modifygraph dateInfo(bottom)={1,1,2}
	Label left "Total Number Concentration (#/cm\\S3\\M)\rdNdlogDp\\BMob\\M";DelayUpdate
	Label bottom "Time (hrs:min:sec)";Delayupdate
	TextBox/C/N=text0/A=MC/S=3/x=30/y=40 "SMPS NConc TSeries\r       "+year+"_"+month+"_"+day;delayupdate
	if(Export_CSV==1 && Symbolic_Path==0)
		SavePICT/E=-8/B=72 as "NConc_"+year+month+day+"_"+timestart
	elseif(Export_CSV==1 && Symbolic_Path==1)
		SavePICT/P=Put_Data_Here/E=-8/B=72 as "NConc_"+year+month+day+"_"+timestart
	Endif
	wavestats/W NConc_Total
   string newstatswname = nameofwave(NConc_Total)+"_Stats"
	rename M_Wavestats, $newstatswname


	
End

function seediffnumb(datafoldername) 
	string datafoldername
	
	//Create the table to see how the AIM software and our integration compare
	wave 'TotalConc.(#/cm3)', NConc_Total, Datetimewave
	make/n=(dimsize(NConc_total,0)) percent_diff
	percent_diff = ('TotalConc.(#/cm3)' - NConc_total	)/	'TotalConc.(#/cm3)'*100
	Edit/N=AIM_Igor_Difference
	appendToTable Datetimewave,NConc_total,'TotalConc.(#/cm3)', percent_diff	
	
	//Create the graph
	Display NConc_total vs Datetimewave
	appendtograph 'TotalConc.(#/cm3)' vs Datetimewave	
	Modifygraph dateInfo(bottom)={1,1,2};delayupdate
	modifygraph lsize('TotalConc.(#/cm3)')=0.01,lsize(NConc_Total)=0.01,rgb(NConc_Total)=(0,0,0);delayupdate	
	Label left "Total Number Concentration (#/cm\\S3\\M)\rdNdlogDp\\BMob\\M";DelayUpdate
	Label bottom "Time (hrs:min:sec)";Delayupdate
	TextBox/C/x=30/y=40 /N=text0/S=3/A=MC "SMPS TSeries Difference\r\n\\s(NConc_Total) Igor TSeries\r\n\\s('TotalConc.(#/cm³)') SMPS TSeries"
End



function maketseriesgraphmass(year, month, day, timestart) //Generates a timeseries graph of the Aim file loaded in

	string year, month, day, timestart

	wave datetimewave, MConc_Total
	
	Display Mconc_total vs datetimewave
	Modifygraph dateInfo(bottom)={1,1,2}
	Label left "Total Mass Concentration (µg/m\\S3\\M)\rdNdlogDp\\BMob\\M";DelayUpdate
	Label bottom "Time (hrs:min:sec)";Delayupdate
	TextBox/C/N=text0/A=MC/S=3/x=30/y=40 "SMPS MConc TSeries\r       "+year+"_"+month+"_"+day;delayupdate
	//SavePICT/E=-6/B=72 as "MConc_"+year+month+day+"_"+timestart
	wavestats/W MConc_Total
   string newstatswname = nameofwave(MConc_Total)+"_Stats"
	rename M_Wavestats, $newstatswname
	Edit 
	dowindow/C SMPS_TConc_Stats_Table_Mass
	appendtotable $newstatswname.ld
	
	
End


Function Tw2Nwmass(W)
Wave /T W
Variable np = numpnts(W)
Make /O /N=(np) Impar_mass
Variable x
for(x=0;x<np;x+=1)
    Impar_mass[x] = str2num(W[x])
endfor
End

Function Nw2Twmass(W)
Wave W
Variable np = numpnts(W)
Make /T /O /N=(np) texttime
Variable x
for(x=0;x<np;x+=1)
    texttime[x] = num2str(W[x])
endfor
End

function massmaketseriesgraph(year, month, day, timestart,Export_CSV,Symbolic_Path) //Generates a timeseries graph of the Aim file loaded in
	
	string year, month, day, timestart
	Variable Export_CSV,Symbolic_Path

	wave datetimewave, MConc_Total
	
	Display Mconc_total vs datetimewave
	Modifygraph dateInfo(bottom)={1,1,2}
	Label left "Total Mass Concentration (µg/m\\S3\\M)\rdNdlogDp\\BMob\\M";DelayUpdate
	Label bottom "Time (hrs:min:sec)";Delayupdate
	TextBox/C/N=text0/A=MC/S=3/x=30/y=40 "SMPS MConc TSeries\r       "+year+"_"+month+"_"+day;delayupdate
	if(Export_CSV==1 && Symbolic_Path==0)
		SavePICT/E=-8/B=72 as "MConc_"+year+month+day+"_"+timestart
	elseif(Export_CSV==1 && Symbolic_Path==1)
		SavePICT/P=Put_Data_Here/E=-8/B=72 as "MConc_"+year+month+day+"_"+timestart
	Endif
	wavestats/W MConc_Total
   string newstatswname = nameofwave(MConc_Total)+"_Stats"
	rename M_Wavestats, $newstatswname
//	Edit 
//	dowindow/R/C SMPS_TConc_Stats_Table_Mass
//	appendtotable $newstatswname.ld
	
	
End

function seediffmass(datafoldername) //Allows the creation of a table that appends the DateTimewave as well as the the AIM #conc and SMPS generated Nconc; does this on a graph as well
	string datafoldername
	
	//The same change is needed for mass, it will also be marked with CHANGE ctrl+F for this
	
	
	//For when aim is weird 'TotalConc.(g/m)' 
	// 'TotalConc.(µg/m³)'
	
	//Create the table to see
	wave 'TotalConc.(g/m)','TotalConc.(µg/m³)', MConc_total,DateTimewave	//Put both here just in case
	make/n=(dimsize(MConc_total,0)) differencemass
	differencemass ='TotalConc.(µg/m³)' - MConc_total	//CHANGE
	Edit/N=AIM_Igor_Differencemass
	appendToTable DateTimewave, MConc_total,'TotalConc.(µg/m³)', differencemass	//CHANGE
	
	//Create the graph
	Display MConc_total vs DateTimewave
	appendtograph'TotalConc.(µg/m³)' vs DateTimewave	//CHANGE
	Modifygraph dateInfo(bottom)={1,1,2};delayupdate
	modifygraph lsize('TotalConc.(µg/m³)')=0.01,lsize(MConc_Total)=0.01,rgb(MConc_Total)=(0,0,0);delayupdate	//CHANGE
	Label left "Total Mass Concentration (µg/m\\S3\\M)\rdNdlogDp\\BMob\\M";DelayUpdate
	Label bottom "Time (hrs:min:sec)";Delayupdate
	TextBox/C/x=30/y=40 /N=text0/S=3/A=MC "SMPS Mass TSeries Difference\r\n\\s(MConc_Total) Igor  Mass TSeries\r\n\\s('TotalConc.(µg/m³)') SMPS TSeries"
End

function exportcsvmass(year,month,day,timestart)
	string year, month, day, timestart
	wave Excel_DateTime, MConc_total
	string savename
	savename = year+"_"+month+"_"+day+"_"+timestart+"_Mass_Excel_Time_Series"	//If I could get this to work by getting the integer number into the timeformat then that would be great
	print "Name of exported CSV: "+savename
	Save/J/M="\r\n"/DLIM=","/W Excel_DateTime,MConc_Total as savename		//CHANGE
End

Function cummtseriesmass()
	wave Tmass_concat, Datetimewv_concat
	Display Tmass_concat vs Datetimewv_concat
	Label Bottom "Time (HH:MM:SS)"
	label left "Total Mass Conc. (µg/m\\S3\\M)"
	modifygraph nticks(bottom)=10
End





Function testfbwidth()
	Wave testdiam
	Duplicate/o testdiam testbinwidth
	testbinwidth = NaN
	variable i
	for(i=0; i<(numpnts(testbinwidth)-1);i+=1)
		testbinwidth[i] = testdiam[i+1]-testdiam[i]
	Endfor
End





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////Hourly Concentrations stuff for panel///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Concatenate datetimewaves and N/Mconc waves from different folders

Function Get_Waves_For_Concatenation_numb(ba) : ButtonControl 
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			MakeWavesForConcat()
		case 2:
			break
		endswitch
		
End


Function MakeWavesForConcat()
		concatedatafiles(1,"SMPS_MidPoint")
		concatedatafiles(1,"SMPS_Start")
		concatedatafiles(1,"SMPS_Stop")
		concatedatafiles(1,"datetimewave")
		
		concatedatafiles(1,"TotalConc.(#/cm3)")
		concatedatafiles(1,"NConc")
		concatedatafiles(1,"NConc_Total")
		concatedatafiles(1,"Geo.Mean(nm)")
		
		concatedatafiles(2,"MConc")
		concatedatafiles(2,"MConc_Total")
			
End






Function/S SortedDataFolderList(sourceFolderStr, sortOptions)
    String sourceFolderStr  // e.g., "root:'A Data Folder'"
    Variable sortOptions    // e.g., 16 - See SortList for details
   
    String dfList = ""
   
    Variable numDataFolders = CountObjects(sourceFolderStr, 4)
    Variable i
    for (i=0; i< numDataFolders; i+=1)
        String dfName = GetIndexedObjName(sourceFolderStr, 4, i)
        dfList += dfName + ";"
    endfor
   
    dfList = SortList(dfList, ";", sortOptions)
    return dfList
End


Function Make_tseries_graph_button_numb(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			Make_tseries_graph_numb("NConc_Total","datetimewave")
			Make_tseries_graph_numb("MConc_Total","datetimewave")
		case 2:
			break
		endswitch
		
End

function Make_tseries_graph_numb(variablename, datwave)
	String variablename, datwave
	
	setdatafolder root:AllTime
	
	display $variablename vs $datwave
	Label left variablename 
	Label bottom datwave
	setdatafolder root:
End

Function Make_tseries_graph_button_mass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			Make_tseries_graph_mass()
		case 2:
			break
		endswitch
		
End

function Make_tseries_graph_Mass()
	setdatafolder Concatenated_Wave_Mass
	wave Concatenated_Datetimewave_Waves, Concatenated_MNConc_Waves
	display Concatenated_MNConc_Waves vs Concatenated_Datetimewave_Waves
	Label left "Mass Concentration (µg/cm\\S3\\M)";DelayUpdate
	Label bottom "Date (HH:MM:SS)"
	Legend/C/N=text0/J/S=3/A=LT "\\s(Concatenated_MNConc_Waves) SMPS Mass Concentration"
	setdatafolder root:
End






/////////////////////////////////////////////////////////////////
///////////////////////HOURLY AVERAGE WORK///////////////////////
/////////////////////////////////////////////////////////////////

Function get_hourly_averages_button_numb(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			get_hourly_averages_numb()
		case 2:
			break
		endswitch
		
End


Function get_hourly_averages_numb()	
////Set intial folder and get waves from Concat folder to Hourly Averages folder
//	setdatafolder root:Concatenated_Wave_Number
//	wave Concatenated_Datetimewave_Waves, Concatenated_TNConc_Waves
//	duplicate Concatenated_Datetimewave_Waves, root:Hourly_Averages:Concatenated_DatetimeWave_Numb
//	duplicate Concatenated_TNConc_Waves, root:Hourly_Averages:Concatenated_TNConc
//	setdatafolder root:Hourly_Averages
//Get the hourly Averages
//Intial Parameters
	variable yearfirst,monthfirst,dayfirst,hourfirst,minfirst,secfirst
	variable hourstart
	prompt yearfirst "Enter the year of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt monthfirst "Enter the month of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt dayfirst "Enter the day of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt hourfirst "Enter the hour of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt minfirst "Enter the minutes of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt secfirst "Enter the seconds of the first point in the concatenated_Datetimewave_Waves Wave"
// Get information out of the user about the start point of the timedatewave
	doprompt "Enter the parameters",yearfirst, monthfirst, dayfirst, hourfirst, minfirst, secfirst
	if(V_flag==1)
		Print "user cancelled"
		Setdatafolder root:
		return -1
	else
	
	
	
	//Set intial folder and get waves from Concat folder to Hourly Averages folder
	setdatafolder root:Concatenated_Wave_Number
	wave Concatenated_Datetimewave_Waves, Concatenated_TNConc_Waves
	duplicate Concatenated_Datetimewave_Waves, root:Hourly_Averages:Concatenated_DatetimeWave_Numb
	duplicate Concatenated_TNConc_Waves, root:Hourly_Averages:Concatenated_TNConc
	setdatafolder root:Hourly_Averages
	
//Find out when the file starts
	variable First_day = date2secs(yearfirst,monthfirst,dayfirst)
	variable Start_time_file = first_day+(hourfirst*3600)+(minfirst*60)+secfirst
//Determine the difference in the start of the day and the start of the file
	variable time_diff = start_time_file - first_day
//Go to the hour start of the file
	variable YYMMDDHH_start_file = first_day+(hourfirst*3600)
//Save this as startpoint as we will be starting the hourly averages here
	variable startpoint = YYMMDDHH_start_file
	variable Startpointinc = YYMMDDHH_Start_File	//Use this in the loop to update the hours
//Establish the hourly marker for the average
	variable hourinc = startpoint+3600	
//Start the for/if loops
	variable idx = 0
	variable timeidx = startpoint
	variable npnts = dimsize(Concatenated_TNConc_Waves,0)
	variable overallidx = 0
	variable tempmean,updatedidx
	variable i=0
	variable adjustednpnts = npnts - 1
	variable timeoverby10min
	string timeshiftHHMMSSstr,timeshiftYYMMDDstr, yearstring, monthstring, daystring, hourstring
	variable yearvariable, monthvariable, dayvariable, hourvariable
//	variable timeshiftvar
//free waves to hold the temporary data
	make/o/d/free/n=(npnts) Stored_TNConc = NaN
	make/o/d/n=10000 Stored_HourlyAverage_numb = NaN
	make/o/d/n=10000 Stored_Datetimewave_Numb = NaN
	for(overallidx=0;overallidx<adjustednpnts;overallidx+=1)
		if(timeidx<hourinc && idx<adjustednpnts)		//If we are still in the same hour
			for(idx=updatedidx;timeidx<hourinc;idx+=1)
				if(idx<=adjustednpnts)
				else
					wavetransform zapnans Stored_TNConc
				tempmean = mean(Stored_TNConc)
				Stored_HourlyAverage_Numb[i] =tempmean
				Stored_Datetimewave_Numb[i] = startpointinc
				startpointinc += 3600
				break
				endif
				Stored_TNConc[idx] = Concatenated_TNConc_Waves[idx]
				timeidx=Concatenated_Datetimewave_Waves[idx]
				updatedidx = idx
				overallidx = idx
				timeoverby10min = hourinc+(600)
				
			endfor
		elseif(timeidx>hourinc || timeidx==hourinc&& idx<adjustednpnts)	//If we have gone over that hour
			if(timeidx>timeoverby10min && idx<adjustednpnts)	//if we have gone over by more than 10 min
				Stored_TNConc[updatedidx]=NaN	//The last point that is in the TNConc wave belongs to the next time period, so remove it
				wavetransform zapnans Stored_TNConc
				tempmean = mean(stored_TNConc)
				i+=1
				Stored_HourlyAverage_Numb[i] = tempmean
				timeidx = Concatenated_Datetimewave_Waves[updatedidx]
				Stored_Datetimewave_Numb[i] = startpointinc
				//if we are increasing by more than 10 min we are dealing with a significant time change and therefore need to start the hourly cycle 
				// again correctly. We cannot just add an hour to it. 
				timeshiftHHMMSSstr = secs2Time(timeidx,3)
				timeshiftYYMMDDstr = secs2Date(timeidx,-2,"_")
				yearstring = timeshiftYYMMDDstr[0,3]
				monthstring = timeshiftYYMMDDstr[5,6]
				daystring = timeshiftYYMMDDstr[8,9]
				hourstring = timeshiftHHMMSSstr[0,1]
				
				//AS I TROUBLE SHOOT THIS I NEED TO REMEMBER THAT MY FIRST ISSUE IS GOING FROM 7/11/2023 17:16:43 TO 7/11/2023 18:12:33
				
				//Idea for when I get back to this. take the string we are given from sec2date/time and then get the YYYY+MM+DD+HH out of it and 
				//	set that equal to hourinc to get the next actual hour.
				
				yearvariable = str2num(yearstring)
				yearvariable -= 1904		//Igor time starts at 1/1/1904
				yearvariable *= 365*24*3600		//Seconds in a year -> this is dicy, depends on the year
				yearvariable -=24*3600 //loose 1 day
				monthvariable = str2num(monthstring)
				//Find out how many seconds are in the month the data point is in
				if(monthvariable == 3)
					monthvariable *=28*24*3600
				elseif(monthvariable == 4||monthvariable ==6||monthvariable ==9||monthvariable ==11)
					monthvariable *=30*24*3600
				else
					monthvariable *=31*24*3600
				endif	
				monthvariable -= 5*24*3600		//loose 5 days to correct?
				dayvariable = str2num(daystring)
				dayvariable -= 1
				dayvariable *= 24*3600		//seconds in a day -> this is good. 
				hourvariable = str2num(hourstring)
				hourvariable *= 3600		//seconds in an hour -> this is good. 
				
				
				
				startpointinc = yearvariable+monthvariable+dayvariable+hourvariable	//Update the hour to be the start of the hour (taken from the time of the next data point)
				hourinc = startpointinc+3600	// the hourinc (which marks the end of the hour should be the startpoint inc plus 3600 seconds)
				redimension/n=(npnts) Stored_TNConc
				Stored_TNConc = NaN
				overallidx = idx
			elseif(timeidx<timeoverby10min && idx<adjustednpnts)		//if we have gone over by less than 10 min		
				Stored_TNConc[updatedidx]=NaN
				wavetransform zapnans Stored_TNConc
				tempmean = mean(Stored_TNConc)
				i+=1
				Stored_HourlyAverage_Numb[i] =tempmean
				Stored_Datetimewave_Numb[i] = startpointinc
				startpointinc += 3600 //Increase the hour by 1; this will give the hour that the data is representative for, mind you that there will be times where one hour is only composed of a couple of data points. 
				timeidx = hourinc
				hourinc += 3600
				//i+=1
				idx = updatedidx
				redimension/n=(npnts) Stored_TNConc
				Stored_TNConc = NaN
				overallidx = idx
			endif
		elseif(idx>=adjustednpnts)
			break
		endif
	endfor
	wavetransform zapnans Stored_HourlyAverage_Numb
	wavetransform zapnans Stored_Datetimewave_Numb
	rename Stored_Datetimewave_Numb, Hourly_Averaged_Datetime_Numb
	rename Stored_HourlyAverage_Numb, Hourly_Average_Number
	wave Hourly_Averaged_Datetime_Numb
	SetScale d 0,0,"dat",Hourly_Averaged_Datetime_Numb
	setdatafolder root:
Endif
End

Function get_hourly_averages_button_mass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			get_hourly_averages_mass()
		case 2:
			break
		endswitch
		
End

Function get_hourly_averages_mass()		
////Set intial folder and get waves from Concat folder to Hourly Averages folder
//	setdatafolder root:Concatenated_Wave_Mass
//	wave Concatenated_Datetimewave_Waves, Concatenated_MNConc_Waves
//	duplicate Concatenated_Datetimewave_Waves, root:Hourly_Averages:Concatenated_DatetimeWave_Mass
//	duplicate Concatenated_MNConc_Waves, root:Hourly_Averages:Concatenated_MNConc
//	setdatafolder root:Hourly_Averages
//Get the hourly Averages
//Intial Parameters
	variable yearfirst,monthfirst,dayfirst,hourfirst,minfirst,secfirst
	variable hourstart
	prompt yearfirst "Enter the year of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt monthfirst "Enter the month of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt dayfirst "Enter the day of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt hourfirst "Enter the hour of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt minfirst "Enter the minutes of the first point in the concatenated_Datetimewave_Waves Wave"
	prompt secfirst "Enter the seconds of the first point in the concatenated_Datetimewave_Waves Wave"
// Get information out of the user about the start point of the timedatewave
	doprompt "Enter the parameters",yearfirst, monthfirst, dayfirst, hourfirst, minfirst, secfirst
	if(V_flag==1)
		Print "user cancelled"
		setdatafolder root:
		return -1
	else
	//Set intial folder and get waves from Concat folder to Hourly Averages folder
	setdatafolder root:Concatenated_Wave_Mass
	wave Concatenated_Datetimewave_Waves, Concatenated_MNConc_Waves
	duplicate Concatenated_Datetimewave_Waves, root:Hourly_Averages:Concatenated_DatetimeWave_Mass
	duplicate Concatenated_MNConc_Waves, root:Hourly_Averages:Concatenated_MNConc
	setdatafolder root:Hourly_Averages
//Find out when the file starts
	variable First_day = date2secs(yearfirst,monthfirst,dayfirst)
	variable Start_time_file = first_day+(hourfirst*3600)+(minfirst*60)+secfirst
//Determine the difference in the start of the day and the start of the file
	variable time_diff = start_time_file - first_day
//Go to the hour start of the file
	variable YYMMDDHH_start_file = first_day+(hourfirst*3600)
//Save this as startpoint as we will be starting the hourly averages here
	variable startpoint = YYMMDDHH_start_file
	variable Startpointinc = YYMMDDHH_Start_File	//Use this in the loop to update the hours
//Establish the hourly marker for the average
	variable hourinc = startpoint+3600	
//Start the for/if loops
	variable idx = 0
	variable timeidx = startpoint
	variable npnts = dimsize(Concatenated_MNConc_Waves,0)
	variable overallidx = 0
	variable tempmean,updatedidx
	variable i=0
	variable adjustednpnts = npnts - 1
	variable timeoverby10min
	string timeshiftHHMMSSstr,timeshiftYYMMDDstr, yearstring, monthstring, daystring, hourstring
	variable yearvariable, monthvariable, dayvariable, hourvariable
//free waves to hold the temporary data
	make/o/d/free/n=10000 Stored_MNConc = NaN
	make/o/d/n=10000 Stored_HourlyAverage_Mass = NaN
	make/o/d/n=10000 Stored_Datetimewave_Mass = NaN
		for(overallidx=0;overallidx<adjustednpnts;overallidx+=1)
		if(timeidx<hourinc && idx<adjustednpnts)		//If we are still in the same hour
			for(idx=updatedidx;timeidx<hourinc;idx+=1)
				if(idx<=adjustednpnts)
				else
					wavetransform zapnans Stored_MNConc
				tempmean = mean(Stored_MNConc)
				Stored_HourlyAverage_Mass[i] =tempmean
				Stored_Datetimewave_Mass[i] = startpointinc
				startpointinc += 3600
				break
				endif
				Stored_MNConc[idx] = Concatenated_MNConc_Waves[idx]
				timeidx=Concatenated_Datetimewave_Waves[idx]
				updatedidx = idx
				overallidx = idx
				timeoverby10min = hourinc+(600)
				
			endfor
		elseif(timeidx>hourinc || timeidx==hourinc&& idx<adjustednpnts)	//If we have gone over that hour
			if(timeidx>timeoverby10min && idx<adjustednpnts)	//if we have gone over by more than 10 min
				Stored_MNConc[updatedidx]=NaN	//The last point that is in the MNConc wave belongs to the next time period, so remove it
				wavetransform zapnans Stored_MNConc
				tempmean = mean(stored_MNConc)
				i+=1
				Stored_HourlyAverage_Mass[i] = tempmean
				timeidx = Concatenated_Datetimewave_Waves[updatedidx]
				Stored_Datetimewave_Mass[i] = startpointinc
				//if we are increasing by more than 10 min we are dealing with a significant time change and therefore need to start the hourly cycle 
				// again correctly. We cannot just add an hour to it. 
				timeshiftHHMMSSstr = secs2Time(timeidx,3)
				timeshiftYYMMDDstr = secs2Date(timeidx,-2,"_")
				yearstring = timeshiftYYMMDDstr[0,3]
				monthstring = timeshiftYYMMDDstr[5,6]
				daystring = timeshiftYYMMDDstr[8,9]
				hourstring = timeshiftHHMMSSstr[0,1]
				
				//AS I TROUBLE SHOOT THIS I NEED TO REMEMBER THAT MY FIRST ISSUE IS GOING FROM 7/11/2023 17:16:43 TO 7/11/2023 18:12:33
				
				//Idea for when I get back to this. take the string we are given from sec2date/time and then get the YYYY+MM+DD+HH out of it and 
				//	set that equal to hourinc to get the next actual hour.
				
				yearvariable = str2num(yearstring)
				yearvariable -= 1904		//Igor time starts at 1/1/1904
				yearvariable *= 365*24*3600		//Seconds in a year -> this is dicy, depends on the year
				yearvariable -=24*3600 //loose 1 day
				monthvariable = str2num(monthstring)
				//Find out how many seconds are in the month the data point is in
				if(monthvariable == 3)
					monthvariable *=28*24*3600
				elseif(monthvariable == 4||monthvariable ==6||monthvariable ==9||monthvariable ==11)
					monthvariable *=30*24*3600
				else
					monthvariable *=31*24*3600
				endif	
				monthvariable -= 5*24*3600		//loose 5 days to correct?
				dayvariable = str2num(daystring)
				dayvariable -= 1
				dayvariable *= 24*3600		//seconds in a day -> this is good. 
				hourvariable = str2num(hourstring)
				hourvariable *= 3600		//seconds in an hour -> this is good. 
				
				
				
				startpointinc = yearvariable+monthvariable+dayvariable+hourvariable	//Update the hour to be the start of the hour (taken from the time of the next data point)
				hourinc = startpointinc+3600	// the hourinc (which marks the end of the hour should be the startpoint inc plus 3600 seconds)
				redimension/n=(npnts) Stored_MNConc
				Stored_MNConc = NaN
				overallidx = idx
			elseif(timeidx<timeoverby10min && idx<adjustednpnts)		//if we have gone over by less than 10 min		
				Stored_MNConc[updatedidx]=NaN
				wavetransform zapnans Stored_MNConc
				tempmean = mean(Stored_MNConc)
				i+=1
				Stored_HourlyAverage_Mass[i] =tempmean
				Stored_Datetimewave_Mass[i] = startpointinc
				startpointinc += 3600 //Increase the hour by 1; this will give the hour that the data is representative for, mind you that there will be times where one hour is only composed of a couple of data points. 
				timeidx = hourinc
				hourinc += 3600
				//i+=1
				idx = updatedidx
				redimension/n=(npnts) Stored_MNConc
				Stored_MNConc = NaN
				overallidx = idx
			endif
		elseif(idx>=adjustednpnts)
			break
		endif
	endfor
	wavetransform zapnans Stored_HourlyAverage_Mass
	wavetransform zapnans Stored_Datetimewave_Mass
	rename Stored_Datetimewave_Mass, Hourly_Averaged_Datetime_Mass
	rename Stored_HourlyAverage_Mass, Hourly_Averaged_Mass
	wave Hourly_Averaged_Datetime_Mass
	SetScale d 0,0,"dat",Hourly_Averaged_Datetime_Mass

setdatafolder root:
Endif
End

Function HourlyAverageGraph_number_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			Houly_Average_Graph_Number()
		case 2:
			break
		endswitch
		
End

Function Houly_Average_Graph_Number()
	setdatafolder root:Hourly_Averages
	wave Hourly_Average_Number, Hourly_Averaged_Datetime_Numb
	display Hourly_Average_Number vs Hourly_Averaged_Datetime_Numb
	Label bottom, "DateTime (MM:DD:YYYY:HH)"
	Label left, "Number Concentration \r(#/cm\S3\M; dNdlogDp\Bmob\M)"
	TextBox/C/N=text0/A=RT "Hourly Averaged Number Concentration\r\\s(Hourly_Average_Number) Hourly Average"
	setdatafolder root:
End

Function HourlyAverageGraph_mass_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			Houly_Average_Graph_Mass()
		case 2:
			break
		endswitch
		
End

Function Houly_Average_Graph_Mass()
	setdatafolder root:Hourly_Averages
	wave Hourly_Averaged_Mass, Hourly_Averaged_Datetime_Mass
	display Hourly_Averaged_Mass vs Hourly_Averaged_Datetime_Mass
	Label bottom, "DateTime (MM:DD:YYYY:HH)"
	Label left, "Mass Concentration \r(µg/m\S3\M\S3\M; dMdlogDp\Bmob\M)"
	TextBox/C/N=text0/A=RT "Hourly Averaged Mass Concentration\r\\s(Hourly_Average_Number) Hourly Average"
	setdatafolder root:
End

Function ResetHourlyAvgflr_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			Reset_Hourly_Average_Fldr()
		case 2:
			break
		endswitch
		
End

Function Reset_Hourly_Average_Fldr()
	setdatafolder root:Hourly_Averages
	Killwaves/A
	setdatafolder root:
	
End




//////////////////////////////////////////////////////////
/////////////////Size Distribution Work///////////////////
//////////////////////////////////////////////////////////

Function getsizedistwaves_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			
			killsizedist()
			getsizedistwaves_numb()
			getSizeDistrGraphWaves_numb()
			
			setdatafolder Root:
			getsizedistwaves_mass()
			getSizeDistrGraphWaves_mass()
			setdatafolder root:
		case 2:
			break
		endswitch
		
End


Function killsizedist()
	//Set up prompts
	doalert/T="Delete all?" 1, "Are you sure?\r\rSelect Yes to delete all graphs, tables, and \rwaves for the size distributions and generate new ones. \r\rSelect No to cancel."
	if(V_flag==1)
		KillAllTables()
		KillAllGraphs()
		
		KillDataFolder/Z root:Size_Distributions_Mass:
		KillDataFolder/Z root:Size_Distributions_Numb:
		
		NewDataFolder root:Size_Distributions_Mass
		NewDataFolder root:Size_Distributions_Numb
		
	endif
End

function getSizeDistwaves_numb()
	setdatafolder root:size_distributions_Numb
	DFREF dfrSD = GetdatafolderDFR()
	setdataFolder root:Number_Concentration
	DFREF dfrNC = GetdatafolderDFR()
	string Foldername, newdatafoldername
	variable SDnumvar = 0
	string SDnumstr = num2str(SDnumvar)
	variable SDnumDataFolders = countobjectsDFR(dfrNC,4)
	variable i
	for(i=0;i<SDnumDatafolders;i+=1)
		Foldername = GetindexedObjNameDFR(dfrNC,4,i)
		SetdataFolder ":'"+foldername+"':"
		SDnumvar+=1
		SDnumstr = num2str(SDnumvar)
		//function stuff here
		
			wave NConc, diam, datetimewave
		//Get the number conc wave first
			string tempnameNConc = "Size_Distribution_Holder"
			duplicate/O NConc,$tempnameNConc
			movewave $tempnameNConc,dfrSD
			SetdataFolder dfrNC	//reset back to inital datafolder
		//Get the diameter wave second
			SetdataFolder ":'"+foldername+"':"
			string tempnameDiam = "Size_Distribution_Diam"
			duplicate/O diam, $tempnameDiam
			movewave $tempnamediam, dfrSD
		//Get the datetime wave third
			string tempdatetimename = "Size_Distribution_datetimewave"
			duplicate/O datetimewave, $tempdatetimename
			movewave $tempdatetimename, dfrSD
			
		//Go back to the size dist folder and create a datafolder to move the two waves into
			setdatafolder dfrSD
			newdatafoldername = "Size_Distributions_"+Foldername
			newdatafolder/S $newdatafoldername
			DFREF dfrNDF =getdatafolderdfr()
			setdatafolder dfrSD
			movewave $tempnameNConc, dfrNDF:$tempnameNConc
			movewave $tempnameDiam, dfrNDF:$tempnameDiam
			movewave $tempdatetimename, dfrNDF:$tempdatetimename
		//End stuff and return to root 
		Setdatafolder dfrNC
	endfor
	Setdatafolder root:
End

Function getsizedistwaves_button_mass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			getsizedistwaves_mass()
			getSizeDistrGraphWaves_mass()
			setdatafolder root:
		case 2:
			break
		endswitch
		
End


function getSizeDistwaves_mass()
	setdatafolder root:size_distributions_Mass
	DFREF dfrSD = GetdatafolderDFR()
	setdataFolder root:Mass_Concentration
	DFREF dfrMC = GetdatafolderDFR()
	string Foldername, newdatafoldername
	variable SDnumvar = 0
	string SDnumstr = num2str(SDnumvar)
	variable SDnumDataFolders = countobjectsDFR(dfrMC,4)
	variable i
	for(i=0;i<SDnumDatafolders;i+=1)
		Foldername = GetindexedObjNameDFR(dfrMC,4,i)
		SetdataFolder ":'"+foldername+"':"
		SDnumvar+=1
		SDnumstr = num2str(SDnumvar)
		//function stuff here
		
			wave MConc, diam, datetimewave
		//Get the mass conc wave first
			string tempnameMConc = "Mass_Distribution_Holder"
			duplicate/O MConc,$tempnameMConc
			movewave $tempnameMConc,dfrSD
			SetdataFolder dfrMC	//reset back to inital datafolder
		//Get the datetimewave second
			SetdataFolder ":'"+foldername+"':"
			string tempnameDiam = "Mass_Distribution_Diam"
			duplicate/O diam, $tempnameDiam
			movewave $tempnamediam, dfrSD
		//Get the datetime wave third
			string tempdatetimename = "Mass_Distribution_datetimewave"
			duplicate/O datetimewave, $tempdatetimename
			movewave $tempdatetimename, dfrSD
		//Go back to the size dist folder and create a datafolder to move the two waves into
			setdatafolder dfrSD
			newdatafoldername = "Mass_Distributions_"+Foldername
			newdatafolder/S $newdatafoldername
			DFREF dfrNDF =getdatafolderdfr()
			setdatafolder dfrSD
			movewave $tempnameMConc, dfrNDF:$tempnameMConc
			movewave $tempnameDiam, dfrNDF:$tempnameDiam
			movewave $tempdatetimename, dfrNDF:$tempdatetimename
		//End stuff and return to root 
		Setdatafolder dfrMC
	endfor
	Setdatafolder root:
End

Function getsizedistgraphwaves_button_numb(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			getSizeDistrGraphWaves_numb()
			getSizeDistrGraphWaves_mass()
		case 2:
			break
		endswitch
		
End

function getSizeDistrGraphWaves_numb()
	setdatafolder root:size_distributions_numb
	DFREF dfrSD = GetdatafolderDFR()
	variable SDnumDataFolders = countobjectsDFR(dfrSD,4)
	variable ivar = 0
	string istr = num2str(ivar)
	variable idx,gidx
	for(idx = 0; idx<SDnumDatafolders;idx+=1)
		string Foldername = getindexedObjNameDFR(dfrSD,4,idx)
		setdataFolder ":'"+foldername+"':"
		wave  Size_distribution_Holder,MatrixforExtraction_transposed, onedwave
		ivar+=1
		istr = num2str(ivar)
	//waves for graphs here
		
		string scanname = "Size_Distribution_Scan_"
		variable scannumbvar = 0
		string scannumbstr = num2str(scannumbvar)
		variable matrixrow = dimsize(Size_distribution_Holder,0)
		variable matrixColumn = dimsize(Size_distribution_Holder,1)
		
		variable firstindex = 0	// When the matrix gets transposed and then turned into a 2D wave. We will need to get the 110 points that make up
		//									all of the bins	and extract them into a wave that can be plotted against the diameter. 
		variable lastindex = matrixcolumn
		variable i = 0		
				
		variable totalmatrixspots = matrixrow*matrixcolumn	// get the total amount of points in the matrix
		//make /n=(totalmatrixspots) onedwave
		duplicate Size_distribution_Holder, MatrixforExtraction_Transposed		//duplicate the matrix
		Matrixtranspose MatrixforExtraction_Transposed //switch x-> y to y-> x in the matrix
		Matrixop onedwave = redimension(MatrixforExtraction_Transposed,totalmatrixspots,1) // Take the matrix and redimension it to be a 
		//				1D wave of length 'totalmatrixspots'
		for(i=0;i<matrixrow;i+=1)
			duplicate/R=(firstindex,lastindex) onedwave, $scanname+scannumbstr
			firstindex+=matrixcolumn //This was hard coded as 111, but should be the number of diameter bins
			lastindex+=matrixcolumn
			scannumbvar+=1
			scannumbstr=num2str(scannumbvar)
		endfor
		setdatafolder dfrSD
	endfor
	

End

Function getsizedistgraphwaves_button_mass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			getSizeDistrGraphWaves_mass()
		case 2:
			break
		endswitch
		
End

function getSizeDistrGraphWaves_mass()	
	setdatafolder root:size_distributions_mass
	DFREF dfrSD = GetdatafolderDFR()
	variable SDnumDataFolders = countobjectsDFR(dfrSD,4)
	variable ivar = 0
	string istr = num2str(ivar)
	variable idx,gidx
	for(idx = 0; idx<SDnumDatafolders;idx+=1)
		string Foldername = getindexedObjNameDFR(dfrSD,4,idx)
		setdataFolder ":'"+foldername+"':"
		wave  Mass_distribution_Holder,MatrixforExtraction_transposed, onedwave
		ivar+=1
		istr = num2str(ivar)
	//waves for graphs here
		variable i = 0
		string scanname = "Mass_Distribution_Scan_"
		variable scannumbvar = 0
		string scannumbstr = num2str(scannumbvar)
		variable matrixrow = dimsize(Mass_distribution_Holder,0)
		variable matrixColumn = dimsize(Mass_distribution_Holder,1)
		variable totalmatrixspots = matrixrow*matrixcolumn	// get the total amount of points in the matrix
		
		
		variable firstindex = 0	// When the matrix gets transposed and then turned into a 2D wave. We will need to get the 110 points that make up
		//									all of the bins	and extract them into a wave that can be plotted against the diameter. 
		variable lastindex = matrixcolumn
		
		//make /n=(totalmatrixspots) onedwave
		duplicate Mass_distribution_Holder, MatrixforExtraction_Transposed		//duplicate the matrix
		Matrixtranspose MatrixforExtraction_Transposed //switch x-> y to y-> x in the matrix
		Matrixop onedwave = redimension(MatrixforExtraction_Transposed,totalmatrixspots,1) // Take the matrix and redimension it to be a 
		//																														1D wave of length 'totalmatrixspots'
		for(i=0;i<matrixrow;i+=1)
			duplicate/R=(firstindex,lastindex) onedwave, $scanname+scannumbstr
			firstindex+=matrixcolumn
			lastindex+=matrixcolumn
			scannumbvar+=1
			scannumbstr=num2str(scannumbvar)
		endfor
		
		setdatafolder dfrSD
	endfor

End

Function MakeSDGraphs_button_numb(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			NVAR indivfile_Y, indivfile_Mon, indivfile_D, indivfile_H, indivfile_Min, indivfile_S
			string dataflder = "root:Size_Distributions_Numb:Size_Distributions_"+num2str(indivfile_Y)+"_"+num2str(indivfile_Mon)+"_"+num2str(indivfile_D)+"_"+num2str(indivfile_H)+"_"+num2str(indivfile_Min)+"_"+num2str(indivfile_S)+"_Numb"
			MakeSDgraphs_numb(dataflder,"Size_Distribution_Diam",1)
			setdatafolder root:
		case 2:
			break
		endswitch
		
End

function makeSDgraphs_numb(datafoldername,diametername, interval)
	String datafoldername,diametername
	variable interval
		
	setdatafolder $datafoldername
	
	String mywavelist = WaveList("Size_Distribution_Scan_*", ";","")
	variable numbdf = ItemsInList(mywavelist)
	
	variable i
	
	Display
	for(i=0;i<(numbdf*interval);i+=interval)
		string scannumb_name = "Size_Distribution_Scan_"+num2str(i)
		AppendtoGraph $Scannumb_name vs $diametername
		Label left "dNdlogdp (#/cm\\S3\\M)";DelayUpdate
		Label bottom "Diameter Midpoint (nm)";Delayupdate
		ModifyGraph log(bottom)=1
		ModifyGraph mode=6

	endfor
	
End

Function MakeSDGraphs_button_mass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			NVAR indivfile_Y, indivfile_Mon, indivfile_D, indivfile_H, indivfile_Min, indivfile_S
			string dataflder = "root:Size_Distributions_Mass:Mass_Distributions_"+num2str(indivfile_Y)+"_"+num2str(indivfile_Mon)+"_"+num2str(indivfile_D)+"_"+num2str(indivfile_H)+"_"+num2str(indivfile_Min)+"_"+num2str(indivfile_S)+"_Mass"
			MakeSDgraphs_mass(dataflder,"Mass_Distribution_Diam",1)
		case 2:
			break
		endswitch
		
End

function makeSDgraphs_mass(datafoldername,diametername, interval)
	String datafoldername,diametername
	variable interval
	
	setdatafolder $datafoldername
	wave Mass_Distribution_Diam
	
	String mywavelist = WaveList("Mass_Distribution_Scan_*", ";","")
	variable numbdf = ItemsInList(mywavelist)
	variable i
	

	Display 
	for(i=0;i<(numbdf*interval);i+=interval)
		string scannumb_name = "Mass_Distribution_Scan_"+num2str(i)
		AppendtoGraph $scannumb_name vs $diametername
		Label left "dMdlogdp (µg/m\\S3\\M)";DelayUpdate
		Label bottom "Diameter Midpoint (nm)";Delayupdate
		ModifyGraph log(bottom)=1
		ModifyGraph mode=6	

	endfor
	setdatafolder root:	
End




Function MakeHeatmap_Numb_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			heatmap_indiv_numb()
		case 2:
			break
		endswitch
		
End

function heatmap_indiv_numb()
//initiate prompt and parameters
	//string DFstring 
	//prompt DFstring, "Full path to datafolder desired"
	//doprompt "Enter the full path to the data folder that will be used to generate the Heatmap", DFstring
	//if(V_flag==1)
	//	Print "user cancelled"
	//	return -1
	//else
	setdatafolder root:
	NVAR indivfile_Y, indivfile_Mon, indivfile_D, indivfile_H, indivfile_Min, indivfile_S
	string DFstring = "root:Size_Distributions_Numb:Size_Distributions_"+num2str(indivfile_Y)+"_"+num2str(indivfile_Mon)+"_"+num2str(indivfile_D)+"_"+num2str(indivfile_H)+"_"+num2str(indivfile_Min)+"_"+num2str(indivfile_S)+"_Numb"
//		
	SetdataFolder Dfstring
	DFREF currdf = getdataFolderDFR()
	
	//check to see if wave exist already and if so kill them
//	wave SD_Bin_Edges
//	setdatafolder currdf
//	if(waveexists(SD_Bin_Edges))
//		killwaves SD_Bin_Edges
//	endif
	
//	setdatafolder root:root:Parameter_Data_Folder:
//	wave Size_Distribution_Bin_Edges
//	Duplicate/O Size_Distribution_Bin_Edges, SD_Bin_Edges
//	movewave SD_Bin_Edges, currdf:SD_Bin_Edges
//	setdatafolder currdf
	
	wave Size_Distribution_Diam, Size_Distribution_Holder, Size_Distribution_datetimewave, SD_Edges, SD_Datetime_Edges
//	variable ndiam = dimsize(Size_Distribution_Diam, 0)
//	variable nscans = dimsize(Size_Distribution_Holder,0)
	make/o/n=1 SD_Bin_Edges
	Make/d/o/n=1 SD_DT_Edges
	MakeEdgesWave(Size_Distribution_Diam, SD_Bin_Edges)
	MakeEdgesWave(Size_Distribution_datetimewave, SD_DT_Edges)
	setscale d, 0,0, "dat", SD_DT_Edges
	
	display
	AppendImage Size_Distribution_Holder vs {SD_DT_Edges,SD_Bin_Edges};DelayUpdate
	ModifyImage Size_Distribution_Holder ctab= {*,*,Geo,0}
	Label left "Diameter (nm)";DelayUpdate
	Label bottom "DateTime (DD:MM:YYYY HH:MM:SS)"
	ColorScale/A=RT/C/N=text0 image=Size_Distribution_Holder
	ColorScale/A=RT/C/N=text0  ctab={0,100,Geo,0};DelayUpdate
	ColorScale/A=RT/C/N=text0 "dNdlogDp\\BMob\\M (#/cm\\S3\\M)"
//	endif	
	setdatafolder root:
End


Function MakeHeatmap_Mass_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			heatmap_indiv_Mass()
		case 2:
			break
		endswitch
		
End

function heatmap_indiv_mass()
	
	setdatafolder root:
	NVAR indivfile_Y, indivfile_Mon, indivfile_D, indivfile_H, indivfile_Min, indivfile_S
	string DFstring = "root:Size_Distributions_Mass:Mass_Distributions_"+num2str(indivfile_Y)+"_"+num2str(indivfile_Mon)+"_"+num2str(indivfile_D)+"_"+num2str(indivfile_H)+"_"+num2str(indivfile_Min)+"_"+num2str(indivfile_S)+"_Mass"
	DFREF currdf = $Dfstring
	Setdatafolder currdf
	
	
	wave Mass_Distribution_Diam, Mass_Distribution_Holder, Mass_Distribution_datetimewave

	make/o/n=1 SD_Bin_Edges
	Make/d/o/n=1 SD_DT_Edges
	MakeEdgesWave(Mass_Distribution_Diam, SD_Bin_Edges)
	MakeEdgesWave(Mass_Distribution_datetimewave, SD_DT_Edges)
	setscale d, 0,0, "dat", SD_DT_Edges
	
	display
	AppendImage Mass_Distribution_Holder vs {SD_DT_Edges,SD_Bin_Edges};DelayUpdate
	ModifyImage Mass_Distribution_Holder ctab= {*,*,Geo,0}
	Label left "Diameter (nm)";DelayUpdate
	Label bottom "DateTime (DD:MM:YYYY HH:MM:SS)"
	ColorScale/A=LT/C/N=text0 image=Size_Distribution_Holder
	ColorScale/A=LT/C/N=text0  ctab={0,100,Geo,0};DelayUpdate
	ColorScale/A=LT/C/N=text0 "dMdlogDp\\BMob\\M (µg/m\\S3\\M)"

	setdatafolder root:
End

Function MakeHeatmap_all_individual_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			heatmap_all_individual()
		case 2:
			break
		endswitch
		
End

function heatmap_all_individual()
	//Set up prompts
	variable type, sve
	prompt type, "Enter '1' for Number or '2' for Mass if you want to generate individual heatmaps for all of the Number or Mass Data."
	prompt sve, "Enter '1' to save or '0' to not save the heatmaps that will be generated."
	doprompt "Please Enter the Following Parameters.", Type, Sve
	if(V_flag==1)
		Print "user cancelled"
		return -1
	else
	//setup inital parameters
	variable ndfs	//Number of data folders (within the big SD folder)
	variable dfnumb //Number of the datafolder we are in
	string dfname	//Name of datafolder we are in
	string savefilename //if the user wants to save
	
	
	if(type == 1)
		setdatafolder root:Size_Distributions_Numb:
		DFREF ndf = GetdataFolderDFR()
		ndfs = countobjectsDFR(ndf, 4)
		
		String ndfname = GetdataFolder(1)		
		String dfList = SortedDataFolderList(ndfname, 16)
		variable numDataFolders = ItemsInList(dfList)
				
		for(dfnumb=0;dfnumb<ndfs;dfnumb+=1)
			dfname = StringFromList(dfnumb, dfList)
			setdataFolder "Root:Size_Distributions_Numb:'"+dfname+"':"
			DFREF currdf = GetdataFolderDFR()
			//Check to make sure that there is more than one scan
			variable numbscans
			wave Size_Distribution_datetimewave
			numbscans = dimsize(Size_Distribution_datetimewave,0)
			if(numbscans>1)
			//Impliment code written for individual functions
			//check to see if wave exist already and if so kill them
				wave SD_Bin_Edges
				if(waveexists(SD_Bin_Edges))
					killwaves SD_Bin_Edges
				endif
	

		
				wave Size_Distribution_Diam, Size_Distribution_Holder, Size_Distribution_datetimewave, SD_Edges, SD_Datetime_Edges
				variable ndiam = dimsize(Size_Distribution_Diam, 0)
				variable nscans = dimsize(Size_Distribution_Holder,0)
				make/o/n=1 SD_Bin_Edges
				Make/d/o/n=1 SD_DT_Edges
				MakeEdgesWave(Size_Distribution_Diam, SD_Bin_Edges)
				MakeEdgesWave(Size_Distribution_datetimewave, SD_DT_Edges)
				setscale d, 0,0, "dat", SD_DT_Edges
	
				display
				AppendImage Size_Distribution_Holder vs {SD_DT_Edges,SD_Bin_Edges};DelayUpdate
				ModifyImage Size_Distribution_Holder ctab= {*,*,Geo,0}
				Label left "Diameter (nm)";DelayUpdate
				Label bottom "DateTime (DD:MM:YYYY HH:MM:SS)"
				ColorScale/A=RT/C/N=text0 image=Size_Distribution_Holder
				ColorScale/A=RT/C/N=text0  ctab={0,100,Geo,0};DelayUpdate
				ColorScale/A=RT/C/N=text0 "dNdlogDp\\BMob\\M (#/cm\\S3\\M)"
				if(sve ==1)
					savefilename = "Heatmap (Number) of file "+dfname
					SavePICT/E=-8/EF=1/I/W=(0,0,21,11) as savefilename	//currently this leaves them as just files, will see if they fix by sitting
					//The /P=Save_heatmapPath saves it to the the temporary processed folder
				elseif(sve==0)
				//donothing
				elseif(sve!=1||sve!=0)
					print "To save or not save you must either type '1' or '2'"
					return -1
				endif
			elseif(numbscans<=1)	// In the case that the scan does not have enough scans to generate a heatmap. /p=home should also work well 
				print "Due to a low number of scans within this data folder a heatmap cannot be generated for it"
				print dfname
			Endif
		Endfor
	
	
	
//do same but with mass
	elseif(type == 2)
		setdatafolder root:Size_Distributions_Mass:
		DFREF ndf = GetdataFolderDFR()
		ndfs = countobjectsDFR(ndf, 4)
		ndfname = GetdataFolder(1)
		
		dfList = SortedDataFolderList(ndfname, 16)
		numDataFolders = ItemsInList(dfList)
		
		for(dfnumb=0;dfnumb<ndfs;dfnumb+=1)
			dfname = StringFromList(dfnumb, dfList)
			setdataFolder "Root:Size_Distributions_Mass:'"+dfname+"':"
			DFREF currdf = GetdataFolderDFR()
			//Check to make sure that there is more than one scan
			//	variable numbscans		//already exists 
			wave Mass_Distribution_datetimewave
			numbscans = dimsize(Mass_Distribution_datetimewave,0)
			if(numbscans>1)
			//Impliment code written for individual functions
			//check to see if wave exist already and if so kill them
				wave SD_Bin_Edges
				if(waveexists(SD_Bin_Edges))
					killwaves SD_Bin_Edges
				endif
	
	
				wave Mass_Distribution_Diam, Mass_Distribution_Holder, Mass_Distribution_datetimewave, SD_Edges, SD_Datetime_Edges
				ndiam = dimsize(Mass_Distribution_Diam, 0)
				nscans = dimsize(Mass_Distribution_Holder,0)
				make/o/n=1 SD_Bin_Edges
				Make/d/o/n=1 SD_DT_Edges
				MakeEdgesWave(Mass_Distribution_Diam, SD_Bin_Edges)
				MakeEdgesWave(Mass_Distribution_datetimewave, SD_DT_Edges)
				setscale d, 0,0, "dat", SD_DT_Edges
	
				display
				AppendImage Mass_Distribution_Holder vs {SD_DT_Edges,SD_Bin_Edges};DelayUpdate
				ModifyImage Mass_Distribution_Holder ctab= {*,*,Geo,0}
				Label left "Diameter (nm)";DelayUpdate
				Label bottom "DateTime (DD:MM:YYYY HH:MM:SS)"
				ColorScale/A=RT/C/N=text0 image=Size_Distribution_Holder
				ColorScale/A=RT/C/N=text0  ctab={0,100,Geo,0};DelayUpdate
				ColorScale/A=LT/C/N=text0 "dMdlogDp\\BMob\\M (µg/m\\S3\\M)"	
				if(sve ==1)
					savefilename = "Heatmap (Mass) of file "+dfname
					SavePICT/E=-8/EF=1/I/W=(0,0,21,11) as savefilename	//currently this leaves them as just files, will see if they fix by sitting
					//The /P=Save_heatmapPath saves it to the the temporary processed folder
				elseif(sve==0)
				//donothing
				endif
			elseif(numbscans<=1)	// In the case that the scan does not have enough scans to generate a heatmap. /p=home should also work well 
				print "Due to a low number of scans within this data folder a heatmap cannot be generated for it"
				print dfname
			Endif	
		Endfor
	elseif(type!=1 ||	type!=2)
		print "Need type to be '1' or '2'"
		return -1
	Endif
	
	
	
	
	endif
	setdatafolder root:	
End




//////////////////////////////////////////////
//////////////General Functions///////////////
//////////////////////////////////////////////



Function Kill_All_Graphs_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			KillAllGraphs()
		case 2:
			break
		endswitch
		
End

Function KillAllGraphs()		//Kills all Graphs
    string fulllist = WinList("*", ";","WIN:1")
    string name, cmd
    variable i
   
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        dowindow/K $name  
    endfor
end

Function Kill_All_Tables_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			KillAllTables()
		case 2:
			break
		endswitch
		
End


Function KillAllTables()		//Kills all Tables 
    string fulllist = WinList("*", ";","WIN:2")
    string name, cmd
    variable i
   
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        dowindow/K $name  
    endfor
end

Function KillAllDataWaves()
	
End

Function MakeEdgesWave(centers, edgesWave)
	Wave centers // Input wave
	Wave edgesWave // Output wave
	
	Variable N=numpnts(centers)
	
	Redimension/N=(N+1) edgesWave
	edgesWave[0]=centers[0]-0.5*(centers[1]-centers[0])
	edgesWave[N]=centers[N-1]+0.5*(centers[N-1]-centers[N-2])
	edgesWave[1,N-1]=centers[p]-0.5*(centers[p]-centers[p-1])
End

Function Pointsinwave2NAN(w, p1, p2)	//sets points in a wave to NaN from point 1 to point 2
 wave w
 variable p1, p2
 variable i 
 for(i=p1;i<=p2;i+=1)
 	W[i] = NaN
 Endfor
End

Function Zero2Nan(w)
	wave w
	variable wlength = dimsize(w,0)
	variable i 
	for(i=0;i<wlength;i+=1)
		if(w[i] == 0)
			w[i] = NaN
		else
		endif
	endfor
End




//////////////////////////////////////////////////
///  Recalculate Mass (if you change density  ////
//////////////////////////////////////////////////


function RecalcMass_Button(ba):ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			RecalcMass()
		case 2:
			break
		endswitch
end



function RecalcMass() //If you add any more function that deal with mass, they should be addressed here.
	//Pull in global variable density
	NVAR density
	
	
	//setup initial parameters
	variable ndfs	//Number of data folders (within the big SD folder)
	variable dfnumb //Index of the datafolder we are in
	string dfname	//Name of datafolder we are in
	
	
	setdatafolder root:Number_Concentration:
		DFREF ndf = GetdataFolderDFR()
		ndfs = countobjectsDFR(ndf, 4)
		for(dfnumb=0;dfnumb<ndfs;dfnumb+=1)
			dfname = getindexedObjNameDFR(ndf,4,dfnumb)
			setdataFolder "Root:Number_Concentration:'"+dfname+"':"
			DFREF currdf = GetdataFolderDFR()
			
				NconctoVandSA(density) //Do conversion to mass
				
				wave MConc, binwidth,dlogDp
				wave diam
				Tconcmass(MConc,diam[0],diam[numpnts(diam)-1], diam, binwidth, dlogDp)
				
				wave MConc_Total_Stats, MConc_Total
				if (waveexists(MConc_Total_Stats)==1)
					Killwaves MConc_Total_Stats 
				endif
				
				wavestats/W MConc_Total
  				string newstatswname = nameofwave(MConc_Total)+"_Stats"
				rename M_Wavestats, $newstatswname
				
				wave MConc_Total, MConc_Total_Stats
				string massname = dfname[0, strlen(dfname) - 5] + "Mass"
				setdatafolder root:Mass_Concentration:$massname
				DFREF massDF = getdataFolderDFR()
				
				Wave MConc,MConc_Total,MConc_Total_Stats
				if (waveexists(MConc)==1)
					Killwaves MConc,MConc_Total,MConc_Total_Stats 
				Endif
				
				setdatafolder currdf
				
				Wave MConc,MConc_Total,MConc_Total_Stats
				movewave MConc,massDF:MConc
				movewave MConc_Total,massDF:MConc_Total
				movewave MConc_Total_Stats,massDF:MConc_Total_Stats
 
				Setdatafolder root:
	

		Endfor
End

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

function TSIStat_Button(ba):ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			
			
		case 2:
			break
		endswitch
end

// Based on Appendix C of AIM Aerosol Instrument Manager® Software for Scanning Mobility Particle Sizer™  
// (SMPS™) Spectrometer User’s Manual P/N 1930038, Revision H April 2010 
// https://cires1.colorado.edu/jimenez-group/Manuals/AIM_SMPS_manual.pdf
Function [variable GeoMean, variable GeoSD, variable AvgConc] TSIStatistics(Wave dWdlogDp, Wave Diam)

	
	Make/O/N=(numpnts(Diam)) GM_num
	Make/O/N=(numpnts(Diam)) GM_den
	
	Make/O/N=(numpnts(Diam)) W
	
	Duplicate/O diam binwidth
	binwidth = Nan
	variable i
	For (i=0; i<(numpnts(binwidth)-1);i++)
		binwidth[i] = diam[i+1]-diam[i]
	
	EndFor
	
	Duplicate/O diam dlogDp 
	dlogDp = Nan
	dlogDp = log(diam+0.5*binwidth)-log(diam-0.5*binwidth)
	
	Variable j
	variable numbins = numpnts(diam)
	
	Make/FREE/N=(numbins) Dl, Du

	For (j=0; j<numbins; j++)
		if (j == 0)
			Dl[j] = diam[j] - 0.5*binwidth[j]
			Du[j] = diam[j] + 0.5*binwidth[j]	
		elseif (j == (numbins-1))
			Dl[j] = diam[j] - 0.5*binwidth[j-1]
			Du[j] = diam[j] + 0.5*binwidth[j-1]
		else
			Dl[j] = diam[j] - 0.5*binwidth[j-1]
			Du[j] = diam[j] + 0.5*binwidth[j]	
		endif
	
	dlogDp[j] = log(Du[j])- log(Dl[j])	
	EndFor
	
	W=DWdlogDp*dlogDp
	
	Make/O/N=(numpnts(W)) AddW
	AddW=W[i]
	For (i=1; i<(numpnts(W)); i++)
		AddW[i] = AddW[i-1]+W[i]
	EndFor
	
	GM_num = W * ln(diam)
	GM_den = W
	GeoMean = exp(Sum(GM_num)/Sum(GM_den))
	
	Print "Geometric Mean is " + num2str(GeoMean)
	
	GM_num = W * ( ln(diam)-ln(GeoMean) )^2
	GM_den = W
	GeoSD = exp(sqrt(Sum(GM_num)/Sum(W)))
	Print "Geometric Standard Devation is " + num2str(GeoSD)
	
	AvgConc = sum(W)
	Print "Total Num Conc is " + num2str(Sum(W))
	
	Killwaves AddW, binwidth, dlogDp, GM_den, GM_num, W
	
End


//////////////////////////////////////////////////
///       Average Size Distribution           ////
//////////////////////////////////////////////////


Function AverageSizeDistribution()
	Variable Avg_Starttime, Avg_Stoptime
	Avg_Starttime = date2secs(2024,02,08)+ 12*60*60 + 34*60 +0  //Have to provide these
	Avg_Stoptime = date2secs(2024,02,08)+ 12*60*60 + 36*60 +0   // Have to provide these
	
	
	Setdatafolder root:Cummulative_HeatMap:Number:
	
	Wave Concatenated_Matrices
	Wave Concatenated_DateTimes
	Wave diameter
	

	
	FindLevel Concatenated_DateTimes, Avg_Starttime  //Find the first index when the specified time is greater than the time of a scan
	variable start_index = ceil(V_LevelX)
	
	FindLevel Concatenated_DateTimes, Avg_Stoptime
	variable stop_index = floor(V_LevelX)
	
	variable numbins = dimsize(Concatenated_Matrices,1)
	print numbins
	Make/N=(1,numbins)/O NC_Mean
	NC_Mean=0
	
	variable j
	For (j=0;j<(numbins-1); j++)
		Duplicate/O/R=[start_index,stop_index][j] Concatenated_Matrices, NC_subset
		NC_mean[0][j]= mean(NC_subset)
	EndFor
	
	
	string mywavename = "MeanSizeDistribution"
	Duplicate/O NC_mean $mywavename
	KillWaves NC_mean, NC_subset
	
	//Transpose so that you have a real size distribution
	
	Matrixtranspose $mywavename
	
	Display $mywavename vs diameter
	Label left "dNdlogdp (#/cm\\S3\\M)";DelayUpdate
	Label bottom "Diameter Midpoint (nm)";Delayupdate
	ModifyGraph log(bottom)=1
	ModifyGraph mode=6
	
	//Average total? Do statistics on this distribution?
	
	Variable GeoMean, GeoSD, AvgConc
	[GeoMean, GeoSD, AvgConc] = TSIStatistics($mywavename, diameter)

End



/////////////////////////////////////////////
/////////////////////////////////////////////
/////////////////////////////////////////////
////////////////////////////////////////////


Function concatedatafiles(type,variablename)
	variable type //(1=number; 2=mass)
	String variablename
	String ndfname
	
	//Define relevant datafolders
	If (type == 1)  //number
		DFREF MDF = root:Alltime: //Set a subfolder for temporary processing later on
		DFREF ndf = root:Number_Concentration:
		ndfname = "root:Number_Concentration:"
	
	Elseif (type == 2) //mass
		DFREF MDF = root:Alltime: //Set a subfolder for temporary processing later on
		DFREF ndf = root:Mass_Concentration:
		ndfname = "root:Mass_Concentration:"
		
	Else
		
		print "You have to choose 1 (Number) or 2 (Mass)"
	
	Endif
	
	SetDataFolder ndf //Number or Mass _Concentration
	variable ndfs = countobjectsDFR(ndf, 4)	//Count the number of data folders
	variable dfnumb // Index of data folder	
	
	String dfList = SortedDataFolderList(ndfname, 16)
	variable numDataFolders = ItemsInList(dfList)
	
	
	For (dfnumb=0;dfnumb<ndfs;dfnumb+=1)		//for each datafolder, duplicate the wave from the SMPS file folder and place together in a temporary folder for concatenation
		wave variablewave = $variablename
		string dfname = StringFromList(dfnumb, dfList)
		setdataFolder ndf
		setdataFolder dfname
		DFREF currdf = GetdataFolderDFR()

				//Get names for duplication
		wave variablewave = $variablename
		string newvariablename = "Temp_"+num2str(dfnumb)
		Duplicate/O variablewave, MDF:$Newvariablename
				
	endFor
	
	//Write code to give error if the numofdiambins of NConc is not the same
	
	setdatafolder mdf
	//create the lists of the matrix waves and datetime waves
		string namelist = wavelist("Temp*",";","")
	
	concatenate/O/NP=0 namelist, ConcatenatedVariable
	
	string concatstring = variablename// + "_concat"
	Duplicate/O ConcatenatedVariable $concatstring
	Killwaves concatenatedvariable
	
	
	For (dfnumb=0;dfnumb<ndfs;dfnumb+=1)	
	wave variablewave = $variablename
		dfname = getindexedObjNameDFR(ndf,4,dfnumb)
		setdataFolder MDF

		//Get names for duplication
		wave variablewave = $variablename
		newvariablename = "Temp_"+num2str(dfnumb)
		Killwaves $newvariablename
				
	endFor

End



Function MakeHeatmap_all_Number_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			heatmap_all_cumulative_LG(1)
		case 2:
			break
		endswitch
		
End

Function MakeHeatmap_all_Mass_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			heatmap_all_cumulative_LG(2)
		case 2:
			break
		endswitch
		
End

Function heatmap_all_cumulative_LG(type)
	variable type
	
	//Define relevant folders
	if (type ==1)
		DFREF ndf = root:Number_Concentration:
		DFREF all = root:AllTime:
		string variablename = "NConc"
	
	elseif (type ==2)
		DFREF ndf = root:Mass_Concentration:
		DFREF all = root:AllTime:
		variablename = "MConc"	
	else
		print "You have to choose 1 (Number) or 2 (Mass)"
		
	Endif
	
	setdatafolder ndf
	variable ndfs = countobjectsDFR(ndf, 4)
	
	string ndfname = GetdataFolder(1)
	string dfList = SortedDataFolderList(ndfname, 16)
	variable numDataFolders = ItemsInList(dfList)
	
	string dfname = StringFromList(0, dfList)
	setdataFolder ndf:$dfname

	//A heatmap requires x and y axis that have n+1 values compared the length and width of the 2D wave. 
	Duplicate/FREE :diam diamofone
	Duplicate/FREE :diam wave_delta
	wave_delta = 0
	variable i 
	
	for(i=1;i<ndfs;i+=1)
		dfname = StringFromList(i, dfList)
		setdataFolder ndf:$dfname
		Wave diam
		
		wave_delta = abs(diamofone-diam)
		if (sum(wave_delta) > 0.1)
			print "The files have different diameter bins and cannot be combined."  //Error if diameter bins dont match up.
			break
		endif
		
		
	endfor
	
	Setdatafolder all
	Duplicate/O diamofone, diameter
	Duplicate/O diamofone, diameter_bins
	
	MakeEdgesWave(diamofone, diameter_bins)
	
	Duplicate/O :SMPS_MidPoint, SMPS_MidPoint_Bins
	MakeEdgesWave(:SMPS_MidPoint, SMPS_MidPoint_Bins)
	
	GraphHeatMap(type)
	
End

Function GraphHeatMap(type)
	variable type
		
	//create the entire heatmap
	If (type ==1)
		Wave NConc, SMPS_MidPoint_Bins, Diameter_Bins
		display
		appendimage NConc vs {SMPS_MidPoint_Bins,Diameter_Bins};delayUpdate
		ModifyImage NConc ctab= {*,*,Geo,0}
		Label left "Diameter (nm)";DelayUpdate
		Label bottom "DateTime (DD:MM:YYYY HH:MM:SS)"
		SetScale d 0,0,"dat",SMPS_MidPoint_Bins

		ColorScale/A=RT/C/N=text0  ctab={0,100,Geo,0};DelayUpdate
		ColorScale/A=RT/C/N=text0 "dNdlogDp\\BMob\\M (#/cm\\S3\\M)"
		ColorScale/C/N=text0 image=NConc
	
	elseif(type ==2)
		Wave MConc, SMPS_MidPoint_Bins, Diameter_Bins
		display
		appendimage MConc vs {SMPS_MidPoint_Bins,Diameter_Bins};delayUpdate
		ModifyImage MConc ctab= {*,*,Geo,0}
		Label left "Diameter (nm)";DelayUpdate
		Label bottom "DateTime (DD:MM:YYYY HH:MM:SS)"
		ColorScale/A=RT/C/N=text0  ctab={0,100,Geo,0};DelayUpdate
		ColorScale/A=RT/C/N=text0 "dMdlogDp\\BMob\\M (ug/m\\S3\\M)"
		ColorScale/C/N=text0 image=MConc
		SetScale d 0,0,"dat",SMPS_MidPoint_Bins
	else
		print "The files have different diameter bins and cannot be combined."
	endif

End


Function IrregularTime_HeatMap_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			Setdatafolder root:
			NVAR avg_start_Y
			NVAR avg_start_Mon
			NVAR avg_start_D
			NVAR avg_start_H
			NVAR avg_start_Min
			NVAR avg_start_S
	
			NVAR avg_stop_Y
			NVAR avg_stop_Mon
			NVAR avg_stop_D
			NVAR avg_stop_H
			NVAR avg_stop_Min
			NVAR avg_stop_S
			
			NVAR interval
		
			string newfoldername = "root:IrregularTimeAvg:IrregAvg_" + num2str(avg_start_Y) + "_" + num2str(avg_start_Mon)+ "_" + num2str(avg_start_D) + "_"+ num2str(avg_start_H) + "_" + num2str(avg_start_H) + "_"+ num2str(avg_start_Min) + "_int" + num2str(interval)    
			SetDataFolder $newfoldername
			GraphHeatMap(1)
			GraphHeatMap(2)
			
		case 2:
			break
		endswitch
		
End


Function IrregularTime_Avg_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			IrregularTime_Avg()
			Setdatafolder root:
		case 2:
			break
		endswitch
		
End


Function IrregularTime_Avg()  
	
	Setdatafolder root:
	NVAR avg_start_Y
	NVAR avg_start_Mon
	NVAR avg_start_D
	NVAR avg_start_H
	NVAR avg_start_Min
	NVAR avg_start_S
	
	NVAR avg_stop_Y
	NVAR avg_stop_Mon
	NVAR avg_stop_D
	NVAR avg_stop_H
	NVAR avg_stop_Min
	NVAR avg_stop_S
	
	NVAR interval

	
	DFREF AllTime = root:AllTime
	DFREF TimeAvg = root:IrregularTimeAvg
	
	string newfoldername = "root:IrregularTimeAvg:IrregAvg_" + num2str(avg_start_Y) + "_" + num2str(avg_start_Mon)+ "_" + num2str(avg_start_D) + "_"+ num2str(avg_start_H) + "_" + num2str(avg_start_H) + "_"+ num2str(avg_start_Min) + "_int" + num2str(interval)   
	NewDataFolder/O $newfoldername
	DFREF newfolder = $newfoldername
	
	SetDataFolder AllTime
	
	
	//Generate timewaves
	concatedatafiles(1,"SMPS_Start")
	concatedatafiles(1,"SMPS_Stop")
	concatedatafiles(1,"SMPS_MidPoint")
	
	//Generate mass and number concentration 2D waves
	concatedatafiles(1,"NConc")
	concatedatafiles(2,"MConc") 
	

	
	//Change the global variables to a real time
	variable avg_starttime = date2secs(avg_start_Y, avg_start_Mon, avg_start_D) + 60*60*avg_start_H + 60*avg_start_Min + avg_start_S
	variable avg_stoptime = date2secs(avg_stop_Y, avg_stop_Mon, avg_stop_D) + 60*60*avg_stop_H + 60*avg_stop_Min + avg_stop_S
	
	
	//Find index for the specified start and stop time in the the concatenated timewaves
	Wave SMPS_Start, SMPS_Stop, SMPS_Midpoint
	
	Variable avgstart_index, avgstop_index 
	Findlevel/P/Q SMPS_Start, avg_starttime 
		if(V_Flag==0)
			avgstart_index = floor(V_LevelX)
			print avgstart_index
		else
			print "Starttime is out of range of data"
		endif
		
	Findlevel/P/Q SMPS_Stop, avg_stoptime 
		if(V_Flag==0)
			avgstop_index = floor(V_LevelX)
			print avgstop_index
		else
			print "Stoptime is out of range of data"
		endif
		
	
	//Copy the subset of the NConc 2-D matrix (and accompanying extra info) for the specified time bins
	Wave NConc, MConc, diameter, diameter_bins
	
	Duplicate/R=(avgstart_index, avgstop_index)/O NConc newfolder:NConc
	Duplicate/R=(avgstart_index, avgstop_index)/O MConc newfolder:MConc
	Duplicate/R=(avgstart_index, avgstop_index)/O SMPS_Midpoint newfolder:SMPS_MidPoint
	Duplicate/O diameter_bins newfolder:diameter_bins
	Duplicate/O diameter newfolder:diameter
	
	Setdatafolder newfolder
	
	//Makes a new wave that is the average size distribution for the specified time
	AvgSizeDistribution()
	
	//Makes separate waves for individual sample runs at the specified interval (in run #)
	SeparateSizeDistrforGraphs_Num(interval)	
	SeparateSizeDistrforGraphs_Mass(interval)
	
	//Makes a graph with size distribution for individual sample runs 
	makeSDgraphs_numb(newfoldername,"diameter",interval)
	
	//Do some statistics on the new size distribution
	Setdatafolder newfolder
	Variable GeoMean, GeoSD, AvgConc
	Wave Avg_NConc
	[GeoMean, GeoSD, AvgConc] = TSIStatistics(Avg_NConc, diameter)

	//Add the average size distribution and the statistics information to the graph that has the individual sample runs
	
	Duplicate/O :SMPS_MidPoint, SMPS_MidPoint_Bins
	MakeEdgesWave(:SMPS_MidPoint, SMPS_MidPoint_Bins)
	
	AppendtoGraph :Avg_NConc vs :diameter
	ErrorBars Avg_NConc SHADE= {0,4,(0,0,0,0),(0,0,0,0)},wave=(:Std_Nconc,:Std_Nconc)
	ModifyGraph log(bottom)=1
	Label left "dNdlogdp (#/cm\\S3\\M)";DelayUpdate
	Label bottom "Diameter Midpoint (nm)";Delayupdate
	ModifyGraph lsize(Avg_NConc)=2,rgb(Avg_NConc)=(0,0,0) //Make average black thick line
	
	//Makes a string that includes the prescribed start and stop times
	string str_start = num2str(avg_start_Mon) + "/" + num2str(avg_start_D) + "/" + num2str(avg_start_Y)+ " " + num2str(avg_start_H) + ":" + num2str(avg_start_H) + ":"+ num2str(avg_start_Min)
	string str_stop = num2str(avg_stop_Mon) + "/" + num2str(avg_stop_D) + "/" + num2str(avg_stop_Y)+ " " + num2str(avg_stop_H) + ":" + num2str(avg_stop_H) + ":"+ num2str(avg_stop_Min)
	
	TextBox/C/N=text0/F=0/A=RT "\JCAvg Number Dist.\r" + str_start + "\r" + str_stop + "\rGeo Mean = "+ num2str(GeoMean) + "\rGeom STD = " + num2str(GeoSD) + "\rTotal Conce = " + num2str(AvgConc) + ""
	
	
	//Repeat for Mass
	makeSDgraphs_mass(newfoldername,"diameter",interval)
	
	//Do some statistics on the new size distribution
	Setdatafolder newfolder
	Wave Avg_MConc
	[GeoMean, GeoSD, AvgConc] = TSIStatistics(Avg_MConc, diameter)

	//Add the average size distribution and the statistics information to the graph that has the individual sample runs
	
	AppendtoGraph :Avg_MConc vs :diameter
	ErrorBars Avg_MConc SHADE= {0,4,(0,0,0,0),(0,0,0,0)},wave=(:Std_Mconc,:Std_Mconc)
	ModifyGraph log(bottom)=1
	Label left "dMdlogdp (ug/m\\S3\\M)";DelayUpdate
	Label bottom "Diameter Midpoint (nm)";Delayupdate
	ModifyGraph lsize(Avg_MConc)=2,rgb(Avg_MConc)=(0,0,0) //Make average black thick line
	
	TextBox/C/N=text0/F=0/A=RT "\JCAvg Mass Dist.\r" + str_start + "\r" + str_stop + "\rGeo Mean = "+ num2str(GeoMean) + "\rGeom STD = " + num2str(GeoSD) + "\rTotal Conce = " + num2str(AvgConc) + ""
	
	Setdatafolder root:
End


// Separates 2D wave into individual 1D waves so that they can be plotted.
// Plotting every run is too much, so "interval" is an integer so that every "nth sample run" will be included
function SeparateSizeDistrforGraphs_Num(interval)
	variable interval
	string currdfr = GetDataFolder(1)
	
	Wave NConc
	variable i = 0
				
	//Transpose NConc 2D wave so that rows are diameters
	duplicate/O NConc, NConc_Trans
	Matrixtranspose NConc_Trans
		
	//Make each *interval* column of the transposed wave into individual 1D waves with unique names
	for (i=0;i<dimsize(NConc,0);i+=interval)
		string thiswavename = currdfr + "Size_Distribution_Scan_" + num2str(i)
		Matrixop/O $thiswavename = col(NConc_Trans,i)
		Redimension/N=-1 $thiswavename
	Endfor

End


function SeparateSizeDistrforGraphs_Mass(interval)
	variable interval
	string currdfr = GetDataFolder(1)
		
	Wave MConc
	variable i = 0		
				
	//Repeat for MConc
	Wave MConc
	duplicate/O MConc, MConc_Trans
	Matrixtranspose MConc_Trans
		
	for (i=0;i<dimsize(MConc,0);i+=interval)
		string thiswavename = currdfr + "Mass_Distribution_Scan_" + num2str(i)
		Matrixop/O $thiswavename = col(MConc_Trans,i)
		Redimension/N=-1 $thiswavename
	Endfor

End

// For a 2D wave of size distribution (rows are samples, columns are diameters), this finds the average signal at a given diameter
// And writes a 1D wave with the average and standard deviations
Function AvgSizeDistribution()
	Wave NConc, MConc, diameter_bins, diameter
		
	MatrixOP/O Avg_NConc = sumcols(replaceNaNs(NConc,0)) / numRows(Nconc) //??
	MatrixOP/O Std_Nconc = sqrt(varCols(NConc))
	
	Matrixtranspose Avg_NConc
	Matrixtranspose Std_Nconc
	
	Redimension/N=-1 Avg_NConc //Make Avg_NConc a 1D wave
	Redimension/N=-1 Std_NConc
	
	//Repeat for MConc
	
	MatrixOP/O Avg_MConc = sumcols(replaceNaNs(MConc,0)) / numRows(Nconc)
	MatrixOP/O Std_Mconc = sqrt(varCols(MConc))
	
	Matrixtranspose Avg_MConc
	Matrixtranspose Std_Mconc
	
	Redimension/N=-1 Avg_MConc //Make Avg_MConc a 1D wave
	Redimension/N=-1 Std_MConc
	
	
End


///////////////////////////////////////////////
///////////////////////////////////////////////
///////    Making ICARTT file          ////////
///////////////////////////////////////////////
///////////////////////////////////////////////


Function MakeICARTTTable_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			MakeICARTTTable_SMPS()
		case 2:
			break
		endswitch
		
End

Function InitializeICARTT_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			InitializeICARTTsection()
		case 2:
			break
		endswitch
		
End

Function InitializeICARTTsection()
	if(datafolderexists("root:ICARTTwaves")==0)
		NewDataFolder root:ICARTTwaves
	endif
	
	DFREF dfr_I = root:ICARTTwaves
	SetDataFolder dfr_I
	
	Variable/G ICARTTstart_Y
	Variable/G ICARTTstart_M
	Variable/G ICARTTstart_D
	Variable/G ICARTTstop_Y
	Variable/G ICARTTstop_M
	Variable/G ICARTTstop_D


End

Function MakeICARTTTable_SMPS()
	NVAR SoftwareVersion = root:SoftwareVersion
	
	DFREF dfr_I = root:ICARTTwaves
	
	concatedatafiles(1,"SMPS_Start")
	concatedatafiles(1,"SMPS_Stop")
	concatedatafiles(1,"SMPS_MidPoint")
	
	concatedatafiles(1,"Geo.Mean(nm)")
	
	If (SoftwareVersion==1)
		concatedatafiles(1,"Geo.Std.Dev") // AIM 11
		concatedatafiles(1,"SheathTemp(C)")
		concatedatafiles(1,"SheathPressure(kPa)")
	else
		concatedatafiles(1,"Geo.Std.Dev.") //AIM 10 and Willis box
		concatedatafiles(1,"SampleTemp(C)")
		concatedatafiles(1,"SamplePressure(kPa)")
	endif
	
	concatedatafiles(1,"TotalConc.(#/cm3)")
	concatedatafiles(1,"NConc_Total")
	concatedatafiles(1,"NConc")
	
	concatedatafiles(2,"MConc_Total")
	
	
	Setdatafolder root:AllTime
	
	Wave SMPS_Start, SMPS_Stop, SMPS_MidPoint
	//Round
	Duplicate/O SMPS_Start, dfr_I:Time_Start
	Duplicate/O SMPS_Stop, dfr_I:Time_Stop
	Duplicate/O SMPS_MidPoint, dfr_I:Time_Mid
	
	
	
	Duplicate/O :'TotalConc.(#/cm3)' dfr_I:TSI_NumbConc
	Duplicate/O :'NConc_Total' dfr_I:Farmer_NumbConc	
	Duplicate/O :'Geo.Mean(nm)' dfr_I:GeoMean
	Duplicate/O :'MConc_Total' dfr_I:Farmer_MassConc	
	
	If (SoftwareVersion==1)
		Duplicate/O :'Geo.Std.Dev' dfr_I:GeoStdDev  //AIM 11
		Duplicate/O :'SheathTemp(C)' dfr_I:Temp
		Duplicate/O :'SheathPressure(kPa)' dfr_I:Press
	Else
		Duplicate/O :'Geo.Std.Dev.' dfr_I:GeoStdDev //AIM10 and Willis box
		Duplicate/O :'SampleTemp(C)' dfr_I:Temp
		Duplicate/O :'SamplePressure(kPa)' dfr_I:Press
	EndIf
	
	Duplicate/O :NConc dfr_I:NConc
	
	
	Setdatafolder dfr_I
	Wave diameter
	Make/T/O VarNameWave
	varnamewave = {"Time_Start","SMPS_Stoptime","SMPS_MidPointTime","TSI_NumbConc","GeoMean", "GeoStdDev","Farmer_MassConc", "Farmer_NumbConc", "Temp","Press", "NConc"}
	variable i

	Wave Time_Start, Time_Stop, Time_Mid
	Time_Start = Round(Time_Start)
	Time_Stop = Round(Time_Stop)	
	Time_Mid = Round(Time_Mid)
	
	Edit Time_Start, Time_Stop, Time_Mid
	
	ModifyTable format(Time_Start)=8,format(Time_Stop)=8,format(Time_Mid)=8
	ModifyTable digits(Time_Start)=1, digits(Time_Stop)=1, digits(Time_Mid)=1
	

	For (i=3; i<numpnts(varnamewave); i++)
		string thisname = varnamewave[i] 
		AppendtoTable $thisname
		ModifyTable format($thisname)=3, digits($thisname)=1
	EndFor
	
	ModifyTable digits(:GeoStdDev) = 3
	
	Killwaves varnamewave

	SetDatafolder root:
End


function SeparateforICARTT()
	Wave NConc, diameter
	variable i = 0		
				
	
	string variablenames
	variablenames = ""
	for(i=0; i<(numpnts(diameter)); i+=1)
		variablenames += "D" +num2str(i) + ";"
	endfor

		
	//Make each *interval* column of the transposed wave into individual 1D waves with unique names
	for (i=0;i<dimsize(NConc,1);i++)
		string thiswavename = stringfromlist(i, variablenames)
		Matrixop/O $thiswavename = col(NConc,i)
		Redimension/N=-1 $thiswavename
	Endfor

End



/////////////////////////////////////////////
/////////////////////////////////////////////


Function TrimTable_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			TrimTable()
		case 2:
			break
		endswitch
		
End


Function TrimTable() 
		
	NVAR ICARTTstart_Y
	NVAR ICARTTstart_M
	NVAR ICARTTstart_D
	NVAR ICARTTstop_Y
	NVAR ICARTTstop_M
	NVAR ICARTTstop_D
	
	
	//
	variable starttime = date2secs(ICARTTstart_Y,ICARTTstart_M,ICARTTstart_D)
	variable stoptime = date2secs(ICARTTstop_Y,ICARTTstop_M,ICARTTstop_D+1)

	Setdatafolder root:ICARTTwaves
	DFREF icarttfdr = root:ICARTTwaves
	string ifdrname = "root:ICARTTwaves"
	variable numofwaves = CountObjects(ifdrname,1)
	
		
	variable i,j
	string timewavename = "Time_Start"
	
	FindValue/V=(starttime)/T=65 $timewavename
	variable startindex = V_Value
		if (V_Value == -1)
			startindex = 0
		Endif
		
		print num2str(startindex)
	
	FindValue/V=(stoptime)/T=65 $timewavename
	variable stopindex = V_Value+1
		if (V_Value == -1)
			stopindex = numpnts($timewavename)
		Endif

	For (j=0;j<numofwaves;j++)
			String thisotherwavename = GetIndexedObjName(ifdrname, 1, j)
			DeletePoints stopindex,100000, $thisotherwavename
			DeletePoints 0, startindex, $thisotherwavename
	EndFor

	
End

	
	
////////////////////////////////////////////////////////////////////////
/////////////    test procedures for troubleshooting    ////////////////    
////////////////////////////////////////////////////////////////////////

Function testscan()

	variable yearv, monthv, dayv, timestartHHv,timestartMMv,timestartSSv, runnum
	string therest
	string firstdataline =  "1,2023/7/29,08:44:44,27.8,98.3,47.1"
	
	//sscanf firstdataline, "%i,%i%*[/]%i%*[/]%i%*[,]%i%*[:]%i%*[:]%i%*[,]%s", scannum, yearv, monthv, dayv,timestartHHv,timestartMMv,timestartSSv, therest
	//sscanf firstdataline, "1,%d%*[/]%d%*[/]%d%*[,]%d%*[:]%d%*[:]%d%*[,]%s", yearv,monthv,dayv,timestartHHv,timestartMMv,timestartSSv, therest
	sscanf firstdataline, "1,%d%*[/]%d%*[/]%d%*[,]%d%*[:]%d%*[:]%d%*[,]%s", yearv,monthv,dayv,timestartHHv,timestartMMv,timestartSSv, therest
	
	print num2str(yearv)
	print num2str(monthv)
	print num2str(dayv)
	print num2str(timestartHHv)
	print num2str(timestartMMv)
	print num2str(timestartSSv)

End

Function testcross()
		DFREF dfrSD = root:size_distributions_Numb
	DFREF dfrNC = root:Number_Concentration
	string Foldername, newdatafoldername
	variable SDnumvar = 0
	string SDnumstr = num2str(SDnumvar)
	variable SDnumDataFolders = countobjectsDFR(dfrNC,4)
	variable i
	
	Setdatafolder dfrNC
	for(i=0;i<SDnumDatafolders;i+=1)
		Foldername = GetindexedObjNameDFR(dfrNC,4,i)
		SetdataFolder ":'"+foldername+"':"
		SDnumvar+=1
		SDnumstr = num2str(SDnumvar)
		//function stuff here
		
		wave NConc, diam, datetimewave
		newdatafoldername = "root:Size_Distributions_:" + Foldername		
		
		//Get the number conc wave first
			string tempnameNConc = ":Size_Distribution_Holder"
			duplicate/O NConc,$(newdatafoldername+tempnameNConc)
		ENdFor
	
ENd

Function testnames()
	string lnames = "date,dateW, date"
	lnames = replacestring("date_",lnames,"date")
	print lnames
End



Function testgrep()
	variable refnum
	//String thisfilename
	//thisfilename = "C:\Users\lgarofal\OneDrive - Colostate\Documents\Documents\SMPS Software\Willis SMPS\From AIM 11\2024-02-29_112852_SMPS.csv"
	//thisfilename = "C:\Users\lgarofal\OneDrive - Colostate\Documents\Documents\SMPS Software\Willis SMPS\Willis_DifferentDate\2024_03_01_10_15_27_SMPS.txt"
	
	NewPath/O path, "C:\Users\lgarofal\OneDrive - Colostate\Documents\Documents\SMPS Software\Willis SMPS\Willis_DifferentDate"
	string thisfilename = "2024_03_01_10_15_27_SMPS.txt"	
	
	//NewPath/O path, "C:\Users\lgarofal\OneDrive - Colostate\Documents\Documents\SMPS Software\Willis SMPS\From AIM 11"
	//string thisfilename = "2024-02-29_112852_SMPS.csv"	
	Open/R/P=path/Z=2 refnum as thisfilename
	Variable lineNumber = 0
	String firstdataline
	
	Grep/e=("garbage")  thisfilename
	print V_flag
	print V_startParagraph
	Grep/list/e=("Scan Number")  thisfilename //AIM 11 variable name
//	Grep/e=("Scan Number")  thisfilename //AIM 11 variable name
	print V_flag
	
	variable NameLine = V_startParagraph 
	
	Print NameLine
	Close/A
End   

function testopen()
	setdatafolder root:test
	
	string file_ext = ".txt"
   variable f=0
   string fname            
       
   //Ask the user to identify a folder on the computer
   getfilefolderinfo/D
   
   //Store the folder that the user has selected as a new symbolic path in IGOR called cgms
   newpath/O cgms S_path

	//Create a list of all files that are .txt files in the folder. -1 parameter addresses all files.
	string filelist= indexedfile(cgms,-1,file_ext)
   variable refNum    
    //Begin processing the list
   do
        //store the ith name in the list into wname.
        fname = stringfromlist(f,filelist)

		Open/R/P=cgms/Z refNum as fname
		variable err = V_flag


			if (err == -1)
		Print "DemoOpen cancelled by user."
		return -1
	endif

	if (err != 0)
		DoAlert 0, "Error in DemoOpen"
		return err
	endif
	
	variable lineNumber=0
	
	
		f++
		Close refNum
	Loadwave/J/L={25,26,0,0,0}/A/P=cgms fname
	while(f<itemsinlist(filelist))
	
End

	
Function KillAllData_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			KillEverything()
		case 2:
			break
		endswitch
		
End

Function KillEverything()
	doalert/T="Delete all?" 1, "Are you sure?\r\rSelect Yes to delete all data: graphs, tables, and \rwaves. \r\rSelect No to cancel."
	If (V_flag==1)
		KillAllGraphs()
		KillAllTables()
		KillAllData()
	Endif
End

Function KillAllData()

	DFREF All_DF = root:Alltime: //Set a subfolder for temporary processing later on
	DFREF ICARTT_DF = root:ICARTTwaves:
	DFREF Irreg_DF = root:IrregularTimeAvg
	DFREF Mass_DF = root:Mass_Concentration
	DFREF Numb_DF = root:Number_Concentration
	DFREF SD_Mass = root:Size_Distributions_Mass
	DFREF SD_Numb = root:Size_Distributions_Numb
	
		
	Setdatafolder All_DF
	Killwaves/a/z
	
	Setdatafolder ICARTT_DF 
	Killwaves/a/z
	
	Setdatafolder root:
	variable i
	For (i=0;i<(CountObjectsDFR(Irreg_DF,4));i=1)
		Setdatafolder Irreg_DF
		KillDataFolder $GetIndexedObjNameDFR(Irreg_DF,4,i)
	EndFor
	
	For (i=0;i<CountObjectsDFR(Mass_DF,4);i=1)
		Setdatafolder Mass_DF
		KillDataFolder $GetIndexedObjNameDFR(Mass_DF,4,i)
	EndFor
	
	For (i=0;i<CountObjectsDFR(Numb_DF,4);i=1)
		Setdatafolder Numb_DF
		KillDataFolder $GetIndexedObjNameDFR(Numb_DF,4,i)
	EndFor
	
	For (i=0;i<CountObjectsDFR(SD_Mass,4);i=1)
		Setdatafolder SD_Mass
		KillDataFolder $GetIndexedObjNameDFR(SD_Mass_DF,4,i)
	EndFor
	
	For (i=0;i<CountObjectsDFR(SD_Numb,4);i=1)
		Setdatafolder SD_Numb
		KillDataFolder $GetIndexedObjNameDFR(SD_Numb,4,i)
	EndFor
	
	Setdatafolder root:
	
End


FUNCTION SMPS_Bring_Panel_2_Front()
	
	IF(strlen(WinList("*SMPS*",";","WIN:64"))>0)	
		DoWindow/F SMPS_Data_Processor
		
	ELSE
		DoAlert 1, "There is no SMPS!  Do you want to create one?"
		
		IF(V_Flag==1)
			InitializePanel()
			Execute "SMPS_Data_Processor()"
		ENDIF
	ENDIF
	
END