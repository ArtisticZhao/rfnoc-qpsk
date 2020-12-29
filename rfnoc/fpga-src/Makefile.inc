RFNOC_SRCS += $(addprefix $(RFNOC_OOTEXAMPLE_DIR)/fpga-src/, \
    noc_block_qpsk.v \
    polar_costas.v   \
    loop_filter.v    \
    BitSync.v \
    syncout.v \
    clktrans.v \
    differpd.v \
    monostable.v \
    controldivfreq.v \
    keep_one_in_n_desample.v \
    keep_one_in_n_zip.v \
)
