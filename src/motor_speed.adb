-- Ángel Pérez Porras

with Motor_Sim;     use Motor_Sim;
with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

procedure Motor_Speed is
   --
   --  Specification
   --

   --
   --  The Edges protected object acts as an atomic edge counter for the motor
   --  pulse signal
   --
   protected Edges is
      --
      --  Reads the current edge count to a variable and resets the counter
      --
      procedure Read_And_Reset (Result : out Natural);

      --
      --  Increments the edge counter atomically
      --
      procedure Add_One;
   private
      Edge_Count : Natural := 0;
   end Edges;

   --
   --  The Sampler task has two responsibilities:
   --    (1) Monitor the motor pulse signal in order to detect every pulse edge
   --    (2) Keep track of the edges of the motor pulse signal
   --
   task Sampler is
   end Sampler;

   --
   --  The Speedometer task periodically reports motor speed in RPM.
   --  When terminated, will end the Sampler task and finish the program
   --  execution
   --
   task Speedometer is
      entry Finish;
   end Speedometer;

   --
   --  Implementation
   --
   protected body Edges is
      procedure Read_And_Reset (Result : out Natural) is
      begin
         Result     := Edge_Count;
         Edge_Count := 0;
      end Read_And_Reset;

      procedure Add_One is
      begin
         Edge_Count := Edge_Count + 1;
      end Add_One;
   end Edges;

   task body Sampler is
      -- Last pulse value
      Last_Pulse : Boolean := Motor_Pulse;
      -- Next scheduled sampling time
      Next_Sample_Time : Time := Clock;
   begin
      -- Keep polling signal until Speedometer task terminates
      while not Speedometer'Terminated loop
         if Motor_Pulse /= Last_Pulse then
            Last_Pulse := Motor_Pulse;
            Edges.Add_One;
         end if;
      end loop;
      Put_Line ("Sampler task terminated");
   end Sampler;

   task body Speedometer is
      -- Constant for converting to RPM
      K : constant Natural := 5;
      -- Sampler refresh rate (t_ref)
      Refresh_Rate : constant Time_Span := Milliseconds (1500);

      -- Next scheduled speed report time
      Next_Report_Time : Time;
      -- Current number of edges
      Edge_Count : Natural;
      -- Current speed
      Speed : Natural;
      -- If True, the task will keep running; otherwise it will be terminated
      -- upon the next iteration
      Keep_Running : Boolean := True;
   begin
      while Keep_Running loop
         select
            accept Finish do
               -- Terminate task
               Keep_Running := False;
            end Finish;
         else
            Next_Report_Time := Clock;

            -- Obtain the current number of edges in the motor pulse signal
            Edges.Read_And_Reset (Edge_Count);
            -- Convert edge count to speed in RPM
            Speed := K * Edge_Count;
            Put_Line ("Speed:" & Speed'Image & " RPM");

            Next_Report_Time := Next_Report_Time + Refresh_Rate;
            delay until Next_Report_Time;
         end select;
      end loop;
      Put_Line ("Speedometer task terminated");
   end Speedometer;
begin

   Put_Line ("Speedometer");
   Put_Line ("-----------");
   Put_Line ("Motor stopped for 5 seconds");
   delay 5.0;

   Put_Line ("10 seconds at full speed");
   Set_Speed (Full);
   Motor_On;
   delay 10.0;

   Put_Line ("10 seconds at half speed");
   Set_Speed (Half);
   delay 10.0;

   Put_Line ("Another 10 seconds at full speed");
   Set_Speed (Full);
   delay 10.0;

   Put_Line ("Stopping motor for 5 seconds");
   Motor_Off;
   delay 5.0;

   Put_Line ("Ending speedometer");
   --  Finishing Speedometer must finish Sampler as well
   Speedometer.Finish;
   Put_Line ("End of main task");

end Motor_Speed;
