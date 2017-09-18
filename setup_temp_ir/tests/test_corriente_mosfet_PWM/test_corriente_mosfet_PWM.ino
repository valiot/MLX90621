int MOSFET = 9;
int current = A0;

void setup(){
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(MOSFET, OUTPUT);
  pinMode(current, INPUT);
}

void loop(){
  control_and_sense(0, 2000, 8);
  control_and_sense(64, 2000, 8);
  control_and_sense(128, 2000, 8);
  control_and_sense(192, 2000, 8);
  control_and_sense(255, 2000, 8);
  control_and_sense(128, 2000, 8);
  control_and_sense(64, 2000, 8);
  control_and_sense(32, 2000, 8);
}

void control_and_sense(int MOS_val, int duration, int steps){
  int step_delay = duration / steps;
  analogWrite(MOSFET, MOS_val);
  digitalWrite(LED_BUILTIN, MOS_val > 127 ? HIGH : LOW);
  for (int i = 0; i < steps; i++){
    delay(step_delay);
    Serial.print(MOS_val);
    Serial.print(" ");
    Serial.println(analogRead(current));
  }
}
