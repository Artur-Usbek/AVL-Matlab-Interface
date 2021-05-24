%% AVL Interface


%% Geo-Definition
%Aircraft
PWOne       = Airplane('PWOne');

%Wing
PWOne_Wing  = Surface('Wing');

%Section 1
Section_1   = Section("NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_1.addControlSurface(Control_1);

%Section 2
Section_2   = Section("NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_2.addControlSurface(Control_1);

%Section 3
Section_3   = Section("NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_3.addControlSurface(Control_1);

%Section 4
Section_4   = Section("NACA12.dat");
Control_1	= ControlSurface("Aileron");
Section_4.addControlSurface(Control_1);

% Add Section to Wing
PWOne_Wing.addSection(Section_1);
PWOne_Wing.addSection(Section_2);
PWOne_Wing.addSection(Section_3);
PWOne_Wing.addSection(Section_4);

% Add wing to Aircraft
PWOne.addSurface(PWOne_Wing);

% Generate code
PWOne.writeAVLInput("PWOne.avl");

%% Run generation
