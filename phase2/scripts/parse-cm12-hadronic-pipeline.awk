BEGIN {
    OFS = "\t"
}

/CM12DIAG PRDLT/ {
    start = index($0, "CM12DIAG PRDLT")
    count = split(substr($0, start), field)
    row = field[3]
    maximum_row = row
    family[row] = field[4]
    branch[row] = field[5]
    legacy_l[row] = field[6]
    rotation_form[row] = field[7]
    base_form[row] = field[8]
    state_index[row] = field[9]
    form_selector[row] = 10 * field[7] + field[8]
    epx[row] = field[10]
    epxx[row] = field[11]
}

/CM12DIAG PNMOD/ {
    start = index($0, "CM12DIAG PNMOD")
    count = split(substr($0, start), field)
    row = field[3]
    pnmod_input_ll[row] = field[8]
    pnmod_derived_l[row] = field[9]
    pnmod_nfx[row] = field[10]
    pnmod_branch[row] = field[11]
    pnmod_pg1[row] = field[12]
    pnmod_pg2[row] = field[13]
    pnmod_pg3[row] = field[14]
    pnmod_tr_before[row] = field[15]
    pnmod_ti_before[row] = field[16]
    pnmod_tr_after[row] = field[17]
    pnmod_ti_after[row] = field[18]
}

/CM12DIAG PNPWI POSTMOD/ {
    start = index($0, "CM12DIAG PNPWI POSTMOD")
    count = split(substr($0, start), field)
    row = field[4]
    pnpwi_ein[row] = field[10]
    pnpwi_postmod_tr[row] = field[11]
    pnpwi_postmod_ti[row] = field[12]
    pnmod_early_return[row] = field[13]
}

/CM12DIAG PNPWI DISPATCH/ {
    start = index($0, "CM12DIAG PNPWI DISPATCH")
    count = split(substr($0, start), field)
    row = field[4]
    dispatch_n[row] = field[10]
    dispatch_title[row] = field[11]
    previous_title[row] = "BLANK"
    if (count == 15) {
        previous_title[row] = field[12]
    }
    effective_e[row] = field[count - 1]
    dither_before[row] = field[count]
}

/CM12DIAG PNPWI RESULT/ {
    start = index($0, "CM12DIAG PNPWI RESULT")
    count = split(substr($0, start), field)
    row = field[4]
    pnpwi_result_tr[row] = field[11]
    pnpwi_result_ti[row] = field[12]
}

/CM12DIAG ADDRESK PRE/ {
    start = index($0, "CM12DIAG ADDRESK PRE")
    count = split(substr($0, start), field)
    row = field[4]
    addresk_nf[row] = field[9]
    addresk_pg1[row] = field[10]
    addresk_pg2[row] = field[11]
    addresk_pg3[row] = field[12]
    addresk_pre_tr[row] = field[13]
    addresk_pre_ti[row] = field[14]
}

/CM12DIAG ADDRESK POST/ {
    start = index($0, "CM12DIAG ADDRESK POST")
    count = split(substr($0, start), field)
    row = field[4]
    addresk_post_tr[row] = field[13]
    addresk_post_ti[row] = field[14]
}

END {
    print "row_id", "family", "branch", "legacy_l", \
        "rotation_form", "base_form", "state_index", "form_selector", \
        "epx", "epxx", "pnmod_input_ll", "pnmod_derived_l", \
        "pnmod_nfx", "pnmod_branch", "pnmod_pg1", "pnmod_pg2", \
        "pnmod_pg3", "pnmod_tr_before", "pnmod_ti_before", \
        "pnmod_tr_after", "pnmod_ti_after", "pnpwi_ein", \
        "pnpwi_postmod_tr", "pnpwi_postmod_ti", \
        "pnmod_early_return", "dispatch_n", "dispatch_title", \
        "previous_title", "effective_e", "dither_before", \
        "pnpwi_result_tr", "pnpwi_result_ti", "addresk_nf", \
        "addresk_pg1", "addresk_pg2", "addresk_pg3", \
        "addresk_pre_tr", "addresk_pre_ti", "addresk_post_tr", \
        "addresk_post_ti"
    for (row = 1; row <= maximum_row; row++) {
        if (dispatch_n[row] == "") {
            dispatch_n[row] = "NA"
            dispatch_title[row] = "NA"
            previous_title[row] = "NA"
            effective_e[row] = "NA"
            dither_before[row] = "NA"
            pnpwi_result_tr[row] = "NA"
            pnpwi_result_ti[row] = "NA"
        }
        print row, family[row], branch[row], legacy_l[row], \
            rotation_form[row], base_form[row], state_index[row], \
            form_selector[row], epx[row], epxx[row], \
            pnmod_input_ll[row], pnmod_derived_l[row], pnmod_nfx[row], \
            pnmod_branch[row], pnmod_pg1[row], pnmod_pg2[row], \
            pnmod_pg3[row], pnmod_tr_before[row], pnmod_ti_before[row], \
            pnmod_tr_after[row], pnmod_ti_after[row], pnpwi_ein[row], \
            pnpwi_postmod_tr[row], pnpwi_postmod_ti[row], \
            pnmod_early_return[row], dispatch_n[row], dispatch_title[row], \
            previous_title[row], effective_e[row], dither_before[row], \
            pnpwi_result_tr[row], pnpwi_result_ti[row], addresk_nf[row], \
            addresk_pg1[row], addresk_pg2[row], addresk_pg3[row], \
            addresk_pre_tr[row], addresk_pre_ti[row], \
            addresk_post_tr[row], addresk_post_ti[row]
    }
}
