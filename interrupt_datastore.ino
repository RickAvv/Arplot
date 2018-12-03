#include <TimerThree.h>

const int analogInputsNeeded = 2;
int samplingFreq = 100; //sampling frequency for Lever/Piezo in Hz
unsigned long timestamp;
unsigned long sessionStartTime;

uint16_t analog1read = 0;
uint16_t analog2read = 0;
uint16_t analog3read = 0;
uint16_t analog4read = 0;

const int analog1pin = A1;
const int analog2pin = A2;
const int analog3pin = A3;
const int analog4pin = A4;

uint8_t digitalValue1;
uint8_t digitalValue2;
uint8_t digitalValue3;
uint8_t digitalValue4;
uint8_t digitalValue5;
uint8_t digitalValue6;
uint8_t digitalValue7;
uint8_t digitalValue8;
uint8_t digitalValue9;
uint8_t digitalValue10;

uint8_t writeFlag_main = 0;


struct datastore {
  const int8_t header1 = 0xff;
  const int8_t header2 = 0xff;
  volatile int8_t analog1a = 0;                   //piezo sensor read
  volatile int8_t analog1b = 0;
  volatile int8_t analog2a = 0;                   //lever sensor read
  volatile int8_t analog2b = 0;
  volatile int8_t analog3a = 0;                   //spare analog read
  volatile int8_t analog3b = 0;
  volatile int8_t analog4a = 0;                   //spare analog read
  volatile int8_t analog4b = 0;
  volatile int8_t digital1 = 0;                   //reward delivered (writes number of motor steps for reward)
  volatile int8_t digital2 = 0;                   //cue1
  volatile int8_t digital3 = 0;                   //cue2
  volatile int8_t digital4 = 0;                   //cue3
  volatile int8_t digital5 = 0;                   //houselight
  volatile int8_t digital6 = 0;                   //trialstate
  volatile int8_t digital7 = 0;                   //trialblock
  volatile int8_t digital8 = 0;                   //spare digital
  volatile int8_t digital9 = 0;                   //spare digital
  volatile int8_t digital10 = 0;                  //spare digital
  volatile int8_t timestamp1 = 0;                 //timestamp
  volatile int8_t timestamp2 = 0;
  volatile int8_t timestamp3 = 0;
  volatile int8_t timestamp4 = 0;
  volatile int8_t writeFlag = 0;                  //flag to start writing csv file in Processing
};


void logAndDisplayData() {                                  //this is the interrupt that reads sensors, packs data and sends them through Serial3

  timestamp = millis() - sessionStartTime;                  //take timestamp

  datastore data;                                    //the struct is the information packet that is sent to the computer
  data.header1;                                             //it needs headers so that Processing knows where the packet starts
  data.header2;
  if (analogInputsNeeded >= 1) {
    analog1read = analogRead(analog1pin);
    data.analog1a = ((analog1read >> 8) & 0xff);
    data.analog1b = (analog1read & 0xff);
  }
  if (analogInputsNeeded >= 2) {
    analog2read = analogRead(analog2pin);
    data.analog2a = ((analog2read >> 8) & 0xff);
    data.analog2b = (analog2read & 0xff);
  }
  if (analogInputsNeeded >= 3) {
    analog3read = analogRead(analog3pin);
    data.analog3a = ((analog3read >> 8) & 0xff);
    data.analog3b = (analog3read & 0xff);
  }
  if (analogInputsNeeded >= 4) {
    analog4read = analogRead(analog4pin);
    data.analog4a = ((analog4read >> 8) & 0xff);
    data.analog4b = (analog4read & 0xff);
  }

  data.digital1 = (digitalValue1 & 0xff);
  data.digital2 = (digitalValue2 & 0xff);
  data.digital3 = (digitalValue3 & 0xff);
  data.digital4 = (digitalValue4 & 0xff);
  data.digital5 = (digitalValue5 & 0xff);
  data.digital6 = (digitalValue6 & 0xff);
  data.digital7 = (digitalValue7 & 0xff);
  data.digital8 = (digitalValue8 & 0xff);
  data.digital9 = (digitalValue9 & 0xff);
  data.digital10 = (digitalValue10 & 0xff);

  data.timestamp1 = ((timestamp >> 24) & 0xff);
  data.timestamp2 = ((timestamp >> 16) & 0xff);
  data.timestamp3 = ((timestamp >> 8) & 0xff);
  data.timestamp4 = (timestamp & 0xff);
  data.writeFlag = (writeFlag_main & 0xff);

  Serial3.write((const uint8_t *)&data, sizeof(data));        // with just one call to Serial3.write(), we can now send the information packet through the serial, casting it as a byte array
}


void setup() {
  Serial3.begin(115200);
  
  samplingFreq = 1000000 / samplingFreq;
  Timer3.initialize();
  Timer3.setPeriod(samplingFreq);
  Timer3.attachInterrupt(logAndDisplayData);
}

void loop() {

}
