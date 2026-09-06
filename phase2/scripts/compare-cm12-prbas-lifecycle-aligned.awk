BEGIN {
    FS = OFS = "\t"
}

function normalized_title(value, result) {
    result = value
    gsub(/_+$/, "", result)
    if (result == "BLANK") result = ""
    if (result == "" || result == "NA") return result
    return result
}

NR == FNR {
    if (FNR == 1) next
    row = $3
    typed_family[row] = $4
    typed_branch[row] = $5
    typed_l[row] = $7
    typed_state[row] = $8
    typed_selector[row] = $9
    typed_dispatch[row] = $10
    typed_dispatch_branch[row] = $11
    typed_title[row] = normalized_title($13)
    typed_previous[row] = normalized_title($14)
    typed_pre_reset[row] = $15
    typed_post_reset[row] = $16
    typed_input[row] = $17
    typed_effective[row] = $18
    typed_dither[row] = $19
    typed_hadronic_real[row] = $30
    typed_hadronic_imag[row] = $31
    next
}

FNR == 1 {
    print "row_id", "family", "branch", "legacy_l", "state_index", \
        "form_selector", "typed_dispatch", "legacy_dispatch", \
        "typed_title", "legacy_title", "typed_previous", \
        "legacy_previous", "typed_pre_reset", "legacy_pre_reset", \
        "typed_post_reset", "legacy_post_reset", "typed_input", \
        "legacy_epxx", "typed_effective", "legacy_effective", \
        "typed_dither", "legacy_dither", "typed_hadronic_real", \
        "legacy_hadronic_real", "typed_hadronic_imag", \
        "legacy_hadronic_imag", "exact", "first_field"
    next
}

{
    row = $2
    legacy_title = normalized_title($15)
    legacy_previous = normalized_title($16)
    first_field = ""
    if ($3 != typed_family[row]) first_field = "family"
    else if ($4 != typed_branch[row]) first_field = "branch"
    else if ($5 != typed_l[row]) first_field = "legacy_l"
    else if ($8 != typed_state[row]) first_field = "state_index"
    else if ($9 != typed_selector[row]) first_field = "form_selector"
    else if ($10 != typed_pre_reset[row]) first_field = "pre_reset_energy"
    else if ($11 != typed_post_reset[row]) first_field = "post_reset_energy"
    else if ($13 != typed_dispatch[row]) first_field = "dispatch"
    else if ($13 == "F" && typed_dispatch_branch[row] != 0) \
        first_field = "suppressed_dispatch_branch"
    else if ($13 == "F" && typed_title[row] != "") \
        first_field = "suppressed_dispatch_title"
    else if ($13 == "F" && typed_previous[row] != "") \
        first_field = "suppressed_previous_title"
    else if ($13 == "F" && typed_input[row] != 0) \
        first_field = "suppressed_input_energy"
    else if ($13 == "F" && typed_effective[row] != 0) \
        first_field = "suppressed_effective_energy"
    else if ($13 == "F" && typed_dither[row] != 0) \
        first_field = "suppressed_dither"
    else if ($13 == "F" && typed_hadronic_real[row] != 0) \
        first_field = "suppressed_hadronic_real"
    else if ($13 == "F" && typed_hadronic_imag[row] != 0) \
        first_field = "suppressed_hadronic_imag"
    else if ($13 == "T" && $14 != typed_dispatch_branch[row]) \
        first_field = "dispatch_branch"
    else if ($13 == "T" && legacy_title != typed_title[row]) \
        first_field = "dispatch_title"
    else if ($13 == "T" && legacy_previous != typed_previous[row]) \
        first_field = "previous_title"
    else if ($13 == "T" && $12 != typed_input[row]) \
        first_field = "input_energy"
    else if ($13 == "T" && $17 != typed_effective[row]) \
        first_field = "effective_energy"
    else if ($13 == "T" && $18 != typed_dither[row]) \
        first_field = "dither"
    else if ($13 == "T" && $19 != typed_hadronic_real[row]) \
        first_field = "hadronic_real"
    else if ($13 == "T" && $20 != typed_hadronic_imag[row]) \
        first_field = "hadronic_imag"

    print row, $3, $4, $5, $8, $9, typed_dispatch[row], $13, \
        typed_title[row], legacy_title, typed_previous[row], \
        legacy_previous, typed_pre_reset[row], $10, \
        typed_post_reset[row], $11, typed_input[row], $12, \
        typed_effective[row], $17, typed_dither[row], $18, \
        typed_hadronic_real[row], $19, typed_hadronic_imag[row], $20, \
        (first_field == "" ? "yes" : "no"), \
        (first_field == "" ? "NA" : first_field)
}
