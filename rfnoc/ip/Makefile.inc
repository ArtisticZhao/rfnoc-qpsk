include $(RFNOC_OOTEXAMPLE_DIR)/ip/nco/Makefile.inc
include $(RFNOC_OOTEXAMPLE_DIR)/ip/cmpy_0/Makefile.inc
include $(RFNOC_OOTEXAMPLE_DIR)/ip/c_addsub_0/Makefile.inc
include $(RFNOC_OOTEXAMPLE_DIR)/ip/add_pre_phase/Makefile.inc


LIB_OOT_IP_XCI_SRCS = \
$(LIB_IP_NCO_SRCS) \
$(LIB_IP_CMPY_0_SRCS) \
$(LIB_IP_C_ADDSUB_0_SRCS) \
$(LIB_IP_ADD_PRE_PHASE_SRCS)


LIB_OOT_IP_SYNTH_OUTPUTS = \
$(LIB_IP_NCO_OUTS) \
$(LIB_IP_CMPY_0_OUTS) \
$(LIB_IP_C_ADDSUB_0_OUTS) \
$(LIB_IP_ADD_PRE_PHASE_OUTS)

LIB_IP_XCI_SRCS += $(LIB_OOT_IP_XCI_SRCS)
