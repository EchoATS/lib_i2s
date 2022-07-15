// Copyright 2018-2021 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

/* A simple application example used for code snippets in the library
 * documentation.
 */
#include <platform.h>
#include <xs1.h>
#include "i2s.h"
#include <print.h>
#include <stdlib.h>

#define SAMPLE_FREQUENCY (192000)
#define MASTER_CLOCK_FREQUENCY (24576000)
#define DATA_BITS (32)

[[distributable]]
void my_application(server i2s_frame_callback_if i_i2s) {
  while (1) {
    select {
      case i_i2s.init(i2s_config_t &?i2s_config, tdm_config_t &?tdm_config):
        i2s_config.mode = I2S_MODE_LEFT_JUSTIFIED;
        // Complete setup
        break;
      case i_i2s.restart_check() -> i2s_restart_t restart:
        // Inform the I2S slave whether it should restart or exit
        restart = I2S_NO_RESTART;
        break;
      case i_i2s.receive(size_t num_in, int32_t samples[num_in]):
        // Handle a received sample
        break;
      case i_i2s.send(size_t num_out, int32_t samples[num_out]):
        // Provide a sample to send
        break;
    }
  }
}

out buffered port:32 p_dout[2] = {XS1_PORT_1D, XS1_PORT_1E};
in buffered port:32 p_din[2] = {XS1_PORT_1I, XS1_PORT_1J};
in port p_bclk = XS1_PORT_1A;
in buffered port:32 p_lrclk = XS1_PORT_1C;

clock bclk = XS1_CLKBLK_1;

int main(void) {
  interface i2s_frame_callback_if i_i2s;

  par {
    i2s_frame_slave(i_i2s, p_dout, 2, p_din, 2, DATA_BITS, p_bclk, p_lrclk, bclk);
    my_application(i_i2s);
  }
  return 0;
}

// end
