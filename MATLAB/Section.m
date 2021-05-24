classdef Section < handle
    
    properties
        Airfoil
        Name
        
        X_LeadingEdge = 0
        Y_LeadingEdge = 0
        Z_LeadingEdge = 0
        Chord         = 1
        Angle         = 0
        NSpan         = 10
        Sspace        = -1
        
        ControlSurfaces = []
        
    end
    
    methods
        function obj = Section(Name, Airfoil)
            obj.Name    = Name;
            obj.Airfoil = Airfoil;
        end
        
        function addControlSurface(obj,ControlSurface)
            obj.ControlSurfaces = [obj.ControlSurfaces, ControlSurface];
        end
        
        function code = getCode(obj)
            code        = {};
            
            % Header
            code{end+1} = "#";
            code{end+1} = "#--------------------------------------------------------------";
            code{end+1} = "#";
            
            % Section Data
            % Table Columns
            str_hash     = pad("#", 8);
            str_Xle      = pad("Xle", 8);
            str_Yle      = pad("Yle", 8);
            str_Zle      = pad("Zle", 8);
            str_chord    = pad("chord", 8);
            str_angle    = pad("angle", 8);
            str_Nspan    = pad("Nspan", 8);
            str_Sspace   = pad("Sspace", 8);
            code{end+1} = str_hash + str_Xle + str_Yle + str_Zle + str_chord + ...
                          str_angle + str_Nspan + str_Sspace;
            % Header
            code{end+1} = "SECTION";
            
            % Values
            str_hash     = pad("", 8);
            str_Xle      = pad(sprintf("%0.3f", obj.X_LeadingEdge), 8);
            str_Yle      = pad(sprintf("%0.3f", obj.Y_LeadingEdge), 8);
            str_Zle      = pad(sprintf("%0.3f", obj.Z_LeadingEdge), 8);
            str_chord    = pad(sprintf("%0.3f", obj.Chord), 8);
            str_angle    = pad(sprintf("%0.3f", obj.Angle), 8);
            str_Nspan    = pad(sprintf("%0.3f", obj.NSpan), 8);
            str_Sspace   = pad(sprintf("%0.3f", obj.Sspace), 8);
            code{end+1}  = str_hash + str_Xle + str_Yle + str_Zle + str_chord + ...
                           str_angle + str_Nspan + str_Sspace;
                       
                       
            % Airfoil
            code{end+1} = "";
            code{end+1} = "AFILE";
            code{end+1} = obj.Airfoil;
            
            % Control Surfaces
            code{end+1} = "";
            for iControl = 1:length(obj.ControlSurfaces)
                ControlSurface  = obj.ControlSurfaces(iControl);
                code{end+1}     = ControlSurface.getCode();
            end
            
            % Join Code
            code            = join(string(code), "\n");
            
        end
        
    end
    
end