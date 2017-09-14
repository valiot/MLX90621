/*
 *  VisualizeTemperatures.pde
 *
 *  A simple Processing Sketch which listens to a  
 *  Teensy 3.1+ Arduino board connected to a Melexis MLX90621
 *  and visualizes the temperature values measured by its 
 *  4x16 matrix as a color matrix 
 *
 *  WARNING!
 *  Per 11.10.2015 this script was adapted through quick and dirty copy and paste programming.
 *  This enabled me to demonstrate, and make use of, some alternative visualisations during measurement.
 *  The resulting code needs to be cleaned up and refactored.
 *
 *  Created on: 9.7.2015
 *      Author: Robin van Emden
 */

import org.jnativehook.GlobalScreen;
import org.jnativehook.NativeHookException;
import org.jnativehook.keyboard.NativeKeyEvent;
import org.jnativehook.keyboard.NativeKeyListener;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

import processing.serial.*;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Arrays; 
import java.text.SimpleDateFormat;
import java.util.Date;

public static final boolean  WRITE_TO_FILE = false;

//import controlP5.*;
//ControlP5 cp5;
//Slider s_max;
//Slider s_min;

PrintWriter output;
Serial serialConnection;
String sensorReading;
String[] serialString;  
String serialCheck;  
String portName_w = "eensy"; 
String portName_m = "cu.usbmodem1411"; //cu.usbserial-AJ03MS39
String portName_m2 = "cu.usbserial-AJ03MS39"; //
int portNumber;  
int serialIndex;  
Double temperatureToString;
double[][] drawTemperatures2D;
double[][] temperatures2D;
double H, S, B;
boolean waitFirstNewline;
SMA[][] sma2D = new SMA[4][16];
SMA[][] sma2Dlong = new SMA[4][16];
SimpleDateFormat sdf;
double[] tempValues1D[];
PImage img;
double[][] quadrant = new double[4][16];
double[][] quadrantLong = new double[4][16];
boolean spaceCheck = false;
String pressedSpace = "";

//Min = morado, max = rojo
float min = 80.0;
float max = 100.0;
float gradMax = 20;

void setup() {
  size(700, 600);
  // log global keypress
  try {
    // Get the logger for "org.jnativehook" and set the level to warning.
    Logger logger = Logger.getLogger(GlobalScreen.class.getPackage().getName());
    logger.setLevel(Level.WARNING);
    GlobalScreen.registerNativeHook();
    GlobalScreen.addNativeKeyListener(new GlobalKeyListenerExample());
  }
  catch (NativeHookException ex) {
    System.err.println("There was a problem registering the native hook.");
    System.err.println(ex.getMessage());
  }


  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 16; j++) {  
      sma2D[i][j]= new SMA(6);
      sma2Dlong[i][j]= new SMA(40);
    }
  }  
  img = createImage(16, 4, RGB);
  img.loadPixels(); 
  if (WRITE_TO_FILE) {
    sdf = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss_SSS");  
    output = createWriter(sdf.format(new Date())+"_output.txt");
  }

  waitFirstNewline = false;
  sensorReading="";

  findSerialPort(); 
  try {
    serialConnection = new Serial(this, Serial.list()[portNumber], 115200);//19200);  
    serialConnection.bufferUntil('\n');
  } 
  catch (RuntimeException e) {
    noLoop();
    System.out.println("Connection to serial failed");
  }
}


public class GlobalKeyListenerExample implements NativeKeyListener {
  public void nativeKeyPressed(NativeKeyEvent e) {
    System.out.println("Key Pressed: " + NativeKeyEvent.getKeyText(e.getKeyCode()));
    if (NativeKeyEvent.getKeyText(e.getKeyCode()) == "Space") {
      spaceCheck = true;
    }
  }
  public void nativeKeyReleased(NativeKeyEvent e) {
    //System.out.println("Key Released: " + NativeKeyEvent.getKeyText(e.getKeyCode()));
  }
  public void nativeKeyTyped(NativeKeyEvent e) {
    //System.out.println("Key Typed: " + NativeKeyEvent  .getKeyText(e.getKeyCode()));
  }
}


void serialEvent (Serial serialConnection) {
  sensorReading = serialConnection.readStringUntil('\n');
  if (sensorReading != null) {
    if (waitFirstNewline) {
      sensorReading=trim(sensorReading);
    } else {
      serialConnection.clear();
      waitFirstNewline = true;
    }
  }
}

void draw() {
  background(0);
  translate(35, 35);
  fill(255);
  noStroke();
  
  drawTemperatures2D = parseInput(sensorReading);

  if (drawTemperatures2D!=null) {
    if (WRITE_TO_FILE) {

      if (spaceCheck) {
          pressedSpace = "1";
          spaceCheck = false;
      } else {
          pressedSpace = "0";
      }
      output.println(pressedSpace+"~"+sdf.format(new Date())+"~"+sensorReading); 
      output.flush();
    }

    for (int i = 15; i >= 0; i--) {  
      pushMatrix();
      for (int j = 0; j < 4; j++) {


        img.pixels[i+j*16]=getColor((float)drawTemperatures2D[j][i], min, max);
        fill(getColor((float)drawTemperatures2D[j][i], min, max));
        rect(0, 0, 30, 30);
        textSize(10);
        fill(0);
        temperatureToString = (double) Math.round(drawTemperatures2D[j][i] * 10) / 10;
        text(temperatureToString.toString(), 4, 20);
        translate(0, 40);
      }
      popMatrix();
      translate(40, 0);
    }
  }

//Imagen filtrada
  translate(-640, 185);
  img.filter(BLUR);
  img.updatePixels();
  pushMatrix();
  scale(-1.0, 1.0);
  image(img, -630, 0, 630, 150);
  popMatrix();

  translate(0, 185);
  fill(255);
  noStroke();
  if (drawTemperatures2D!=null) {
    int LT = 0, RT = 0, LB = 0, RB = 0;
    for (int i = 15; i >= 0; i--) {  
      pushMatrix();
      for (int j = 0; j < 4; j++) {
        double longValue = sma2Dlong[j][i].compute(drawTemperatures2D[j][i]);
        double shortValue = sma2D[j][i].compute(drawTemperatures2D[j][i]);
        //GRADIENTE
        double nowValue = longValue - shortValue;
        fill(gradientColor((float)nowValue, gradMax));
        rect(0, 0, 30, 30);
        textSize(10);
        fill(0);
        temperatureToString = -(double) Math.round(nowValue * 10) / 10;
        text(temperatureToString.toString(), 4, 20);
        translate(0, 40);
      }
      popMatrix();
      translate(40, 0);
    }
  }
  
  textSize(12);
  fill(1,0,1);
  text("Min: ", -640,170);
  text(int(min), -615,170);
  text("Max: ", -580,170);
  text(int(max), -555,170);
}


double[][] parseInput(String input) {
  String[] temperatureRows;
  temperatureRows = input.split("~");
  if (temperatureRows.length<4) return null;
  temperatures2D = new double[temperatureRows.length][];
  int i= 0;
  String[] temperatureCols;
  for (String row : temperatureRows) {
    row = row.substring(1, row.length()-1);
    temperatureCols = row.split(",");
    if (temperatureCols.length<16) return null;
    int j = 0;
    temperatures2D[i] = new double[temperatureCols.length];
    for (String col : temperatureCols) {
      try {
        temperatures2D[i][j++] = Double.parseDouble(col);
      }
      catch(NumberFormatException ex) {
        return null;
      }
    }
    i++;
  }
  return temperatures2D;
}

color getColor(float val, float min, float max)
{
  colorMode(HSB, 1.0);
  double H = 0.0;
  double S = 0.0; 
  double B = 0.0;
  
  if(val<min)
  {
    H = 0;
    S = 0; 
    B = (double)min(map(val, 0, min, 0.75, 0.25), 0.75); 
  }
  else
  {
    H = (double)min(map(val, min, max, 0.8, 0.0), 0.8); //0.8=purple (min), 0.0 = red (max)
    S = 0.9; 
    B = 0.9; 
  }
  return color((float)(H), (float)(S), (float)(B));
}

color gradientColor(float val, float max){
  double H, S, B;
  colorMode(HSB, 1.0);
  if(val < 0.0){
    H = 0.6;
    S = (double)map(abs(val), 0.0, max, 0.0, 1.0);
    B = 0.9;
  }
  else if (val > 0.0){
    H = 0.0;
    S = (double)map(val, 0.0, max, 0.0, 1.0);
    B = 0.9;
  }
  else {
    H = 0.0;
    S = 0.0;
    B = 0.9;
  }
  return color((float)(H), (float)(S), (float)(B));
}

void findSerialPort() {
  serialString = Serial.list();  
  for (int i = serialString.length - 1; i > 0; i--) {  
    serialCheck = serialString[i];  
    serialIndex = serialCheck.indexOf(portName_m);  
    if (serialIndex > -1) portNumber = i;
    serialIndex = serialCheck.indexOf(portName_m2);  
    if (serialIndex > -1) portNumber = i;
    serialIndex = serialCheck.indexOf(portName_w);  
    if (serialIndex > -1) portNumber = i;
  }
}    



public class SMA {
  private final Queue<Double> window = new LinkedList<Double>();
  private final int period;
  private double sum;

  public SMA(int period) {
    this.period = period;
  }

public double compute(double num) {
    sum += num;
    window.add(num);
    if (window.size() > period) {
      sum -= window.remove();
    }
    if (window.isEmpty()) return 0; 
    return sum / window.size();
  }
}

public static double mean(double[] m) {
  double total = 0;
  for (double element : m) {
    total += element;
  }

  double average = total / m.length;
  return average;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      min = min+1;
    } else if (keyCode == DOWN) {
      min = min-1;
    } 
    if (keyCode == RIGHT) {
      max = max+1;
    } else if (keyCode == LEFT) {
      max = max-1;
    } 
  }
 switch(key) {
    case('d'):min=80;max=100;break;
    case('D'):min=80;max=100;break;
    case('1'):min=10;max=30;break;
    case('2'):min=20;max=40;break;
    case('3'):min=30;max=50;break;
    case('4'):min=40;max=60;break;
    case('5'):min=50;max=70;break;
    case('6'):min=60;max=80;break;
    case('7'):min=70;max=90;break;
    case('8'):min=80;max=100;break;
    case('9'):min=90;max=110;break; 
  }
}