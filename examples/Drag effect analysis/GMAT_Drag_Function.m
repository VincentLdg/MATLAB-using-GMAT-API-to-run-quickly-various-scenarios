function data=GMAT_Drag_Function(time_of_propagation,drag_area)
    
    % HELP:
    %
    % time_of_propagation = Orbital propagation time in days
    % drag_area = Drag Area value for the chaser satellite in m^2
    %
    % Data = Matrix containing the GMAT simulation output 
    % The satellite's alltitude and the corresponding time 

    % FUNCTION:
    
    % Creation of a GMAT New Script, starting from the GMAT basic_script
    % and creating and run the new script with the input values 
    
    % Open the GMAT script and extract the content
    path_folder = ".\GMAT_API_with_MATLAB\"; % !!! change it with your personal path 
    basic_script = fopen(path_folder + "satellite_case.script",'r'); 
    basic_script_content = fread(basic_script) ;
    fclose(basic_script)  ;
    basic_script_content = char(basic_script_content.') ;
    
    % Add the mission sequence
    mission_sequence = convertStringsToChars("Propagate Propagator(Satellite) {Satellite.ElapsedDays = " + time_of_propagation + "};");
    new_script_content = [basic_script_content, newline, mission_sequence];
      
    % Save the new script
    new_script_filename = "New_script_satellite_case.script";
    new_script = fopen(path_folder + new_script_filename,'wt'); 
    fwrite(new_script, new_script_content, 'char');
    fclose(new_script);
    
    % Load the GMAT API and open the new script with the mission sequence 
    load_gmat();
    GMATAPI.LoadScript(path_folder + new_script_filename);
    
    % Get the object Satellite and set the valeu of the DragArea
    satellite = GMATAPI.GetObject("Satellite");
    satellite.SetField("DragArea",drag_area);

    % Run of the GMAT script and collect the results
    GMATAPI.RunScript();
    data = table2array(readtable(path_folder + 'satellite_case_report.txt'));  

end