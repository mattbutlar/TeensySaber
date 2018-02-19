#ifndef BUTTONS_LATCHING_BUTTON_H
#define BUTTONS_LATCHING_BUTTON_H

#include "debounced_button.h"

// Latching button
class LatchingButton : public Looper,
                       public CommandParser,
                       public DebouncedButton {
public:
  LatchingButton(enum BUTTON button, int pin, const char* name)
    : Looper(),
      CommandParser(),
      name_(name),
      button_(button),
      pin_(pin) {
    pinMode(pin, INPUT_PULLUP);
#ifdef ENABLE_SNOOZE
    snooze_digital.pinMode(pin, INPUT_PULLUP, RISING);
#endif
  }

  const char* name() override { return name_; }

protected:
  void Loop() override {
    STATE_MACHINE_BEGIN();
    while (true) {
      while (!DebouncedRead()) YIELD();
      saber.Event(button_, EVENT_LATCH_ON);
      while (DebouncedRead()) YIELD();
      saber.Event(button_, EVENT_LATCH_OFF);
    }
    STATE_MACHINE_END();
  }

  bool Parse(const char* cmd, const char* arg) override {
    if (!strcmp(cmd, name_)) {
      if (current_modifiers & button_) {
        saber.Event(button_, EVENT_LATCH_ON);
      } else {
        saber.Event(button_, EVENT_LATCH_OFF);
      }
      return true;
    }
    return false;
  }

  void Help() override {
    STDOUT.print(" ");
    STDOUT.print(name_);
    STDOUT.print(" - toggles the ");
    STDOUT.print(name_);
    STDOUT.println(" button");
  }

  bool Read() override {
    return digitalRead(pin_) == LOW;
  }

  const char* name_;
  enum BUTTON button_;
  StateMachineState state_machine_;
  uint8_t pin_;
};

#endif
