include $(TOOLS_DIR)/make/viv_ip_builder.mak

LIB_IP_NCO_SRCS = $(IP_BUILD_DIR)/nco/nco.xci

LIB_IP_NCO_OUTS = $(addprefix $(IP_BUILD_DIR)/nco/, \
nco.xci.out \
synth/nco.vhd \
)

$(LIB_IP_NCO_SRCS) $(LIB_IP_NCO_OUTS) : $(RFNOC_OOTEXAMPLE_DIR)/ip/nco/nco.xci
	$(call BUILD_VIVADO_IP,nco,$(ARCH),$(PART_ID),$(RFNOC_OOTEXAMPLE_DIR)/ip,$(IP_BUILD_DIR),0)
