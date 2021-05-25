classdef Executor
    
    methods (Static)
        function execute(Input_Files, Error_Files)
            
            parfor iFile = 1:length(Input_Files)
                cmd         = {};
                Input_File = FileManager.makeWriteable(Input_Files(iFile));
                Error_File = FileManager.makeWriteable(Error_Files(iFile));

                avl_exe = "avl.exe";   %Create path to exe file
                cmd{1} = "cd ..";
                cmd{2} = sprintf("%s < %s > %s & exit", avl_exe, Input_File, Error_File);
                avl_command = join(string(cmd), " & "); % create command line

                process = Executor.generateCMDProcess();
                process.Start();   %start Process/ open cmd window

                process.StandardInput.WriteLine(avl_command);   %input command into cmd-Console->Starting AVL
                process.StandardInput.Flush();
                process.StandardInput.Close();
                while ~process.HasExited
                   pause(1);
                end
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function process = generateCMDProcess()
            process                                    = System.Diagnostics.Process(); % Create Process
            process.StartInfo.FileName                 = 'cmd.exe'; % cmd.exe should be starte
            process.StartInfo.WindowStyle              = System.Diagnostics.ProcessWindowStyle.Hidden;
            process.StartInfo.CreateNoWindow           = true; % should no windows be opened?
            process.StartInfo.UseShellExecute          = false; % for output/input Redirection = false
            process.StartInfo.RedirectStandardInput    = true; % automatic Input
            process.EnableRaisingEvents                = true;
            
        end
    end
    
end