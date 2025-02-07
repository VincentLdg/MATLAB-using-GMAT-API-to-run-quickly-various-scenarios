# MATLAB Function using GMAT API

The goal of this function is to modify an existing GMAT script using the **GMAT API**. This can be useful **to compare initial conditions, satellite's parameters, propagators, burns, ect...**

I programmed this function for a specific project but  you can use this code as inspiration and adapt it to your own project.

**Complete tutorial in the example file on the study of the effect of atmospheric friction on ISS altitude.**

## Requirements

* Download [GMAT](https://sourceforge.net/projects/gmat/)
* Before running the function, be sure to be in folder **bin** located in GMAT folder (GMAT→bin). Because we need to use the function **"load_GMAT"** to call the GMAT application without interface.     

# Using the GMAT API with MATLAB to quickly generate multiple scenarios 

This project provides a streamlined method for using the GMAT (General Mission Analysis Tool) API with MATLAB. It enables users to easily generate mission scenarios and directly process the results within MATLAB. Due to the lack of extensive documentation for the GMAT API, this approach offers a workaround to efficiently interact with GMAT through MATLAB.

## Features
- Automates the modification and execution of GMAT mission scripts via MATLAB.
- Enables parameter variations without manual intervention in GMAT.
- Extracts simulation results from GMAT directly into MATLAB for further analysis.
- Simplifies the usage of the GMAT API, making it more accessible for mission simulations.

## Process Overview

### 1. Define the Mission in GMAT
- Create a GMAT mission script defining all necessary mission parameters (satellite, propagator, thrusters, etc.).
- Determine which parameters will be varied during simulations:
  - If the parameters are part of the mission sequence (e.g., different propagators, propagation duration, maneuver parameters), **do not include a mission sequence in the GMAT script**.
  - Otherwise, if the mission sequence remains constant, it can be fully integrated into the GMAT script.
- Add a **Report File** to the GMAT script to store simulation results in a text file.

### 2. Implement the MATLAB Function
- The MATLAB function takes as **inputs** the values of parameters to be modified.
- The function executes the following steps:
  1. **Add the Mission Sequence** (if necessary).
  2. **Open the GMAT Script** via the API (`LoadScript`).
  3. **Modify the Parameters** via the API (`SetField`).
  4. **Run the Simulation** via the API (`RunScript`).
  5. **Retrieve Mission Data** from the Report File for further processing in MATLAB.


## Requirements
- [GMAT](https://gmat.gsfc.nasa.gov/) installed with API access.
- MATLAB with access to GMAT API functions. Need to add the path `GMAT/bin` in MATLAB using the button `Set Path` in the `Home` menu

## MATLAB Example : The effect of the drag surface on a satellite
Our satellite is in circular orbit at 350 km of height, at this height the atmosphere still affects te satellites by slowding them down. To maintain the orbit, the satellite must use his thruster and consumes ergol which is very 
Consider a satellite in a circular orbit at 350 km altitude. At this altitude, the Earth's atmosphere is still present, creating drag forces that gradually slow down the satellite. As a result, to maintain its orbit, the satellite must periodically use its propulsion system, consuming onboard fuel.

Using the GMAT API with MATLAB, we can analyze how the drag surface area affects the satellite's orbit. 
- The mission duration is fixed at 10 days
- The satellite's drag area will vary from 15m² to 35 m²
- We recover the satellite's altitude at the end of the mission 

### 1. Creation of the mission script with GMAT
- Create your mission with GMAT application ([GMAT docs](https://documentation.help/GMAT/UsingGmat.html)), initialise the spacecraft, the propagator and the report file .
<p align="center">
<img src="\pictures\mission_ressources.jpg" alt="Description de l'image" width="150" height="330"></p>
- We can add a mission sequence, just a 10 days propagation. We run the mission to see if the data are well saved in the reportfile and to see how the mission sequence looked in the script because we must have the same format. 
<p align="center">
<img src="\pictures\mission_sequence.jpg" alt="Description de l'image" width="231" height="185">
</p>
<p align="center">
<img src="\pictures\mission_sequence.jpg" alt="Description de l'image" width="231" height="185">
</p>

### 2. MATLAB function implementation

- Function initilisation with the input parameters :
    - time_of_propagation : duration of the mission in days
    - drag_area : satellite's drag area in m²
The output is the data extracted from the report file mission

```matlab
function data=GMAT_Drag_Function(time_of_propagation,drag_area)
```

- Open the GMAT script (whitout mission sequence)
```matlab
basic_script = fopen(path_folder + "satellite_case.script",'r');
basic_script_content = fread(basic_script);
fclose(basic_script);
basic_script_content = char(basic_script_content.');
```
- Add the mission content and save the new script
```matlab
mission_sequence = convertStringsToChars("Propagate Propagator(Satellite) {Satellite.ElapsedDays = " + time_of_propagation + "};");
new_script_content = [basic_script_content, newline, mission_sequence];
    
new_script_filename = "New_script_satellite_case.script";
new_script = fopen(path_folder+new_script_filename,'wt');
fwrite(new_script, new_script_content, 'char');
fclose(new_script);
```
- Load GMAT API and open the new script
```matlab
load_gmat();
GMATAPI.LoadScript(path_folder + new_script_filename);
```
- Get the object `Satellite` and change is `DragArea`
```matlab
satellite = GMATAPI.GetObject("Satellite");
satellite.SetField("DragArea",drag_area);
```

-Run the mission and recover the data in the report file
```matlab
GMATAPI.RunScript();
data = table2array(readtable(path_folder + 'satellite_case_report.txt')); 
```

### 3. Main MATLAB code and results
- Define the parameters 
```matlab
time_of_propagation = 10;  % Simulation duration (days)
drag_areas = 15:0.5:35;  % Drag area (m²)
altitudes_after_10_days = zeros(size(drag_areas));
```
- Run the mission for each drag area and recover the satellite's altitude
```matlab
for i = 1:length(drag_areas)
    drag_area = drag_areas(i);
    result = GMAT_Drag_Function(time_of_propagation, drag_area); 
    altitudes_after_10_days(i) = result(end, 2);
    drag_area
end
```

- Plot the results
```matlab
figure;
plot(drag_areas, altitudes_after_10_days, '-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Drag Area (m²)');
ylabel(sprintf('Altitude after %d days (km)', time_of_propagation));
title(sprintf('Evolution of the Altitude after %d days as a function of Drag Area', time_of_propagation));
grid on;
```



### Load the GMAT script (MATLAB)
Load this script in MATLAB as a text file
```matlab
    GMAT_script =fopen(path_folder+script_name,'r'); 
    script_content = fread(GMAT_script) ;
    fclose(GMAT_script) ;
    script_content = char(script_content.') ;
```
***Create the mission sequence***, add it at the end of the GMAT script and save it.
```matlab
    line_maneuver=convertStringsToChars("Maneuver Default_dV(Satellite);");
    line_propagation=convertStringsToChars("Propagate "+Propagator_name+"(Satellite) {Satellite.ElapsedSecs = "+Time_propagation+"};");
    updated_script_content = [script_content, newline, line_maneuver, newline, line_propagation];

    new_script = fopen(path_folder+updated_script_name,'wt');  
    fwrite(updated_script, updated_script_content, 'char');
    fclose(updated_script);
```
### Load the updated GMAT script and modify it (MATLAB)
Call GMAT API (be sure to be in the bin folder where the **"load_GMAT"** is located)
```matlab
   load_gmat();
```

Load the updated script (GMAT API)
```matlab
   GMATAPI.LoadScript(path_folder + updated_script_name);
```

You can modify an existing variable with the GMAT API function **'GetObject'** and **'SetField'**.
This is an example that modify the initial cartesian position of the satellite :
```matlab
   Satellite_pos=GMATAPI.GetObject("Satellite");
   Satellite_pos.SetField("X",new_X);
   Satellite_pos.SetField("Y",new_Y);
   Satellite_pos.SetField("Z",new_Z);
```

### Run the simulation and recover the data
```matlab
    GMATAPI.RunScript();
    Data= table2array(readtable(path_folder+'Report_file.txt')); 
```



