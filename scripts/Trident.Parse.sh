#!/bin/bash
# $1 - LOGFILE
# $2 - BINWIDTH


#Intel Top-Down uArch Analysis
#factor = 4 HT off / 2 HT on
#slots = 4 * cpu_clk_unhalted;
#fe_bound = idq_uops_not_delivered / slots;
#$bad_spec = (uops_issued - uops_retired_slots + 4*recovery_cycles) / slots;
#retiring = uops_retired_slots / slots;
#be_bound = 1 - fe_bound - bad_spec - retiring;

SCALE=$2;
DURATION=1;

if (( SCALE == 0 )) 
then 
SCALE=1 
fi

echo "\"Timestamp\"; \"slots s0\"; \"fe bound s0\"; \"bad spec s0\"; \"retiring s0\"; \"be bound s0\"; \
\"slots s1\"; \"fe bound s1\"; \"bad spec s1\"; \"retiring s1\"; \"be bound s1\"; \
\"S0 RBW\"; \"S0 WBW\"; \"S1 RBW\"; \"S1 WBW\"; \"RM BW\"; \"TOT BW\"; \
\"S0 BW CY\"; \"S1 BW CYC\"; \"RM BW CYC\"; \"S0 BW IN\"; \"S1 BW IN\";\"RM BW IN\"; \
\"S0 IPC\"; \"S1 IPC\"; \"RM IPC\"; \
\"RATIO P0\"; \"RATIO P1\"; \"RATIO P2\"; \"RATIO P3\"; \"RATIO P4\"; \"RATIO P5\"; \"RATIO P6\"; \"RATIO P7\";\
\"S0 PO\"; \"S0 PM\"; \"S1 PO\"; \"S1 PM\"" > $1".proc"

tail -n+2 $1 | \
awk -F ";" -v SCALE="$SCALE" -v DURATION="$DURATION" \
	 '( NF>12 && SCALE>1 ){ 
								S0_C0_RBW += $2; S0_C1_RBW += $3; S0_C2_RBW += $4; S0_C3_RBW += $5;
                                S0_C0_WBW += $6; S0_C1_WBW += $7; S0_C2_WBW += $8; S0_C3_WBW += $9;
                                S0_C0_PO += $10; S0_C1_PO += $11; S0_C2_PO += $12; S0_C3_PO += $13;
                                S0_C0_PM += $14; S0_C1_PM += $15; S0_C2_PM += $16; S0_C3_PM += $17;
                                S0_IN += $18; S0_CYC += $19; S0_UOPS_NDV += $20; S0_UOPS_ISS += $21; S0_UOPS_RET += $22; S0_REC_CYC += $23;
                                S0_CYC_EXE_P0 += $24; S0_CYC_EXE_P1 += $25; S0_CYC_EXE_P2 += $26; S0_CYC_EXE_P3 += $27; 
                                S0_CYC_EXE_P4 += $28; S0_CYC_EXE_P5 += $29; S0_CYC_EXE_P6 += $30; S0_CYC_EXE_P7 += $31;

                                S1_C0_RBW += $32; S1_C1_RBW += $33; S1_C2_RBW += $34; S1_C3_RBW += $35;
                                S1_C0_WBW += $36; S1_C1_WBW += $37; S1_C2_WBW += $38; S1_C3_WBW += $39;
								S1_C0_PO += $40; S1_C1_PO += $41; S1_C2_PO += $42; S1_C3_PO += $43;
                                S1_C0_PM += $44; S1_C1_PM += $45; S1_C2_PM += $46; S1_C3_PM += $47;
                                S1_IN += $48; S1_CYC += $49; S1_UOPS_NDV += $50; S1_UOPS_ISS += $51; S1_UOPS_RET += $52; S1_REC_CYC += $53;
                                S1_CYC_EXE_P0 += $54; S1_CYC_EXE_P1 += $55; S1_CYC_EXE_P2 += $56; S1_CYC_EXE_P3 += $57; 
                                S1_CYC_EXE_P4 += $58; S1_CYC_EXE_P5 += $59; S1_CYC_EXE_P6 += $60; S1_CYC_EXE_P7 += $61; } \

 	  ( NF>12 && NR%SCALE==0 ){ Timestamp = $1;				
								Timestamp = NR * DURATION;
								S0_C0_RBW += $2; S0_C1_RBW += $3; S0_C2_RBW += $4; S0_C3_RBW += $5;
                                S0_C0_WBW += $6; S0_C1_WBW += $7; S0_C2_WBW += $8; S0_C3_WBW += $9;
                                S0_C0_PO += $10; S0_C1_PO += $11; S0_C2_PO += $12; S0_C3_PO += $13;
                                S0_C0_PM += $14; S0_C1_PM += $15; S0_C2_PM += $16; S0_C3_PM += $17;
                                S0_IN += $18; S0_CYC += $19; S0_UOPS_NDV += $20; S0_UOPS_ISS += $21; S0_UOPS_RET += $22; S0_REC_CYC += $23;
                                S0_CYC_EXE_P0 += $24; S0_CYC_EXE_P1 += $25; S0_CYC_EXE_P2 += $26; S0_CYC_EXE_P3 += $27; 
                                S0_CYC_EXE_P4 += $28; S0_CYC_EXE_P5 += $29; S0_CYC_EXE_P6 += $30; S0_CYC_EXE_P7 += $31;

                                S1_C0_RBW += $32; S1_C1_RBW += $33; S1_C2_RBW += $34; S1_C3_RBW += $35;
                                S1_C0_WBW += $36; S1_C1_WBW += $37; S1_C2_WBW += $38; S1_C3_WBW += $39;
								S1_C0_PO += $40; S1_C1_PO += $41; S1_C2_PO += $42; S1_C3_PO += $43;
                                S1_C0_PM += $44; S1_C1_PM += $45; S1_C2_PM += $46; S1_C3_PM += $47;
                                S1_IN += $48; S1_CYC += $49; S1_UOPS_NDV += $50; S1_UOPS_ISS += $51; S1_UOPS_RET += $52; S1_REC_CYC += $53;
                                S1_CYC_EXE_P0 += $54; S1_CYC_EXE_P1 += $55; S1_CYC_EXE_P2 += $56; S1_CYC_EXE_P3 += $57; 
                                S1_CYC_EXE_P4 += $58; S1_CYC_EXE_P5 += $59; S1_CYC_EXE_P6 += $60; S1_CYC_EXE_P7 += $61;

								
								SOCKET_PEAK_BANDWIDTH_HASWELL_E5_2630_V3 = 40 * 1E+9;
								SOCKET_PEAK_BANDWIDTH_HASWELL_E5_2630_V3 = 5E+8;
								CLK = 2.4 * 1E+9;
								NO_SOCKET = 2;
								NO_CORES = 8;
								PK_IPC = 4;

								PK_BW_CY = SOCKET_PEAK_BANDWIDTH_HASWELL_E5_2630_V3 / ( CLK * NO_CORES );
								PK_BW_IN_0 = SOCKET_PEAK_BANDWIDTH_HASWELL_E5_2630_V3 / ( CLK * PK_IPC );
								PK_BW_IN = PK_BW_CY / PK_IPC;

								TOT_BW = DURATION * SCALE * SOCKET_PEAK_BANDWIDTH_HASWELL_E5_2630_V3 * 2;

								if( S0_IN == 0 ){ S0_IN = 1 };
                                if( S1_IN == 0 ){ S1_IN = 1 };
                                if( S0_CYC == 0 ){ S0_CYC = 1 };
                                if( S1_CYC == 0 ){ S1_CYC = 1 };

								S0_RBW = ( S0_C0_RBW + S0_C1_RBW + S0_C2_RBW + S0_C3_RBW ) * 64;
								S0_WBW = ( S0_C0_WBW + S0_C1_WBW + S0_C2_WBW + S0_C3_WBW ) * 64;
								S1_RBW = ( S1_C0_RBW + S1_C1_RBW + S1_C2_RBW + S1_C3_RBW ) * 64;
								S1_WBW = ( S1_C0_WBW + S1_C1_WBW + S1_C2_WBW + S1_C3_WBW ) * 64;
								RM_BW = TOT_BW - ( S0_RBW + S0_WBW + S1_RBW + S1_WBW );
								
								S0_IPC = S0_IN / S0_CYC;
								S1_IPC = S1_IN / S1_CYC;
								RM_IPC = ( 2 * PK_IPC ) - S0_IPC - S1_IPC;

								S0_BW_CY = ( S0_RBW + S0_WBW ) / S0_CYC;								
								S1_BW_CY = ( S1_RBW + S1_WBW ) / S1_CYC;
								RM_BW_CY = S0_BW_CY + S1_BW_CY;

								S0_BW_IN = ( S0_RBW + S0_WBW ) / S0_IN;
								S1_BW_IN = ( S1_RBW + S1_WBW ) / S1_IN;
								RM_BW_IN = S0_BW_IN + S1_BW_IN;

								S0_PO = ( S0_C0_PO + S0_C1_PO + S0_C2_PO + S0_C3_PO )
								S0_PM = ( S0_C0_PM + S0_C1_PM + S0_C2_PM + S0_C3_PM )
								
								S1_PO = ( S1_C0_PO + S1_C1_PO + S1_C2_PO + S1_C3_PO )
								S1_PM = ( S1_C0_PM + S1_C1_PM + S1_C2_PM + S1_C3_PM )

								S0_RATIO_P0 = S0_CYC_EXE_P0 / S0_CYC; S0_RATIO_P1 = S0_CYC_EXE_P1 / S0_CYC;
								S0_RATIO_P2 = S0_CYC_EXE_P2 / S0_CYC; S0_RATIO_P3 = S0_CYC_EXE_P3 / S0_CYC;
								S0_RATIO_P4 = S0_CYC_EXE_P4 / S0_CYC; S0_RATIO_P5 = S0_CYC_EXE_P5 / S0_CYC;
								S0_RATIO_P6 = S0_CYC_EXE_P6 / S0_CYC; S0_RATIO_P7 = S0_CYC_EXE_P7 / S0_CYC;
									
								S1_RATIO_P0 = S1_CYC_EXE_P0 / S1_CYC; S1_RATIO_P1 = S1_CYC_EXE_P1 / S1_CYC;
								S1_RATIO_P2 = S1_CYC_EXE_P2 / S1_CYC; S1_RATIO_P3 = S1_CYC_EXE_P3 / S1_CYC;
								S1_RATIO_P4 = S1_CYC_EXE_P4 / S1_CYC; S1_RATIO_P5 = S1_CYC_EXE_P5 / S1_CYC;
								S1_RATIO_P6 = S1_CYC_EXE_P6 / S1_CYC; S1_RATIO_P7 = S1_CYC_EXE_P7 / S1_CYC;

								S0_ALU_PO_TOT = S0_CYC_EXE_P0 + S0_CYC_EXE_P1 + S0_CYC_EXE_P5 + S0_CYC_EXE_P6;
								S0_MEM_PO_TOT = S0_CYC_EXE_P2 + S0_CYC_EXE_P3 + S0_CYC_EXE_P4 + S0_CYC_EXE_P7;
								
								S1_ALU_PO_TOT = S1_CYC_EXE_P0 + S1_CYC_EXE_P1 + S1_CYC_EXE_P5 + S1_CYC_EXE_P6;
								S1_MEM_PO_TOT = S1_CYC_EXE_P2 + S1_CYC_EXE_P3 + S1_CYC_EXE_P4 + S1_CYC_EXE_P7;
								
								S0_ALU_PO_TOT = S0_RATIO_P0 + S0_RATIO_P1 + S0_RATIO_P5 + S0_RATIO_P6;
								S0_MEM_PO_TOT = S0_RATIO_P2 + S0_RATIO_P3 + S0_RATIO_P4 + S0_RATIO_P7;
								
								S1_ALU_PO_TOT = S1_RATIO_P0 + S1_RATIO_P1 + S1_RATIO_P5 + S1_RATIO_P6;
								S1_MEM_PO_TOT = S1_RATIO_P2 + S1_RATIO_P3 + S1_RATIO_P4 + S1_RATIO_P7;

								RATIO_P0 = S0_RATIO_P0 + S1_RATIO_P0;
								RATIO_P1 = S0_RATIO_P1 + S1_RATIO_P1;
								RATIO_P2 = S0_RATIO_P2 + S1_RATIO_P2;
								RATIO_P3 = S0_RATIO_P3 + S1_RATIO_P3;
								RATIO_P4 = S0_RATIO_P4 + S1_RATIO_P4;
								RATIO_P5 = S0_RATIO_P5 + S1_RATIO_P5;
								RATIO_P6 = S0_RATIO_P6 + S1_RATIO_P6;
								RATIO_P7 = S0_RATIO_P7 + S1_RATIO_P7;
								
								factor = 4;
								cutoff = 1E+10 * SCALE * DURATION;
								cutoff = 0;
								
								slots_s0 = factor * S0_CYC; slots_s1 = factor * S1_CYC;
								fe_bound_s0 = S0_UOPS_NDV / slots_s0; fe_bound_s1 = S1_UOPS_NDV / slots_s1;
								bad_spec_s0 = ( S0_UOPS_ISS - S0_UOPS_RET + ( factor * S0_REC_CYC ) ) / slots_s0; bad_spec_s1 = ( S1_UOPS_ISS - S1_UOPS_RET + ( factor * S1_REC_CYC ) ) / slots_s1;
								retiring_s0 = S0_UOPS_RET / slots_s0; retiring_s1 = S1_UOPS_RET / slots_s1;
								be_bound_s0 = 1 - fe_bound_s0 - bad_spec_s0 - retiring_s0; be_bound_s1 = 1 - fe_bound_s1 - bad_spec_s1 - retiring_s1; 

								if( slots_s0 < ( cutoff ) ) { fe_bound_s0 = 1; bad_spec_s0 = 0; retiring_s0 = 0; be_bound_s0 = 0; };
								if( slots_s1 < ( cutoff ) ) { fe_bound_s1 = 1; bad_spec_s1 = 0; retiring_s1 = 0; be_bound_s1 = 0; };

								S0_CMP_CYC_EXE_PORT = S0_CYC_EXE_P0 + S0_CYC_EXE_P1 + S0_CYC_EXE_P5 + S0_CYC_EXE_P6;
								S0_MEM_CYC_EXE_PORT = S0_CYC_EXE_P2 + S0_CYC_EXE_P3 + S0_CYC_EXE_P4 + S0_CYC_EXE_P7;


								printf "%s;%9.3G;%5.2F;%5.2F;%5.2F;%5.2F;%9.3G;%5.2F;%5.2F;%5.2F;%5.2F;", \
										Timestamp, slots_s0, fe_bound_s0, bad_spec_s0, retiring_s0, be_bound_s0, \
										slots_s1, fe_bound_s1, bad_spec_s1, retiring_s1, be_bound_s1;
								
								printf "%9.3G;%9.3G;%9.3G;%9.3G;%9.3G;%9.3G;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;", \
										S0_RBW, S0_WBW, S1_RBW, S1_WBW, RM_BW, TOT_BW, \
										S0_BW_CYC, S1_BW_CYC, RM_BW_CY, S0_BW_IN, S1_BW_IN, RM_BW_IN, S0_IPC, S1_IPC, RM_IPC;

								
								printf "%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;%5.2F;", \
                                        RATIO_P0, RATIO_P1, RATIO_P2, RATIO_P3, RATIO_P4, RATIO_P5, RATIO_P6, RATIO_P7;

								printf "%9.3G;%9.3G;%9.3G;%9.3G;\n", \
                                        S0_PO, S0_PM, S1_PO, S1_PM; 


								S0_C0_RBW = 0; S0_C1_RBW = 0; S0_C2_RBW = 0; S0_C3_RBW = 0;
                                S0_C0_WBW = 0; S0_C1_WBW = 0; S0_C2_WBW = 0; S0_C3_WBW = 0;
                                S0_C0_PO = 0; S0_C1_PO = 0; S0_C2_PO = 0; S0_C3_PO = 0;
                                S0_C0_PM = 0; S0_C1_PM = 0; S0_C2_PM = 0; S0_C3_PM = 0;
                                S0_IN = 0; S0_CYC = 0; S0_UOPS_NDV = 0; S0_UOPS_ISS = 0; S0_UOPS_RET = 0; S0_REC_CYC = 0;
                                S0_CYC_EXE_P0 = 0; S0_CYC_EXE_P1 = 0; S0_CYC_EXE_P2 = 0; S0_CYC_EXE_P3 = 0; 
                                S0_CYC_EXE_P4 = 0; S0_CYC_EXE_P5 = 0; S0_CYC_EXE_P6 = 0; S0_CYC_EXE_P7 = 0;

                                S1_C0_RBW = 0; S1_C1_RBW = 0; S1_C2_RBW = 0; S1_C3_RBW = 0;
                                S1_C0_WBW = 0; S1_C1_WBW = 0; S1_C2_WBW = 0; S1_C3_WBW = 0;
                                S1_C0_PO = 0; S1_C1_PO = 0; S1_C2_PO = 0; S1_C3_PO = 0;
                                S1_C0_PM = 0; S1_C1_PM = 0; S1_C2_PM = 0; S1_C3_PM = 0;
                                S1_IN = 0; S1_CYC = 0; S1_UOPS_NDV = 0; S1_UOPS_ISS = 0; S1_UOPS_RET = 0; S1_REC_CYC = 0;
                                S1_CYC_EXE_P0 = 0; S1_CYC_EXE_P1 = 0; S1_CYC_EXE_P2 = 0; S1_CYC_EXE_P3 = 0; 
                                S1_CYC_EXE_P4 = 0; S1_CYC_EXE_P5 = 0; S1_CYC_EXE_P6 = 0; S1_CYC_EXE_P7 = 0;
																												}' >> $1".proc"


gnuplot <<-EOFMarker
reset
set datafile separator ";"
set autoscale
set terminal svg noenhanced size 2000,1000 background rgb 'white'
set key samplen 2 spacing 1 font ",14"
set output '$1.scale$2.uarch.svg'; 
set key top left outside horizontal
set yrange [0:200]
#set ylabel "% of total"
unset ytics
#set xtics font ",8"
#set xtics 0,10,300
#unset xtics
set xrange [0:]
set xtics 100
set xlabel "Elapsed Time (seconds)"
set key width 20
set grid y
set border 3
set style data histogram
set style histogram rowstacked gap 1
set style fill solid noborder
set boxwidth 1
#set xtics rotate by -45

stats '$1.proc' using 27:1 name "C27"
stats '$1.proc' using 28:1 name "C28"
stats '$1.proc' using 29:1 name "C29"
stats '$1.proc' using 30:1 name "C30"

#stats '$1.proc' using 31:1 name "C31"
#stats '$1.proc' using 32:1 name "C32"
#stats '$1.proc' using 33:1 name "C33"
#stats '$1.proc' using 34:1 name "C34"

stats '$1.proc' using 12:1 name "C12"
stats '$1.proc' using 13:1 name "C13"
stats '$1.proc' using 14:1 name "C14"
stats '$1.proc' using 15:1 name "C15"
stats '$1.proc' using 16:1 name "C16"
stats '$1.proc' using 18:1 name "C18"
stats '$1.proc' using 19:1 name "C19"
stats '$1.proc' using 21:1 name "C21"
stats '$1.proc' using 22:1 name "C22"

#max_c27_31 = ( C27_max_x > C28_max_x ? C27_max_x : C28_max_x ) > ( C29_max_x > C30_max_x ? C29_max_x : C30_max_x ) ? ( C27_max_x > C28_max_x ? C27_max_x : C28_max_x ) : ( C29_max_x > C30_max_x ? C29_max_x : C30_max_x )

#max_c27_30 = 1

#val_c27_30( x ) = 10 

#rem_c27_30( a, b, c, d ) = ( 20. * ( ( ( C27_max_x + C28_max_x + C29_max_x + C30_max_x ) - ( a + b + c + d ) ) / ( C27_max_x + C28_max_x + C29_max_x + C30_max_x ) ) )

#show variables all

set label "Histogram binwidth xaxis '$SCALE' - (Aggregated over $SCALE s)" right at screen 0.97,0.97 tc lt 1 font ",14"

set ylabel "Top down analysis split"
set ytics 0,0.1,1
set yrange [0:1]
plot '$1.proc' u  ( 1. * ( ( \$3 + \$8 ) / ( \$3 + \$4 + \$5 + \$6 + \$8 + \$9 + \$10 + \$11 ) ) ) t "Front-End Bound" lc rgb '#A0A0A0', \
    '' u  ( 1. * ( ( \$4 + \$9 ) / ( \$3 + \$4 + \$5 + \$6 + \$8 + \$9 + \$10 + \$11 ) ) ) t "Bad Speculation" lc rgb '#0000cd', \
    '' u  ( 1. * ( ( \$5 + \$10 ) / ( \$3 + \$4 + \$5 + \$6 + \$8 + \$9 + \$10 + \$11 ) ) ) t "Retiring" lc rgb '#F08080', \
    '' u  ( 1. * ( ( \$6 + \$11 ) / ( \$3 + \$4 + \$5 + \$6 + \$8 + \$9 + \$10 + \$11 ) ) ) t "Back-End Bound" lc rgb '#2E8B57';
#    '' u  ( 25. * ( \$24 + \$25 ) ) t "IPC" lc rgb '#8060C0';
#	'' u  ( 50. * ( ( \$12 + \$14 ) / \$17 ) ) t "Mem Read BW" lc rgb '#386CB0', \
#	'' u  ( 50. * ( ( \$13 + \$15 ) / \$17 ) ) t "Mem Write BW" lc rgb '#F0027F';
#	'' u  ( 50. * ( \$16 / \$17 ) ) t col(16) lc rgb '#A6CEE3';
#	'' u  ( 125. * ( \$14 / \$17 ) ) t col(14) lc rgb '#BF5B17', \
#	'' u  ( 125. * ( \$15 / \$17 ) ) t col(15) lc rgb '#666666';
#	'' u  ( 100. * ( \$27 / max_c27_30 ) ) t col(27) lc rgb '#4DAF4A', \
#	'' u  ( 100. * ( \$28 / max_c27_30 ) ) t col(28) lc rgb '#984EA3', \
#	'' u  ( 100. * ( \$29 / max_c27_30 ) ) t col(29) lc rgb '#FF7F00', \
#	'' u  ( 100. * ( \$30 / max_c27_30 ) ) t col(30) lc rgb '#FFFF33', \
#	'' u  ( 100. * ( ( ( 4 * max_c27_30 ) - ( \$27 + \$28 + \$29 + \$30 ) ) / max_c27_30 ) ) t "REM" lc rgb '#000000', \
#	'' u  ( ( 25. * ( \$31 / ( C31_max_x + C32_max_x + C33_max_x + C34_max_x ) ) ) + ( rem_c27_30( \$27, \$28, \$29, \$30 ) ) ) t col(31) lc rgb '#5EAF4A', \
#    '' u  ( ( 25. * ( \$32 / ( C31_max_x + C32_max_x + C33_max_x + C34_max_x ) ) ) + ( rem_c27_30( \$27, \$28, \$29, \$30 ) ) ) t col(32) lc rgb '#A94EA3', \
#    '' u  ( ( 25. * ( \$33 / ( C31_max_x + C32_max_x + C33_max_x + C34_max_x ) ) ) + ( rem_c27_30( \$27, \$28, \$29, \$30 ) ) ) t col(33) lc rgb '#007F00', \
#    '' u  ( ( 25. * ( \$34 / ( C31_max_x + C32_max_x + C33_max_x + C34_max_x ) ) ) + ( rem_c27_30( \$27, \$28, \$29, \$30 ) ) ) t col(34) lc rgb '#00FF33';


set output '$1.scale$2.ipc.svg';
set ylabel "IPC"
set ytics auto
set yrange [0:4]
plot '$1.proc' u ( ( \$24 + \$25 ) / 2 )  not lc rgb '#8060C0';

set output '$1.scale$2.mem.svg';
set ylabel "Memory Access (GiB)"
set ytics auto
set autoscale y
plot '$1.proc' u  ( ( ( \$12 + \$14 ) / \$17 ) ) t "Read" lc rgb '#386CB0', \
    '' u  ( ( ( \$13 + \$15 ) / \$17 ) ) t "Write" lc rgb '#F0027F';

set output '$1.scale$2.pp.svg';
set ylabel "Ratio of cycles the port is active"
set ytics 0.5
set yrange [0:6]
plot '$1.proc' u  27 t "Port 0" lc rgb '#666666', \
    '' u  28 t "Port 1" lc rgb '#A6761D', \
    '' u  32 t "Port 5" lc rgb '#7570B3', \
    '' u  33 t "Port 6" lc rgb '#D95F02', \
    '' u  29 t "Port 2" lc rgb '#E6AB02', \
    '' u  30 t "Port 3" lc rgb '#66A61E', \
    '' u  31 t "Port 4" lc rgb '#E7298A', \
    '' u  34 t "Port 7" lc rgb '#1B9E77';

set output '$1.scale$2.mp.svg';
set ylabel "Ratio of memory requests that resulted in Page Empty/Miss/Hit"
set ytics auto
set yrange [0:1]
plot '$1.proc' u ( ( ( \$35 + \$37 ) - ( \$36 + \$38 ) ) / ( ( \$12 + \$14 + \$13 + \$15 ) / 64 ) ) t "Page Empty" lc rgb '#7570B3', \
    '' u  ( ( \$36 + \$38 ) / ( ( \$12 + \$14 + \$13 + \$15 ) / 64 ) ) t "Page Miss" lc rgb '#D95F02', \
    '' u  ( 1 - ( ( \$36 + \$38 ) / ( ( \$12 + \$14 + \$13 + \$15 ) / 64 ) ) - ( ( ( \$35 + \$37 ) - ( \$36 + \$38 ) ) / ( ( \$12 + \$14 + \$13 + \$15 ) / 64 ) ) ) t "Page Hit" lc rgb '#66A61E';

EOFMarker

exit 0
