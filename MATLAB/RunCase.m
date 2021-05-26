classdef RunCase < handle  
   properties
       Name
       Variables = struct()
   end
   
   methods
       
       function obj = RunCase(Name, aircraft)
           obj.Name = Name;
           
           obj.Variables.alpha  = 0;
           obj.Variables.beta   = 0;
           
           % Get Control Variables
           controls = {};
           for iSurface = 1:length(aircraft.Surfaces)
               Surface  = aircraft.Surfaces(iSurface);
               for jSection = 1:length(Surface.Sections)
                   Section = Surface.Sections(jSection);
                   for kControlSurface = 1:length(Section.ControlSurfaces)
                       ControlSurface  = Section.ControlSurfaces(kControlSurface);
                       controls{end+1} = ControlSurface.Name;
                   end
               end
           end
           controls = unique(string(controls));
           for iControl = 1:length(controls)
               ControlName = controls(iControl);
                obj.Variables.(ControlName) = 0;
           end
       end
       
       function code = getCode(obj, idx)
           code = {};
           % header
            code{end+1} = "";
            code{end+1} = "---------------------------------------------";
            code{end+1} = sprintf("Run case  %i:\t %s", idx, obj.Name);
            code{end+1} = "";
            
            %TrimParameters
            fNames = fieldnames(obj.Variables);
            for iField = 1:length(fNames)
                var = string(fNames(iField));
                code{end+1} = RunCase.getVarCode(var, obj.Variables.(var));
            end
            
            % Join Code
            code            = join(string(code), "\n ");
       end
   end
   
   methods(Static, Access = private)
       function code = getVarCode(var, val)
           name     = pad(var, 25);
           arrow    = pad("->", 4);
           equal    = pad("=", 4);
           val      = sprintf("%0.5f", val);
           code     = name + arrow + name + equal + val; 
       end
   end
    
    
end