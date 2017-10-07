

/*
 * MLX90621.h
 *
 *  Created on: 08.07.2014
 *      Author: Max Ritter
 *
 *  Adapted by https://github.com/longjos
 *  	Adapted for use with Arduino UNO
 *
 *  Adapted again by https://github.com/barucAlmaguer
 *      Adapted for adq. speed control, ems calibration etc
 */

#ifndef MLX90621_H_
#define MLX90621_H_
//lalala
#ifdef __cplusplus

//Libraries to be included
#include <Arduino.h>
#include <Wire.h>

//Begin registers
#define CAL_ACOMMON_L 0xD0
#define CAL_ACOMMON_H 0xD1
#define CAL_ACP_L 0xD3
#define CAL_ACP_H 0xD4
#define CAL_BCP 0xD5
#define CAL_alphaCP_L 0xD6
#define CAL_alphaCP_H 0xD7
#define CAL_TGC 0xD8
#define CAL_AI_SCALE 0xD9
#define CAL_BI_SCALE 0xD9


#define VTH_L 0xDA
#define VTH_H 0xDB
#define KT1_L 0xDC
#define KT1_H 0xDD
#define KT2_L 0xDE
#define KT2_H 0xDF
#define KT_SCALE 0xD2

//Common sensitivity coefficients
#define CAL_A0_L 0xE0
#define CAL_A0_H 0xE1
#define CAL_A0_SCALE 0xE2
#define CAL_DELTA_A_SCALE 0xE3
#define CAL_EMIS_L 0xE4
#define CAL_EMIS_H 0xE5
#define CAL_KSTA_L 0xE6
#define CAL_KSTA_H 0xE7


//Config register = 0xF5-F6
#define OSC_TRIM_VALUE 0xF7

//Bits within configuration register 0x92
#define POR_TEST 10

//Refresh rate options:
#define RATE_512HZ  0b0000
//#define RATE_512HZ  0b0001
//#define RATE_512HZ  0b0010
//#define RATE_512HZ  0b0011
//#define RATE_512HZ  0b0100
//#define RATE_512HZ  0b0101
#define RATE_256HZ  0b0110
#define RATE_128HZ  0b0111
#define RATE_64HZ   0b1000
#define RATE_32HZ   0b1001
#define RATE_16HZ   0b1010
#define RATE_8HZ    0b1011
#define RATE_4HZ    0b1100
#define RATE_2HZ    0b1101
#define RATE_1HZ    0b1110
#define RATE_0_5HZ  0b1111

//Resolution options:
#define RES_15bit   0b00
#define RES_16bit   0b01
#define RES_17bit   0b10
#define RES_18bit   0b11

class MLX90621 {
private:
	/* Variables */
	byte refreshRate; //Set this value to your desired refresh frequency
  byte resolution; //Set this value to your desired resolution (0-3)
	float temperatures[64]; //Contains the calculated temperatures of each pixel in the array
	float Tambient; //Tracks the changing ambient temperature of the sensor


	byte loopCount = 0; //Used in main loop

	/* Methods */
	void readEEPROM();
	void writeTrimmingValue();
	void calculateTA();
	void readPTAT();
	void calculateTO();
	void readIR();
	void readCPIX();
	void preCalculateConstants();
	int16_t twos_16(uint8_t highByte, uint8_t lowByte);
	int8_t twos_8(uint8_t byte);
	uint16_t unsigned_16(uint8_t highByte, uint8_t lowByte);
	uint16_t readConfig();
	boolean checkConfig();
	float v_ir_off_comp, ksta, v_ir_tgc_comp, v_ir_comp, alpha_comp;
	float tak4, resolution_comp;
	int16_t a_common, a_i_scale, b_i_scale, k_t1_scale, k_t2_scale;
	uint8_t eepromData[256]; //Contains the full EEPROM reading from the MLX90621
	float k_t1, k_t2, emissivity, tgc, alpha_cp, a_cp, b_cp, v_th;
	uint16_t ptat;
	int16_t cpix;
	float a_ij, b_ij, alpha_ij;
	float minTemp, maxTemp;
public:
  void setRefreshRate(uint8_t refrate = RATE_1HZ);
  void setResolution(uint8_t res = RES_18bit);
  void setEmissivity(float ems);
  void setConfiguration();
	int16_t irData[64]; //Contains the raw IR data from the sensor
	void initialize();
	void measure(bool);
	float getTemperature(uint8_t num);
	float getAmbient();
	float getMinTemp();
	float getMaxTemp();

};

#endif
#endif

