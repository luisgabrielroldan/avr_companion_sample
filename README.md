# AVRCompanionSample

This is an example application to show how to use [AVR](https://github.com/luisgabrielroldan/avr) to keep an arduino companion updated.

Usually in my projects I need hard realtime (e.g. Send/Receive IR signals) which is a complicated task to achieve with Nerves because you have the erlang scheduler plus the OS multitasking. So for those times where realtime is needed the simplest solution is to have hardware that supports it like an Arduino.

This is a Nerves project that uses [elixir_make](https://github.com/elixir-lang/elixir_make) to compile an Arduino sketch and include it on the release ( saved in the application priv folder).

The Arduino sketch receives commands through the serial port and can perform to tasks:
  - Read the Analog pins.
  - Set the builtin led state.

When the system boots up, `AVRCompanionSample.Arduino` starts calling the `AVR.update/4` to check and update (if necessary) the firmware on the device.

## Hardware

The hardware used for this example was a Raspberry Pi 3 and an Arduino Uno connected by USB.
It's also possible to use the RPI hardware serial port. For that is necessary to configure a GPIO pin to reset the arduino (Check AVR docs).

## Prequisites

To build the Arduino sketch you need to have [arduino-mk](https://github.com/sudar/Arduino-Makefile) installed.

## Environment vars

This vars can be useful depending on the system you have.

- `ARDMK_VENDOR`: Board vendor/maintainer/series.

For Arch Linux I'm using:
```
export ARDMK_VENDOR=archlinux-arduino
```
