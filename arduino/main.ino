#include <Arduino.h>

#define BAUDRATE 9600
#define SERIAL Serial
#define LED_PIN LED_BUILTIN

typedef struct {
  uint8_t code;
  uint8_t analog_id;
  uint16_t value;
} analog_result_t;

void setup() {
  SERIAL.begin(BAUDRATE);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
}

uint8_t read_byte() {
  while (!SERIAL.available());

  return SERIAL.read();
}

void set_led() {
  uint8_t state  = read_byte();

  if (state > 0) {
    digitalWrite(LED_PIN, HIGH);
  } else {
    digitalWrite(LED_PIN, LOW);
  }

  SERIAL.write('L');
  SERIAL.write(state);
  SERIAL.write(0);
  SERIAL.write(0);
}

void read_analog() {
  analog_result_t result;
  int analogPins[] = {A0, A1, A2, A3};
  uint8_t analog_id = read_byte();

  if (analog_id < 4) {
    result.code = 'A';
    result.analog_id = analog_id;
    result.value = analogRead(analogPins[analog_id]);

    SERIAL.write((uint8_t*)&result, sizeof(analog_result_t));
  }
}

void cmd() {
  uint8_t cmd = read_byte();

  switch(cmd) {
    case 'L':
      set_led();
      break;
    case 'A':
      read_analog();
      break;
    default:
      break;
  }
}

void loop() {
  if (SERIAL.available()) {
    cmd();
  }
}
