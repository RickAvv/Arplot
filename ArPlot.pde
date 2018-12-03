import processing.serial.*;
import javax.swing.*;

PrintWriter logfile;

Serial port;          //Create object from Serial class
int valAnalog1;       
int valAnalog2;       
int valAnalog3;
int valAnalog4;
int valueAnalog1;      //Piezo sensor value
int valueAnalog2;      //Lever sensor value
int valueAnalog3;      //Spare analog value
int valueAnalog4;      //Spare analog value

int valueDigital1;     //Reward value
int valueDigital2;     //Cue1 value
int valueDigital3;     //Cue2 value
int valueDigital4;     //Cue3 value
int valueDigital5;     //Houselight value
int valueDigital6;     //TrialState value
int valueDigital7;     //Trial block value
int valueDigital8;     //Spare digital value
int valueDigital9;     //Spare digital value
int valueDigital10;    //Spare digital value

int valueTimestamp;
int valueTimestamp_display;

int valuePositioning;
boolean writeFlag = false;
boolean closeFileFlag = false;
String hours_disp;
String minutes_disp;
String seconds_disp;

String day;
String month;

String filename;

int numRewards = 0;
int lastReward;
int numTrials = 0;
int lastTrialState;
int numTrialsinBlock = 0;
int numBlocks = 0;
int lastBlock = 1;
float succRate = 0;
int numRewardsinBlock = 0;
float succRateinBlock = 0;


float mapAnalog1Val;
float mapAnalog2Val;
float mapAnalog3Val;
float mapRewardVal;

long previousMillis;
boolean recBlink = false;

int[] valuesAnalog1;
int[] valuesAnalog2;
int[] valuesAnalog3;
int[] valuesDigital1;
byte[] inBytes;

int windowHeight = 200;
int windowHeightsmall = 150;
int windowSeparator = 15;

int topWindow1 = 0;
int botWindow1 = windowHeight;
int topWindow2 = botWindow1 + windowSeparator;
int botWindow2 = topWindow2 + windowHeight;
int topWindow3 = botWindow2 + windowSeparator;
int botWindow3 = topWindow3 + windowHeight;
int topWindow4 = botWindow3 + windowSeparator;
int botWindow4 = topWindow4 + windowHeightsmall;
int topWindow5 = botWindow4 + windowSeparator;
int botWindow5 = topWindow5 + windowHeightsmall;

//thresh
float piezoThreshold = map(14, 0, 1023, 0, 425);
float leverThreshold = map(552, 500, 650, 0, windowHeight);

PFont f;
PFont bigFont;

JTextField topWin1Lim_pop = new JTextField();
JTextField botWin1Lim_pop = new JTextField();
JTextField topWin2Lim_pop = new JTextField();
JTextField botWin2Lim_pop = new JTextField();
JTextField topWin3Lim_pop = new JTextField();
JTextField botWin3Lim_pop = new JTextField();

int topWin1Lim = 1023;
int botWin1Lim = 0;
int topWin2Lim = 1023;
int botWin2Lim = 0;
int topWin3Lim = 1023;
int botWin3Lim = 0;

Object[] messageZoom = {
  "Upper Window1 Limit:", topWin1Lim_pop, 
  "Lower Window1 Limit:", botWin1Lim_pop, 
  "Upper Window2 Limit:", topWin2Lim_pop, 
  "Lower Window2 Limit:", botWin2Lim_pop, 
  "Upper Window3 Limit:", topWin3Lim_pop, 
  "Lower Window4 Limit:", botWin3Lim_pop, 
};

JTextField MouseID_pop = new JTextField();
JTextField Experiment_pop = new JTextField();
JTextField Treatment_pop = new JTextField();
JTextField Genotype_pop = new JTextField();

String MouseID = "N/A";
String Experiment = "N/A";
String Treatment = "N/A";
String Genotype = "N/A";

Object[] message = {
  "MouseID:", MouseID_pop, 
  "Experiment:", Experiment_pop, 
  "Treatment:", Treatment_pop, 
  "Genotype:", Genotype_pop
};

/////////////////////////////////////////////////////////////// 
void drawGrid() {
  //mask
  stroke(255);
  fill(255);
  rect(0, botWindow1, width, windowSeparator);
  rect(0, botWindow2, width, windowSeparator);
  rect(0, botWindow3, width, windowSeparator);
  rect(0, botWindow4, width, windowSeparator);
  textFont(f, 16);
  fill(255);  
  text("Analog1", 15, topWindow1 + 25);
  text("Analog2", 15, topWindow2 + 25);
  text("Analog3", 15, topWindow3 + 25);
  text("Reward", 15, topWindow4 + 25);
  displaySummary();  
  //thresholds
  stroke(255, 0, 0);
  line(0, botWindow2-leverThreshold, width, botWindow2-leverThreshold);
}

void displaySummary() {
  textFont(f, 16);
  fill(255);  
  text("Trial Tot   " + numTrials, 15, topWindow5 + 25);
  text("Trial in Block   " + numTrialsinBlock, 15, topWindow5 + 50);
  text("Block num   " + numBlocks, 15, topWindow5 + 75);
  text("Rewards   " + numRewards, 150, topWindow5 + 25);  
  if (valueDigital6 == 2) {
    if (numTrials !=0) {
      succRate = ((float)numRewards/numTrials)*100.00;
    } else {
      succRate  = 0;
    }
    if (numTrialsinBlock !=0) {
      succRateinBlock = ((float)numRewardsinBlock/numTrialsinBlock)*100.00;
    } else {
      succRateinBlock = 0;
    }
  }
  succRate = round(succRate*100)/100.0;
  succRateinBlock = round(succRateinBlock*100)/100.0;
  text("Success Rate   " + succRate + "%", 150, topWindow5 + 50);
  text("Success Rate Block   " + succRateinBlock + "%", 150, topWindow5 + 75);
}

void promptMetadata() {
  numRewards = 0;
  numRewardsinBlock = 0;
  numTrials = 0;
  numTrialsinBlock = 0;
  succRate = 0;
  succRateinBlock = 0;
  int option = JOptionPane.showConfirmDialog(null, message, "Session details", JOptionPane.OK_CANCEL_OPTION);
  if (option == JOptionPane.OK_OPTION) {
    MouseID = MouseID_pop.getText();
    Experiment = Experiment_pop.getText();
    Treatment = Treatment_pop.getText();
    Genotype = Genotype_pop.getText();
  }
}

void adjustZoom() {
  int option = JOptionPane.showConfirmDialog(null, messageZoom, "Adjust Zoom", JOptionPane.OK_CANCEL_OPTION);
  if (option == JOptionPane.OK_OPTION) {
    topWin1Lim = Integer.parseInt(topWin1Lim_pop.getText());
    botWin1Lim = Integer.parseInt(botWin1Lim_pop.getText());
    topWin2Lim = Integer.parseInt(topWin2Lim_pop.getText());
    botWin2Lim = Integer.parseInt(botWin2Lim_pop.getText());
    topWin3Lim = Integer.parseInt(topWin3Lim_pop.getText());
    botWin3Lim = Integer.parseInt(botWin3Lim_pop.getText());
  }
}  

void keyPressed() {
  if (key == 'n') {
    promptMetadata();
  }
  if (key == 'z') {
    adjustZoom();
  }
}

void openNewFile() {
  for (int i = 1; i < 100; i++) {
    if (day() <=10) {
      day = ("0" + day());
    } else {
      day = str(day());
    }
    if (month() <= 10) {
      month = ("0" + month());
    } else {
      month = str(month());
    }
    String date = new String(year() + "-" + month + "-" + day);
    if (i == 1) {
      filename = (MouseID + " " + date + ".csv");
    } else {
      filename = (MouseID + " " + date + " (" + i + ")" + ".csv");
    }
    if (createReader(filename) == null) {                                  // only open a new file if it doesn't exist
      logfile = createWriter(filename);

      logfile.print("Date:," + day() + "/" + month() + "/" + year());
      logfile.println("," + hour() + ":" + minute() + ":" + second());
      logfile.println();
      logfile.println("MouseID:,," + MouseID);
      logfile.println("Experiment:,," + Experiment);
      logfile.println("Treatment:,," + Treatment);
      logfile.println("Genotype:,," + Genotype);
      logfile.print("\n\n");
      logfile.print("Analog1," + "Analog2," + "Analog3," + "Analog4," + "Digital1," + "Digital2," + "Digital3,");
      logfile.print("Digital4," + "Digital5," + "Digital6," + "Digital7," + "Digital8," + "Digital9," + "Digital10,");
      logfile.println("Timestamp");
      break;  // leave the loop!
    }
  }
}

void pushvalueAnalog1(int value) {
  for (int i=0; i<width-1; i++)
    valuesAnalog1[i] = valuesAnalog1[i+1];
  valuesAnalog1[width-1] = value;
}
void pushvalueAnalog2(int value) {
  for (int i=0; i<width-1; i++)
    valuesAnalog2[i] = valuesAnalog2[i+1];
  valuesAnalog2[width-1] = value;
}
void pushvalueAnalog3(int value) {
  for (int i=0; i<width-1; i++)
    valuesAnalog3[i] = valuesAnalog3[i+1];
  valuesAnalog3[width-1] = value;
}
void pushvalueDigital1(int value) {
  for (int i=0; i<width-1; i++)
    valuesDigital1[i] = valuesDigital1[i+1];
  valuesDigital1[width-1] = value;
}

int getYAnalog1(int val) {
  mapAnalog1Val = map(val, botWin1Lim, topWin1Lim, botWindow1, topWindow1);
  return (int)mapAnalog1Val;
}
int getYAnalog2(int val) {
  mapAnalog2Val = map(val, botWin2Lim, topWin2Lim, botWindow2, topWindow2);
  return (int)mapAnalog2Val;
}
int getYAnalog3(int val) {
  mapAnalog3Val = map(val, botWin3Lim, topWin3Lim, botWindow3, topWindow3);
  return (int)mapAnalog3Val;
}
int getYReward(int val) {
  if (val != 0) {
    val = 1;
  }
  mapRewardVal = map(val, 0, 1, botWindow4 - 25, topWindow4 + 75);
  return (int)mapRewardVal;
}

void drawLinesPiezo() {
  stroke(255);

  int k = valuesAnalog1.length - width;

  int x0Piezo = 0;
  int y0Piezo = getYAnalog1(valuesAnalog1[k]);
  for (int i=1; i<width; i++) {
    k++;
    int x1Piezo = (int) (i * (width-1) / (width-1));
    int y1Piezo = getYAnalog1(valuesAnalog1[k]);
    line(x0Piezo, y0Piezo, x1Piezo, y1Piezo);
    x0Piezo = x1Piezo;
    y0Piezo = y1Piezo;
  }
}  

void drawLinesLever() {
  stroke(255);

  int k = valuesAnalog2.length - width;

  int x0 = 0;
  int y0 = getYAnalog2(valuesAnalog2[k]);
  for (int i=1; i<width; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (width-1));
    int y1 = getYAnalog2(valuesAnalog2[k]);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
  }
}  

void drawLinesAnalog3() {
  stroke(255);

  int k = valuesAnalog3.length - width;

  int x0 = 0;
  int y0 = getYAnalog3(valuesAnalog3[k]);
  for (int i=1; i<width; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (width-1));
    int y1 = getYAnalog3(valuesAnalog3[k]);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
  }
}  

void drawLinesReward() {
  stroke(255);

  int k = valuesDigital1.length - width;

  int x0 = 0;
  int y0 = getYReward(valuesDigital1[k]);
  for (int i=1; i<width; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (width-1));
    int y1 = getYReward(valuesDigital1[k]);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
  }
}  

boolean checkHeader() {
  int header = port.read();
  if ((header & 0xff) == 0xff) {
    int header2 = port.read();
    if (((header & 0xff) & (header2 & 0xff)) == 0xff) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

void RECsign() {
  if (writeFlag) {
    if (millis() >= previousMillis + 500) {
      recBlink = !recBlink;
      previousMillis = millis();
    }
    if (recBlink) {
      textFont(f, 32);
      text("Rec", (width - 80), 45);
      stroke(255, 0, 0);
      fill(255, 0, 0);
      ellipse((width - 100), 34, 19, 19);
    }
  }
}

void serialEvent(Serial port) {  //this functions gets triggered every time new data comes through the serial port
  try {
    if (port.available() >= 25) {
      if (checkHeader()) {
        inBytes = port.readBytes(23);
      }
      int byte1 = inBytes[0] & 0xff;      
      int byte2 = inBytes[1] & 0xff;                
      valueAnalog1 = (byte1 << 8) | (byte2);        //Piezo Sensor value

      int byte3 = inBytes[2] & 0xff;
      int byte4 = inBytes[3] & 0xff;    
      valueAnalog2 = (byte3 << 8) | (byte4);        //Lever Sensor value

      int byte5 = inBytes[4] & 0xff;                
      int byte6 = inBytes[5] & 0xff;
      valueAnalog3 = (byte5 << 8) | (byte6);        //Spare analog value

      int byte7 = inBytes[6] & 0xff;
      int byte8 = inBytes[7] & 0xff;
      valueAnalog4 = (byte7 << 8) | (byte8);        //Spare analog value

      int byte9 = inBytes[8] & 0xff;                
      valueDigital1 = byte9;                        //Reward Delivered
      if ((valueDigital1 != 0) && (lastReward == 0)) {
        numRewards++;
        numRewardsinBlock++;
      }
      lastReward = valueDigital1;  

      int byte10 = inBytes[9] & 0xff;
      valueDigital2 = byte10;                        //Cue1

      int byte11 = inBytes[10] & 0xff;
      valueDigital3 = byte11;                        //Cue2

      int byte12 = inBytes[11] & 0xff;
      valueDigital4 = byte12;                        //Cue3

      int byte13 = inBytes[12] & 0xff;
      valueDigital5 = byte13;                        //Houselight

      int byte14 = inBytes[13] & 0xff;
      valueDigital6 = byte14;                        //TrialState      
      if ((valueDigital6 != 2) && (lastTrialState == 2)) {
        numTrials++;
        numTrialsinBlock++;
      }
      lastTrialState = valueDigital6;

      int byte15 = inBytes[14] & 0xff;
      valueDigital7 = byte15;                        //TrialBlock
      if (valueDigital7 != lastBlock) {
        numTrialsinBlock = 0;
        numRewardsinBlock = 0;
      }
      lastBlock = valueDigital7;

      int byte16 = inBytes[15] & 0xff;
      valueDigital8 = byte16;

      int byte17 = inBytes[16] & 0xff;
      valueDigital9 = byte17;

      int byte18 = inBytes[17] & 0xff;
      valueDigital10 = byte18;

      int byte19 = inBytes[18] & 0xff;                //Timestamp
      int byte20 = inBytes[19] & 0xff;
      int byte21 = inBytes[20] & 0xff;
      int byte22 = inBytes[21] & 0xff;
      valueTimestamp = (byte19 << 24) | (byte20 << 16) | (byte21 << 8) | (byte22);
      valueTimestamp_display = valueTimestamp;

      int byte23 = inBytes[22] & 0xff;
      if (!writeFlag) {
        if (byte23 == 1) {
          openNewFile();
          writeFlag = true;
        }
      } else {
        if (byte23 == 0) {
          writeFlag = false;
          closeFileFlag = true;
        }
      }
      if (writeFlag) {
        logfile.print(valueAnalog1 + ",");
        logfile.print(valueAnalog2 + ",");
        logfile.print(valueAnalog3 + ",");
        logfile.print(valueAnalog4 + ",");
        logfile.print(valueDigital1 + ",");
        logfile.print(valueDigital2 + ",");
        logfile.print(valueDigital3 + ",");
        logfile.print(valueDigital4 + ",");
        logfile.print(valueDigital5 + ",");
        logfile.print(valueDigital6 + ",");
        logfile.print(valueDigital7 + ",");
        logfile.print(valueDigital8 + ",");
        logfile.print(valueDigital9 + ",");
        logfile.print(valueDigital10 + ",");
        logfile.println(valueTimestamp);
      }
      if (closeFileFlag) {
        logfile.flush();
        logfile.close();
        closeFileFlag = false;
      }
    }
  } 
  catch(RuntimeException e) {
  }
}

void displayNumberData() {
  text(valueAnalog1, 15, topWindow1 + 45);
  text(valueAnalog2, 15, topWindow2 + 45);
  text(valueAnalog3, 15, topWindow3 + 45);
  displayTime();
}

void displayTime() {
  int hours = (valueTimestamp_display/1000) / (60*60);
  if (hours < 10) {
    hours_disp = ("0" + hours);
  } else {
    hours_disp = Integer.toString(hours);
  }
  int remainder = (valueTimestamp_display/1000) % (60*60);
  int minutes = remainder / 60;
  if (minutes < 10) {
    minutes_disp = ("0" + minutes);
  } else {
    minutes_disp = Integer.toString(minutes);
  }
  int seconds = remainder % 60;
  if (seconds < 10) {
    seconds_disp = ("0" + seconds);
  } else {
    seconds_disp = Integer.toString(seconds);
  }
  text(hours_disp + ":" + minutes_disp + ":" + seconds_disp, (width - 100), 70);
}

void setup() 
{
  promptMetadata();
  size(690, 900);
  f = createFont("Arial", 12, true);
  
  //// Open the port that the board is connected to and use the same speed (115200 bps)
  //printArray(Serial.list());
  port = new Serial(this, "COM6", 115200);
  valuesAnalog1 = new int[width];
  valuesAnalog2 = new int[width];
  valuesAnalog3 = new int[width];
  valuesDigital1 = new int[width];
  inBytes = new byte[22];
  smooth();
  //logfile = createWriter(filename);
}

void draw() {
  background(0);
  drawGrid();
  if (valueAnalog1 != -1) {
    pushvalueAnalog1(valueAnalog1);
  }
  drawLinesPiezo();

  if (valueAnalog2 != -1) {
    pushvalueAnalog2(valueAnalog2);
  }
  drawLinesLever();

  if (valueAnalog3 != -1) {
    pushvalueAnalog3(valueAnalog3);
  }
  drawLinesAnalog3();

  if (valueDigital1 != -1) {
    pushvalueDigital1(valueDigital1);
  }
  drawLinesReward(); 

  displayNumberData();  
  RECsign();
}