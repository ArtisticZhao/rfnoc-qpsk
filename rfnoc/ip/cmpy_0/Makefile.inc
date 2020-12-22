include $(TOOLS_DIR)/make/viv_ip_builder.mak

LIB_IP_CMPY_0_SRCS = $(IP_BUILD_DIR)/cmpy_0/cmpy_0.xci

LIB_IP_CMPY_0_OUTS = $(addprefix $(IP_BUILD_DIR)/cmpy_0/, \
cmpy_0.xci.out \
synth/cmpy_0.vhd \
)

$(LIB_IP_CMPY_0_SRCS) $(LIB_IP_CMPY_0_OUTS) : $(RFNOC_OOTEXAMPLE_DIR)/ip/cmpy_0/cmpy_0.xci
	$(call BUILD_VIVADO_IP,cmpy_0,$(ARCH),$(PART_ID),$(RFNOC_OOTEXAMPLE_DIR)/ip,$(IP_BUILD_DIR),0)
