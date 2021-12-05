
with Ada.Real_Time;               use Ada.Real_Time;
with Ada.Real_Time.Timing_Events; use Ada.Real_Time.Timing_Events;

with System;

package body Motor_Sim is

   Period : constant array (Speed_Mode) of Time_Span :=
     (Full => Microseconds ( 60_000_000 / (   Max_RPM    * Edges_Per_Turn)  ),
      Half => Microseconds ( 60_000_000 / ((Max_RPM / 2) * Edges_Per_Turn)) );

   protected Motor
     with Priority => System.Interrupt_Priority'Last is

      procedure Drive (On : Boolean);
      procedure Set_Speed (Mode : Speed_Mode);
      function Pulse return Boolean;

   private

      Pulse_Signal : Boolean := False;
      Running      : Boolean := False;
      Next         : Time;

      Simulator_Period : Time_Span := Period (Half);  -- arbitrary default

      Pulse_TE     : Timing_Event;
      procedure Pulse_Handler (TE : in out Timing_Event);

   end Motor;

   protected body Motor is

      procedure Set_Speed (Mode : Speed_Mode) is
      begin
         Simulator_Period := Period (Mode);
      end Set_Speed;


      procedure Drive (On : Boolean) is
         Now       : constant Time := Clock;
         Cancelled : Boolean;
      begin
         if On then
            if not Running then  --  Motor on
               Next := Now;
               Running := True;
               Set_Handler (Event   => Pulse_TE,
                            At_Time => Next,
                            Handler => Pulse_Handler'Access);
            end if;
         else   --  Motor off
            Running := False;
            Cancel_Handler (Pulse_TE, Cancelled);
         end if;
      end Drive;

      procedure Pulse_Handler (TE : in out Timing_Event) is
      begin
         Pulse_Signal := not Pulse_Signal;
         Next := Next + Simulator_Period;
         Set_Handler (Event   => Pulse_TE,
                      At_Time => Next,
                      Handler => Pulse_Handler'Access);
      end Pulse_Handler;

      function Pulse return Boolean is (Pulse_Signal);

   end Motor;

   --------------
   -- Motor_On --
   --------------

   procedure Motor_On is
   begin
      Motor.Drive (On => True);
   end Motor_On;

   ---------------
   -- Motor_Off --
   ---------------

   procedure Motor_Off is
   begin
      Motor.Drive (On => False);
   end Motor_Off;

   -----------------
   -- Motor_Pulse --
   -----------------

   function Motor_Pulse return Boolean is (Motor.Pulse);

   ----------------
   --  Set_Speed --
   ----------------

   procedure Set_Speed (S : Speed_Mode) is
   begin
      Motor.Set_Speed (S);
   end Set_Speed;

end Motor_Sim;
