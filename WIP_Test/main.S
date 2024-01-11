_start:
        ld a0, test_label
spin:
        j spin

test_label:     .dword 0x1000
