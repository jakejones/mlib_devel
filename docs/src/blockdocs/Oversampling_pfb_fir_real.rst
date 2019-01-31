Oversampling Polyphase FIR Filter
==========================
| **Block:** Oversampling Polyphase FIR Filter (``oversampling_pfb_fir_real``)
| **Block Author**: Jake Jones
| **Document Author**: Jake Jones

+--------------------------------------------------------------------------+
| .. raw:: html                                                            |
|                                                                          |
|    <div id="toctitle">                                                   |
|                                                                          |
| .. rubric:: Contents                                                     |
|    :name: contents                                                       |
|                                                                          |
| .. raw:: html                                                            |
|                                                                          |
|    </div>                                                                |
|                                                                          |
| -  `Summary <#summary>`__                                                |
| -  `Mask Parameters <#mask-parameters>`__                                |
| -  `Ports <#ports>`__                                                    |
| -  `Description <#description>`__                                        |
|                                                                          |
|    -  `Usage <#usage>`__                                                 |
+--------------------------------------------------------------------------+

Summary 
--------

An oversampled PFB solves the problem of aliasing / scalloping loss at the channel edges by increasing the width of the channel while maintaining a constant channel separation. The overlapping parts of the channels are usually discarded during a second stage of fine pfb's. The filter response is designed such that the transition from passband to stopband occures within the redundant overlapping regions that are to be discarded later.

An oversampling PFB outputs data at a rate that is F times larger than the input rate, where F is the oversampling factor. Since the input data rate is usually 1 sample per clock tick, the output rate is increased by doubling the demux factor such that 2 samples in parallel are output every clock tick. However the data is only valid for a fraction (1/F) of the time, this results in an output datarate that is between 1 and 2 times the input rate (1 < F < 2). Unfortunately doubling the demux factor comes at the cost of twice as much DSP usage which is usually of short supply.


Mask Parameters 
-----------------

+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Parameter                        | Variable     | Description                                                                                                                                                                   |
+==================================+==============+===============================================================================================================================================================================+
| Number of channels               | N            | The total number of channels / the FFT size.                                                                                                                                  |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Number of taps                   | T            | The number of taps in the PFB. The coefficient window must be of length N*T.                                                                                                  |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Oversampling Factor              | F            | The oversampling factor is the fraction defined by (output_datarate / input_datarate). This determines how much wider the channels will be.                                   |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Number of Inputs                 | I            | The number of parallel input streams from the ADC.                                                                                                                            |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Demux Factor seen at input       | demux_in     | This is the number of samples received in parallel for each input stream. The demux factor on the output will be double this.                                                 |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Input Bitwidth                   | in_bits      | The bitwidth of the input data. Note it is assumed that the input data is of the form 'Fix_(in_bits)_(in_bits-1)'                                                             |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Output Bitwidth                  | out_bits     | The bitwidth that the output can grow to. The output is of the form 'Fix_(out_bits)_(out_bits-1)'                                                                             |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Coefficient Bitwidth             | c_bits       | The bitwidth of the coefficients that are stored in Read Only Memory.                                                                                                         |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Window Function                  | windowfunc   | A string (you must include surrounding quotes) of a function call that will return the PFB coefficients. Note it must return a window of length N*T. e.g. 'kaiser(512*8)'     |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Stop block from regenerating!    | done         | If the the tick box is checked the block will not regenerate when you click OK. Usefull when the design is large and things get slow.                                         |
+----------------------------------+--------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Ports 
-------

+-------------+-------+-------------+---------------------------------------------------------------------------+
| Port        | Dir   | Data Type   | Description                                                               |
+=============+=======+=============+===========================================================================+
| sync_in     | IN    | Boolean     | Indicates that this clock cycle contains valid data                       |
+-------------+-------+-------------+---------------------------------------------------------------------------+
| bus_in      | IN    | Inherited   | The (real) time-domain stream(s). Bus format = [in_0 in_1 ...]            |
+-------------+-------+-------------+---------------------------------------------------------------------------+
| sync_out    | OUT   | Boolean     | Indicates this clock cycle is the first of the valid data                 |
+-------------+-------+-------------+---------------------------------------------------------------------------+
| bus_out     | OUT   | Inherited   | Same as the input bus, except output datawidth is specified as mask param |
+-------------+-------+-------------+---------------------------------------------------------------------------+
| dvalid_out  | OUT   | Boolean     | Data is output in bursts with a duty cycle of (1/F)*100%.                 |
+-------------+-------+-------------+---------------------------------------------------------------------------+

Description 
------------
Usage 
^^^^^^

| This block expects a bus of inputs streams of the form [ in_0 in_1 ... in_I ] to be present on the bus_in port. Each input stream is itself a bus of size equal to the input demux factor, e.g. [ s(n) s(n+1) ... s(n+demux_in) ] where s(n) is time signal and n represents the samples in time (Note the sample that arived first is in the most significant slot of the bus). The raw time signal s(n) is expected to be a signed fixed point number of the form 'Fix_(in_bits)_(in_bits-1)'.

| The block considers the clock cycle following the sync pulse as the first data sample. Only one sync pulse is expected, in the event another sync pulse arives the block will reset itself which will interupt the output dvalid signals and will require the FFT block to be flushed and resynced also.









