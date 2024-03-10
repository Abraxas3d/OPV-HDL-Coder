-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/opv_receiver_HDL_coder_input/OPVReceiv_ip_dut.vhd
-- Created: 2024-02-14 00:33:08
-- 
-- Generated by MATLAB 9.14 and HDL Coder 4.1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: OPVReceiv_ip_dut
-- Source Path: OPVReceiv_ip/OPVReceiv_ip_dut
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY OPVReceiv_ip_dut IS
  PORT( received_i                        :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16
        received_q                        :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16
        audio_or_data                     :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16
        );
END OPVReceiv_ip_dut;


ARCHITECTURE rtl OF OPVReceiv_ip_dut IS

  -- Component Declarations
  COMPONENT OPVReceiv_ip_src_OPV_Receiver
    PORT( received_i                      :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16
          received_q                      :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16
          audio_or_data                   :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : OPVReceiv_ip_src_OPV_Receiver
    USE ENTITY work.OPVReceiv_ip_src_OPV_Receiver(rtl);

  -- Signals
  SIGNAL audio_or_data_sig                : std_logic_vector(15 DOWNTO 0);  -- ufix16

BEGIN
  u_OPVReceiv_ip_src_OPV_Receiver : OPVReceiv_ip_src_OPV_Receiver
    PORT MAP( received_i => received_i,  -- sfix16
              received_q => received_q,  -- sfix16
              audio_or_data => audio_or_data_sig  -- sfix16
              );

  audio_or_data <= audio_or_data_sig;

END rtl;
