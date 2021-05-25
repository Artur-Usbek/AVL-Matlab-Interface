classdef FileManager < handle
    properties
        AVL_Configuration_Path
        AVL_Error_Path      = [];
        AVL_Input_Path      = [];
        AVL_Mass_Path
        AVL_Run_Path        = [];
        AVL_Results_Path    = [];
        Project_Name
        Project_Path
    end
    
    
    properties (Access = private)
        Airfoil_DataBase_Path   = "../Airfoil_DataBase/"
        Project_Base_Path       = "../Projects/"
        Airfoils_Paths          = []
        Airfoils                = []
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
        
        
        function addAirfoil(obj, Airfoil)
            if ~isempty(obj.Airfoils)
                if any(contains(obj.Airfoils, Airfoil))
                    format = "Airfoil: Already added: '%s'\n";
                    fprintf(format, Airfoil)
                    return
                end
            end
            
            Airfoil_path = fullfile(obj.Airfoil_DataBase_Path, Airfoil + ".dat");
            if exist(Airfoil_path, 'file')
                obj.Airfoils       = [obj.Airfoils; Airfoil];
                obj.Airfoils_Paths = [obj.Airfoils_Paths; Airfoil_path];
                format = "Airfoil: Found '%s' at '%s'\n";
                fprintf(format, Airfoil, Airfoil_path)
            else
                format = "Airfoil: Could not find '%s' at '%s' ! \n Please Add File to Project Folder Manually";
                warning(format, Airfoil, Airfoil_path);
            end
            
        end
        
        function start(obj, Airplane, Cases, Masses)
            obj.Project_Name = Airplane.Name;
            obj.createProjectFolder();
            obj.copyAirfoils(Airplane);
            obj.writeAVLConfigurationsFile(Airplane);
            if nargin > 2
                obj.writeAVLRunFile(Cases);
            end
            if nargin > 3
               obj.writeAVLMassFile(Masses); 
            end
            
            obj.writeAVLInputFile(Cases);
            
            obj.AVL_Error_Path = replace(obj.AVL_Run_Path, ".run", ".err");
            
        end
        
    end
    methods (Access = private)
        function createProjectFolder(obj)
            if exist(obj.Project_Path, "dir")
                format = "Using Already Existent Folder: %s";
                warning(format, obj.Project_Path);
            else
                format = "Creating New Folder: %s\n";
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
            
            for iAirfoil = 1:length(obj.Airfoils_Paths)
                Airfoil_Path = obj.Airfoils_Paths(iAirfoil);
                format = "Airfoil: Copying %s to %s \n";
                fprintf(format, Airfoil_Path, obj.Project_Path)
                copyfile(Airfoil_Path, obj.Project_Path);
                format = "Airfoil: Copying successful \n";
                fprintf(format, Airfoil_Path, obj.Project_Path)
            end
        end
        
        function writeAVLConfigurationsFile(obj, Airplane)
            fprintf("Configuration: Generating Code");
            ConfigurationCode = Airplane.getConfigurationCode();
            % Write To File
            obj.AVL_Configuration_Path = fullfile(obj.Project_Path, obj.Project_Name+".avl");
            fid = fopen(obj.AVL_Configuration_Path, 'w+');
            fprintf(fid, ConfigurationCode);
            fclose(fid);
            fprintf("Configuration: Finished Writing to %s\n",obj.AVL_Configuration_Path);
        end
        
        function writeAVLMassFile(obj)
            
        end
        
        function writeAVLRunFile(obj, Cases)
            Max_Run_Cases   = 25;
            NoRunFiles      = ceil(length(Cases) / Max_Run_Cases);
            
            for iFile =  1:NoRunFiles
                %
                RunCode = {};

                % Cases
                idxes = [(iFile-1)*Max_Run_Cases+1, iFile*Max_Run_Cases];
                if idxes(2) > length(Cases)
                    idxes(2) = length(Cases);
                end
                
                runNo = 1;
                for iCase = idxes(1):idxes(2)
                    runCase = Cases(iCase);
                    RunCode{end+1} = runCase.getCode(runNo);
                    runNo = runNo +1;
                end

                % Join Code
                RunCode            = join(string(RunCode), "\n ");

                % Write To File
                fileName = sprintf("%s_%03d.run", obj.Project_Name, iFile);
                filePath = fullfile(obj.Project_Path,  fileName);
                obj.AVL_Run_Path = [obj.AVL_Run_Path, filePath];
                fid = fopen(filePath, 'w+');
                fprintf(fid, RunCode);
                fclose(fid);
            end
        end
        
        function writeAVLInputFile(obj, Cases)
            
           obj.AVL_Results_Path = replace(obj.AVL_Run_Path, ".run", ".res");
           obj.AVL_Input_Path   = replace(obj.AVL_Run_Path, ".run", ".inp");
           
           
            Max_Run_Cases   = 25;
            NoRunFiles      = ceil(length(Cases) / Max_Run_Cases);
           
           for iFile = 1:length(obj.AVL_Results_Path)
               Run_File     = FileManager.makeWriteable(obj.AVL_Run_Path(iFile));
               Config_File  = FileManager.makeWriteable(obj.AVL_Configuration_Path);
               Res_File     = FileManager.makeWriteable(obj.AVL_Results_Path(iFile));

               cmds             = {};
               cmds{end+1}    = sprintf("LOAD %s", Config_File);
               cmds{end+1}    = sprintf("CASE %s", Run_File);
               cmds{end+1}    = "Oper";
               % First Case
               cmds{end+1}    = "X"; % Execute Case
               cmds{end+1}    = "W"; % Write Forces to file
               cmds{end+1}    = Res_File; % name of file
                
               
                % Cases
                idxes = [(iFile-1)*Max_Run_Cases+1, iFile*Max_Run_Cases];
                if idxes(2) > length(Cases)
                    idxes(2) = length(Cases);
                end
               
                runNo = 2;
               for iCase = idxes(1)+1:idxes(2)
                   cmds{end+1}    = string(runNo);    % Switch to this case
                   cmds{end+1}    = "X";              % Execute Case
                   cmds{end+1}    = "W";              % Write Forces to file
                   cmds{end+1}    = "";               % No Name of File = append to previous File
                   runNo          = runNo + 1;
               end

               cmds{end+1}    = ""; % Leave Oper
               cmds{end+1}    = "quit"; % quit AVL


                % Join Code
                cmds            = join(string(cmds), "\n");

               % Write Code to File
                fid = fopen(obj.AVL_Input_Path(iFile), 'w+');
                fprintf(fid, cmds);
                fclose(fid);
           end
        end
        
        
    end
    
    methods (Static)
        function path = makeWriteable(path)
            path = replace(path, "..\", "");
            path = replace(path, "\", "/");
        end
        
        
    end
    
end