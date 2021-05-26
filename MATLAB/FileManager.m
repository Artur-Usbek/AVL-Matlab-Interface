classdef FileManager < handle
    
    properties (Access = public)
        AVL_Configuration_Path
        AVL_Error_Path      = [];
        AVL_Input_Path      = [];
        AVL_Mass_Path
        AVL_Results_Path    = [];
        AVL_Run_Path        = [];
        Project_Name
        Project_Path
    end
    
    
    properties (Access = private)
        Airfoils                = []
        Airfoil_DataBase_Path   = "../Airfoil_DataBase/"
        Airfoil_Paths           = []
        Project_Base_Path       = "../Projects/"
    end
    
    properties (Constant)
        MAX_RUN_CASES           = 25
    end
    
    methods 
        
        function obj  = FileManager()
        end
        
        function projectpath = get.Project_Path(obj)
            if isempty(obj.Project_Name)
                warning("FileManager.m: Project Name not defined!");
                projectpath = [];
                return
            end
            obj.Project_Path = fullfile(obj.Project_Base_Path, obj.Project_Name);
            projectpath = obj.Project_Path;
        end
        
        function  set.Project_Path(obj, path)
            obj.Project_Path = path;
        end
        
        function  set.Project_Name(obj, name)
            obj.Project_Name = name;
            fprintf("Project: Set Project Name to %s\n", obj.Project_Name);
        end
        
        function addAirfoil(obj, Airfoil)
            % Check if Airfoil was already added
            if ~isempty(obj.Airfoils)
                if any(contains(obj.Airfoils, Airfoil))
                    format = "Airfoil: Already added: '%s'\n";
                    fprintf(format, Airfoil)
                    return
                end
            end
            
            % Try to find Airfoil in Airfoil_Database Folder
            Airfoil_path = fullfile(obj.Airfoil_DataBase_Path, Airfoil + ".dat");
            if exist(Airfoil_path, 'file')
                obj.Airfoils       = [obj.Airfoils; Airfoil];
                obj.Airfoil_Paths = [obj.Airfoil_Paths; Airfoil_path];
                format = "Airfoil: Found '%s' at '%s'\n";
                fprintf(format, Airfoil, Airfoil_path)
            else
                format = "Airfoil: Could not find '%s' at '%s' ! \n Please Add File to Project Folder Manually";
                warning(format, Airfoil, Airfoil_path);
            end
            
        end
        
        function start(obj, Airplane, Cases, Masses)
            fprintf("General: Starting Generation\n");
            
            % Setting Project Name
            obj.Project_Name = Airplane.Name;
            
            % Creating the Folder in Projects
            obj.createProjectFolder();
            
            % Copy the used Airfoils from Airfoil_DataBase to Project Folder 
            obj.copyAirfoils(Airplane);
            
            % Create the Aircraft Configuration File
            obj.writeAVLConfigurationsFile(Airplane);
            
            % Create the Run Files
            if nargin > 2
                obj.writeAVLRunFile(Cases);
            end
            
            % Create the MassFile
            if nargin > 3
                obj.writeAVLMassFile(Masses);
            end
            
            % Create the Input Files
            obj.writeAVLInputFile(Cases);
            
            % Generate Error File Names
            obj.AVL_Error_Path = replace(obj.AVL_Run_Path, ".run", ".err");
            
            fprintf("General: Finished Generation\n");
        end
        
    end
    
    methods (Access = private)
        function createProjectFolder(obj)
            if exist(obj.Project_Path, "dir")
                format = "Project Folder: Using Already Existent Folder: %s";
                warning(format, obj.Project_Path);
            else
                format = "Project Folder: Creating New Folder: %s\n";
                fprintf(format, obj.Project_Path);
                mkdir(obj.Project_Path);
            end
            
        end
        
        function copyAirfoils(obj, Airplane)
            % Add Airfoils
            for iSurface = 1:length(Airplane.Surfaces)
                Surface = Airplane.Surfaces(iSurface);
                for jSection = 1:length(Surface.Sections)
                    Section = Surface.Sections(jSection);
                    obj.addAirfoil(Section.Airfoil);
                    AirfoilPath = fullfile(obj.Project_Path, Section.Airfoil);
                    Section.Airfoil = FileManager.makeWriteable(AirfoilPath);
                end
            end
            
            % Copy Airfoil
            for iAirfoil = 1:length(obj.Airfoil_Paths)
                Airfoil_Path    = obj.Airfoil_Paths(iAirfoil);
                format          = "Airfoil: Copying %s to %s \n";
                fprintf(format, Airfoil_Path, obj.Project_Path);
                copyfile(Airfoil_Path, obj.Project_Path);
                format = "Airfoil: Copying successful %s to %s \n";
                fprintf(format, Airfoil_Path, obj.Project_Path)
            end
        end
        
        function writeAVLConfigurationsFile(obj, Airplane)
            fprintf("Configuration: Generating Code\n");
            ConfigurationCode = Airplane.getConfigurationCode();
            % Write To File
            obj.AVL_Configuration_Path = fullfile(obj.Project_Path, obj.Project_Name+".avl");
            fid = fopen(obj.AVL_Configuration_Path, 'w+');
            fprintf(fid, ConfigurationCode);
            fclose(fid);
            format = "Configuration: Finished Writing Configuration to %s\n";
            fprintf(format, obj.AVL_Configuration_Path);
        end
        
        function writeAVLMassFile(obj)
            warning("FileManager.m: Not Implemented Yet");
        end
        
        function writeAVLRunFile(obj, Cases)
            NoRunFiles      = ceil(length(Cases) / obj.MAX_RUN_CASES);
            
            for iFile =  1:NoRunFiles
                
                % Cases
                idxes = [(iFile-1)*obj.MAX_RUN_CASES+1, iFile*obj.MAX_RUN_CASES];
                if idxes(2) > length(Cases)
                    idxes(2) = length(Cases);
                end
                currCases = Cases(idxes(1):idxes(2));
                
                % Name
                fileName            = sprintf("%s_%03d.run", obj.Project_Name, iFile);
                filePath            = fullfile(obj.Project_Path,  fileName);
                obj.AVL_Run_Path    = [obj.AVL_Run_Path, filePath];
                
                % Generate
                FileManager.generateRun(filePath, currCases);
                
            end
        end
        
        function writeAVLInputFile(obj, Cases)
            
            obj.AVL_Results_Path = replace(obj.AVL_Run_Path, ".run", ".res");
            obj.AVL_Input_Path   = replace(obj.AVL_Run_Path, ".run", ".inp");
            
            parfor iFile = 1:length(obj.AVL_Results_Path)
                % Files
                Run_File     = FileManager.makeWriteable(obj.AVL_Run_Path(iFile));
                Config_File  = FileManager.makeWriteable(obj.AVL_Configuration_Path);
                Res_File     = FileManager.makeWriteable(obj.AVL_Results_Path(iFile));
                InputFilePath = obj.AVL_Input_Path(iFile);
                
                % Cases
                idxes = [(iFile-1)*obj.MAX_RUN_CASES+1, iFile*obj.MAX_RUN_CASES];
                if idxes(2) > length(Cases)
                    idxes(2) = length(Cases);
                end
                currCases = Cases(idxes(1):idxes(2));
                
                % Generate
                FileManager.generateInput(currCases, InputFilePath, Run_File, Config_File, Res_File);
            end
        end
        
        
    end
    
    methods (Static, Access = public)
        
        function path = makeWriteable(path)
            path = replace(path, "..\", "");
            path = replace(path, "\", "/");
        end
        
    end
    
    methods (Static, Access = private)
        
        function generateInput(Cases, InputFilePath, Run_File, Config_File, Res_File)
            format = "InputFile: Starting Generation (%s)\n";
            fprintf(format, InputFilePath);
            
            cmds           = {};
            cmds{end+1}    = sprintf("LOAD %s", Config_File);   % Load Aircraft
            cmds{end+1}    = sprintf("CASE %s", Run_File);      % Load Runs
            cmds{end+1}    = "Oper";                            % Go to Oper Menu
            
            % First Case
            cmds{end+1}    = "X"; % Execute Case
            cmds{end+1}    = "W"; % Write Forces to file
            cmds{end+1}    = Res_File; % name of file
            
            % Further Cases
            for iCase = 2:length(Cases)
                cmds{end+1}    = string(iCase);    % Switch to this case
                cmds{end+1}    = "X";              % Execute Case
                cmds{end+1}    = "W";              % Write Forces to file
                cmds{end+1}    = "";               % No Name of File = append to previous File
            end
            
            % Closing AVL
            cmds{end+1}    = ""; % Leave Oper
            cmds{end+1}    = "quit"; % quit AVL
            
            
            % Join Code
            cmds            = join(string(cmds), "\n");
            
            format = "InputFile: Finished Generation (%s)\n";
            fprintf(format, InputFilePath);
            
            % Write Code to File
            format = "InputFile: Start Writing (%s)\n";
            fprintf(format, InputFilePath);
            
            fid = fopen(InputFilePath, 'w+');
            fprintf(fid, cmds);
            fclose(fid);
            
            format = "InputFile: Finished Writing (%s)\n";
            fprintf(format, InputFilePath);
        end
        
        function generateRun(filePath, Cases)
                format = "RunFile: Starting Generation %s\n";
                fprintf(format, filePath);
                
                % Get Code
                RunCode = cell(length(Cases), 1);
                for iCase = 1:length(Cases)
                    runCase         = Cases(iCase);
                    RunCode{iCase}  = runCase.getCode(iCase);
                end

                % Join Code
                RunCode = join(string(RunCode), "\n ");
                
                format = "RunFile: Finished Generation %s\n";
                fprintf(format, filePath);

                % Write To File
                format = "RunFile: Start Writing %s\n";
                fprintf(format, filePath);
                
                fid     = fopen(filePath, 'w+');
                fprintf(fid, RunCode);
                fclose(fid);
                
                format = "RunFile: Finished Writing %s\n";
                fprintf(format, filePath);
            
        end
        
    end
    
end