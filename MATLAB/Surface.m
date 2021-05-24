classdef Surface < handle
    properties
        Name
        Nchord          = 10
        Cspace          = 1
        Nspan           = 20
        Sspace          = 1
        YDuplicate      = 0
        Angle           = 0
        
        X_Scale         = 1
        Y_Scale         = 1
        Z_Scale         = 1
        
        X_Translation   = 0
        Y_Translation   = 0
        Z_Translation   = 0
        
        Sections        = []
        
    end
    
    methods
        function obj = Surface(Name)
            obj.Name = Name;
        end
        
        function addSection(obj, Section)
            obj.Sections = [obj.Sections, Section];
        end
        
        function code = getCode(obj)
            code        = {};
            
            % Header
            code{end+1} = "#";
            code{end+1} = "#==============================================================";
            code{end+1} = "#";
            
            % Surface and Surface Name
            code{end+1} = "SURFACE";
            code{end+1} = obj.Name;
            
            % Panels
            str_NChord  = pad(sprintf("%i", obj.Nchord), 5);
            str_Cspace  = pad(sprintf("%i", obj.Cspace), 5);
            str_Nspan   = pad(sprintf("%i", obj.Nspan), 5);
            str_Sspace  = pad(sprintf("%i", obj.Sspace), 5);
            comment     = "!   Nchord   Cspace   Nspan  Sspace";
            code{end+1} = pad(str_NChord + str_Cspace +str_Nspan + str_Sspace, 22) + comment;  
            
            % YDuplicate
            code{end+1} = "#";  
            code{end+1} = "# reflect image wing about y=0 plane";  
            code{end+1} = "YDUPLICATE";  
            code{end+1} = sprintf("%0.f", obj.YDuplicate);
            
            % Twist Angle
            code{end+1} = "#";  
            code{end+1} = "# twist angle bias for whole surface"; 
            code{end+1} = "ANGLE";
            code{end+1} = sprintf("%0.3f", obj.Angle);
            
            % Scaling
            code{end+1} = "#"; 
            code{end+1} = "SCALE"; 
            str_XScale  = pad(sprintf("%0.3f", obj.X_Scale), 6);
            str_YScale  = pad(sprintf("%0.3f", obj.Y_Scale), 6);
            str_ZScale  = pad(sprintf("%0.3f", obj.Z_Scale), 6);
            code{end+1} = str_XScale + str_YScale + str_ZScale;
            
            % Translation
            code{end+1} = "#"; 
            code{end+1} = "# x,y,z bias for whole surface"; 
            code{end+1} = "TRANSLATE"; 
            str_XTrans  = pad(sprintf("%0.3f", obj.X_Translation), 6);
            str_YTrans  = pad(sprintf("%0.3f", obj.Y_Translation), 6);
            str_ZTrans  = pad(sprintf("%0.3f", obj.Z_Translation), 6);
            code{end+1} = str_XTrans + str_YTrans + str_ZTrans;
            
            % Sections
            for iSection = 1:length(obj.Sections)
                Section  	= obj.Sections(iSection);
                code{end+1} = Section.getCode();
            end
            
            % Join Code
            code            = join(string(code), "\n");
            
        end
        
    end
    
end