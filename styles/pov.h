#ifndef STYLES_POV_H
#define STYLES_POV_H

// TODO(hubbe): Make it work with FastLED
#if defined(ENABLE_WS2811)

// Usage: &style_pov
// return value: suitable for preset array

// This style draws "Star Wars" in the air if you swing the saber
// carefully back and forth. Unfortunately you can't really see
// the result without a slow exposure camera. It's possible that
// dotstar APA102 pixels would be fast enough to do the effect
// full justice, but I haven't tried that.

#include "star_wars_logo_pov_data.h"

void rle_decode(const unsigned char *input,
                 unsigned char *output,
                 int output_length) {
  int olen = 0;
  while (olen < output_length) {
    if (*input == 255) {
      int i;
      int offset = input[1]+1;
      int len = input[2];
      input += 3;
      for (i = 0; i < len; i++) {
         *output = output[-offset];
         output++;
         olen++;
      }
    }
    else if (*input < 128) {
      memcpy(output, input+1, *input + 1);
      output += *input + 1;
      olen += *input + 1;
      input += *input + 2;
    } else {
      memset(output, input[1], *input - 128 + 2);
      output += *input - 128 + 2;
      olen += *input - 128 + 2;
      input += 2;
    }
  }
}

// POV writer.
class StylePOV : public BladeStyle, public SaberBase {
public:
  StylePOV() : SaberBase(NOLINK) {
  }
  void activate() override {
    SaberBase::Link(this);
    STDOUT.println("POV Style");
  }
  void deactivate() override {
    SaberBase::Unlink(this);
  }
  Vec3 extrapolate_accel() {
    uint32_t now = micros();
    Vec3 sum(0.0, 0.0, 0.0);
    float sum_t = 0.0;
    for (size_t i = 0; i < NELEM(accel_entries_); i++) {
      float t = now - accel_entries_[i].t;
      sum_t += t;
      sum += accel_entries_[i].accel;
    }
    Vec3 avg = sum * (1.0 / NELEM(accel_entries_));
    float avg_t = sum_t / NELEM(accel_entries_);

    Vec3 dot_sum(0.0,0.0,0.0);
    float t_square_sum = 0.0;
    for (size_t i = 0; i < NELEM(accel_entries_); i++) {
      float t = (now - accel_entries_[i].t) - avg_t;
      Vec3 v = accel_entries_[i].accel - avg;
      t_square_sum += t * t;
      dot_sum += v * t;
    }
    Vec3 slope = dot_sum * (1.0 / t_square_sum);
#if 0
    STDOUT.print("SLOPE: ");
    STDOUT.print(slope.x * 100.0);
    STDOUT.print(", ");
    STDOUT.print(slope.y * 100.0);
    STDOUT.print(", ");
    STDOUT.println(slope.z * 100.0);
#endif
    return sum - slope * avg_t;
  }

  void SB_Accel(const Vec3& accel) override {
    entry_++;
    if (entry_ >= NELEM(accel_entries_)) entry_ = 0;
    accel_entries_[entry_].accel = accel;
    accel_entries_[entry_].t = micros();
  }

  void run(BladeBase* blade) override {
    Vec3 v = extrapolate_accel();
    float fraction = 0.5 - atan2f(v.y, v.x) * 2.0 / M_PI;
    // STDOUT.print("F:");
    // STDOUT.println(fraction);
    if (fraction < 0 || fraction > 1.0) {
      memset((unsigned char *)&MonopodWS2811::drawBuffer,
              0,
              maxLedsPerStrip * 3);
      return;
    }
    int col = fraction * NELEM(imageoffsets);
    rle_decode(imagedata + imageoffsets[col],
                (unsigned char *)&MonopodWS2811::drawBuffer,
                maxLedsPerStrip * 3);
    size_t num_leds = blade->num_leds();
    if (num_leds < maxLedsPerStrip) {
      for (size_t i = 0; i < maxLedsPerStrip; i++) {
         MonopodWS2811::drawBuffer[i] =
           MonopodWS2811::drawBuffer[i * maxLedsPerStrip / num_leds];
      }
    }
    blade->allow_disable();
  }
private:
  struct { uint32_t t; Vec3 accel; } accel_entries_[10];
  size_t entry_;
  Color8* data_;
  int width_;
  int height_;
};

StyleFactoryImpl<StylePOV> style_pov;
#endif

#endif
