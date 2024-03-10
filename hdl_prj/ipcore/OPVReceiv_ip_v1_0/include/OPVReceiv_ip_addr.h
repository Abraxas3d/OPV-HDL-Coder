/*
 * File Name:         hdl_prj/ipcore/OPVReceiv_ip_v1_0/include/OPVReceiv_ip_addr.h
 * Description:       C Header File
 * Created:           2024-02-14 00:33:08
*/

#ifndef OPVRECEIV_IP_H_
#define OPVRECEIV_IP_H_

#define  IPCore_Reset_OPVReceiv_ip         0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_OPVReceiv_ip        0x4  //enabled (by default) when bit 0 is 0x1
#define  IPCore_Timestamp_OPVReceiv_ip     0x8  //contains unique IP timestamp (yymmddHHMM): 2402140032
#define  received_i_Data_OPVReceiv_ip      0x100  //data register for Inport received i
#define  received_q_Data_OPVReceiv_ip      0x104  //data register for Inport received q
#define  audio_or_data_Data_OPVReceiv_ip   0x108  //data register for Outport audio or data

#endif /* OPVRECEIV_IP_H_ */
