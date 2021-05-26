classdef ResultsLoader
    
    methods (Static)
        
        function res_tabs = load(filePath)
            format = "Results: Loading Results from %s\n";
            fprintf(format, filePath);
            
            %Read and Preprocess Text
            fileText = ResultsLoader.readFile(filePath);
            
            %Split into individual Runs
            splitedText = ResultsLoader.splitIntoRuns(fileText);
            
            %Preallocate Container
            res_tabs = cell(length(splitedText), 1);
            
            % Loop over every RunCase
            for iCase = 1:length(splitedText)
                format = "Results: Loading Results from RunNo. %i from %s\n";
                fprintf(format, iCase, filePath);
                
                % Get Text for current RunCase
                runFileText = splitedText{iCase};
                
                % Extract all equal Solution (name = value)
                [names, values] = ResultsLoader.extractSolution(runFileText);
                res_tab = array2table(values, 'VariableNames', names);
                
                % extract RunCase
                res_tab.("RunCase") = ResultsLoader.extractRunName(runFileText);
                
                % extract configuration
                res_tab.("Config") = ResultsLoader.extractConfigName(runFileText);
                
                %Assign results
                res_tabs{iCase} = res_tab;
                
                format = "Results: Finished Loading Results from RunNo. %i from %s\n";
                fprintf(format, iCase, filePath);
            end
            
            res_tabs = vertcat(res_tabs{:});
            format = "Results: Finished Loading Results from %s\n";
            fprintf(format, filePath);
        end
    end
    
    methods(Static, Access = private)
        
        function splitedText = splitIntoRuns(fileText)
            idxes           = find(contains(fileText, "Vortex Lattice Output")); % Every Run Starts with it
            idxes           = idxes-1; % going one line up where "----------" Line is
            noCases         = length(idxes);
            idxes(end+1)    = length(fileText);
            splitedText     = cell(noCases, 1);
            for iCase = 1:noCases
                %get Current Case text
                idx = idxes(iCase:iCase+1);
                splitedText{iCase} = fileText(idx(1):idx(2)-1);
            end
        end
        
        
        function fileText = readFile(filePath)
            % Read text
            fileText = textread(filePath, '%s', 'delimiter', '\n','whitespace', '');
            % Delete empty cells
            fileText(cellfun( @(content) isempty(content), fileText)) = [];
            % Conver to string
            fileText = string(fileText);
            % Replace Tab with whitespace
            fileText = regexprep(fileText, '\t', ' ');
            % strip down to only one whitespace
            fileText = regexprep(fileText,' +',' ');
        end
        
        function value = extractConfigName(runText)
            expr = "Configuration: ?(\w+)";
            [tokens, ~] = regexp(runText, expr, 'tokens','match');
            tokens(cellfun( @(content) isempty(content), tokens)) = [];  % delete empty
            value = tokens{1}{1};
        end
        
        function value = extractRunName(runText)
            expr = "Run case: ?(\w+)";
            [tokens, ~] = regexp(runText, expr, 'tokens','match');
            tokens(cellfun( @(content) isempty(content), tokens)) = [];  % delete empty
            value = tokens{1}{1};
        end
        
        function [names, values] = extractSolution(runText)
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
            [tokens, ~] = regexp(runText, expr, 'tokens','match');
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
            
            
        end
        
    end
    
end