classdef ControlSurface < handle
   properties
       Name
       Gain     = 1
       X_hinge  = 0.75
       HingeVec = [0 1 0]
       SignDUp  = 1
       
   end
   
   methods
       function obj = ControlSurface(Name)
            obj.Name = Name;
       end
       
       function code = getCode(obj)
            code        = {};
            
            % Header
            code{end+1} = "#";
            code{end+1} = "#++++++> Control: %s <++++++";
            code{end+1} = "#";
            
           % Control Surface
            code{end+1} = "CONTROL";
           % Control Data
           
            % Table Columns
            str_Cname       = pad("#Cname", 12);
            str_Cgain       = pad("Cgain", 6);
            str_Xhinge      = pad("Xhinge", 8);
            str_HingeVec	= pad("HingeVec", 16);
            str_SgnDup      = pad("SgnDup", 6);
            code{end+1}     = str_Cname + str_Cgain + str_Xhinge + str_HingeVec + str_SgnDup;
            
            % Table valus
            str_Cname       = pad(obj.Name, 12);
            str_Cgain       = pad(sprintf("%0.1f", obj.Gain), 6);
            str_Xhinge      = pad(sprintf("%0.2f", obj.X_hinge), 8);
            str_HingeVec_X  = pad(sprintf("%0.2f", obj.HingeVec(1)), 5);
            str_HingeVec_Y  = pad(sprintf("%0.2f", obj.HingeVec(2)), 5);
            str_HingeVec_Z  = pad(sprintf("%0.2f", obj.HingeVec(3)), 5);
            str_HingeVec   	= pad(str_HingeVec_X + str_HingeVec_Y + str_HingeVec_Z, 16);
            str_SgnDup      = pad(sprintf("%0.1f", obj.SignDUp), 6);
            code{end+1}     = str_Cname + str_Cgain + str_Xhinge + str_HingeVec + str_SgnDup;
            
            % Join Code
            code            = join(string(code), "\n");
       end
       
   end
    
    
end