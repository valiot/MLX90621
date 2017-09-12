int MOSFET = 9;


void setup(){
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(MOSFET, OUTPUT);

}

void loop(){
  analogWrite(MOSFET, 0);
  digitalWrite(LED_BUILTIN, LOW);
  delay(2000);
  analogWrite(MOSFET, 64);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(2000);
  analogWrite(MOSFET, 128);
  digitalWrite(LED_BUILTIN, LOW);
  delay(2000);
  analogWrite(MOSFET, 192);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(2000);
  analogWrite(MOSFET, 255);
  digitalWrite(LED_BUILTIN, LOW);
  delay(2000);
  analogWrite(MOSFET, 128);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(2000);
  analogWrite(MOSFET, 64);
  digitalWrite(LED_BUILTIN, LOW);
  delay(2000);
  analogWrite(MOSFET, 32);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(2000);
}
