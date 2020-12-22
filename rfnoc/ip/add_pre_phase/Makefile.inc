include $(TOOLS_DIR)/make/viv_ip_builder.mak

LIB_IP_ADD_PRE_PHASE_SRCS = $(IP_BUILD_DIR)/add_pre_phase/add_pre_phase.xci

LIB_IP_ADD_PRE_PHASE_OUTS = $(addprefix $(IP_BUILD_DIR)/add_pre_phase/, \
add_pre_phase.xci.out \
synth/add_pre_phase.vhd \
)

$(LIB_IP_ADD_PRE_PHASE_SRCS) $(LIB_IP_ADD_PRE_PHASE_OUTS) : $(RFNOC_OOTEXAMPLE_DIR)/ip/add_pre_phase/add_pre_phase.xci
	$(call BUILD_VIVADO_IP,add_pre_phase,$(ARCH),$(PART_ID),$(RFNOC_OOTEXAMPLE_DIR)/ip,$(IP_BUILD_DIR),0)
