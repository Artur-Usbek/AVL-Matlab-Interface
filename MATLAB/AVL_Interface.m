classdef AVL_Interface < handle
    properties
        Aircraft
        Cases   = []
        Masses  = []
    end
    
    properties (Access=private)
        FM = FileManager()
    end
    
    methods
        function obj = AVL_Interface()
        end
        
        function addCase(obj, Case)
           obj.Cases = [obj.Cases, Case];
        end
        
        function generateAVLInputs(obj)
            
            if isempty(obj.Aircraft)
               warning("AVL_Analysis.m: Aircraft not definied");
               return
            end
            
            % Start Generation etc of files
            obj.FM.start(obj.Aircraft, obj.Cases);
            
        end
        
        function execute(obj)
            Executor.execute(obj.FM.AVL_Input_Path, obj.FM.AVL_Error_Path);
        end
        
        function result = loadResults(obj, folder_path)
            % If no File is provided
            if nargin < 2
                folder_path = obj.FM.Project_Path;
            end
            
            % Find all files with .res ending
            dir_data        = dir(fullfile(folder_path, "*.res"));
            res_File_tabs   = cell(length(dir_data), 1);
            
            % Load results from every File
            parfor iFile = 1:length(dir_data)
                folder                  = dir_data(iFile).folder;
                name                    = dir_data(iFile).name;
                res_file_path           = fullfile(folder, name);
                res_File_tabs{iFile}    = ResultsLoader.load(res_file_path);
            end
            
            % Add All tables together
            result = vertcat(res_File_tabs{:});
        end
        
        
        
    end
    
    
end