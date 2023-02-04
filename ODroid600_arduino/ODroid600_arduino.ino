#include <SPI.h>
#include <SD.h>
long pt_A = A0;
long pt_B = A2;
long pt_C = A3;
long pt_D = A4;
long readingA = 0;
long readingB = 0;
long readingC = 0;
long readingD = 0;
int tempSens = A1;
int tempInput;
double temp;
File myFile;

void setup() {
  // put your setup code here, to run once:
pinMode(2, OUTPUT);
pinMode(3, OUTPUT);
pinMode(6, OUTPUT);
pinMode(7, OUTPUT);
pinMode(pt_A, INPUT); 
pinMode(pt_B, INPUT); 
pinMode(pt_C, INPUT); 
pinMode(pt_D, INPUT); 
Serial.begin(9600);
Serial.print("Initializing SD card...");
if (!SD.begin(4)) {
Serial.println("initialization failed!");
while (1);
}
Serial.println("initialization done.");
myFile = SD.open("log.txt", FILE_WRITE);
if (myFile) {
    Serial.print("Writing header to file...\n");
    myFile.println("minutes,transistor_value_A,transistor_value_B,transistor_value_C,transistor_value_D,temperature");
    // close the file:
    myFile.close();
    Serial.println("done writing header");
  } else {
    // if the file didn't open, print an error:
    Serial.println("error opening file");
  }

}

void loop() {
  // put your main code here, to run repeatedly:
digitalWrite(2,HIGH);
digitalWrite(3,HIGH);
digitalWrite(6,HIGH);
digitalWrite(7,HIGH);
delay(10);
long readingA_mean = 0;
long readingB_mean = 0;
long readingC_mean = 0;
long readingD_mean = 0;
for (int i=0; i < 100; i++) {
readingA_mean = readingA_mean + long(analogRead(pt_A));
readingB_mean = readingB_mean + long(analogRead(pt_B));
readingC_mean = readingC_mean + long(analogRead(pt_C));
readingD_mean = readingD_mean + long(analogRead(pt_D));
delay(100);
}
digitalWrite(2, LOW);
digitalWrite(3, LOW);
digitalWrite(6, LOW);
digitalWrite(7, LOW);
tempInput = analogRead(A1); //read the temperature
temp = (double)tempInput / 1024; //find percentage of input reading
temp = temp * 5; //multiply by 5V to get voltage
temp = temp - 0.5; //Subtract the offset
temp = temp * 100; //Convert to degrees
readingA_mean = readingA_mean/long(100);
readingB_mean = readingB_mean/long(100);
readingC_mean = readingC_mean/long(100);
readingD_mean = readingD_mean/long(100);
Serial.println(readingA_mean);
Serial.println(String(millis()*1.66667e-5)+','+ String(readingA_mean)+','+String(readingB_mean)+','+String(readingC_mean)+','+String(readingD_mean)+','+String(temp));
myFile = SD.open("log.txt", FILE_WRITE);
myFile.println(String(millis()*1.66667e-5)+','+ String(readingA_mean)+','+String(readingB_mean)+','+String(readingC_mean)+','+String(readingD_mean)+','+String(temp));
myFile.close();
delay(60000); // take a reading every 60 seconds

}
