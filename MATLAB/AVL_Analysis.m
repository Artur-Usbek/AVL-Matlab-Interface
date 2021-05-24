classdef AVL_Analysis < handle
    properties
        Aircraft
        cases = []
    end
    
    methods
        function obj = AVL_Analysis(Aircraft)
            obj.Aircraft = Aircraft;
        end
        
        function addCase(obj, Case)
           obj.cases = [obj.cases, Case];
        end
        
        function writeAVLInput(obj, filePath)
            code = {};
            % Cases
            for iCase = 1:length(obj.cases)
                runCase = obj.cases(iCase);
                code{end+1} = runCase.getCode(iCase);
            end
            
            % Join Code
            code            = join(string(code), "\n ");
            
            % Write To File
            fid = fopen(filePath, 'w');
            fprintf(fid, code);
            fclose(fid);
            
        end
        
    end
    
    
end