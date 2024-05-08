# MATLAB Function using GMAT API

The goal of this function is to modify an existing GMAT script using the **GMAT API**. This can be useful **to compare initial conditions, satellite's parameters, propagators, burns, ect...**

I programmed this function for a specific project but  you can use this code as inspiration and adapt it to your own project.

## Requirements

* Download [GMAT](https://sourceforge.net/projects/gmat/)
* Before running the function, be sure to be in folder **bin** located in GMAT folder (GMAT→bin). Because we need to use the function **"load_GMAT"** to call the GMAT application without interface.     

## Principle 
### Creation of the mission (GMAT)
* Create your mission with GMAT application ([GMAT docs](https://documentation.help/GMAT/UsingGmat.html)), initialise the spacecraft, the propagator, the burn.
<p align="center">
<img src="\pictures\mission_ressources.jpg" alt="Description de l'image" width="150" height="330">
</p>
* Don't create Mission sequence because this is where you specify the maneuvers (burn, propagator and time of propagation), the GMAT API cannot modify this part, to modify those values we create the mission sequence in MATLAB.
<p align="center">
<img src="\pictures\mission_sequence.jpg" alt="Description de l'image" width="231" height="185">
</p>
* Add a report file in the output of the simulation, this is how we will recover the data
<p align="center">
<img src="\pictures\mission_output.jpg" alt="Description de l'image" width="150" height="330">
</p>
* GMAT will automatically create a GMAT script that we will load and modify with MATLAB.

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



