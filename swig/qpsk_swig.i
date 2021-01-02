/* -*- c++ -*- */

#define QPSK_API
#define ETTUS_API

%include "gnuradio.i"/*			*/// the common stuff

//load generated python docstrings
%include "qpsk_swig_doc.i"
//Header from gr-ettus
%include "ettus/device3.h"
%include "ettus/rfnoc_block.h"
%include "ettus/rfnoc_block_impl.h"

%{
#include "ettus/device3.h"
#include "ettus/rfnoc_block_impl.h"
#include "qpsk/qpsk.h"
#include "qpsk/slice.h"
%}

%include "qpsk/qpsk.h"
GR_SWIG_BLOCK_MAGIC2(qpsk, qpsk);
%include "qpsk/slice.h"
GR_SWIG_BLOCK_MAGIC2(qpsk, slice);
