int MOSFET = 9;


void setup(){
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(MOSFET, OUTPUT);

}

void loop(){
  digitalWrite(MOSFET, HIGH);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(2000);
  digitalWrite(MOSFET, LOW);
  digitalWrite(LED_BUILTIN, LOW);
  delay(2000);
}
