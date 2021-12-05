--  Nombre y apellidos

with Motor_Sim;   use Motor_Sim;
with Ada.Text_IO; use Ada.Text_IO;

procedure Motor_Speed is
   protected Edges is
   --  Declare protected subprograms:
   --      Add_One
   --      Read_And_Reset

   private
   -- ...
   end Edges;

   task Sampler is
   -- ...
   end Sampler;

   task Speedometer is
   -- Declare Finish
   end Speedometer;

begin

   Put_Line ("Speedometer");
   Put_Line ("-----------");
   Put_Line ("Motor stopped for 3 seconds");
   delay 3.0;

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

   Put_Line ("Stopping motor for 3 seconds");
   Motor_Off;
   delay 3.0;

   Put_Line ("Ending speedometer");
   --  Finishing Speedometer must finish Sampler as well
   --  Speedometer.Finish;
   Put_Line ("End of main task");

end Motor_Speed;
