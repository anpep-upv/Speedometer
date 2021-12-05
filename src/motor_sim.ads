--  Package Motor_Sim
--  Jorge Real
 
package Motor_Sim is

   Max_RPM        : constant := 1000;    --  Max Speed in RPM
   Edges_Per_Turn : constant := 4*2;     --  4-tooth wheel sensor, 2 edges/tooth

   type Speed_Mode is (Full, Half);      -- Full -> Max_Speed; Half -> Full/2

   procedure Motor_On;                      -- Turn motor on
   procedure Motor_Off;                     -- Turn motor off
   procedure Set_Speed (S : in Speed_Mode); -- To set nominal speed
   function Motor_Pulse return Boolean;     -- Value of pulse signal

end Motor_Sim;
