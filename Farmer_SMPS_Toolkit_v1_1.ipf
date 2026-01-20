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
	
	Variable/G PP_VersionNumber
	Variable/G PP_FlagWave_Start
	variable/G PP_FlagWave_End
	Variable/G PP_FlagWave_Value
	
	Variable/G UTC_offset_StandardTime
	
	Variable/G MinimumDiameter
	Variable/G MaximumDiameter
	
	Variable/G SoftwareVersion // 0 is 10.3 and from the box (DDMMYY). 1 is from AIM11. 2 is from 10.3 (MMDDYY), 3 is for ICARTT files
	Make/T/N=3/O VersionNames
	VersionNames = {"AIM 10.3 DDMMYYYY","AIM 11","AIM 10.3 YYYYMMDD", "Farmer Group ICARTT"}
	Make/O/N=3 VersionTypes
	VersionTypes = {0,1,2,3}
	//Slider slider0 variable=SoftwareVersion,userTicks={VersionTypes,VersionNames}
	
	Variable/G Interval =10 //default to plot every 10th scan
	
	If (datafolderexists("root:AllTime") ==0)
		NewDataFolder AllTime
		NewDataFolder ICARTTwaves
		NewDataFolder IrregularTimeAvg
		NewDataFolder Number_Concentration
		NewDataFolder Size_Distributions_Numb
		NewDataFolder Size_Distributions_Mass
	Endif
	

	
	InitializeICARTTsection()
	
	Execute "SMPS_Data_Processor()"
	
End

Window SMPS_Data_Processor() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(48,54,929,990) as "SMPS_DataViewer_FarmerGroup"
	ModifyPanel cbRGB=(61166,61166,61166), frameStyle=1, frameInset=7
	ShowTools/A
	ShowInfo/W=$WinName(0,64)
	SetDrawLayer UserBack
	DrawPICT 723,8,0.04329,0.0470085,PICT_1
	SetDrawEnv linethick= 2
	DrawLine 12,359,1114,359
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
	DrawRect 21,391,214,475
	DrawText 101,409,"Start Time"
	SetDrawEnv linethick= 0,fillfgc= (49151,65535,65535),fillbgc= (49151,65535,65535)
	DrawRect 220,392,393,476
	DrawText 278,411,"Stop Time"
	SetDrawEnv linethick= 0,fillfgc= (65535,49151,62258),fillbgc= (65535,49151,62258)
	DrawRect 360,643,731,740
	DrawText 419,667,"\\JCICARTT Time Range --- Dates Inclusives"
	SetDrawEnv linethick= 2
	DrawLine 12,753,1114,753
	DrawText 64,751,"\\JCFor reference:\rUTC = MST + 7\rUTC = EST + 5"
	DrawText 23,296,"1. Specify Diameter Sizes.\rIf 0, will use min and max diameters in TSI file"
	TitleBox Title01,pos={11.00,9.00},size={287.00,28.00},title="Farmer Lab SMPS Data Processor"
	TitleBox Title01,help={"This Processor can only work with AIM 10.3 Files"}
	TitleBox Title01,fSize=20,frame=0
	TitleBox Title02,pos={397.00,11.00},size={263.00,21.00},title="Adam De Groodt and Lauren Garofalo"
	TitleBox Title02,help={"As this was written Lauren Garfalo was a research scientist in the Farmer lab and Adam De Groodt was a 2nd year Ph.D. Student in the Farmer Lab. "}
	TitleBox Title02,fSize=16,frame=0
	TitleBox Title03,pos={448.00,41.00},size={182.00,45.00},title="Correspondence to\rAdam.De_Groodt@colostate.edu\rOr Lauren.Garofalo@colostate.edu"
	TitleBox Title03,help={"Please do not be afraid to reach out to me for help.\rIf I am gone from the lab when you are looking to use this then ask someone around the lab if they happen to have my information.\rDelphine is the person that is most likley to have it. \r-Adam"}
	TitleBox Title03,fSize=12,frame=0
	Button process_databutt,pos={15.00,127.00},size={262.00,33.00},proc=LoadOneFile_Button,title="Load and Process One File"
	Button process_databutt,help={"This button will allow the user to load in the datafile that will be analyzed."}
	Button process_databutt,fSize=20
	Button help_butt,pos={752.00,177.00},size={105.00,39.00},proc=help_button,title="Help"
	Button help_butt,help={"The Help Button Provides some Instructions as well as errors that could occur within the dataloading and analysis process"}
	Button help_butt,fSize=20
	Button Setup_waves_for_tseries_nconc_butt,pos={366.00,258.00},size={214.00,43.00},proc=MakeWavesforAllTime_Button,title="Set up waves for full time series \r(Number and Mass)"
	Button Setup_waves_for_tseries_nconc_butt,help={"Grabs the nessesary wave from the loaded in Number Concentration data that has been loaded in and puts them into the cummulative number folder\r Then concatenates the waves to prep for the creation of the graph"}
	TitleBox cumulative_title,pos={14.00,227.00},size={179.00,28.00},title="Plot a full time series"
	TitleBox cumulative_title,help={"These buttons perform cummulative work that will be done on the files loaded in thusfar.\rRemmeber to reset the folder anytime that more data is being loaded in and is wanting to be added to to the cummulative work. "}
	TitleBox cumulative_title,fSize=20,frame=0
	Button get_tseries_graph_butt_numb,pos={369.00,304.00},size={219.00,43.00},proc=Make_tseries_graph_button_numb,title="Make Time Series Graphs \r(Integrated Number and Mass Conc.)"
	Button get_tseries_graph_butt_numb,help={"Goes to the Concatenated_Wave_Number folder and creates the time series graph based on the waves that have been loaded in there. "}
	TitleBox ICARTT_title,pos={15.00,636.00},size={164.00,28.00},title="Make ICARTT Table"
	TitleBox ICARTT_title,help={"Buttons that perform Hourly Average concentrations.\rCummulative Work process above must have been preformed in order to perform Houly Average work. \rThe Hourly Average buttons need the first points year, month, day, hour, min, sec to work."}
	TitleBox ICARTT_title,fSize=20,frame=0
	TitleBox SDwork,pos={15.00,490.00},size={165.00,28.00},title="Plot individual files"
	TitleBox SDwork,help={"This section allows the creation of size distribution graphs."}
	TitleBox SDwork,fSize=20,frame=0
	Button getmakesizedistwaves_numb,pos={15.00,527.00},size={198.00,37.00},proc=getsizedistwaves_button,title="Generate Number and \rMass Size Distributions"
	Button getmakesizedistwaves_numb,help={"Gets the waves, organizes them and then generates the size distributions to be viewed with the \"Make Number Size Distribution Graphs\" button. "}
	Button makeSDGraphs,pos={463.00,515.00},size={150.00,40.00},proc=MakeSDGraphs_button_numb,title="Plot All Scans in File\rNumber"
	Button makeSDGraphs,help={"Makes all the SD graphs in individual graphs for a data file loaded in.\rUser must copy the full path and then paste it into the popup generated when the button is pressed. "}
	Button makeSDGraphs,fColor=(49151,53155,65535)
	Button Killallgraphs_butt,pos={699.00,28.00},size={125.00,44.00},proc=Kill_All_Graphs_button,title="Kill All Graphs"
	Button Killallgraphs_butt,help={"Kills All Current Graphs Open within the File"}
	Button MakeMSDGraphs,pos={472.00,563.00},size={150.00,40.00},proc=MakeSDGraphs_button_mass,title="Plot All Scans in File\rMass"
	Button MakeMSDGraphs,help={"Makes a Size Distribution Graph for the Full path to the folder.\rUser must copy the full path and then paste it into the popup generated when the button is pressed. "}
	Button MakeMSDGraphs,fColor=(49151,53155,65535)
	TitleBox expworktitlebox,pos={21.00,366.00},size={226.00,28.00},title="Plot a specific time period"
	TitleBox expworktitlebox,fSize=20,frame=0
	Button Kill_All_Tables_Button,pos={702.00,73.00},size={125.00,44.00},proc=Kill_All_Tables_button,title="Kill All Tables"
	Button Kill_All_Tables_Button,help={"Kills All Current Tables Open within the File "}
	Button Heatmap_Numb_butt,pos={627.00,514.00},size={150.00,40.00},proc=MakeHeatmap_Numb_button,title="Make Heat Map for File\rNumber"
	Button Heatmap_Numb_butt,help={"Make a Heat Map for a specific file in the Size Distribution folder.\rUser will need to provide a full path to the folder desired"}
	Button Heatmap_Numb_butt,fColor=(49151,53155,65535)
	Button Heatmap_Numb_butt1,pos={625.00,568.00},size={150.00,40.00},proc=MakeHeatmap_Mass_button,title="Make Heat Mapfor File \rMass"
	Button Heatmap_Numb_butt1,help={"Make a Heat Map for a specific file in the Size Distribution folder.\rUser will need to provide a full path to the folder desired"}
	Button Heatmap_Numb_butt1,fColor=(49151,53155,65535)
	Button Heatmap_All_Individual,pos={16.00,572.00},size={195.00,50.00},proc=MakeHeatmap_all_individual_button,title="Make \rN = (number of files) \r Heat Maps"
	Button Heatmap_All_Individual,help={"Make a Heat Map for a specific file in the Size Distribution folder.\rUser will need to provide a full path to the folder desired"}
	SetVariable setvar0,pos={18.00,88.00},size={362.00,41.00},title="\\Z20Assumed Density of Aerosol, g cm\\S-3"
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
	Button Heatmap_All,pos={593.00,259.00},size={120.00,37.00},proc=MakeHeatmap_all_Number_button,title="Make Heat Map \r (Number)"
	Button Heatmap_All_Individual2,pos={598.00,308.00},size={113.00,37.00},proc=MakeHeatmap_all_Mass_button,title="Make Heat Map\r (Mass)"
	SetVariable indivfile_Y6,pos={45.00,414.00},size={65.00,18.00},title="Year"
	SetVariable indivfile_Y6,limits={-inf,inf,0},value= avg_start_Y
	SetVariable indivfile_Y7,pos={47.00,434.00},size={65.00,18.00},title="Month"
	SetVariable indivfile_Y7,limits={-inf,inf,0},value= avg_start_Mon
	SetVariable indivfile_Y8,pos={46.00,457.00},size={65.00,18.00},title="Day"
	SetVariable indivfile_Y8,limits={-inf,inf,0},value= avg_start_D
	SetVariable indivfile_Y9,pos={135.00,433.00},size={65.00,18.00},title="Minute"
	SetVariable indivfile_Y9,limits={-inf,inf,0},value= avg_start_Min
	SetVariable indivfile_Y0,pos={135.00,411.00},size={65.00,18.00},title="Hour"
	SetVariable indivfile_Y0,limits={-inf,inf,0},value= avg_start_H
	SetVariable indivfile_Y06,pos={135.00,454.00},size={65.00,18.00},title="Second"
	SetVariable indivfile_Y06,limits={-inf,inf,0},value= avg_start_S
	SetVariable indivfile_Y07,pos={229.00,415.00},size={65.00,18.00},title="Year"
	SetVariable indivfile_Y07,limits={-inf,inf,0},value= avg_stop_Y
	SetVariable indivfile_Y08,pos={234.00,437.00},size={65.00,18.00},title="Month"
	SetVariable indivfile_Y08,limits={-inf,inf,0},value= avg_stop_Mon
	SetVariable indivfile_Y09,pos={242.00,459.00},size={65.00,18.00},title="Day"
	SetVariable indivfile_Y09,limits={-inf,inf,0},value= avg_stop_D
	SetVariable indivfile_Y10,pos={311.00,435.00},size={65.00,18.00},title="Minute"
	SetVariable indivfile_Y10,limits={-inf,inf,0},value= avg_stop_Min
	SetVariable indivfile_Y01,pos={311.00,413.00},size={65.00,18.00},title="Hour"
	SetVariable indivfile_Y01,limits={-inf,inf,0},value= avg_stop_H
	SetVariable indivfile_Y11,pos={311.00,456.00},size={65.00,18.00},title="Second"
	SetVariable indivfile_Y11,limits={-inf,inf,0},value= avg_stop_S
	Button button0,pos={605.00,373.00},size={149.00,53.00},proc=IrregularTime_Avg_button,title="Find Irregular Time \r Average Size Distribution"
	Button button0,labelBack=(49151,65535,65535),fColor=(49151,65535,65535)
	Button button1,pos={608.00,428.00},size={149.00,53.00},proc=IrregularTime_HeatMap_button,title="Make Irregular Time \r Heat Map"
	Button button1,labelBack=(49151,65535,65535),fColor=(49151,65535,65535)
	Button MakeICARTTTable,pos={190.00,665.00},size={148.00,43.00},proc=MakeICARTTTable_button,title="Kill All Tables and \rMake ICARTT Table"
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
	Button InitializeICARTT,pos={25.00,664.00},size={150.00,20.00},proc=InitializeICARTT_button,title="Initialize ICARTT section"
	SetVariable Interval,pos={446.00,398.00},size={125.00,33.00},bodyWidth=21,title="\\JRPlot every nth scan\rinterval:"
	SetVariable Interval,limits={1,inf,0},value= Interval
	Slider slider0,pos={55.00,37.00},size={159.00,45.00}
	Slider slider0,limits={0,3,1},variable= SoftwareVersion
	Slider slider0,userTicks={VersionTypes,VersionNames}
	Button Kill_All_Data,pos={703.00,116.00},size={125.00,44.00},proc=KillAllData_button,title="Kill All Data"
	Button Kill_All_Data,help={"Kills All Data in the file"}
	Button Kill_All_Data,fColor=(65535,16385,16385)
	SetVariable UTCoffset,pos={39.00,691.00},size={130.00,18.00},title="UTC = Local ST + "
	SetVariable UTCoffset,limits={-inf,inf,0},value= UTC_offset_StandardTime
	CheckBox Export_Check,pos={388.00,91.00},size={238.00,15.00},proc=Export_CheckProc,title="Export CSVs and figures of individual files?"
	CheckBox Export_Check,variable= Check_Box_Export_Single_File
	CheckBox Create_Symbolic_Path_for_Export_checkbox,pos={386.00,111.00},size={201.00,30.00},proc=Create_Symbolic_Path_for_Export_checkboxProc,title="Save exported files to one location?\r (Only works with multiload)"
	CheckBox Create_Symbolic_Path_for_Export_checkbox,value= 0
	TitleBox PP_title1,pos={15.00,760.00},size={138.00,28.00},title="Post-Processing"
	TitleBox PP_title1,help={"Buttons that move important waves to post-processing folder."}
	TitleBox PP_title1,fSize=20,frame=0
	Button PP_MoveWaves2PP,pos={16.00,788.00},size={192.00,20.00},proc=PP_MoveWaves2PP_button,title="1. Move Waves to Post-Processing"
	Button PP_CreateTime_Series1,pos={214.00,789.00},size={151.00,20.00},proc=PP_CreateTSeries_button,title="Create Time Series Graph"
	Button PP_SetFlags_Button,pos={19.00,838.00},size={98.00,21.00},proc=PP_Set_Flags_button,title="3. Set Flags"
	SetVariable PP_SetVar_FlagWave_StartAdjust,pos={20.00,861.00},size={201.00,18.00},title="Flag Wave Start Index"
	SetVariable PP_SetVar_FlagWave_StartAdjust,limits={0,inf,1},value= PP_FlagWave_Start
	SetVariable PP_SetVar_FlagWave_Value,pos={22.00,902.00},size={201.00,18.00},title="Flag Wave Value"
	SetVariable PP_SetVar_FlagWave_Value,limits={0,1,1},value= PP_FlagWave_Value
	SetVariable PP_SetVar_FlagWave_EndAdjust2,pos={22.00,882.00},size={201.00,18.00},title="Flag Wave End Index"
	SetVariable PP_SetVar_FlagWave_EndAdjust2,limits={0,inf,1},value= PP_FlagWave_End
	Button PP_Mask_Data_Button1,pos={120.00,837.00},size={98.00,21.00},proc=PP_Mask_Data_button,title="4. Mask Data"
	Button PP_CreateMaskTime_Series2,pos={18.00,813.00},size={186.00,21.00},proc=PP_CreateMaskTime_Series_button,title="2. Create Mask Time Series Graph"
	Button PP_Reset_Mask_Waves_Button,pos={217.00,812.00},size={128.00,21.00},proc=PP_Reset_Mask_Waves_button,title="Reset Mask Waves"
	Button PP_MakeICARTTTable_SMPS_button,pos={394.00,788.00},size={237.00,21.00},proc=PP_MakeICARTTTable_SMPS_button,title="Create Post Processing ICARTT Table"
	SetVariable setvar1,pos={30.00,301.00},size={146.00,18.00},title="Minimum Diameter"
	SetVariable setvar1,limits={-inf,inf,0},value= MinimumDiameter
	SetVariable setvar2,pos={30.00,324.00},size={146.00,18.00},title="Maximum Diameter"
	SetVariable setvar2,limits={-inf,inf,0},value= MaximumDiameter
	Button button2,pos={567.00,165.00},size={160.00,46.00},proc=checkdiam_button,title="Check that diameters in\r all files are the same"
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

function help_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			help_button_for_button()
		case 2:
			break
		endswitch
end

//12/8/2025: AJD Edited. Edited 'Autogenerated Graphs when loading datafiles' section
//Changed graph names to match the generated graphs (single file load; multifile keeps same structure but adds numbers with number of files loaded (graph3,Graph4,Graph5...etc)
//Commented the section on table stats which does not appear when loading single or multiple files
function help_button_for_button()
	string SMPSBaseName= UniqueName("SMPS_Data_Processor_Help", 10, 0) 
	NewPanel /K=1 /EXT=0 /HOST=SMPS_Data_Processor  /N=SMPS_Data_Processor_Help /W=(0, 0, 0.86, 0.67)
	NewNotebook /HOST=# /N=$SMPSBaseName /F=0 /K=1 /OPTS=(0^1 + 0^2 + 0^3)  /W=(0,0,1,1)
	Notebook # text="This is the window generated by activating the SMPS_Data_Processor help button\r"
	Notebook # text="\r"
	Notebook # text="The SMPS_Data_Processor is able to load one or multiple .txt or .csv files that \r"
	Notebook # text="	are exported by AIM V10.3 or AIM 11 software, or internal datalogging from an \r"  
	Notebook # text="	SMPS. The data is loaded and can be viewed on different time scales\r"
	Notebook # text="	One can generate a table of concatenated data from multiple files suitable\r"
	Notebook # text="	for an ICARTT file\r"
	Notebook # text="\r"
	Notebook # text="The panel can accept several different formats\r"
	Notebook # text="1. AIM 10.3 with YYYYMMDD format\r"
	Notebook # text="2. AIM 11 with DDMMYYYY format\r"
	Notebook # text="3. AIM 10.3 with DDMMYYY format\r"	
	Notebook # text="4. ICARTT files (generated by Farmer group)\r"
	Notebook # text="\r"	
	Notebook # text="For all exported datafiles\r"
	Notebook # text="\r"
	Notebook # text="The exported textfile from the AIM software must be exported with either\r"
	Notebook # text="	number dW/dlogDp, be in the comma delimited format, and be in the\r"
	Notebook # text="	row orientation. The raw data must be unchecked and the date format must\r"
	Notebook # text="	match the format above. The exported number format must be in decimal point and\r"
	Notebook # text="	for something with many scans the checkmarked box of 'Export all Channels'\r"
	Notebook # text="	must be checked.\r"
	Notebook # text="\r"
	Notebook # text="To load one datafile, click 'Load and Process One File.' A dialog will appear\r"
	Notebook # text="	for you to direct to the file of interest.\r"
	Notebook # text="\r"
	Notebook # text="To load multiple datafiles, click the 'Load and Process All Files in a Folder.'A \r"
	Notebook # text="	dialog will appear for you to direct to the folder on interest. You will not see\r"
	Notebook # text="	the files./r"
	Notebook # text="\r"
	Notebook # text="The code generates an integrated number and mass concentration from the size distributions\r"	
	Notebook # text="You can compare the TSI number to the Farmer integrated number concentration for sanity\r"
	Notebook # text="\r"
	Notebook # text="\r"	
	Notebook # text="Plot a full time series - To generate number and mass concentration and 2D image plots\r"
	Notebook # text="of size distributions. You must click this to move forward with following section. \r"	
	Notebook # text="All files must have the same diameter bins. \r"	
	Notebook # text="\r"	
	Notebook # text="Plot a specific time period - to generate average size distributions and 2D image plots.\r"
	Notebook # text="of a user-defined subset of time\r"
	Notebook # text="Plot individual files - to generate size distributions and 2D image plots for an individual file\r"
	Notebook # text="Must click 'Generate Number and Mass Size Distributions' before entering start date and time"
	Notebook # text="\r"	
	Notebook # text="Make ICARTT Table - To generate a table suitable to use with ICARTT_GUI managed by CU Boulder\r"
	Notebook # text=" https://cires1.colorado.edu/jimenez-group/wiki/index.php/Analysis_Software#ICARTT_Igor_Software\r"
	Notebook # text="Trim ICARTT Table to a subset of data. Days are inclusive so 2024, 03, 14 to 2024, 03, 15 will\r"
	Notebook # text="go from Midnight on March 14 to 11:59pm on March 15"	
	Notebook # text="\r"
	Notebook # text="\r"
	Notebook # text="Autogenerated Graphs when loading datafiles\r"  
	Notebook # text="	A. Graph0. NConc_Total vs datetimewave\r"
	Notebook # text="		Time series of integrated number concentration of\r"
	Notebook # text="		the Igor generated Tseries of the data.\r"
	Notebook # text="		Unless there is something wrong, these should both match up pretty well with\r"
	Notebook # text="		each other (within 2% at least)\r"
	Notebook # text="\r"
	Notebook # text="	B. Graph1. AIM_Igor_Difference\r"
	Notebook # text="		This table shows the difference in the integrated NConc vs the TSI Total Conc. We have the timeseries of both\r"
	Notebook # text="		recreated (NConc_Total) and SMPS analzyed TSI (TotalConc.(#/cm3) data and a wave showing the difference ('percent_diff').\r"
	Notebook # text="		These three waves are found underneath the each number concentration file (corresponding to the .txt or .csv file loaded in,\r"
	Notebook # text="\r"
//	Notebook # text="	D. SMPS_TConc_Stats_Table\r"
//	Notebook # text="		This table shows the stats ran on the NConc wave (if you are looking at number conc.\r"
//	Notebook # text="\r"
	Notebook # text="	C. Graph2. MConc_Total vs datetimewave\r"
	Notebook # text="		Time series of recreated integrated mass concentration using the user value of assumed aerosol density.\r"
	Notebook # text="\r"

	Notebook # text="If you are seeing this, scroll to the top!\r"
	
	
	

end

//////////////////////////////////////////////
//////Functions that get the data/////////////
//////////////////////////////////////////////



function gdatanumb()  // Load onefile files
	

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
	 
	//Initialize date and time variables
	variable yearv, monthv, dayv, timestartHHv,timestartMMv,timestartSSv, scannum
	string therest
   NVAR densityconv = root:density
	
	//Finds the first line of data (26 for v10.3 Nano and regular SMPS)
	Variable lineNumber = 0
	String firstdataline
	NVAR SoftwareVersion = root:softwareversion
	
	//More variable
	String lnames, tmpData
	variable NameLine, numofheaderlines
	
	switch(softwareversion)
		case 0:
		case 1:
		case 2:  //If statements were already written for 0,1,2, so I just left it altogether here. Could be changed to use switch-case for 0,1,2 LG
		
		Grep/list/e=("Sample #")  s_Filename //Find the the variable names line in the code
		If (V_startParagraph == -1)
			Grep/list/e=("Scan Number")  s_Filename //AIM 11 variable name
			Grep/e=("Scan Number")  s_Filename //AIM 11 variable name
		Endif
		NameLine = V_startParagraph //NameLine is line number of the line containing the variable list
		lnames = s_value
		
		do
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
    break
    
    case 3:
    //ICARTT file - structured a completely different way, so the readfile is totally different from the TSI SMPS software
	do
		FReadLine refnum, tmpData
        if (strlen(tmpData) == 0)
            return -1           // Error - end of file
        endif
        
        if (lineNumber == 0)
            sscanf tmpData, "%d[, ]%s",numofheaderlines, therest	
		   		
        elseif (lineNumber == 6)
				sscanf tmpData, "%d,%d,%d,%s", yearv, monthv,dayv,therest
        elseif (lineNumber == (numofheaderlines-1))
        		lnames = tmpData
            break  //once we reach the line with header info
        endif
        lineNumber += 1
    while(1)   
   	NameLine = numofheaderlines-1
	break
	
	Endswitch
	   
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
	lnames = ReplaceString(";",lnames,"") // AIM 11 has extra semicolons that mess things up!
	lnames = ReplaceString(",",lnames,";") //Igor functions like working with semicolons (;) but not commas (,) (see help for ItemsInList)
	lnames = replacestring(" ",lnames,"") //remove spaces from variable names; fixes concatenate error we were seeing earlier. 
	lnames = replacestring("date_",lnames,"date") //to handle FROG and FROGSICLE data where an underscore was added by hand
	lnames = replacestring("date",lnames,"DateSMPS") //replace variable name "date" with "DateSMPS" to avoid conflict with Igor date   //This is a problem for AIM 11
	
	if(softwareversion ==3)
		string firstnames, diameternames //Gross. There has to be a better way to do this
	
		diameternames = lnames[strsearch(lnames, "MdPtDiam", 2)+8, strlen(lnames)]
		firstnames = lnames[0,strsearch(lnames, "MdPtDiam", 2)-1]
		diameternames = replacestring("MdPtDiam",diameternames,"") //Remove MdPtDiam from diameter bin variable names		
		diameternames = replacestring("_",diameternames,".")
		lnames = 	firstnames+diameternames	
		lnames = TrimString(lnames,1) // Theres a weird \r at the end of the variable name row
		if (stringmatch(lnames[strlen(lnames)-1], "!;"))  
			lnames = lnames + ";"
		endif
	Endif
	
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
	String Curr_DF_Name = datafoldername+"_Numb"
	
	//Load the data from the file we already found with the dialog
	
	switch(softwareversion)
		case 0:
		case 1:
			Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/V={"\t,"," $",1,0} S_filename //DDMMYYY for 
			break
		case 2:
			Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/R={English,2,2,2,2,"Year/Month/DayOfMonth",40}/A s_filename //YYYYMMDD
			break
		case 3:
			Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/D S_filename  //double precision or things will get weird
			break
	Endswitch
		
	
	int k
	make/t/n=(nnames) impar
	for (k=0;k<nnames;k+=1) //Remove waves that contain all NaNs. 
		string currwavename = stringfromlist(k,lnames)
		Wave currwave = $currwavename
				
		if (waveexists($currwavename) == 1)
			Wavestats/Q currwave
			if (V_npnts==0)
				Killwaves $currwavename
			else
				impar[k] = currwavename
			
			endif
		endif
	endfor
	
//	for (k=0;k<nnames;k+=1) //Create a for loop to zap the incoming waves if they do not have data. AIM generates NaN waves. Is there a way to prevent this? If you dont export all channels, 
//		string currwavename = stringfromlist(k,lnames)
//		impar[k] = currwavename
//	endfor
	
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
	
//	for(j=0;j<(numofbins);j++)
//		String Wvname = stringfromlist(j,binnames)
//		Killwaves/Z $Wvname
//	Endfor

	//Fix naming for the Total Concentration Variable
	wave  'TotalConc.(#/cm)','TotalConc.(#/cm3)',	'TotalConc.(#/cm³)', 'TotalConcentration(#/cmÂ³)'	//Put all here
	if(waveexists('TotalConc.(#/cm)')==1)
		rename 'TotalConc.(#/cm)', 'TotalConc.(#/cm3)'	
	elseif (waveexists('TotalConc.(#/cm³)')==1)
		rename 'TotalConc.(#/cm³)', 'TotalConc.(#/cm3)'
	elseif (waveexists('TotalConcentration(#/cmÂ³)')==1)
		rename 'TotalConcentration(#/cmÂ³)' 'TotalConc.(#/cm3)'
	else
	endif	

	//Adds date and time waves to make one "date and time" wave
	
	Wave StartTime, DateSMPSTimeSampleStart, DateSMPS, Time_Start
	If (waveexists(StartTime)==1)
		Wave DateSMPS, StartTime
		Duplicate/O DateSMPS datetimewave
		datetimewave = DateSMPS + StartTime
	Elseif(waveexists(DateSMPSTimeSampleStart)==1)
		Duplicate/O DateSMPSTimeSampleStart datetimewave
		Killwaves DateSMPSTimeSampleStart
	Elseif (waveexists(Time_Start)) //ICARTT file
		Wave Time_Start, Time_Stop, Time_Mid,Time_Start_Local, Time_Stop_Local, Time_Mid_Local
		Time_Start += date2secs(yearv,monthv,dayv)	
		Time_Stop += date2secs(yearv,monthv,dayv)	
		Time_Mid += date2secs(yearv,monthv,dayv)	
		Time_Start_Local += date2secs(yearv,monthv,dayv)	
		Time_Stop_Local += date2secs(yearv,monthv,dayv)	
		Time_Mid_Local += date2secs(yearv,monthv,dayv)
		Duplicate/O Time_Start datetimewave
	Endif	
	setscale d, 0,0, "dat", datetimewave
		
	//Impliments the startstopwaves function
	Wave datetimewave,'ScanTime(s)', 'DMAatHighVoltage(THIGH)(s)'
	If (waveexists('ScanTime(s)')==1)
		startstopwaves(datetimewave, 'ScanTime(s)')
	Elseif (waveexists('DMAatHighVoltage(THIGH)(s)') ==1)
		Wave'DMAatHighVoltage(THIGH)(s)','DMAatLowVoltage(TLOW)(s)','DMAVRampingUp(TUP)(s)','DMAVRampingDown(TDOWN)(s)'
		Duplicate/O 'DMAVRampingUp(TUP)(s)' 'ScanTime(s)'
		'ScanTime(s)' = 'DMAatHighVoltage(THIGH)(s)' + 'DMAatLowVoltage(TLOW)(s)' + 'DMAVRampingUp(TUP)(s)' + 'DMAVRampingDown(TDOWN)(s)'
		startstopwaves(datetimewave, 'ScanTime(s)')
	Else
		
	Endif	
	
	//Integrates mass concentration from # concentration and bins
	Wave NConc
	Tconc(NConc,mindia,maxdia)
	Wave NConc_Total
	
	//Impliments the transformation of Nconc to Volume and SA
	NconctoVandSA(densityconv)
	
	//Integrates mass concentration from # concentration and bins
	wave MConc
	
	Tconc(MConc,mindia,maxdia)
	Wave MConc_Total
	
	//Integrates surface area concentration from # concentration and bins
	wave SAConc
	
	Tconc(SACOnc, mindia, maxdia)
	Wave SAConc_Total

	If (softwareversion != 3) //No need to compare on the ICARTT file
		//Impliments the graphing for number
		maketseriesgraphnumb(yearstr, monthstr, daystr, timestartstr)
		seediffnumb()

		//Impliments the graphing for mass; since mass isn't directly being imported there is nothing to compare it to AIM wise so that function is not called here. 
		massmaketseriesgraph(yearstr, monthstr, daystr, timestartstr)
	Endif

	If (softwareversion==3) //Change wavenames to match the initial upload
//		Rename TSI_NumbConc 'TotalConc.(#/cm3)'
		Rename Time_Start_local SMPS_Start
		Rename Time_Stop_Local SMPS_Stop
		Rename Time_Mid_Local SMPS_MidPoint
//		Rename GeoMean 'Geo.Mean(nm)'
//		Rename GeoStdDev 'Geo.Std.Dev'

		Rename Farmer_NumbConc 'TotalConc.(#/cm3)'
		Rename Farmer_GeoMean 'Geo.Mean(nm)'
		Rename Farmer_GeoStdDev 'Geo.Std.Dev'
	Endif
	
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
	
	switch(softwareversion)
		string file_ext
		case 0:
		file_ext = ".txt" //AIM 10 and Willis box
		break
		case 1:
		file_ext = ".csv" //AIM 11
		break
		case 2:
		file_ext = ".txt" //AIM 10 and Willis box
		break
		case 3:
		file_ext = ".ict" //ICARTT
		break
	endswitch
		
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
			
	//Initialize date and time variables
	variable yearv, monthv, dayv, timestartHHv,timestartMMv,timestartSSv, scannum
	string therest
   NVAR densityconv = root:density
	
	//Finds the first line of data (26 for v10.3 Nano and regular SMPS)
	Variable lineNumber = 0
	String firstdataline
	NVAR SoftwareVersion = root:softwareversion
	
	//More variable
	String lnames, tmpData
	variable NameLine, numofheaderlines
	
	switch(softwareversion)
		case 0:
		case 1:
		case 2:  //Code for 0,1,2 was already written, so I left it like this. LG
		
	Grep/list/e=("Sample #")  s_Filename //Find the the variable names line in the code
		If (V_startParagraph == -1)
			Grep/list/e=("Scan Number")  s_Filename //AIM 11 variable name
			Grep/e=("Scan Number")  s_Filename //AIM 11 variable name
		Endif
	NameLine = V_startParagraph //NameLine is line number of the line containing the variable list
	lnames = s_value
	
	do
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
    break  
    
    case 3:
    //ICARTT file - structured a completely different way, so the readfile is totally different from the TSI SMPS software
	do
		FReadLine refnum, tmpData
        if (strlen(tmpData) == 0)
            return -1           // Error - end of file
        endif
        
        if (lineNumber == 0)
            sscanf tmpData, "%d[, ]%s",numofheaderlines, therest	
		   		
        elseif (lineNumber == 6)
				sscanf tmpData, "%d,%d,%d,%s", yearv, monthv,dayv,therest
        elseif (lineNumber == (numofheaderlines-1))
        		lnames = tmpData
            break  //once we reach the line with header info
        endif
        lineNumber += 1
    while(1)   
   	NameLine = numofheaderlines-1
	break
	
	Endswitch
   
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
	lnames = ReplaceString(";",lnames,"") // AIM 11 has extra semicolons that mess things up!
	lnames = ReplaceString(",",lnames,";") //Igor functions like working with semicolons (;) but not commas (,) (see help for ItemsInList)
	lnames = replacestring(" ",lnames,"") //remove spaces from variable names; fixes concatenate error we were seeing earlier. 
	lnames = replacestring("date_",lnames,"date") //to handle FROG and FROGSICLE data where an underscore was added by hand
	lnames = replacestring("date",lnames,"DateSMPS") //replace variable name "date" with "DateSMPS" to avoid conflict with Igor date   //This is a problem for AIM 11
	
	if(softwareversion ==3)
		string firstnames, diameternames //Gross. There has to be a better way to do this
	
		diameternames = lnames[strsearch(lnames, "MdPtDiam", 2)+8, strlen(lnames)]
		firstnames = lnames[0,strsearch(lnames, "MdPtDiam", 2)-1]
		diameternames = replacestring("MdPtDiam",diameternames,"") //Remove MdPtDiam from diameter bin variable names		
		diameternames = replacestring("_",diameternames,".")
		lnames = 	firstnames+diameternames	
		lnames = TrimString(lnames,1) // Theres a weird \r at the end of the variable name row
		if (stringmatch(lnames[strlen(lnames)-1], "!;"))  
			lnames = lnames + ";"
		endif
	Endif
		
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
	String numdfr_name = "root:Number_Concentration:"+"'" +Datafoldername + "_Numb"+"'" 
	
	
	//Load the data from the file we already found with the dialog
	
	switch(softwareversion)
		case 0:
		case 1:
			Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/V={"\t,"," $",1,0} S_filename //DDMMYYY for 
			break
		case 2:
			Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/R={English,2,2,2,2,"Year/Month/DayOfMonth",40}/A s_filename //YYYYMMDD
			break
		case 3:
			Loadwave/J/B=ColumnInfoString/L={nameline,(nameline+1),0,0,0}/A/D S_filename  //double precision or things will get weird
			break
	Endswitch
	
	int k
	make/t/n=(nnames) impar
	for (k=0;k<nnames;k+=1) //Remove waves that contain all NaNs. 
		string currwavename = stringfromlist(k,lnames)
		Wave currwave = $currwavename
				
		if (waveexists($currwavename) == 1)
			Wavestats/Q currwave
			if (V_npnts==0)
				Killwaves $currwavename
			else
				impar[k] = currwavename
			
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
	
	//Add date and time waves to make one "date and time" wave - LG
	
	Wave StartTime, DateSMPSTimeSampleStart, DateSMPS, Time_Start
	If (waveexists(StartTime)==1)
		Wave DateSMPS, StartTime
		Duplicate/O DateSMPS datetimewave
		datetimewave = DateSMPS + StartTime
	Elseif(waveexists(DateSMPSTimeSampleStart)==1)
		Duplicate/O DateSMPSTimeSampleStart datetimewave
		Killwaves DateSMPSTimeSampleStart
	Elseif (waveexists(Time_Start)) //ICARTT file
		Wave Time_Start, Time_Stop, Time_Mid,Time_Start_Local, Time_Stop_Local, Time_Mid_Local
		Time_Start += date2secs(yearv,monthv,dayv)	
		Time_Stop += date2secs(yearv,monthv,dayv)	
		Time_Mid += date2secs(yearv,monthv,dayv)	
		Time_Start_Local += date2secs(yearv,monthv,dayv)	
		Time_Stop_Local += date2secs(yearv,monthv,dayv)	
		Time_Mid_Local += date2secs(yearv,monthv,dayv)
		Duplicate/O Time_Start datetimewave
	Endif	
	setscale d, 0,0, "dat", datetimewave
			
	//Make SMPS start and stop times

	Wave datetimewave,'ScanTime(s)', 'DMAatHighVoltage(THIGH)(s)'
	If (waveexists('ScanTime(s)')==1)
		startstopwaves(datetimewave, 'ScanTime(s)')
	Elseif (waveexists('DMAatHighVoltage(THIGH)(s)') ==1)
		Wave'DMAatHighVoltage(THIGH)(s)','DMAatLowVoltage(TLOW)(s)','DMAVRampingUp(TUP)(s)','DMAVRampingDown(TDOWN)(s)'
		Duplicate/O 'DMAVRampingUp(TUP)(s)' 'ScanTime(s)'
		'ScanTime(s)' = 'DMAatHighVoltage(THIGH)(s)' + 'DMAatLowVoltage(TLOW)(s)' + 'DMAVRampingUp(TUP)(s)' + 'DMAVRampingDown(TDOWN)(s)'
		startstopwaves(datetimewave, 'ScanTime(s)')
	Else
		
	Endif
	

	
	//Impliments the number binning/dlogdp calculations
	Wave NConc
	Tconc(NConc,mindia,maxdia)
	Wave NConc_Total
	
	//Impliments the transformation of Nconc to Volume and SA
	NconctoVandSA(densityconv)
	
	//Impliments the Mass binning/dlogp calculations
	wave MConc, binwidth,dlogDp, diam
	
	Tconc(MConc,mindia,maxdia)
	Wave MConc_Total
	
	//Integrates surface area concentration from # concentration and bins
	wave SAConc
	
	Tconc(SACOnc, mindia, maxdia)
	Wave SAConc_Total

	
	
	If (softwareversion != 3) //No need to compare on the ICARTT file
		//Impliments the graphing for number
		maketseriesgraphnumb(yearstr, monthstr, daystr, timestartstr)
		seediffnumb()

		//Impliments the graphing for mass; since mass isn't directly being imported there is nothing to compare it to AIM wise so that function is not called here. 
		massmaketseriesgraph(yearstr, monthstr, daystr, timestartstr)

	Endif

	//Change wavenames for ICARTT file load to match SMPS upload names
	If (softwareversion==3) 
		Rename TSI_NumbConc 'TotalConc.(#/cm3)'
		Rename Time_Start_local SMPS_Start
		Rename Time_Stop_Local SMPS_Stop
		Rename Time_Mid_Local SMPS_MidPoint
		Rename GeoMean 'Geo.Mean(nm)'
		Rename GeoStdDev 'Geo.Std.Dev'
	Endif

	Setdatafolder root:
	
	f++
	while(f<itemsinlist(filelist))


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
	
	duplicate/O diam dlogDp
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

function NconctoVandSA(density) //Generate 2D waves for mass and surface area using a density in g/cm3
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
//Mconc is generated by NconctoVandSA(density) function above - LG

//Function Tconcmass(MConc,Dpmin,Dpmax,diam, binwidth,dlogDp)	//User needs to provide Dpmin and Dpmax. Because this is for mass, szdata (which is number starting out is note used but MConc (with calcualted density is); for this szdata is the MConc wave created
//	wave MConc, diam, binwidth,dlogDp	//szdata
//	variable Dpmin, Dpmax
////	fbwidth()
////	wave diam, binwidth
//	variable numbins = numpnts(diam)
//	
//	variable minidx,maxidx
//	Findlevel/P/Q diam, Dpmin //Findlevel -> searches named wave to find X value at the Y level is crossed
//		if(V_Flag==1)
//			minidx = 0
//		else
//			minidx = ceil(V_LevelX) // ceil -> returns the closest integer >= to num (in this case V_LevelX)
//		endif
//		
//		FindLevel/P/Q diam, Dpmax
//		if(v_flag==1)
//			maxidx = (numpnts(diam)-1) //Might not need the -1 because I have zapped the waves
//		else
//			maxidx = floor(V_levelX) // floor -> returns the closest interger <= num (in this case V_levelX)
//		endif
//	
//	//So the purpose of the above section is to scan through diam for dpmax and dpmin and then if V_flag == 1 set the index to the first or last of the wave
//	//if v_flag is not 1 set the dpmin to the closest integer that is >= the level found by findlevel; dpmax set to the closest integer <= the level found by findlevel
//	
////	duplicate diam dlogDp
//	dlogDp = NaN //This clears the wave 
//	dlogDp = log(diam+0.5*binwidth) - log(diam-0.5*binwidth) // dlogDp calculation; this is expanded upon below for each diameter bin
//	// dlogDp = the log value of the diameter + half of the binwidth (the upper; dlogDp,upper) - the log value of the diameter - half of the bindwith(the lower;dlogDp,lower)
//	
//	variable a,b
//	make/FREE/N=(numbins) dL, dU
//	
//	for(b=0; b<numbins;b+=1)
//		if (b==0)
//			dL[b] = diam[b]-0.5*binwidth[b]
//			dU[b] = diam[b]+0.5*binwidth[b]
//		elseif (b ==(numbins-1))
//			dL[b] = diam[b]-0.5*binwidth[b-1]
//			dU[b] = diam[b]+0.5*binwidth[b-1]
//		else
//			dL[b] = diam[b]-0.5*binwidth[b-1]
//			dU[b] = diam[b]+0.5*binwidth[b]
//		endif
//	dlogDp[b] = log(dU[b]) - log(dL[b])
//	Endfor
//	//So the purpose of the above section is to carry out the dlogDp calculation mentioned above but carried for each diameter bin and for
//	//different cases (for example if wer are just starting out (first row) then b==0 and we would calculate dL by setting it = to our
//	//diameter at [b or 0] - 0.5 * the binwidth [at 0]. We would do the dame thing for dU except +0.5*binwidth
//	
//	// if we are already going through the diameters then b == numbins -1 and we would do the same thing except the previous bin
//	
//	// otherwise (and likley for the last row/index in the loop we would only need to go back for dL but not dU
//	
//	variable ndata = dimsize(MConc,0)
//	make/N=(ndata)/O Ctotal
//	variable addnum=0, total = 0
//	for(a=0;a<ndata;a+=1)
//		for(b=minidx;b<=maxidx;b+=1)
//			addnum = MConc[a][b]*dlogDp[b]
//			total+=addnum
//		Endfor
//		Ctotal[a] = total
//		total = 0
//		addnum = 0
//	Endfor
//
//	//So the purpose of this section is to get the total number concentration by taking the dndlogdp and muliplying by dlogp in order to get dn 
//	// then you would sum up all of the dNs to get the total #/cm3 (total number concentration)
//	
//	String totalwavename = nameofWave(MConc)+"_Total"
//	Duplicate/o Ctotal $totalwavename
//	killwaves ctotal
//	//So the purpose of this section is just to rename the total concentration wave to szdata_total which for me is effectivly diam_total
//END
////END MASS VERSION	

function maketseriesgraphnumb(year, month, day, timestart) //Generates a timeseries graph of the Aim file loaded in and provides option to save figure

	string year, month, day, timestart

	wave Datetimewave, NConc_Total
	
	Display Nconc_total vs Datetimewave
	Modifygraph dateInfo(bottom)={1,1,2}
	Label left "Total Number Concentration (#/cm\\S3\\M)\rdNdlogDp\\BMob\\M";DelayUpdate
	Label bottom "Time (hrs:min:sec)";Delayupdate
	TextBox/C/N=text0/A=MC/S=3/x=30/y=40 "SMPS NConc TSeries\r       "+year+"_"+month+"_"+day;delayupdate
	wavestats/W NConc_Total
   string newstatswname = nameofwave(NConc_Total)+"_Stats"
	rename M_Wavestats, $newstatswname
	
	DoUpdate
End

function seediffnumb() 
	
	//Create the table to see how the AIM software and our integration compare
	wave 'TotalConc.(#/cm3)', NConc_Total, Datetimewave
	make/n=(dimsize(NConc_total,0)) percent_diff
	percent_diff = ('TotalConc.(#/cm3)' - NConc_total	)/	'TotalConc.(#/cm3)'*100
//	Edit/N=AIM_Igor_Difference
//	appendToTable Datetimewave,NConc_total,'TotalConc.(#/cm3)', percent_diff	
	
	//Create the graph
	Display NConc_total vs 'TotalConc.(#/cm3)'
	ModifyGraph mode=3,marker=19
	ModifyGraph log=1
	Label bottom "TSI TotalConc.(#/cm3)"
	Label left "Integrated NConc (#/cm3)"
	
	TextBox/C/N=text0/F=0/A=RB/X=0.00/Y=0.00 "Average percent_diff = " + num2str(mean(percent_diff))
	ModifyGraph width=216,height=216
	
	DoUpdate
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
	
	DoUpdate
	
	
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

function massmaketseriesgraph(year, month, day, timestart) //Generates a timeseries graph of the Aim file loaded in
	
	string year, month, day, timestart
	
	wave datetimewave, MConc_Total
	
	Display Mconc_total vs datetimewave
	Modifygraph dateInfo(bottom)={1,1,2}
	Label left "Total Mass Concentration (µg/m\\S3\\M)\rdNdlogDp\\BMob\\M";DelayUpdate
	Label bottom "Time (hrs:min:sec)";Delayupdate
	TextBox/C/N=text0/A=MC/S=3/x=30/y=40 "SMPS MConc TSeries\r       "+year+"_"+month+"_"+day;delayupdate
	wavestats/W MConc_Total
   string newstatswname = nameofwave(MConc_Total)+"_Stats"
	rename M_Wavestats, $newstatswname
//	Edit 
//	dowindow/R/C SMPS_TConc_Stats_Table_Mass
//	appendtotable $newstatswname.ld
	
	
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

Function MakeWavesforAllTime_Button(ba) : ButtonControl 
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			MakeAllTimeWaves()
		case 2:
			break
		endswitch
		
End


Function MakeAllTimeWaves()
		NVAR density = root:density
		NVAR SoftwareVersion = root:SoftwareVersion
		NVAR Dpmin = root:MinimumDiameter
		NVAR Dpmax = root:MaximumDiameter
		
		concatedatafiles(1,"SMPS_MidPoint")
		concatedatafiles(1,"SMPS_Start")
		concatedatafiles(1,"SMPS_Stop")
		concatedatafiles(1,"datetimewave")
		
		concatedatafiles(1,"TotalConc.(#/cm3)")
		concatedatafiles(1,"NConc")
		
		If (SoftwareVersion==1)
			concatedatafiles(1,"SheathTemp(C)")
			concatedatafiles(1,"SheathPressure(kPa)")
		else
			concatedatafiles(1,"SampleTemp(C)")
			concatedatafiles(1,"SamplePressure(kPa)")
		endif
		SetDataFolder root:Alltime
		
		MoveKeyWavesOutofFirstFile()
		

		Wave NConc, diam
		TrimSizeMatrix(DpMin,DpMax,NConc,diam) //Specify diameters
		NconctoVandSA(density)
		
		Wave NConc, MConc, SAConc, diam
		TConc(NConc,Dpmin,Dpmax)
		TConc(MConc,Dpmin,Dpmax)
		Tconc(SAConc,Dpmin,Dpmax)
		
		Wave diam
		Make/O/N=(numpnts(diam))/D diameter_bins= Nan
		MakeEdgesWave(diam, diameter_bins)
		
		Make/O/N=(numpnts(:SMPS_MidPoint))/D SMPS_MidPoint_Bins = Nan
		MakeEdgesWave(:SMPS_MidPoint, SMPS_MidPoint_Bins)
		
		RecalcTSIStats()
		
End

Function MoveKeyWavesOutofFirstFile()
		DFREF currfolder = GetDataFolderDFR()
				
		//Copy diameter wave out of first file
		DFREF ndf = root:Number_Concentration
		variable ndfs = countobjectsDFR(ndf, 4)
	
		string ndfname = "root:Number_Concentration"
		string dfList = SortedDataFolderList(ndfname, 16)
		variable numDataFolders = ItemsInList(dfList)
	
		string dfname = StringFromList(0, dfList)
		setdataFolder ndf:$dfname

		Wave diam
		Duplicate/O diam currfolder:diam
		
		SetdataFolder currfolder
End

Function TrimSizeMatrix(DpMin,DpMax,szdata,diam)
	Variable DpMin, DpMax
	wave szdata, diam
	
	Make/FREE/N=(numpnts(diam)) w1d = 0 
	w1d = diam > DpMin && diam <DpMax ? 1 : w1d
	
	
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

	
	Duplicate/R=[0,dimsize(szdata,0)][minidx,maxidx]/FREE szdata, Trim_szdata 
	Duplicate/R=[minidx,maxidx]/FREE diam, Trim_diam
	
	SetScale y 0, (dimsize(Trim_szdata,1)), Trim_szdata
	
	string og_szdataname = nameofwave(szdata)
	string og_diamname=nameofwave(diam)
	
	Duplicate/O Trim_szdata $og_szdataname
	Duplicate/O Trim_diam $og_diamname
	
End


Function/S SortedWaveList(sourceFolderStr, sortOptions)
    String sourceFolderStr  // "root:ADataFolder"
    Variable sortOptions    // 16 (Case-insensitive alphanumeric sort that sorts wave0 and wave9 before wave10.) - See SortList for details
   
    String myWaveList = ""
   
    Variable numDataWaves = CountObjects(sourceFolderStr, 1)
    Variable i
    for (i=0; i< numDataWaves; i+=1)
        String myWaveName = GetIndexedObjName(sourceFolderStr, 1, i)
        myWaveList += myWaveName + ";"
    endfor
   
    myWaveList = SortList(myWaveList, ";", sortOptions)
    return myWaveList
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
	setdataFolder root:Number_Concentration
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
	ModifyGraph log(left)=1
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
	ModifyGraph log(left)=1

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
				ModifyGraph log(left)=1
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
					ModifyGraph log(left)=1
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

Function PointsinWave2Number(w,p1,p2,n)
	wave w
 	variable p1, p2, n
	variable i 
	for(i=p1;i<=p2;i+=1)
 		W[i] = n
 	Endfor

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
	NVAR density = root:density
	
	
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
				TConc(MConc,diam[0],diam[numpnts(diam)-1])
				
				wave MConc_Total_Stats, MConc_Total
				if (waveexists(MConc_Total_Stats)==1)
					Killwaves MConc_Total_Stats 
				endif
//				
				wavestats/W MConc_Total
  				string newstatswname = nameofwave(MConc_Total)+"_Stats"
				rename M_Wavestats, $newstatswname
//				
//				wave MConc_Total, MConc_Total_Stats
//				string massname = dfname[0, strlen(dfname) - 5] + "Mass"
//				setdatafolder root:Number_Concentration:$massname
//				DFREF massDF = getdataFolderDFR()
				
//				Wave MConc,MConc_Total,MConc_Total_Stats
//				if (waveexists(MConc)==1)
//					Killwaves MConc,MConc_Total,MConc_Total_Stats 
//				Endif
//				
//				setdatafolder currdf
//				
//				Wave MConc,MConc_Total,MConc_Total_Stats
//				movewave MConc,massDF:MConc
//				movewave MConc_Total,massDF:MConc_Total
//				movewave MConc_Total_Stats,massDF:MConc_Total_Stats
 
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
	
	//Print "Geometric Mean is " + num2str(GeoMean)
	
	GM_num = W * ( ln(diam)-ln(GeoMean) )^2
	GM_den = W
	GeoSD = exp(sqrt(Sum(GM_num)/Sum(W)))
	//Print "Geometric Standard Devation is " + num2str(GeoSD)
	
	AvgConc = sum(W)
	//Print "Total Num Conc is " + num2str(Sum(W))
	
	Killwaves AddW, binwidth, dlogDp, GM_den, GM_num, W
	
End


/////////////////////////////////////////////
/////////////////////////////////////////////
/////////////////////////////////////////////
////////////////////////////////////////////


Function concatedatafiles(type,variablename)
	variable type //(1=number; 2=mass)
	String variablename
	String ndfname
	
//	//Define relevant datafolders
//	If (type == 1)  //number
		DFREF MDF = root:Alltime: //Set a subfolder for temporary processing later on
		DFREF ndf = root:Number_Concentration:
		ndfname = "root:Number_Concentration:"
	
//	Elseif (type == 2) //mass
//		DFREF MDF = root:Alltime: //Set a subfolder for temporary processing later on
//		DFREF ndf = root:Mass_Concentration:
//		ndfname = "root:Mass_Concentration:"
//		
//	Else
//		
//		print "You have to choose 1 (Number) or 2 (Mass)"
//	
//	Endif
	
	SetDataFolder ndf //Number or Mass _Concentration
	variable ndfs = countobjectsDFR(ndf, 4)	//Count the number of data folders
	variable dfnumb // Index of data folder	
	
	String dfList = SortedDataFolderList(ndfname, 16)
	variable numDataFolders = ItemsInList(dfList)
	
	
	
	// 20240318 AJD: I want to add some code that will not include a data folder for NConc if the numofdiambins of NConc is not the same (i.e. maybe 13.6 was not filled and thus throws off the entire concatenation process)
	string dfname_checkcolumn = stringfromlist(dfnumb,dflist)
	setdatafolder dfname_checkcolumn
	wave checkcolumn_wave = $variablename
	variable ncolumn_shouldbe = dimsize(checkcolumn_wave,1)
	
	
	For (dfnumb=0;dfnumb<ndfs;dfnumb+=1)		//for each datafolder, duplicate the wave from the SMPS file folder and place together in a temporary folder for concatenation
		wave variablewave = $variablename
		string dfname = StringFromList(dfnumb, dfList)
		variable ncolumn_thereare
		setdataFolder ndf
		setdataFolder dfname
		DFREF currdf = GetdataFolderDFR()

				//Get names for duplication
		wave variablewave = $variablename
		string newvariablename = "Temp_"+num2str(dfnumb)
		ncolumn_thereare = Dimsize(variablewave,1)
		if(ncolumn_thereare != ncolumn_shouldbe)
			Duplicate/O variablewave, MDF:$Newvariablename
			setdatafolder MDF
			wave newvariablewave = $newvariablename
			redimension/N=(-1,ncolumn_shouldbe) newvariablewave
			setdatafolder ndf
			setdatafolder dfname
			print "Due to concatenation constraints " + dfname + " wave " + variablename +" was redimensioned from " + num2str(ncolumn_thereare) + " to " + num2str(ncolumn_shouldbe) +"."
		elseif(ncolumn_thereare == ncolumn_shouldbe)
			Duplicate/O variablewave, MDF:$Newvariablename
		endif
				
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
			SetDataFolder root:Alltime
			GraphHeatMap(1)
		case 2:
			break
		endswitch
		
End

Function MakeHeatmap_all_Mass_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			Setdatafolder root:Alltime
			GraphHeatMap(2)
		case 2:
			break
		endswitch
		
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
		ModifyGraph log(left)=1

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
		ModifyGraph log(left)=1
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
			print "Although heatmaps will be generated, ensure that the history is checked to locate any matrices that were artiically inflated to ensure the concatenation could be performed."
			
			
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
	
	
	MakeAllTimeWaves()

	
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
	Wave NConc, MConc, diam, diameter_bins
	
	Duplicate/R=(avgstart_index, avgstop_index)/O NConc newfolder:NConc
	Duplicate/R=(avgstart_index, avgstop_index)/O MConc newfolder:MConc
	Duplicate/R=(avgstart_index, avgstop_index)/O SMPS_Midpoint newfolder:SMPS_MidPoint
	Duplicate/O diameter_bins newfolder:diameter_bins
	Duplicate/O diam newfolder:diam
	
	Setdatafolder newfolder
	
	//Makes a new wave that is the average size distribution for the specified time
	AvgSizeDistribution()
	
	//Makes separate waves for individual sample runs at the specified interval (in run #)
	SeparateSizeDistrforGraphs_Num(interval)	
	SeparateSizeDistrforGraphs_Mass(interval)
	
	//Makes a graph with size distribution for individual sample runs 
	makeSDgraphs_numb(newfoldername,"diam",interval)
	
	//Do some statistics on the new size distribution
	Setdatafolder newfolder
	Variable GeoMean, GeoSD, AvgConc
	Wave Avg_NConc
	[GeoMean, GeoSD, AvgConc] = TSIStatistics(Avg_NConc, diam)

	//Add the average size distribution and the statistics information to the graph that has the individual sample runs
	
	Duplicate/O :SMPS_MidPoint, SMPS_MidPoint_Bins
	MakeEdgesWave(:SMPS_MidPoint, SMPS_MidPoint_Bins)
	
	AppendtoGraph :Avg_NConc vs :diam
	ErrorBars Avg_NConc SHADE= {0,4,(0,0,0,0),(0,0,0,0)},wave=(:Std_Nconc,:Std_Nconc)
	ModifyGraph log(bottom)=1
	Label left "dNdlogdp (#/cm\\S3\\M)";DelayUpdate
	Label bottom "Diameter Midpoint (nm)";Delayupdate
	ModifyGraph lsize(Avg_NConc)=2,rgb(Avg_NConc)=(0,0,0) //Make average black thick line
	
	//Makes a string that includes the prescribed start and stop times
	String str_start, str_stop
	sprintf str_start, "%02d/%02d/%02d %02d:%02d:%02d", avg_start_Mon,avg_start_D, avg_start_Y, avg_start_H, avg_start_Min, avg_start_s
	sprintf str_stop, "%02d/%02d/%02d %02d:%02d:%02d", avg_stop_Mon,avg_stop_D, avg_stop_Y, avg_stop_H, avg_stop_Min, avg_stop_s
	

	
	TextBox/C/N=text0/F=0/A=RT "\JCAvg Number Dist.\r" + str_start + "\r" + str_stop + "\rGeo Mean = "+ num2str(GeoMean) + "\rGeom STD = " + num2str(GeoSD) + "\rTotal Conce = " + num2str(AvgConc) + ""
	
	
	//Repeat for Mass
	makeSDgraphs_mass(newfoldername,"diam",interval)
	
	//Do some statistics on the new size distribution
	Setdatafolder newfolder
	Wave Avg_MConc
	[GeoMean, GeoSD, AvgConc] = TSIStatistics(Avg_MConc, diam)

	//Add the average size distribution and the statistics information to the graph that has the individual sample runs
	
	AppendtoGraph :Avg_MConc vs :diam
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
	Wave NConc, MConc, diameter_bins, diam
		
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
			KillAllTables()
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
	
	MakeAllTimeWaves()  // Start by recalculating with the specified diameters
	
	Setdatafolder root:AllTime
	
	Wave SMPS_Start, SMPS_Stop, SMPS_MidPoint //Duplicate and rename to simple variable names for ICARTT
	
	Duplicate/O SMPS_Start, dfr_I:Time_Start_local
	Duplicate/O SMPS_Stop, dfr_I:Time_Stop_local
	Duplicate/O SMPS_MidPoint, dfr_I:Time_Mid_local
		
	//Duplicate/O :'TotalConc.(#/cm3)' dfr_I:TSI_NumbConc //With size range options, does it make sense to include the summed all bins from TSI?
	Duplicate/O :'NConc_Total' dfr_I:Farmer_NumbConc	
	Duplicate/O :GeoMean dfr_I:Farmer_GeoMean
	Duplicate/O :GeoSD dfr_I:Farmer_GeoStdDev
	Duplicate/O :'MConc_Total' dfr_I:Farmer_MassConc
	
	
	If (SoftwareVersion==1)
		Duplicate/O :'SheathTemp(C)' dfr_I:Temp //AIM11
		Duplicate/O :'SheathPressure(kPa)' dfr_I:Press
	Else
		Duplicate/O :'SampleTemp(C)' dfr_I:Temp //AIM10 and Willis box
		Duplicate/O :'SamplePressure(kPa)' dfr_I:Press
	EndIf
	
	Duplicate/O :NConc dfr_I:NConc
	
	Duplicate/O :diam dfr_I:diam
	
	
	Setdatafolder dfr_I
	Wave diam
	Wave Time_Start_local, Time_Stop_local, Time_Mid_local
	
	//UTC Date and Time
	Duplicate/O Time_Start_local, Time_Start
	Duplicate/O Time_Stop_local, Time_Stop
	Duplicate/O Time_Mid_local, Time_Mid
	
	ChangeTimetoUTC_wDST()
		
	SeparateforICARTT()  //Divide NConc into Explicitly Named Diameter Bins
	
	//Killwaves :NConc, :diam
	
	Make/T/O VarNameWave
	varnamewave = {"Time_Start","Time_Stop","Time_Mid","Time_Start_Local","Time_Stop_Local","Time_Mid_Local","Farmer_GeoMean", "Farmer_GeoStdDev","Farmer_MassConc", "Farmer_NumbConc", "Temp","Press"}
	string sizedistnames = wavelist("MdPtDiam*",";","")
	sizedistnames = SortList(sizedistnames, ";", 16)
	
	Edit Time_Start, Time_Stop, Time_Mid, Time_Start_Local, Time_Stop_Local, Time_Mid_Local
	
	ModifyTable format(Time_Start)=8,format(Time_Stop)=8,format(Time_Mid)=8, format(Time_Start_Local)=8,format(Time_Stop_Local)=8,format(Time_Mid_Local)=8
	ModifyTable digits(Time_Start)=1, digits(Time_Stop)=1, digits(Time_Mid)=1, digits(Time_Start_Local)=1, digits(Time_Stop_Local)=1, digits(Time_Mid_Local)=1
	
	variable i
	//AJD 12/8/2025: changed i=3 to i=6 to avoid formatting the local time waves to non-date formats
	For (i=6; i<numpnts(varnamewave); i++)
		string thisname = varnamewave[i] 
		AppendtoTable $thisname
		ModifyTable format($thisname)=3, digits($thisname)=1
	EndFor
	
	ModifyTable digits(:Farmer_GeoStdDev) = 3
	ModifyTable digits(:Farmer_MassConc) = 3
	
	For (i=0;i<itemsinlist(sizedistnames);i++)
		AppendtoTable $stringfromlist(i, sizedistnames)
		ModifyTable format($stringfromlist(i, sizedistnames))=3, digits($stringfromlist(i, sizedistnames))=1
	EndFor
		
	Killwaves varnamewave

	SetDatafolder root:
End




function SeparateforICARTT()
	Wave NConc, diam
	variable i = 0		
	
	string sizedistnames = wavelist("MdPtDiam*",";","")
	For(i=0;i<itemsinlist(sizedistnames);i++)
		Killwaves $stringfromlist(i,sizedistnames)
	Endfor
	
	string variablenames
	variablenames = ""
	for(i=0; i<(numpnts(diam)); i+=1)
		variablenames += "MdPtDiam" +num2str(diam[i]) + ";"
	endfor
		
	variablenames = replacestring(".",variablenames,"_") //Change decimals in wave to underscores
		
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
	string timewavename = "Time_Start_Local" //Change to local time
	
	
	FindLevel/Q $timewavename, starttime
	print starttime
	variable startindex = ceil(V_LevelX)
		if (V_flag == 1)
			startindex = 0
		Endif
		
		print "StartIndex = " + num2str(startindex)
	
	FindLevel/Q $timewavename stoptime
	variable stopindex = floor(V_LevelX)
		if (V_flag == 1)
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
//	DFREF Mass_DF = root:Mass_Concentration
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

///////////////////////////////////////////////////////////////////
//////    Daylight Savings Time for Local to UTC conversion    ////



// Returns 1 if the specified Igor timestamp falls in a daylight savings time epoch.
Function DST(timeStamp)
	Variable timeStamp

	Variable day,month,year,dayOfWeek,hours,minutes
	String date_=Secs2Date(timeStamp,-1)
	sscanf date_,"%d/%d/%d (%d)",day,month,year,dayOfWeek
	String time_=Secs2Time(timeStamp,2)
	sscanf time_,"%d:%d",hours,minutes
	switch(month)
	case 1:
	case 2:
	return 0
	break
	case 3:
	Variable minDay=dayOfWeek+7*1 // Second sunday.
	if((day>=minDay && (dayOfWeek!=1 || hours>=2))|| day>=(minDay+7))
	return 1
//	elseif(day>minDay)
//	return 1
	else
	return 0
	endif
	break
	case 4:
	case 5:
	case 6:
	case 7:
	case 8:
	case 9:
	case 10:
	return 1
	break
	case 11:
	minDay=dayOfWeek+7*0 // First sunday.
	if(day>=minDay && (dayOfWeek!=1 || hours>=2)|| day>=(minDay+7))
	return 0
	elseif (day>minDay)
	return 0
	else
	return 1
	endif
	break
	break
	case 12:
	return 0
	break
	default:
	print "No such month:"+num2str(month)
	endswitch
End

	//MDT = UTC - 6 hours
	//MST = UTC - 7 hours
Function ChangeTimetoUTC_wDST()
	variable i
	Wave Time_Start_local, Time_Start, Time_Stop_Local, Time_Stop, Time_Mid_Local, Time_Mid
	NVAR UTCoffset = root:UTC_offset_StandardTime
	
	For(i=0;i<numpnts(Time_Start_local);i++)
		if (DST(Time_Start_local[i])==0) 
			Time_Start[i] = Time_Start_local[i]+UTCoffset*60*60 //Standard time: UTC = MST + 7 hours for Colorado
			Time_Stop[i] = Time_Stop_local[i]+UTCoffset*60*60
			Time_Mid[i] = Time_Mid_local[i]+UTCoffset*60*60
		elseif (DST(Time_Start_local[i])==1)
			Time_Start[i] = Time_Start_local[i]+(UTCoffset-1)*60*60//Daylight Savings Time: UTC = MDT + 6hours for Colorado
			Time_Stop[i] = Time_Stop_local[i]+(UTCoffset-1)*60*60
			Time_Mid[i] = Time_Mid_local[i]+(UTCoffset-1)*60*60			
		
		else
			Print "Error in conversion to UTC"
			Return -1
		Endif
	EndFor
	
End

	
FUNCTION SMPSProc_SMPSPanel(tca) : TabControl
	STRUCT WMTabControlAction &tca

	SWITCH( tca.eventCode )
		CASE 2: // mouse up
			ModifyControlList ControlNameList("",";", "T*"), disable=1							//Disables all controls whose names start with T
			ModifyControlList ControlNameList("",";", ("T"+num2str(tca.tab)+"_*"))+ControlNameList("",";", ("*_T"+num2str(tca.tab)+"_*")), disable=0		//Enables the controls on the active tab
		
	
		BREAK
		
		CASE -1: // control being killed
		BREAK
	ENDSWITCH

END





//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
///////////////////////Post-Processing Functions//////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////




/////Move Waves created in ALLTime to Post_Processing

Function PP_MoveWaves2PP_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			PP_MoveWaves2PP()
		case 2:
			break
		endswitch
		
End

Function PP_MoveWaves2PP()

	//Check to see if the Post_Processing datafolder exists.
	//If it exists then create a reference to it, if it does not then create it and then establish the refrerence to it.  
	If (datafolderexists("root:Post_Processing") ==0)
		NewdataFolder/S Root:Post_Processing
		DFREF PP = GetdatafolderDFR()
		String PP_Name = "Root:Post_Processing"
		if(datafolderexists("root:Post_Processing:Unaltered_Imports")==0)
			Newdatafolder/S root:Post_Processing:Unaltered_Imports
			DFREF PP_UA = GetdatafolderDFR()
			String PP_UA_Name = "root:Post_Processing:Unaltered_Imports"
		elseif(datafolderexists("root:Post_Processing:Unaltered_Imports")==1)
			setdatafolder root:Post_Processing:Unaltered_Imports
			DFREF PP_UA = GetdatafolderDFR()
			PP_UA_Name = "root:Post_Processing:Unaltered_Imports"
		Endif
	elseif(datafolderexists("root:Post_Processing")==1)
		Setdatafolder Root:Post_Processing
		DFREF PP = GetdatafolderDFR()
		PP_Name = "Root:Post_Processing"
		if(datafolderexists("root:Post_Processing:Unaltered_Imports")==0)
			Newdatafolder/S root:Post_Processing:Unaltered_Imports
			DFREF PP_UA = GetdatafolderDFR()
			PP_UA_Name = "root:Post_Processing:Unaltered_Imports"
		elseif(datafolderexists("root:Post_Processing:Unaltered_Imports")==1)
			setdatafolder root:Post_Processing:Unaltered_Imports
			DFREF PP_UA = GetdatafolderDFR()
			PP_UA_Name = "root:Post_Processing:Unaltered_Imports"
		Endif
	Endif
	
	//Establish a reference to the AllTime Datafolder
	If(DataFolderExists("root:AllTime")==1) //If AllTime Exists
		setdatafolder root:AllTime
		DFREF AllTime = GetdatafolderDFR()
		String AllTime_Name = "Root:AllTime"
	elseif(DataFolderExists("root:AllTime")==0)	//If AllTime doesn't exist
		Abort "Root:AllTime DataFolder Does not exist."
	Endif
	
	//Define all of the possible waves in AllTime
	string AllTime_wavelist = SortedWaveList(AllTime_Name,16)
	variable Alltime_NumberofWaves = ItemsinList(AllTime_wavelist)
	//With the datafolder still set to AllTime, move the waves over to Post_Processing and label them as version 0
	variable i
	for(i=0; i<Alltime_NumberofWaves; i++)
		string tempwavename = StringfromList(i,AllTime_Wavelist)
		string updatedwavename = tempwavename + "_Base"
		wave current_Wave = $tempwavename
		duplicate/O $tempwavename, PP_UA:$updatedwavename
	Endfor
	
	
	setdatafolder PP
	
	
	//Create Text waves in order to account for version number and notes
	if(waveexists($"Post_Processing_Notes")==0)
		make/T Post_Processing_Notes
	elseif(waveexists($"Post_Processing_Notes")==1)
	//If the wave already exists, then do nothing
	endif
	
	if(waveexists($"Post_Processing_Explanation")==0)
		make/T Post_Processing_Explanation
	elseif(waveexists($"Post_Processing_Explanation")==1)
	//If the wave already exists, then do nothing
	Endif
	
End


//Create a Time Series of both Mass and Number

Function PP_CreateTSeries_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			PP_CreateTime_Series()
		case 2:
			break
		endswitch
		
End

Function PP_CreateTime_Series()
	Setdatafolder root:Post_Processing:Unaltered_Imports

	wave datetimewave_base, NConc_Total_base, MConc_Total_base	
	string S_Name = "Post_Processing_Time_Series_Graph"
	//Kill previous graph
	KillWindow/Z $S_Name
	Display/N=$S_Name/L=Mass MConc_Total_Base vs datetimewave_Base; AppendToGraph/L=Number NConc_Total_Base vs datetimewave_Base
	ModifyGraph fStyle(Mass)=1,fStyle(Number)=1,lblPos(Mass)=1000,lblPos(Number)=1000,axisEnab(Mass)={0.55,1},axisEnab(Number)={0,0.45},freePos(Mass)=0,freePos(Number)=0;DelayUpdate
	Label Mass "Mass Concentration (µg m\\S-3\\M)";DelayUpdate
	Label Number "Number Concentration (# cm\\S-3\\M)"
	ModifyGraph rgb(MConc_Total_Base)=(0,0,0)
	Legend/C/N=Legend0/A=MC/H={0,5,10}
End

//Create a Time Series of both Mass and Number to be used with the Mask_Wave

Function PP_CreateMaskTime_Series_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			PP_CreateMaskTime_Series()
		case 2:
			break
		endswitch
		
End

Function PP_CreateMaskTime_Series()

	//Get a list of all of the waves in the folders
	
	If(DataFolderExists("root:Post_Processing:Unaltered_Imports:")==1)
		setdatafolder root:Post_Processing:Unaltered_Imports:
		DFREF PP_UI = GetdatafolderDFR()
		String WL_PP_UI = wavelist("*",";","TEXT:0")
		Variable NW_PP_UI = itemsinlist(WL_PP_UI,";")
	elseif(DataFolderExists("root:Post_Processing:Unaltered_Imports:")==0)
		Abort "root:Post_Processing:Unaltered_Imports: does not exist."
	Endif
	
	If(DataFolderExists("root:Post_Processing:")==1)
		setdatafolder root:Post_Processing:
		DFREF PP = GetdatafolderDFR()
		String WL_PP = wavelist("*",";","TEXT:0")
		Variable NW_PP = itemsinlist(WL_PP,";")
	elseif(DataFolderExists("root:Post_Processing:")==0)
		Abort "root:Post_Processing: does not exist."
	endif
	
	//Check to see if there are currently waves in the PostProcessing Data Folder
	if(NW_PP_UI == NW_PP) //If the number of waves in the list are the same there are waves in the PostProcessing Data Folder
		wave Mask_Datetimewave, Mask_NConc_Total, Mask_MConc_Total
		string S_Name = "Post_Processing_Time_Series_Graph"
		//Kill previous graph
		KillWindow/Z $S_Name
		Display/N=$S_Name/L=Mass Mask_MConc_Total vs Mask_Datetimewave; AppendToGraph/L=Number Mask_NConc_Total vs Mask_Datetimewave
		ModifyGraph fStyle(Mass)=1,fStyle(Number)=1,lblPos(Mass)=1000,lblPos(Number)=1000,axisEnab(Mass)={0.55,1},axisEnab(Number)={0,0.45},freePos(Mass)=0,freePos(Number)=0;DelayUpdate
		Label Mass "Mass Concentration (µg m\\S-3\\M)";DelayUpdate
		Label Number "Number Concentration (# cm\\S-3\\M)"
		ModifyGraph rgb(MConc_Total_Base)=(0,0,0)
		Legend/C/N=Legend0/A=MC/H={0,5,10}
	else //If Anything else then waves don't exist. Move them from Unaltered Imports to PostProcessing
		setdatafolder PP_UI
		variable i
		for(i=0;i<NW_PP_UI;i++)
			wave tempwave = $stringfromlist(i,WL_PP_UI,";")
			string NewWaveName = "Mask_"+stringfromlist(i,WL_PP_UI,";")
			Duplicate tempwave,PP:$NewWaveName
		endfor
		//Cut the '_Base' in the duplicated waves
		setdatafolder PP
		RemoveChar2WaveListEnd("", "_Base")	
		
		S_Name = "Post_Processing_Time_Series_Graph"
		//Kill previous graph
		KillWindow/Z $S_Name
		wave Mask_MConc_Total, Mask_NConc_Total, Mask_Datetimewave
		Display/N=$S_Name/L=Mass Mask_MConc_Total vs Mask_Datetimewave; AppendToGraph/L=Number Mask_NConc_Total vs Mask_Datetimewave
		ModifyGraph fStyle(Mass)=1,fStyle(Number)=1,lblPos(Mass)=1000,lblPos(Number)=1000,axisEnab(Mass)={0.55,1},axisEnab(Number)={0,0.45},freePos(Mass)=0,freePos(Number)=0;DelayUpdate
		Label Mass "Mass Concentration (µg m\\S-3\\M)";DelayUpdate
		Label Number "Number Concentration (# cm\\S-3\\M)"
		ModifyGraph rgb(Mask_MConc_Total)=(0,0,0)
		Legend/C/N=Legend0/A=MC/H={0,5,10}
	endif

	//Create Flag_Wave
	Duplicate Mask_NConc_Total, Flag_Wave
	Flag_Wave=0

End


Function RemoveChar2WaveListEnd(wList_helper, EndChar)
	string wList_helper, EndChar
	string wList
	if(stringmatch(wList_helper,"")==1) //If blank
		wList = wavelist("*",";","TEXT:0")
	else
		wList = wavelist("*"+wList_Helper,";","TEXT:0")
	Endif
		
	variable idx; variable nwaves = itemsinlist(wList,";")
	for(idx=0;idx<nwaves;idx++)
		string basestring = stringfromlist(idx,wList,";")
		wave tempwave = $stringfromlist(idx,wList,";")
		basestring = RemoveEnding(basestring,EndChar)
		rename tempwave, $basestring
	endfor
End

//Implimentation of Flag_Wave and Masks


Function PP_Mask_Data_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			PP_Mask_Data()
		case 2:
			break
		endswitch
		
End

Function PP_Set_Flags()
	setdatafolder root:Post_Processing
	String WL_PP = wavelist("*",";","TEXT:0")
	Variable NL_PP = itemsinlist(WL_PP,";")
	if(NL_PP<20)	//There should be at least 20 waves in the Post Processing folder
		abort "Waves do not exist in Post Processing Data Folder."
	Endif
	
	wave Flag_Wave, Mask_DateTime, Mask_DateTimeWave, Mask_NConc_Total, Mask_MConc_Total, Mask_SAConc_Total, Mask_GeoSD, Mask_GeoMean, 'Mask_SampleTemp(C)', 'Mask_SamplePressure(kPa)', 'Mask_TotalConc.(#/cm3)', Mask_AvgConc
	wave Mask_NConc, Mask_MConc, Mask_SAConc, Mask_VConc
	
	setdatafolder root:
	NVAR PP_FlagWave_Start, PP_FlagWave_End, PP_FlagWave_Value
	Setdatafolder root:Post_Processing
	variable nrows = Dimsize(Mask_Datetimewave,0)
	if(waveexists(Flag_Wave)==0)
		make/n=(nrows) Flag_Wave = 0 
	elseif(waveexists(Flag_Wave)==1)
	Endif
	PointsinWave2Number(Flag_Wave, PP_FlagWave_Start, PP_FlagWave_End, PP_FlagWave_Value)
	String S_Name = "Mask_Table"
	killwindow/Z $S_Name
	edit/N=$S_Name
	appendtotable Flag_Wave, Mask_DateTimeWave, Mask_NConc_Total, Mask_MConc_Total, Mask_SAConc_Total, Mask_GeoSD, Mask_GeoMean, 'Mask_SampleTemp(C)', 'Mask_SamplePressure(kPa)', 'Mask_TotalConc.(#/cm3)', Mask_AvgConc, Mask_NConc, Mask_MConc, Mask_SAConc, Mask_VConc
	setscale d 0,0, "dat", Mask_DatetimeWave
	Modifytable format(Mask_DateTimeWave) = 8 
End

Function PP_Set_Flags_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			PP_Set_Flags()
		case 2:
			break
		endswitch
		
End

Function PP_Mask_Data()

	setdatafolder root:Post_Processing
	String WL_PP = wavelist("*",";","TEXT:0")
	Variable NL_PP = itemsinlist(WL_PP,";")
	if(NL_PP<20)	//There should be at least 20 waves in the Post Processing folder
		abort "Waves do not exist in Post Processing Data Folder."
	Endif
	
	wave Flag_Wave, Mask_DateTime, Mask_NConc_Total, Mask_MConc_Total, Mask_SAConc_Total, Mask_GeoSD, Mask_GeoMean, 'Mask_SampleTemp(C)', 'Mask_SamplePressure(kPa)', 'Mask_TotalConc.(#/cm3)', Mask_AvgConc
	wave Mask_NConc, Mask_MConc, Mask_SAConc, Mask_VConc
	//Ensure that we have a Flag Wave
	if(waveexists(Flag_Wave)==0)
		make/n=(dimsize(Mask_Datetime,0)) Flag_Wave = 0 
	elseif(waveexists(Flag_Wave)==1)
	endif
	setdatafolder root:
	NVAR PP_FlagWave_Start, PP_FlagWave_End, PP_FlagWave_Value
	Setdatafolder root:Post_Processing
	
	//Check to see if we have nessesary waves (if so, perform masking)
//	if(waveexists(Mask_Datetime)==1 && waveexists(Mask_NConc_Total)==1 && waveexists(Mask_MConc_Total)==1 && waveexists(Mask_NConc)==1 && waveexists(Mask_MConc)==1)
		//Handle all of the 1D waves first
		Mask_NConc_Total = Flag_wave == 1 ? NaN : Mask_NConc_Total		//If the flagwave is 1 at a given index, then change the corresponding wave (tempwave) to -9999 at this index
		Mask_NConc_Total = Flag_Wave == 0 ? Mask_NConc_Total : Mask_NConc_Total	//If the flagwave is 0 at a given index, then change the corresponding wave (tempwave) to tempwave at this index (do nothing)
	
		Mask_MConc_Total = Flag_wave == 1 ? NaN : Mask_MConc_Total
		Mask_MConc_Total = Flag_Wave == 0 ? Mask_MConc_Total : Mask_MConc_Total
		
		Mask_SAConc_Total = Flag_wave == 1 ? NaN : Mask_SAConc_Total
		Mask_SAConc_Total = Flag_Wave == 0 ? Mask_SAConc_Total : Mask_SAConc_Total
		
		Mask_GeoSD = Flag_Wave == 0 ? Mask_GeoSD : Mask_GeoSD
		Mask_GeoSD = Flag_wave == 1 ? NaN : Mask_GeoSD
		
		Mask_GeoMean = Flag_Wave == 0 ? Mask_GeoMean : Mask_GeoMean
		Mask_GeoMean = Flag_wave == 1 ? NaN : Mask_GeoMean
		
		'Mask_SampleTemp(C)' = Flag_Wave == 0 ? 'Mask_SampleTemp(C)' : 'Mask_SampleTemp(C)'
		'Mask_SampleTemp(C)' = Flag_wave == 1 ? NaN : 'Mask_SampleTemp(C)'
		
		'Mask_TotalConc.(#/cm3)' = Flag_Wave == 0 ? 'Mask_TotalConc.(#/cm3)' : 'Mask_TotalConc.(#/cm3)'
		'Mask_TotalConc.(#/cm3)' = Flag_wave == 1 ? NaN : 'Mask_TotalConc.(#/cm3)'
		
		Mask_AvgConc = Flag_Wave == 0 ? Mask_AvgConc : Mask_AvgConc
		Mask_AvgConc = Flag_wave == 1 ? NaN : Mask_AvgConc
		
		'Mask_SamplePressure(kPa)' = Flag_Wave == 0 ? 'Mask_SamplePressure(kPa)' : 'Mask_SamplePressure(kPa)'
		'Mask_SamplePressure(kPa)' = Flag_wave == 1 ? NaN : 'Mask_SamplePressure(kPa)'

			
		
		//Handle all of the 2D waves
		variable D1_Var, D2_Var
		
		//Number Conc
		For(D1_Var=0; D1_Var<numpnts(Flag_Wave); D1_Var++)
		  	If (Flag_Wave[D1_Var] == 1 )
		  		for(D2_Var=0;D2_Var<Dimsize(Mask_NConc,1); D2_Var++)
					Mask_NConc[D1_Var][D2_Var] = NaN
				Endfor
			Endif
		 Endfor
		 
		 //Mass Conc
		 For(D1_Var=0; D1_Var<numpnts(Flag_Wave); D1_Var++)
		  	If (Flag_Wave[D1_Var] == 1 )
		  		for(D2_Var=0;D2_Var<Dimsize(Mask_MConc,1); D2_Var++)
					Mask_MConc[D1_Var][D2_Var] = NaN
				Endfor
			Endif
		 Endfor
		 
		 //SAConc
		  For(D1_Var=0; D1_Var<numpnts(Flag_Wave); D1_Var++)
		  	If (Flag_Wave[D1_Var] == 1 )
		  		for(D2_Var=0;D2_Var<Dimsize(Mask_SAConc,1); D2_Var++)
					Mask_SAConc[D1_Var][D2_Var] = NaN
				Endfor
			Endif
		 Endfor
		 
		 //VConc
		  For(D1_Var=0; D1_Var<numpnts(Flag_Wave); D1_Var++)
		  	If (Flag_Wave[D1_Var] == 1 )
		  		for(D2_Var=0;D2_Var<Dimsize(Mask_VConc,1); D2_Var++)
					Mask_VConc[D1_Var][D2_Var] = NaN
				Endfor
			Endif
		 Endfor
		
//		Mask_NConc = Flag_Wave == 1 ? NaN : Mask_NConc
//		Mask_NConc = Flag_Wave == 0 ? Mask_NConc : Mask_NConc
//		Mask_MConc = Flag_Wave == 1 ? NaN : Mask_MConc
//		Mask_MConc = Flag_wave == 0 ? Mask_MConc : Mask_MConc
		
//	elseif(waveexists(Mask_Datetime)==0 && waveexists(Mask_NConc_Total)==0 && waveexists(Mask_MConc_Total)==0 && waveexists(Mask_NConc)==0 && waveexists(Mask_MConc)==0)
//		print " Error: Must have a Mask Mass Concentration Wave"
//		return -1
//	else
//	endif
	
End

//LG code for masking
//
//Data1 = myFlag == 1 ? NaN : Data1
//
//Above is the hidden loop. It does the same thing as the below for loop.
//
//For(i=0; i<numpnts(myFlag); i++)
//		If (myFlag[i] ==1)
//			Data2[i] = NaN
//		Endif
//	Endfor
//	
//Data3 = myFlag[p] == 1 ? NaN : Data3


//So what it does is goes through and if myFlag at a certain index equals 1, then it changes the value of Data1 at that same index to a NaN.
//You can put any logic between the first equal sign and the question mark and any value between the question mark and colon. And it can operate on itself. 
//So it can be an easy way to remove values less or greater than a certain number or you can use numtype(num) to change NaNs into -9999, for example

Function PP_Reset_Mask_Waves_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			PP_Reset_Mask_Waves()
		case 2:
			break
		endswitch
		
End

Function PP_Reset_Mask_Waves()

	setdatafolder root:Post_Processing:Unaltered_Imports
	wave DateTimeWave_Base,NConc_Total_Base, MConc_Total_Base,SAConc_Total_Base,GeoSD_Base,GeoMean_Base,'SampleTemp(C)_Base','SamplePressure(kPa)_Base','TotalConc.(#/cm3)_Base',AvgConc_Base
	wave NConc_Base,MConc_Base,SAConc_Base,VConc_Base
	wave Flag_Wave, Mask_DateTime, Mask_DateTimeWave, Mask_NConc_Total, Mask_MConc_Total, Mask_SAConc_Total, Mask_GeoSD, Mask_GeoMean, 'Mask_SampleTemp(C)', 'Mask_SamplePressure(kPa)', 'Mask_TotalConc.(#/cm3)', Mask_AvgConc
	wave Mask_NConc, Mask_MConc, Mask_SAConc, Mask_VConc
	
	duplicate/O Datetimewave_Base, root:Post_Processing:Mask_Datetime
	duplicate/O NConc_Total_Base, root:Post_Processing:Mask_NConc_Total
	duplicate/O MConc_Total_Base, root:Post_Processing:Mask_MConc_Total
	duplicate/O SAConc_Total_Base, root:Post_Processing:Mask_SAConc_Total
	duplicate/O GeoSD_Base,root:Post_Processing:Mask_GeoSD
	duplicate/O GeoMean_Base,root:Post_Processing:Mask_GeoMean
	duplicate/O 'SampleTemp(C)_Base',root:Post_Processing:'Mask_SampleTemp(C)'
	duplicate/O 'SamplePressure(kPa)_Base',root:Post_Processing:'Mask_SamplePressure(kPa)'
	duplicate/O 'TotalConc.(#/cm3)_Base',root:Post_Processing:'Mask_TotalConc.(#/cm3)'
	duplicate/O AvgConc_Base,root:Post_Processing:Mask_AvgConc
	duplicate/O NConc_Base, root:Post_Processing:Mask_NConc
	duplicate/O MConc_Base, root:Post_Processing:Mask_MConc
	duplicate/O SAConc_Base, root:Post_Processing:Mask_SAConc
	duplicate/O VConc_Base, root:Post_Processing:Mask_VConc
	
	setdatafolder root:Post_Processing
	wave Flag_Wave, Mask_MConc_Total
	if(waveexists(Flag_Wave)==0)
	duplicate Mask_MConc_Total, Flag_Wave
	Flag_Wave=0
	elseif(waveexists(Flag_Wave)==1)
		Flag_Wave = 0
	endif

End


//Make ICARTT File for Post_Processing Waves

Function PP_MakeICARTTTable_SMPS_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			PP_MakeICARTTTable_SMPS()
		case 2:
			break
		endswitch
		
End
Function PP_MakeICARTTTable_SMPS()
	NVAR SoftwareVersion = root:SoftwareVersion
	
	setdatafolder root:Post_Processing
	if(datafolderExists("root:Post_Processing:ICARTT_Waves")==0)
		Newdatafolder/S	root:Post_Processing:ICARTT_Waves 
		DFREF IC_W= getdatafolderDFR()
	elseif(datafolderExists("root:Post_Processing:ICARTT_Waves")==1)
		setdatafolder root:Post_Processing:ICARTT_Waves 
		DFREF IC_W = getdatafolderDFR()
	Endif
		
	Setdatafolder root:Post_Processing
	
//	Change all of the waves to the names within post processing	
	
	Wave Mask_SMPS_Start, Mask_SMPS_Stop, Mask_SMPS_MidPoint
	//Round
	Duplicate/O Mask_SMPS_Start, IC_W:Time_Start
	Duplicate/O Mask_SMPS_Stop, IC_W:Time_Stop
	Duplicate/O Mask_SMPS_MidPoint, IC_W:Time_Mid
	
	
	
	Duplicate/O :'Mask_TotalConc.(#/cm3)' IC_W:TSI_NumbConc
	Duplicate/O :'Mask_NConc_Total' IC_W:Farmer_NumbConc	
	Duplicate/O :'Mask_GeoMean' IC_W:GeoMean
	Duplicate/O :'Mask_MConc_Total' IC_W:Farmer_MassConc	
	
	If (SoftwareVersion==1)
		Duplicate/O :'Mask_Geo.Std.Dev' IC_W:GeoStdDev  //AIM 11
		Duplicate/O :'Mask_SheathTemp(C)' IC_W:Temp
		Duplicate/O :'Mask_SheathPressure(kPa)' IC_W:Press
	Else
		Duplicate/O :'Mask_GeoSD' IC_W:GeoStdDev //AIM10 and Willis box
		Duplicate/O :'Mask_SampleTemp(C)' IC_W:Temp
		Duplicate/O :'Mask_SamplePressure(kPa)' IC_W:Press
	EndIf
	
	Duplicate/O :Mask_NConc IC_W:NConc
	
	
	Setdatafolder IC_W
	Wave diameter
	Make/T/O VarNameWave
	varnamewave = {"Time_Start","SMPS_Stoptime","SMPS_MidPointTime","TSI_NumbConc","GeoMean", "GeoStdDev","Farmer_MassConc", "Farmer_NumbConc", "Temp","Press", "NConc"}
	variable i

	Wave Time_Start, Time_Stop, Time_Mid
	Time_Start = Round(Time_Start)
	Time_Stop = Round(Time_Stop)	
	Time_Mid = Round(Time_Mid)
	
	String S_Name = "Post_Processing_ICARTT_Table"
	
	KillWindow/Z $S_Name
	Edit/N=$S_Name Time_Start, Time_Stop, Time_Mid
	
	ModifyTable format(Time_Start)=8,format(Time_Stop)=8,format(Time_Mid)=8
	ModifyTable digits(Time_Start)=1, digits(Time_Stop)=1, digits(Time_Mid)=1
	

	For (i=3; i<numpnts(varnamewave); i++)
		string thisname = varnamewave[i] 
		AppendtoTable $thisname
		ModifyTable format($thisname)=3, digits($thisname)=1
	EndFor
	
	ModifyTable digits(:GeoStdDev) = 3
	
	Killwaves varnamewave
	
	//Change NaN to -9999
	String WL_IC = Wavelist("*",";","TEXT:0")
	variable NW_IC = itemsInList(WL_IC,";")
	for(i=0;i<NW_IC;i++)
		wave tempwave = $stringfromlist(i,WL_IC,";")
		tempwave = numtype(tempwave)== 2 ? -9999 : tempwave	
	endfor	

	SetDatafolder root:
End


Function RecalcTSIStats()
	
	Wave NConc, diam
	Duplicate/O/FREE NConc NConc_Trans
	MatrixTranspose NConc_Trans
	
	variable i //timepoints
	Make/N=(dimsize(NConc,0))/O GeoMean, GeoSD, AvgConc = Nan
	print dimsize(NConc,0)
	
	For (i=0; i<dimsize(NConc,0); i++)
		Matrixop/O/FREE thiswave = col(NConc_Trans,i)
		Redimension/N=-1 thiswave
		
		Variable GeoMeanvar, GeoSDvar, AvgConcvar
		[GeoMeanvar, GeoSDvar, AvgConcvar] = TSIStatistics(thiswave, diam)
		GeoMean[i] = GeoMeanvar
		GeoSD[i] = GeoSDvar
		AvgConc[i] = AvgConcvar
	EndFor

End


function checkdiam_button(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 1: //mouse up
			checkdiameters()
		case 2:
			break
		endswitch
end

Function checkdiameters()
	
	variable type =1 //Check in the Number_Concentration folders
		
	DFREF ndf = root:Number_Concentration:
	String ndfname = "root:Number_Concentration:"
	
	SetDataFolder ndf //Number or Mass _Concentration
	variable ndfs = countobjectsDFR(ndf, 4)	//Count the number of data folders
	variable dfnumb // Index of data folder	
	
	String dfList = SortedDataFolderList(ndfname, 16) //List of YYYY_MM_DD...data foldernames
	variable numDataFolders = ItemsInList(dfList)
	
	Make/N=0/D/O/FREE canon_diam
	setdataFolder ndf:$StringFromList(0, dfList)
	Wave canon_diam = diam // the canonical diameter that we assume all datafiles are is the length of the diameters of the first datafile
	variable canon_diamlength = dimsize(canon_diam,0)
	string dfname  //Count number of different diameter parameters
	
	////For each folder, see if the diameter matches the canonical diameters. If not, put in a different list
	
	int i
	Make/N=2/O/T/FREE SepDiam_strname = ""
	For (i=0;i<ndfs;i++)		
		dfname = StringFromList(i, dfList)
		setdataFolder ndf
		setdataFolder dfname // YYYY_MM_DD... filename
		Wave thisdiam = diam
		
		
		If (dimsize(thisdiam,0)==canon_diamlength) //Compare length of diameter wave to "canonical wave"
			Make/FREE/N=(numpnts(canon_diam)) delta
			delta = abs(canon_diam-thisdiam)  //Compare diameter bins to the canonical bins. If they dont match increase number of diameter in data set.
			If (sum(delta)<1)
				SepDiam_strname[0] = AddListItem(dfname, SepDiam_strname[0], ";")
			Else 
				SepDiam_strname[1] = AddListItem(dfname, SepDiam_strname[1], ";")
			EndIf
		Else			
			SepDiam_strname[1] = AddListItem(dfname, SepDiam_strname[1], ";")
		Endif
		
		
	EndFor	
	
	If (strlen(SepDiam_strname[1]) == 0)
		doalert/T="Diameter Check" 0, "All the loaded files have the same diameter bins"
	Else 
		doalert/T="Diameter Check" 0, "The following files have different diameter bins from the first file:\r" + sepdiam_strname[1]
		Print "The following files have different diameter bins from the first file:\r" + sepdiam_strname[1]
	Endif
	
	SetDataFolder root:
	
End