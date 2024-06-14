
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE0_Nano(
    //////////// CLOCK //////////
    input                      CLOCK_50,
    //////////// LED //////////
    output           [7:0]      LED,
    ////////// KEY SWITCHES
    input            [1:0]      KEY,
    input            [3:0]      SW,
    //////////// SDRAM //////////
    output          [12:0]      DRAM_ADDR,
    output           [1:0]      DRAM_BA,
    output                      DRAM_CAS_N,
    output                      DRAM_CKE,
    output                      DRAM_CLK,
    output                      DRAM_CS_N,
    inout           [15:0]      DRAM_DQ,
    output           [1:0]      DRAM_DQM,
    output                      DRAM_RAS_N,
    output                      DRAM_WE_N,
    //////////// EPCS //////////
    output                      EPCS_ASDO,
    input                       EPCS_DATA0,
    output                      EPCS_DCLK,
    output                      EPCS_NCSO,
    //////////// Accelerometer and EEPROM //////////
    output                      G_SENSOR_CS_N,
    input                       G_SENSOR_INT,
    output                      I2C_SCLK,
    inout                       I2C_SDAT,
    //////////// ADC //////////
    output                      ADC_CS_N,
    output                      ADC_SADDR,
    output                      ADC_SCLK,
    input                       ADC_SDAT,
    //////////// 2x13 GPIO Header //////////
    output           [2:0]      HDMI_OUT,
    output                      HDMI_CLK);

    assign LED = rgb[7:0];
    wire clk_pixel_x5;
    wire clk_pixel;
    wire clk_audio;
    hdmi_pll hdmi_pll(.inclk0(CLOCK_50), .c0(clk_pixel), .c1(clk_pixel_x5), .c2(clk_audio));

    localparam AUDIO_BIT_WIDTH = 16;
    localparam AUDIO_RATE = 48000;
    localparam WAVE_RATE = 480;

    logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word;
    logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word_dampened; // This is to avoid giving you a heart attack -- it'll be really loud if it uses the full dynamic range.
    assign audio_sample_word_dampened = audio_sample_word >> 9;

    //sawtooth #(.BIT_WIDTH(AUDIO_BIT_WIDTH), .SAMPLE_RATE(AUDIO_RATE), .WAVE_RATE(WAVE_RATE)) sawtooth (.clk_audio(clk_audio), .level(audio_sample_word));

    logic [23:0] rgb;// = 24'd523700000000;
    logic [9:0] cx, cy;
    hdmi #( .VIDEO_ID_CODE(4),
            .AUDIO_RATE(AUDIO_RATE),
            .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH))
        hdmi(.clk_pixel_x5(clk_pixel_x5),
             .clk_pixel(clk_pixel),
             .clk_audio(clk_audio),
             .rgb(rgb),
             .audio_sample_word('{audio_sample_word_dampened, audio_sample_word_dampened}),
             .tmds(HDMI_OUT),
             .tmds_clock(HDMI_CLK),
             .cx(cx),
             .cy(cy));

    logic [7:0] character = 8'h30;
    logic [5:0] prevcy = 6'd0;
    always @(posedge clk_pixel) begin
        if (cy == 10'd0) begin
            character <= 8'h30;
            prevcy <= 6'd0;
        end else if (prevcy != cy[9:4]) begin
            character <= character + 8'h01;
            prevcy <= cy[9:4];
        end
    end

    LFSR #(.NUM_BITS(24)) LSFR (
       .i_Clk(CLOCK_50),
       .i_Enable(1),
       .o_LFSR_Data(rgb)
    );

    //console console(.clk_pixel(clk_pixel), .codepoint(character), .attribute({cx[9], cy[8:6], cx[8:5]}), .cx(cx), .cy(cy), .rgb(rgb));

endmodule
