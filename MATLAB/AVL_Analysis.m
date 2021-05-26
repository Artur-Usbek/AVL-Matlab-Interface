classdef AVL_Analysis < handle
    properties
        Aircraft
        Cases   = []
        Masses  = []
    end
    
    properties (Access=private)
        FM = FileManager()
    end
    
    methods
        function obj = AVL_Analysis()
        end
        
        function addCase(obj, Case)
           obj.Cases = [obj.Cases, Case];
        end
        
        function generateAVLInputs(obj)
            
            if isempty(obj.Aircraft)
               warning("AVL_ANalysis.m: Aircraft not definied");
               return
            end
            
            % 
            obj.FM.start(obj.Aircraft, obj.Cases);
            
        end
        
        function execute(obj)
            Executor.execute(obj.FM.AVL_Input_Path, obj.FM.AVL_Error_Path);
        end
        
        function result = loadResults(obj, folder_path)
            
            if nargin < 2
                folder_path = obj.FM.Project_Path;
            end
            
            dir_data = dir(fullfile(folder_path, "*.res"));
            
            res_File_tabs = cell(length(dir_data), 1);
            
            for iFile = 1:length(dir_data)
                res_File_tabs{iFile} = obj.extractData(fullfile(dir_data(iFile).folder, dir_data(iFile).name));
            end
            result = vertcat(res_File_tabs{:});
        end
        
        function res_tabs = extractData(obj, filePath)
            
            fileText = textread(filePath, '%s', 'delimiter', '\n','whitespace', '');
            
            idxes = find(contains(fileText, "Vortex Lattice Output"));
            idxes = idxes-1; % going one line up where "----------" Line is
            
            noCases = length(idxes);
            idxes(end+1) = length(fileText);
            
            res_tabs = cell(noCases,1);
            
            for iCase = 1:noCases
                
               %get Current Case text
               idx = idxes(iCase:iCase+1);
               runFileText = fileText(idx(1):idx(2)-1);
               newFileText = string(runFileText);
               newFileText = regexprep(newFileText, '\t', ' '); % replace Tab with whitespace
               newFileText = regexprep(newFileText,' +',' '); % strip down to only one whitespace
               
               % find Values
               % (\w*['/]?\w*) 
               % -> \w*     = starts with An character (after Whitespace) 
               % -> ['/]?   = can have ' or / 
               % -> \w*     = continues with characters until Whitespace
               % -> ['/]?   = can have ' or / again
               % -> \w*     = continues with characters until Whitespace
               % ([+-]?\d*[\.]?\d*)
               % -> [+-]?   = can start with + or -
               % -> \d*     = followed by 0 or multiple digits
               % -> [.]?    = can have a dot (for floating numbers)
               % -> \d*     = continues with 0 or multiple digits
               expr = "(\w*['/]?\w*['/]?\w*) =([ ]?[+-]?\d*[.]?\d*)";
               [tokens,matches] = regexp(newFileText, expr, 'tokens','match');
               tokens(cellfun( @(content) isempty(content), tokens)) = []; % delete empty
               names    = [];
               values   = [];
               for iTok = 1:length(tokens)
                   tok = tokens{iTok};
                   for iMatch = 1:length(tok)
                       names = [names, tok{iMatch}(1)];
                       values = [values, str2double(tok{iMatch}(2))];
                   end
               end
               
               res_tab = array2table(values, 'VariableNames', names);
               
               % extract runCase
               expr = "Run case: ?(\w+)";
               [tokens,matches] = regexp(newFileText, expr, 'tokens','match');
               tokens(cellfun( @(content) isempty(content), tokens)) = [];  % delete empty
               res_tab.("RunCase") = tokens{1}{1};
               % extract configuration 
               expr = "Configuration: ?(\w+)";
               [tokens,matches] = regexp(newFileText, expr, 'tokens','match');
               tokens(cellfun( @(content) isempty(content), tokens)) = [];  % delete empty
               res_tab.("Config") = tokens{1}{1};
               
               %Assign results
               res_tabs{iCase} = res_tab;
               
            end
            
            res_tabs = vertcat(res_tabs{:});
        end
        
        
    end
    
    
end