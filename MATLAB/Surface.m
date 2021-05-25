classdef Surface < handle
    properties
        Name
        Nchord          = 10
        Cspace          = 1
        Nspan           = 20
        Sspace          = 1
        Angle           = 0
        YDuplicate
        
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
        
        function plot(obj)
            % Get Coordinates
            LeadingEdges        = [obj.Sections.LeadingEdgeCoordinates];
            TrailingEdges       = [obj.Sections.TrailingEdgeCoordinates];
            
            % Scale
            LeadingEdges(1,:)   = obj.X_Scale .* LeadingEdges(1,:);
            TrailingEdges(1,:)  = obj.X_Scale .* TrailingEdges(1,:);
            LeadingEdges(2,:)   = obj.Y_Scale .* LeadingEdges(2,:);
            TrailingEdges(2,:)  = obj.Y_Scale .* TrailingEdges(2,:);
            LeadingEdges(3,:)   = obj.Z_Scale .* LeadingEdges(3,:);
            TrailingEdges(3,:)  = obj.Z_Scale .* TrailingEdges(3,:);
            
            % Transform
            LeadingEdges(1,:)   = LeadingEdges(1,:)     - obj.X_Translation;
            TrailingEdges(1,:)  = TrailingEdges(1,:)    - obj.X_Translation;
            LeadingEdges(2,:)   = LeadingEdges(2,:)     - obj.Y_Translation;
            TrailingEdges(2,:)  = TrailingEdges(2,:)    - obj.Y_Translation;
            LeadingEdges(3,:)   = LeadingEdges(3,:)     - obj.Z_Translation;
            TrailingEdges(3,:)  = TrailingEdges(3,:)    - obj.Z_Translation;
            
            % Rotate
            TrailingEdges   = TrailingEdges - LeadingEdges;   % recentering CoSys to LE
            RotationMatrix  = [ cosd(obj.Angle),      0,    sind(obj.Angle);
                                0,                    1,    0;
                                -sind(obj.Angle),     0, 	cosd(obj.Angle)];
            TrailingEdges   = RotationMatrix * TrailingEdges; % rotating
            TrailingEdges   = TrailingEdges + LeadingEdges;   % recentering again to old CoSys         
            
            % Duplicate
            if ~isempty(obj.YDuplicate)
               LE_dup = LeadingEdges;
               TE_dup = TrailingEdges;
               
               LE_dup(2,:) = LE_dup(2,:) - obj.YDuplicate;  % Move X-Z Plane
               TE_dup(2,:) = TE_dup(2,:) - obj.YDuplicate;  % Move X-Z Plane
               LE_dup(2,:) = -1*LE_dup(2,:);                % Spiegeln
               TE_dup(2,:) = -1*TE_dup(2,:);                % Spiegeln
               LE_dup(2,:) = LE_dup(2,:) + obj.YDuplicate;  % Move Back
               TE_dup(2,:) = TE_dup(2,:) + obj.YDuplicate;  % Move Back
               LE_dup      = flip(LE_dup,2);
               TE_dup      = flip(TE_dup,2);
               LeadingEdges = [LE_dup, LeadingEdges];
               TrailingEdges = [TE_dup, TrailingEdges];
               
            end
            % Transform Data
            
            % Plot Leading Edges
            plot3(LeadingEdges(1,:), LeadingEdges(2,:), LeadingEdges(3,:), 'r', 'LineWidth', 2);
            % PLot Trailing Edges
            plot3(TrailingEdges(1,:), TrailingEdges(2,:), TrailingEdges(3,:), 'g', 'LineWidth', 2);
            
            % Plot Sections
            for iSection = 1:size(LeadingEdges, 2)
                Coordinates = [LeadingEdges(:, iSection), TrailingEdges(:,iSection)];
                plot3(Coordinates(1, :), Coordinates(2, :), Coordinates(3, :), 'k', 'LineWidth', 2);
                
            end
            
        end
        
        function code = getCode(obj)
            code        = {};
            
            % Header
            code{end+1} = "#";
            header      = "#======> Surface: %s <======";
            code{end+1} = sprintf(header, obj.Name);
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