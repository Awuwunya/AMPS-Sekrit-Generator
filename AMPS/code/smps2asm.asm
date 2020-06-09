;GEN-ASM
; ===========================================================================
; ---------------------------------------------------------------------------
; AMPS - SMPS2ASM macro & equate file
; ---------------------------------------------------------------------------
%ifasm% AS
; Note Equates
; ---------------------------------------------------------------------------

	enum nC0=$81,nCs0,nD0,nEb0,nE0,nF0,nFs0,nG0,nAb0,nA0,nBb0,nB0
	enum nC1=$8D,nCs1,nD1,nEb1,nE1,nF1,nFs1,nG1,nAb1,nA1,nBb1,nB1
	enum nC2=$99,nCs2,nD2,nEb2,nE2,nF2,nFs2,nG2,nAb2,nA2,nBb2,nB2
	enum nC3=$A5,nCs3,nD3,nEb3,nE3,nF3,nFs3,nG3,nAb3,nA3,nBb3,nB3
	enum nC4=$B1,nCs4,nD4,nEb4,nE4,nF4,nFs4,nG4,nAb4,nA4,nBb4,nB4
	enum nC5=$BD,nCs5,nD5,nEb5,nE5,nF5,nFs5,nG5,nAb5,nA5,nBb5,nB5
	enum nC6=$C9,nCs6,nD6,nEb6,nE6,nF6,nFs6,nG6,nAb6,nA6,nBb6,nB6
	enum nC7=$D5,nCs7,nD7,nEb7,nE7,nF7,nFs7,nG7,nAb7,nA7,nBb7
	enum nRst=$80, nHiHat=nBb6
%endif%
%ifasm% ASM68K

; this macro is created to emulate enum in AS
enum		macro lable
	rept narg
\lable =	_num
_num =		_num+1
	shift
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Note equates
; ---------------------------------------------------------------------------

_num =		$80
	enum nRst
	enum nC0,nCs0,nD0,nEb0,nE0,nF0,nFs0,nG0,nAb0,nA0,nBb0,nB0
	enum nC1,nCs1,nD1,nEb1,nE1,nF1,nFs1,nG1,nAb1,nA1,nBb1,nB1
	enum nC2,nCs2,nD2,nEb2,nE2,nF2,nFs2,nG2,nAb2,nA2,nBb2,nB2
	enum nC3,nCs3,nD3,nEb3,nE3,nF3,nFs3,nG3,nAb3,nA3,nBb3,nB3
	enum nC4,nCs4,nD4,nEb4,nE4,nF4,nFs4,nG4,nAb4,nA4,nBb4,nB4
	enum nC5,nCs5,nD5,nEb5,nE5,nF5,nFs5,nG5,nAb5,nA5,nBb5,nB5
	enum nC6,nCs6,nD6,nEb6,nE6,nF6,nFs6,nG6,nAb6,nA6,nBb6,nB6
	enum nC7,nCs7,nD7,nEb7,nE7,nF7,nFs7,nG7,nAb7,nA7,nBb7
nHiHat =	nBb6
%endif%
; ===========================================================================
; ---------------------------------------------------------------------------
; Note Equates for PSG4
; ---------------------------------------------------------------------------

		%rsset% nRst
		%rw% 1		; rest channel
nPeri10		%rw% 1		; periodic noise at pitch $10
nPeri20		%rw% 1		; periodic noise at pitch $20
nPeri40		%rw% 1		; periodic noise at pitch $40
nPeriPSG3	%rw% 1		; periodic noise with pitch from PSG3
nWhite10	%rw% 1		; white noise at pitch $10
nWhite20	%rw% 1		; white noise at pitch $20
nWhite40	%rw% 1		; white noise at pitch $40
nWhitePSG3	%rw% 1		; white noise with pitch from PSG3
n4Last =	%re% 0		; used for safe mode
; ===========================================================================
; ---------------------------------------------------------------------------
; Header macros
; ---------------------------------------------------------------------------

; Header - Initialize a music file
sHeaderInit	macro
sPatNum %set%	0
    endm

; Header - Initialize a sound effect file
sHeaderInitSFX	macro

    endm

; Header - Set up channel usage
sHeaderCh	macro fm,psg
%narg% >1 psg <>
		dc.b %macpfx%psg-1, %macpfx%fm-1
		if %macpfx%fm>Mus_HeadFM
			%warning%"You sure there are %macpfx%fm FM channels?"
		endif

		if %macpfx%psg>Mus_PSG
			%warning%"You sure there are %macpfx%psg PSG channels?"
		endif
	else
		dc.b %macpfx%fm-1
	endif
    endm

; Header - Set up tempo and flags
sHeaderTempo	macro flags,tempo
	dc.b %macpfx%flags,%macpfx%tempo
    endm

; Header - Set priority level
sHeaderPrio	macro prio
	dc.b %macpfx%prio
    endm

; Header - Set up a DAC channel
sHeaderDAC	macro loc,vol,samp
	dc.w %macpfx%loc-*

%narg% >1 vol <>
		dc.b (%macpfx%vol)&$FF
	%narg% >2 samp <>
			dc.b %macpfx%samp
		else
			dc.b $00
		endif
	else
		dc.w $00
	endif
    endm

; Header - Set up an FM channel
sHeaderFM	macro loc,pitch,vol
	dc.w %macpfx%loc-*
	dc.b (%macpfx%pitch)&$FF,(%macpfx%vol)&$FF
    endm

; Header - Set up a PSG channel
sHeaderPSG	macro loc,pitch,vol,detune,volenv
	dc.w %macpfx%loc-*
	dc.b (%macpfx%pitch)&$FF,(%macpfx%vol)&$FF,(%macpfx%detune)&$FF,%macpfx%volenv
    endm

; Header - Set up an SFX channel
sHeaderSFX	macro flags,type,loc,pitch,vol
	dc.b %macpfx%flags,%macpfx%type,(%macpfx%pitch)&$FF,(%macpfx%vol)&$FF
	dc.w %macpfx%loc-*
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macros for PSG instruments
; ---------------------------------------------------------------------------

; Patches - ADSR data
;   mode -> sets the flags used for ADSR. Bit7 is always set.
;   atkvol -> Volume to attack to (higher = quieter)
;   atkdelta -> How fast to attack. 2.6 fixed point format
;   decayvol -> Volume to decay to (higher = quieter)
;   decaydelta -> How fast to decay. 2.6 fixed point format
;   releasedelta -> How fast to release. 2.6 fixed point format

spADSR		macro name, mode, atkvol, atkdelta, decayvol, decaydelta, releasedelta
a%dlbs%name%dlbe% %equ%	sPatNum
sPatNum =	sPatNum+1

	dc.b %macpfx%mode, 0
	dc.b %macpfx%atkdelta, %macpfx%atkvol, %macpfx%decaydelta, %macpfx%decayvol, %macpfx%releasedelta
	dc.b 0
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macros for FM instruments
; ---------------------------------------------------------------------------

; Patches - Algorithm and patch name
spAlgorithm	macro val, name
	if (sPatNum<>0)&(safe=0)
		; align the patch
		dc.b ((*)%xor%(sPatNum*spTL4))&$FF
		dc.b (((*)>>8)+(spDe3*spDR3))&$FF
		dc.b (((*)>>16)-(spTL1*spRR3))&$FF
	endif

%narg% >1 name <>
p%dlbs%name%dlbe% %set%		sPatNum
	endif

sPatNum %set%	sPatNum+1
spAl %set%		%macpfx%val
    endm

; Patches - Feedback
spFeedback	macro val
spFe %set%		%macpfx%val
    endm

; Patches - Detune
spDetune	macro op1,op2,op3,op4
spDe1 %set%		%macpfx%op1
spDe2 %set%		%macpfx%op2
spDe3 %set%		%macpfx%op3
spDe4 %set%		%macpfx%op4
    endm

; Patches - Multiple
spMultiple	macro op1,op2,op3,op4
spMu1 %set%		%macpfx%op1
spMu2 %set%		%macpfx%op2
spMu3 %set%		%macpfx%op3
spMu4 %set%		%macpfx%op4
    endm

; Patches - Rate Scale
spRateScale	macro op1,op2,op3,op4
spRS1 %set%		%macpfx%op1
spRS2 %set%		%macpfx%op2
spRS3 %set%		%macpfx%op3
spRS4 %set%		%macpfx%op4
    endm

; Patches - Attack Rate
spAttackRt	macro op1,op2,op3,op4
spAR1 %set%		%macpfx%op1
spAR2 %set%		%macpfx%op2
spAR3 %set%		%macpfx%op3
spAR4 %set%		%macpfx%op4
    endm

; Patches - Amplitude Modulation
spAmpMod	macro op1,op2,op3,op4
spAM1 %set%		%macpfx%op1
spAM2 %set%		%macpfx%op2
spAM3 %set%		%macpfx%op3
spAM4 %set%		%macpfx%op4
    endm

; Patches - Sustain Rate
spSustainRt	macro op1,op2,op3,op4
spSR1 %set%		%macpfx%op1		; Also known as decay 1 rate
spSR2 %set%		%macpfx%op2
spSR3 %set%		%macpfx%op3
spSR4 %set%		%macpfx%op4
    endm

; Patches - Sustain Level
spSustainLv	macro op1,op2,op3,op4
spSL1 %set%		%macpfx%op1		; also known as decay 1 level
spSL2 %set%		%macpfx%op2
spSL3 %set%		%macpfx%op3
spSL4 %set%		%macpfx%op4
    endm

; Patches - Decay Rate
spDecayRt	macro op1,op2,op3,op4
spDR1 %set%		%macpfx%op1		; Also known as decay 2 rate
spDR2 %set%		%macpfx%op2
spDR3 %set%		%macpfx%op3
spDR4 %set%		%macpfx%op4
    endm

; Patches - Release Rate
spReleaseRt	macro op1,op2,op3,op4
spRR1 %set%		%macpfx%op1
spRR2 %set%		%macpfx%op2
spRR3 %set%		%macpfx%op3
spRR4 %set%		%macpfx%op4
    endm

; Patches - SSG-EG
spSSGEG		macro op1,op2,op3,op4
spSS1 %set%		%macpfx%op1
spSS2 %set%		%macpfx%op2
spSS3 %set%		%macpfx%op3
spSS4 %set%		%macpfx%op4
    endm

; Patches - Total Level
spTotalLv	macro op1,op2,op3,op4
spTL1 %set%		%macpfx%op1
spTL2 %set%		%macpfx%op2
spTL3 %set%		%macpfx%op3
spTL4 %set%		%macpfx%op4

; Construct the patch finally.
	dc.b (spFe<<3)+spAl

;   0     1     2     3     4     5     6     7
;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111

spTLMask4 %set%	$80
spTLMask2 %set%	((spAl>=5)<<7)
spTLMask3 %set%	((spAl>=4)<<7)
spTLMask1 %set%	((spAl=7)<<7)

	dc.b (spDe1<<4)+spMu1, (spDe3<<4)+spMu3, (spDe2<<4)+spMu2, (spDe4<<4)+spMu4
	dc.b (spRS1<<6)+spAR1, (spRS3<<6)+spAR3, (spRS2<<6)+spAR2, (spRS4<<6)+spAR4
	dc.b (spAM1<<7)+spSR1, (spAM3<<7)+spsR3, (spAM2<<7)+spSR2, (spAM4<<7)+spSR4
	dc.b spDR1,            spDR3,            spDR2,            spDR4
	dc.b (spSL1<<4)+spRR1, (spSL3<<4)+spRR3, (spSL2<<4)+spRR2, (spSL4<<4)+spRR4
	dc.b spSS1,            spSS3,            spSS2,            spSS4
	dc.b spTL1|spTLMask1,  spTL3|spTLMask3,  spTL2|spTLMask2,  spTL4|spTLMask4

	if safe=1
		dc.b "NAT"	; align the patch
	endif
    endm

; Patches - Total Level (for broken total level masks)
spTotalLv2	macro op1,op2,op3,op4
spTL1 %set%		%macpfx%op1
spTL2 %set%		%macpfx%op2
spTL3 %set%		%macpfx%op3
spTL4 %set%		%macpfx%op4

	dc.b (spFe<<3)+spAl
	dc.b (spDe1<<4)+spMu1, (spDe3<<4)+spMu3, (spDe2<<4)+spMu2, (spDe4<<4)+spMu4
	dc.b (spRS1<<6)+spAR1, (spRS3<<6)+spAR3, (spRS2<<6)+spAR2, (spRS4<<6)+spAR4
	dc.b (spAM1<<7)+spSR1, (spAM3<<7)+spsR3, (spAM2<<7)+spSR2, (spAM4<<7)+spSR4
	dc.b spDR1,            spDR3,            spDR2,            spDR4
	dc.b (spSL1<<4)+spRR1, (spSL3<<4)+spRR3, (spSL2<<4)+spRR2, (spSL4<<4)+spRR4
	dc.b spSS1,            spSS3,            spSS2,            spSS4
	dc.b spTL1,	       spTL3,		 spTL2,		   spTL4

	if safe=1
		dc.b "NAT"	; align the patch
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Equates for sPan
; ---------------------------------------------------------------------------

spNone %equ%	$00
spRight %equ%	$40
spLeft %equ%	$80
spCentre %equ%	$C0
spCenter %equ%	$C0
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands
; ---------------------------------------------------------------------------

; E0xx - Panning, AMS, FMS (PANAFMS - PAFMS_PAN)
sPan		macro pan, ams, fms
%narg% =1 ams ==
		dc.b $E0, %macpfx%pan

%narg% =2 fms == else
		dc.b $E0, %macpfx%pan|%macpfx%ams

	else
		dc.b $E0, %macpfx%pan|(%macpfx%ams<<4)|%macpfx%fms
	endif
    endm

; E1xx - Set channel frequency displacement to xx (DETUNE_SET)
ssDetune	macro detune
	dc.b $E1, %macpfx%detune
    endm

; E2xx - Add xx to channel frequency displacement (DETUNE)
saDetune	macro detune
	dc.b $E2, %macpfx%detune
    endm

; E3xx - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
ssTranspose	macro transp
	dc.b $E3, %macpfx%transp
    endm

; E4xx - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
saTranspose	macro transp
	dc.b $E4, %macpfx%transp
    endm

; E6 - Freeze frequency for the next note (FREQ_FREEZE)
sFqFz %equ%		$E6

; E7 - Do not attack of next note (HOLD)
sHold %equ%		$E7

; E8xx - Set patch/voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_PSG / INS_C_DAC)
sVoice		macro voice
	dc.b $E8, %macpfx%voice
    endm

; F2xx - Set volume envelope to xx (INSTRUMENT - INS_C_PSG) (FM_VOLENV / DAC_VOLENV)
sVolEnv		macro env
	dc.b $F2, %macpfx%env
    endm

; F3xx - Set modulation envelope to xx (MOD_ENV - MENV_GEN)
sModEnv		macro env
	dc.b $F3, %macpfx%env
    endm

; E9xx - Set music speed shoes tempo to xx (TEMPO - TEMPO_SET_SPEED)
ssTempoShoes	macro tempo
	dc.b $E9, %macpfx%tempo
    endm

; EAxx - Set music tempo to xx (TEMPO - TEMPO_SET)
ssTempo		macro tempo
	dc.b $EA, %macpfx%tempo
    endm

; FF18xx - Add xx to music speed tempo (TEMPO - TEMPO_ADD_SPEED)
saTempoSpeed	macro tempo
	dc.b $FF,$18, %macpfx%tempo
    endm

; FF1Cxx - Add xx to music tempo (TEMPO - TEMPO_ADD)
saTempo		macro tempo
	dc.b $FF,$1C, %macpfx%tempo
    endm

; EB - Use sample DAC mode, where each note is a different sample (DAC_MODE - DACM_SAMP)
sModeSampDAC	macro
	dc.b $EB
    endm

; EC - Use pitch DAC mode, where each note is a different pitch (DAC_MODE - DACM_NOTE)
sModePitchDAC	macro
	dc.b $EC
    endm

; EDxx - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
saVol		macro volume
	dc.b $ED, %macpfx%volume
    endm

; EExx - Set channel volume to xx (VOLUME - VOL_CN_ABS)
ssVol		macro volume
	dc.b $EE, %macpfx%volume
    endm

; EFxxyy - Enable/Disable LFO (SET_LFO - LFO_AMSEN)
ssLFO		macro reg, ams, fms, pan
%narg% =2 fms ==
		dc.b $EF, %macpfx%reg,%macpfx%ams

%narg% =3 pan == else
		dc.b $EF, %macpfx%reg,(%macpfx%ams<<4)|%macpfx%fms

	else
		dc.b $EF, %macpfx%reg,(%macpfx%ams<<4)|%macpfx%fms|%macpfx%pan
	endif
    endm

; F0xxzzwwyy - Modulation (AMPS algorithm)
;  ww: wait time
;  xx: modulation speed
;  yy: change per step
;  zz: number of steps
; (MOD_SETUP)
sModAMPS	macro wait, speed, step, count
	dc.b $F0
	sModData %macpfx%wait, %macpfx%speed, %macpfx%step, %macpfx%count
    endm

sModData	macro wait, speed, step, count
	dc.b %macpfx%speed, %macpfx%count, %macpfx%step, %macpfx%wait
    endm

; FF00 - Turn on Modulation (MOD_SET - MODS_ON)
sModOn		macro
	dc.b $FF,$00
    endm

; FF04 - Turn off Modulation (MOD_SET - MODS_OFF)
sModOff		macro
	dc.b $FF,$04
    endm

; FF28xxxx - Set modulation frequency to xxxx (MOD_SET - MODS_FREQ)
ssModFreq	macro freq
	dc.b $FF,$28
	dc.w %macpfx%freq
    endm

; FF2C - Reset modulation data (MOD_SET - MODS_RESET)
sModReset	macro
	dc.b $FF,$2C
    endm

; F1xx - Set portamento speed to xx frames. 0 means portamento is disabled (PORTAMENTO)
ssPortamento	macro frames
	dc.b $F1, %macpfx%frames
    endm

; F4xxxx - Keep looping back to xxxx each time the SFX is being played (CONT_SFX)
sCont		macro loc
	dc.b $FF,$4C
	dc.w %macpfx%loc-*-2
    endm

; F5 - End of channel (TRK_END - TEND_STD)
sStop		macro
	dc.b $F5
    endm

; F6xxxx - Jump to xxxx (GOTO)
sJump		macro loc
	dc.b $F6
	dc.w %macpfx%loc-*-2
    endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing (LOOP)
sLoop		macro index,loops,loc
	dc.b $F7, %macpfx%index
	dc.w %macpfx%loc-*-2
	dc.b %macpfx%loops-1

	if %macpfx%loops<2
		%fatal%"Invalid number of loops! Must be 2 or more!"
	endif
    endm

; F8xxxx - Call pattern at xxxx, saving return point (GOSUB)
sCall		macro loc
	dc.b $F8
	dc.w %macpfx%loc-*-2
    endm

; F9 - Return (RETURN)
sRet		macro
	dc.b $F9
    endm

; FAyyxx - Set communications byte yy to xx (SET_COMM - SPECIAL)
sComm		macro index, val
	dc.b $FA, %macpfx%index,%macpfx%val
    endm

; FBxyzz - Get communications byte y, and compare zz with it using condition x (COMM_CONDITION)
sCond		macro index, cond, val
	dc.b $FB, %macpfx%index|(%macpfx%cond<<4),%macpfx%val
    endm

; FC - Reset condition (COMM_RESET)
sCondOff	macro
	dc.b $FC
    endm

; FDxx - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL)
sGate		macro frames
	dc.b $FD, %macpfx%frames
    endm

; FExxyy - YM command yy on register xx (YMCMD)
sCmdYM		macro reg, val
	dc.b $FE, %macpfx%reg,%macpfx%val
    endm

; FF08xxxx - Set channel frequency to xxxx (CHFREQ_SET)
ssFreq		macro freq
	dc.b $FF,$08
	dc.w %macpfx%freq
    endm

; FF0Cxx - Set channel frequency to note xx (CHFREQ_SET - CHFREQ_NOTE)
ssFreqNote	macro note
	dc.b $FF,$0C, %macpfx%note%xor%$80
    endm

; FF10 - Increment spindash rev counter (SPINDASH_REV - SDREV_INC)
sSpinRev	macro
	dc.b $FF,$10
    endm

; FF14 - Reset spindash rev counter (SPINDASH_REV - SDREV_RESET)
sSpinReset	macro
	dc.b $FF,$14
    endm

; FF20xyzz - Get RAM address pointer offset by y, compare zz with it using condition x (COMM_CONDITION - COMM_SPEC)
sCondReg	macro index, cond, val
	dc.b $FF,$20, %macpfx%index|(%macpfx%cond<<4),%macpfx%val
    endm

; FF24xx - Play another music/sfx (SND_CMD)
sPlayMus	macro id
	dc.b $FF,$24, %macpfx%id
    endm

; FF30xxxxyyyyzzzz - Enable FM3 special mode (SPC_FM3)
sSpecFM3	macro op2, op3, op4
	dc.b $FF,$30

%narg% =0 op2 ==
		dc.w 0
	else
		dc.w %macpfx%op3-*-2
		dc.w %macpfx%op2-*-2
		dc.w %macpfx%op4-*-2
	endif
    endm

; FF34xx - Set DAC filter bank address (DAC_FILTER)
ssFilter	macro bank
	dc.b $FF,$34, %macpfx%bank
    endm

; FF38 - Load the last song from back-up (FADE_IN_SONG)
sBackup		macro
	dc.b $FF,$38
    endm

; FF3Cxx - PSG4 noise mode xx (PSG_NOISE - PNOIS_AMPS)
sNoisePSG	macro mode
	dc.b $FF,$3C, %macpfx%mode
    endm

; FF40yxxx - Enable CSM mode for specific operators y, and set timer a value to x (SPC_FM3 - CSM_ON)
sCSMOn		macro ops, timera
	dc.b $FF,$40, (%macpfx%ops&$F0)|(%macpfx%timera&$03), %macpfx%timera>>2
    endm

; FF44yy - Disable CSM mode and set register mask y (SPC_FM3 - CSM_OFF)
sCSMOff		macro ops
	dc.b $FF,$44, (%macpfx%ops&$F0)|ctFM3
    endm

; FF28xx - Set ADSR mode to xx (ADSR - ADSR_MODE)
ssModeADSR	macro mode
	dc.b $FF,$48, %macpfx%mode
    endm

; FF40 - Freeze 68k. Debug flag (DEBUG_STOP_CPU)
sFreeze		macro
	if safe=1
		dc.b $FF,$40
	endif
    endm

; FF44 - Bring up tracker debugger at end of frame. Debug flag (DEBUG_PRINT_TRACKER)
sCheck		macro
	if safe=1
		dc.b $FF,$44
	endif
    endm

; F4xx -  Setup TL modulation for all operators according to parameter value (TL_MOD - MOD_COMPLEX)
;  xx: lower 4 bits indicate what operators to apply to, and higher 4 bits are the operation:

	%rsset% 0
sctModsEnvr	%rb% $10	; %0000: Setup modulation and reset volume envelope
sctMods		%rb% $10	; %0001: Setup modulation
sctEnvs		%rb% $10	; %0010: Setup volume envelope
sctModsEnvs	%rb% $10	; %0011: Setup modulation and volume envelope
sctModd		%rb% $10	; %0100: Disable modulation
sctMode		%rb% $10	; %0101: Enable modulation
sctModdEnvr	%rb% $10	; %0110: Disable modulation and reset volume envelope
sctModeEnvr	%rb% $10	; %0111: Enable modulation and reset volume envelope
sctModdEnvs	%rb% $10	; %1000: Setup volume envelope and disable modulation
sctModeEnvs	%rb% $10	; %1001: Setup volume envelope and enable modulation
sctVola		%rb% $10	; %1010: Add volume
sctVols		%rb% $10	; %1011: Set volume

sComplexTL	macro val1, val2, val3, val4
%ifasm% ASM68K
	local	mode, index, mask, flags
mode =	(\val1&$F0)|((\val1&1)<<3)|((\val1&2)<<1)|((\val1&4)>>1)|((\val1&8)>>3)
mask =	1

	shift
	dc.b $F4, mode

; NAT: Here is some fun code to setup parameters
	rept 4
		if mode&mask
			; if this channel is enabled, figure out what to do
flags =			8
			case mode&$F0
=$00
flags =				1	; modulation only
=$10
flags =				1	; modulation only
=$20
flags =				2	; envelope only
=$30
flags =				3	; envelope + modulation
=$80
flags =				2	; envelope only
=$90
flags =				2	; envelope only
=$A0
flags =				4	; volume only
=$B0
flags =				4	; volume only
=?
flags =				0	; nothing
			endcase

			if flags&4	; check if we need to do volume modification
				dc.b \val1
				shift
			endif

			if flags&2	; check if we need to do volume envelope
				dc.b \val1
				shift
			endif

			if flags&1	; check if we need to do modulation
				sModData \val1, \val2, \val3, \val4
				shift
				shift
				shift
				shift
			endif
		endif

mask =		mask>>1			; get the next bit to check
	endr
%endif%
%ifasm% AS
.mode =		(val1&$F0)|((val1&1)<<3)|((val1&2)<<1)|((val1&4)>>1)|((val1&8)>>3)
.mask =		1

	shift
	dc.b $F4, .mode

; NAT: Here is some fun code to setup parameters
	rept 4
		if .mode&.mask
			; if this channel is enabled, figure out what to do
			switch .mode&$F0
				case $00
.flags =				1	; modulation only
				case $10
.flags =				1	; modulation only
				case $20
.flags =				2	; envelope only
				case $30
.flags =				3	; envelope + modulation
				case $80
.flags =				2	; envelope only
				case $90
.flags =				2	; envelope only
				case $A0
.flags =				4	; volume only
				case $B0
.flags =				4	; volume only
				elsecase
.flags =				0	; nothing
			endcase

			if .flags&4	; check if we need to do volume modification
				dc.b val1
				shift
			endif

			if .flags&2	; check if we need to do volume envelope
				dc.b val1
				shift
			endif

			if .flags&1	; check if we need to do modulation
				sModData val1, val2, val3, val4
				shift
				shift
				shift
				shift
			endif
		endif

.mask =		.mask>>1		; get the next bit to check
	endm
%endif%
    endm

; FF5x - Turn on TL Modulation for operator x (TL_MOD - MODS_ON)
sModOnTL	macro op
	dc.b $FF, $50|((%macpfx%op-1)*4)
    endm

; FF6x - Turn off TL Modulation for operator x (TL_MOD - MODS_OFF)
sModOffTL	macro op
	dc.b $FF, $60|(%macpfx%op-1)*4)
    endm

; FF7uwwxxyyzz - TL Modulation for operator u
;  ww: wait time
;  xx: modulation speed
;  yy: change per step
;  zz: number of steps
; (TL_MOD - MOD_SETUP)
ssModTL		macro op, wait, speed, step, count
	dc.b $FF, $70|((%macpfx%op-1)*4)
	sModData	%macpfx%wait,%macpfx%speed,%macpfx%step,%macpfx%count
    endm

; FF8yxx - Set TL volume envelope to xx for operator y (TL_MOD - FM_VOLENV)
sVolEnvTL	macro op, val
	dc.b $FF, $80|((%macpfx%op-1)*4), %macpfx%val
    endm

; FF9yxx - Add xx to volume for operator y (TL_MOD - VOL_ADD_TL)
saVolTL		macro op, val
	dc.b $FF, $90|((%macpfx%op-1)*4), %macpfx%val
    endm

; FFAyxx - Set volume to xx for operator y (TL_MOD - VOL_SET_TL)
ssVolTL		macro op, val
	dc.b $FF, $A0|((%macpfx%op-1)*4), %macpfx%val
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Equates for sNoisePSG
; ---------------------------------------------------------------------------

%ifasm% AS
	enum snOff=$00			; disables PSG3 noise mode.
	enum snPeri10=$E0,snPeri20,snPeri40,snPeriPSG3
	enum snWhite10=$E4,snWhite20,snWhite40,snWhitePSG3
%endif%
%ifasm% ASM68K
snOff =		$00			; disables PSG3 noise mode.
_num =		$E0
	enum snPeri10, snPeri20, snPeri40, snPeriPSG3
	enum snWhite10,snWhite20,snWhite40,snWhitePSG3
%endif%
; ---------------------------------------------------------------------------
