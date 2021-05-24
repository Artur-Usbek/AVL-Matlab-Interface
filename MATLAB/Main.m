%% AVL Interface
% TODO:
%       - Plot Geometry
%       - Airfoil and other files automatically copied in seperated folder
%       - Add Names inside header of section
%       - Add mass generator
%       - Add executor for exe

%% Geo-Definition
%Aircraft
PWOne       = Airplane("PWOne");

%Wing
PWOne_Wing  = Surface("Wing");

%Section 1
Section_1   = Section("Section_1", "NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_1.addControlSurface(Control_1);

%Section 2
Section_2   = Section("Section_2", "NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_2.addControlSurface(Control_1);

%Section 3
Section_3   = Section("Section_3", "NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_3.addControlSurface(Control_1);

%Section 4
Section_4   = Section("Section_4", "NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_4.addControlSurface(Control_1);

% Add Section to Wing
PWOne_Wing.addSection(Section_1);
PWOne_Wing.addSection(Section_2);
PWOne_Wing.addSection(Section_3);
PWOne_Wing.addSection(Section_4);

% Add Wing to Aircraft
PWOne.addSurface(PWOne_Wing);

% Generate Configuration Code
PWOne.writeAVLInput("PWOne.avl");

%% Define Analysis
AVL_Anal = AVL_Analysis(PWOne);
% Case1
case_alpha0_beta0	= RunCase("Alpha0_Beta0", PWOne);
case_alpha0_beta0.Variables.Aileron = 0;
case_alpha0_beta0.Variables.Alpha   = 2;
case_alpha0_beta0.Variables.Beta    = 0;

AVL_Anal.addCase(case_alpha0_beta0);
AVL_Anal.addCase(case_alpha0_beta0);
AVL_Anal.addCase(case_alpha0_beta0);
AVL_Anal.addCase(case_alpha0_beta0);

% Generate Run Code
AVL_Anal.writeAVLInput("PWOne.run");


