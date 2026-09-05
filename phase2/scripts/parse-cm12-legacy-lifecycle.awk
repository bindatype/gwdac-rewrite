BEGIN {
    OFS = "\t"
}

index($0, "CM12DIAG PRDLT") && !index($0, "CM12DIAG PRDLT FIELDS") {
    start = index($0, "CM12DIAG PRDLT")
    count = split(substr($0, start), field)
    row = field[3]
    if (row == 1) sequence++
    key = sequence SUBSEP row
    maximum_row[sequence] = row
    family[key] = field[4]
    branch[key] = field[5]
    legacy_l[key] = field[6]
    rotation_form[key] = field[7]
    base_form[key] = field[8]
    state_index[key] = field[9]
    form_selector[key] = 10 * field[7] + field[8]
    epx[key] = field[10]
    epxx[key] = field[11]
}

index($0, "CM12DIAG PNPWI DISPATCH") {
    start = index($0, "CM12DIAG PNPWI DISPATCH")
    count = split(substr($0, start), field)
    row = field[4]
    key = sequence SUBSEP row
    dispatch_branch[key] = field[10]
    dispatch_title[key] = field[11]
    previous_title[key] = "BLANK"
    if (count == 15) previous_title[key] = field[12]
    effective_energy[key] = field[count - 1]
    dither_before[key] = field[count]
}

index($0, "CM12DIAG PNPWI RESULT") {
    start = index($0, "CM12DIAG PNPWI RESULT")
    count = split(substr($0, start), field)
    row = field[4]
    key = sequence SUBSEP row
    hadronic_real[key] = field[11]
    hadronic_imag[key] = field[12]
}

END {
    print "sequence", "row_id", "family", "branch", "legacy_l", \
        "rotation_form", "base_form", "state_index", "form_selector", \
        "epx", "epxx", "dispatch", "dispatch_branch", \
        "dispatch_title", "previous_title", "effective_energy", \
        "dither_before", "hadronic_real", "hadronic_imag"
    for (current_sequence = 1; current_sequence <= sequence; \
        current_sequence++) {
        for (row = 1; row <= maximum_row[current_sequence]; row++) {
            key = current_sequence SUBSEP row
            dispatched = (dispatch_branch[key] == "" ? "F" : "T")
            if (dispatched == "F") {
                dispatch_branch[key] = "NA"
                dispatch_title[key] = "NA"
                previous_title[key] = "NA"
                effective_energy[key] = "NA"
                dither_before[key] = "NA"
                hadronic_real[key] = "NA"
                hadronic_imag[key] = "NA"
            }
            print current_sequence, row, family[key], branch[key], \
                legacy_l[key], rotation_form[key], base_form[key], \
                state_index[key], form_selector[key], epx[key], epxx[key], \
                dispatched, dispatch_branch[key], dispatch_title[key], \
                previous_title[key], effective_energy[key], \
                dither_before[key], hadronic_real[key], hadronic_imag[key]
        }
    }
}
