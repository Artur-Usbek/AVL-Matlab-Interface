%% Test SuperGee
%
clc;
clear all;
close all;
fclose('all');



%% Add Files to File Manager
%FM.AVL_exe_Path = "G:\GitHub\AVL-Matlab-Interface\Test\avl\avl.exe";


%% Geo-Definition 
% Aircraft Definition
SuperGee                    = Airplane("SuperGee");
SuperGee.Reference_Surface  = 336;
SuperGee.Reference_Chord    = 5.5;
SuperGee.Reference_Span     = 59;
SuperGee.Reference_Moment_X = 3;
SuperGee.Reference_Moment_Z = 0.5;
SuperGee.Additional_Drag    = 0.02;

% Wing Definition
SuperGee_Wing  = Surface("Wing");
SuperGee_Wing.YDuplicate = 0;
SuperGee_Wing.Angle      = 2;
SuperGee_Wing.X_Translation = 5.04;
SuperGee_Wing.Z_Translation = 0.9;

% 1. Section Definition
Section_1               = Section("Section_1", "ag45c");
Section_1.X_LeadingEdge = -5.04;
Section_1.Chord         = 7.2;
Section_1.NSpan         = 9;
Section_1.Sspace       	= -0.75;
aileron                 = ControlSurface("aileron");
aileron.Gain            = -1;
aileron.X_hinge         = 0.7;
aileron.HingeVec(3)     = 0.11;
aileron.SignDUp         = -1;
Section_1.addControlSurface(aileron);
camber                    = ControlSurface("camber");
camber.X_hinge         = 0.7;
camber.HingeVec(3)     = 0.11;
Section_1.addControlSurface(camber);


% 2. Section Definition
Section_2               = Section("Section_2", "ag46c");
Section_2.X_LeadingEdge = -3.850;
Section_2.Y_LeadingEdge = 20;
Section_2.Z_LeadingEdge = 1.75;
Section_2.Chord         = 5.5;
Section_2.NSpan         = 5;
Section_2.Sspace       	= -1.25;
Section_2.addControlSurface(aileron);
Section_2.addControlSurface(camber);

% 3. Section Definition
Section_3               = Section("Section_3", "ag47c");
Section_3.X_LeadingEdge = -2.716;
Section_3.Y_LeadingEdge = 27.2;
Section_3.Z_LeadingEdge = 2.380;
Section_3.Chord         = 3.88;
Section_3.NSpan         = 3;
Section_3.Sspace       	= -1.25;
Section_3.addControlSurface(aileron);
Section_3.addControlSurface(camber);

% 4. Section Definition
Section_4               = Section("Section_4", "ag47c");
Section_4.X_LeadingEdge = -2.275;
Section_4.Y_LeadingEdge = 28.7;
Section_4.Z_LeadingEdge = 2.510;
Section_4.Chord         = 3.25;
Section_4.NSpan         = 2;
Section_4.Sspace       	= -1.25;
Section_4.addControlSurface(aileron);
Section_4.addControlSurface(camber);

% 5. Section Definition
Section_5               = Section("Section_5", "ag47c");
Section_5.X_LeadingEdge = -1.925;
Section_5.Y_LeadingEdge = 29.2;
Section_5.Z_LeadingEdge = 2.55;
Section_5.Chord         = 2.75;
Section_5.NSpan         = 2;
Section_5.Sspace       	= -1.3;
Section_5.addControlSurface(aileron);
Section_5.addControlSurface(camber);

% 6. Section Definition
Section_6               = Section("Section_6", "ag47c");
Section_6.X_LeadingEdge = -1.575;
Section_6.Y_LeadingEdge = 29.5;
Section_6.Z_LeadingEdge = 2.58;
Section_6.Chord         = 2.25;
Section_6.NSpan         = 1;
Section_6.Sspace       	= 0;
Section_6.addControlSurface(aileron);
Section_6.addControlSurface(camber);

% Add Sections
SuperGee_Wing.addSection(Section_1);
SuperGee_Wing.addSection(Section_2);
SuperGee_Wing.addSection(Section_3);
SuperGee_Wing.addSection(Section_4);
SuperGee_Wing.addSection(Section_5);
SuperGee_Wing.addSection(Section_6);

% Add Wing to Aircraft
SuperGee.addSurface(SuperGee_Wing);

SuperGee.plot();


%% Define Analysis
AVL_Anal = AVL_Analysis();

%
AVL_Anal.Aircraft = SuperGee;

alphas = -10:1:10;
betas = -10:1:10;
cambers = -5:5:5;
for iAlpha = 1:length(alphas)
    for jBeta = 1:length(betas)
        for kCamber = 1:length(cambers)
        alpha = alphas(iAlpha);
        beta = betas(jBeta);
        camber = cambers(kCamber);
        name = sprintf("Alpha%d_Beta%d", alpha, beta);
        currcase	= RunCase(name, SuperGee);
        currcase.Variables.alpha   = alpha;
        currcase.Variables.beta    = beta;
        currcase.Variables.camber  = camber;
        AVL_Anal.addCase(currcase);
        end
    end
end

%% Generate Folder with all data
AVL_Anal.generateAVLInputs();

%% Execute AVL
AVL_Anal.execute();

%% Load Results
result = AVL_Anal.loadResults();

%%
scatter3(result.Alpha, result.Beta, result.Cmtot)
xlabel("Alpha")
ylabel("Beta")
zlabel("CM")
view([0, 90])

