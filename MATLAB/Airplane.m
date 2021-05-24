classdef Airplane < handle
    properties
        Name
        Mach    = 0
        iYsym   = false
        iZsym   = false
        Zsym    = 0
        
        Reference_Surface   = 1
        Reference_Chord     = 1
        Reference_Span      = 1
        Reference_Moment_X  = 0
        Reference_Moment_Y  = 0
        Reference_Moment_Z  = 0
        
        Additional_Drag     = 0
        
        Surfaces = []
    end
    
   methods
       function obj = Airplane(Name)
           obj.Name = Name;
       end
       
       function addSurface(obj, Surface)
           obj.Surfaces = [obj.Surfaces, Surface];
       end
       
       function code = writeAVLInput(obj, filePath)
        code = {};
        
        % Airplane Name
        code{end+1} = obj.Name;
        
        % Mach
        str_Mach    = sprintf("%0.2f", obj.Mach);
        comment     = "!   Mach";
        code{end+1} = pad(str_Mach, 22) + comment;
        
        % Symmetries
        str_iYsym   = pad(sprintf("%0.f", obj.iYsym), 5);
        str_iZsym   = pad(sprintf("%0.f", obj.iZsym), 5);
        str_Zsym    = pad(sprintf("%0.1f", obj.Zsym), 5);
        comment     = "!   iYsym  iZsym  Zsym";
        code{end+1} = pad(str_iYsym + str_iZsym + str_Zsym, 22) + comment;
        
        % Reference dimensions
        str_Sref    = pad(sprintf("%0.3f", obj.Reference_Surface), 6);
        str_Cref    = pad(sprintf("%0.3f", obj.Reference_Chord), 6);
        str_Bref    = pad(sprintf("%0.3f", obj.Reference_Span), 6);
        comment     = "!   Sref   Cref   Bref   reference area, chord, span";
        code{end+1} = pad(str_Sref + str_Cref + str_Bref, 22) + comment;
        
        % Reference dimensions
        str_Xref    = pad(sprintf("%0.3f", obj.Reference_Moment_X), 6);
        str_Yref    = pad(sprintf("%0.3f", obj.Reference_Moment_Y), 6);
        str_Zref    = pad(sprintf("%0.3f", obj.Reference_Moment_Z), 6);
        comment     = "!   Xref   Yref   Zref   moment reference location (arb.)";
        code{end+1} = pad(str_Xref + str_Yref + str_Zref, 22) + comment;
        
        % Additional Drag
        str_CDp    = sprintf("%0.3f", obj.Additional_Drag);
        code{end+1} = pad(str_CDp, 22) + "!   CDp";
        
        % Surfaces
        for iSurface = 1:length(obj.Surfaces)
            Surface     = obj.Surfaces(iSurface);
            code{end+1}	= Surface.getCode();
        end
        
        
        % Join Code
        code            = join(string(code), "\n");
        fid = fopen(filePath, 'w');
        fprintf(fid, code);
        fclose(fid);
       end
   end
    
end