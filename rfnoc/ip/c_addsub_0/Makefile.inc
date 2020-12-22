include $(TOOLS_DIR)/make/viv_ip_builder.mak

LIB_IP_C_ADDSUB_0_SRCS = $(IP_BUILD_DIR)/c_addsub_0/c_addsub_0.xci

LIB_IP_C_ADDSUB_0_OUTS = $(addprefix $(IP_BUILD_DIR)/c_addsub_0/, \
c_addsub_0.xci.out \
synth/c_addsub_0.vhd \
)

$(LIB_IP_C_ADDSUB_0_SRCS) $(LIB_IP_C_ADDSUB_0_OUTS) : $(RFNOC_OOTEXAMPLE_DIR)/ip/c_addsub_0/c_addsub_0.xci
	$(call BUILD_VIVADO_IP,c_addsub_0,$(ARCH),$(PART_ID),$(RFNOC_OOTEXAMPLE_DIR)/ip,$(IP_BUILD_DIR),0)
