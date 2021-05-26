classdef Executor

    methods (Static)
        function execute(Input_Files, Error_Files)
            NoInputFiles = length(Input_Files);
            
            parfor iFile = 1:NoInputFiles
                % Get File Names
                Input_File = FileManager.makeWriteable(Input_Files(iFile));
                Error_File = FileManager.makeWriteable(Error_Files(iFile));
                
                % Print start
                Executor.printStart(iFile, NoInputFiles, Input_File);
                
                % Generate Command for cmd exe
                avl_command = Executor.generateCMD(Input_File, Error_File);
                
                % Start Process
                process = Executor.startCMDProcess(avl_command);
                
                % Wait until Process finished
                Executor.finishCMDProcess(process);
                
                % Print Finish
                Executor.printFinish(iFile, NoInputFiles, Input_File);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function printStart(iFile, NoInputFiles, Input_File)
            format = "Calculation: Starting Calculation %i of %i (%s)\n";
            fprintf(format, iFile, NoInputFiles, Input_File);
        end
        
        function printFinish(iFile, NoInputFiles, Input_File)
            format = "Calculation: Finished Calculation %i of %i (%s)\n";
            fprintf(format, iFile, NoInputFiles, Input_File);
        end
        
        function avl_command = generateCMD(Input_File, Error_File)
            cmd         = {};
            avl_exe     = "avl.exe";   %Create path to exe file
            cmd{1}      = "cd ..";      % go to main folder
            cmd{2}      = sprintf("%s < %s > %s & exit", avl_exe, Input_File, Error_File);
            avl_command = join(string(cmd), " & "); % create command line
        end
        
        function finishCMDProcess(process)
            while ~process.HasExited
                pause(1);
            end
        end
        
        function process = startCMDProcess(avl_command)
            process                                    = System.Diagnostics.Process(); % Create Process
            process.StartInfo.FileName                 = 'cmd.exe'; % cmd.exe should be started
            process.StartInfo.WindowStyle              = System.Diagnostics.ProcessWindowStyle.Hidden;
            process.StartInfo.CreateNoWindow           = true;  % should no windows be opened?
            process.StartInfo.UseShellExecute          = false; % for output/input Redirection = false
            process.StartInfo.RedirectStandardInput    = true;  % automatic Input
            process.Start();                                    % start Process/ open cmd window
            process.StandardInput.WriteLine(avl_command);       % input command into cmd-Console->Starting AVL
            process.StandardInput.Flush();                      % Send Command
            process.StandardInput.Close();                      % Close Standard Input
        end
    end
    
end