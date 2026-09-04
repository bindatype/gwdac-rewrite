BEGIN {
    FS = OFS = "\t"
}

function candidate_title(value, normalized) {
    normalized = value
    sub(/^\[/, "", normalized)
    sub(/\]$/, "", normalized)
    sub(/[ ]+$/, "", normalized)
    if (normalized == "") return "BLANK"
    return normalized
}

NR == FNR {
    if (FNR == 1) next
    key = $1 SUBSEP $3
    candidate_energy[key] = $2
    candidate_family[key] = $4
    candidate_branch[key] = $5
    candidate_l[key] = $6
    candidate_state[key] = $7
    candidate_selector[key] = $8
    candidate_dispatch[key] = $9
    candidate_dispatch_title[key] = candidate_title($10)
    candidate_previous_title[key] = candidate_title($11)
    candidate_pre_reset[key] = $13
    candidate_input[key] = $14
    candidate_effective[key] = $15
    candidate_dither[key] = $16
    candidate_real[key] = $17
    candidate_imag[key] = $18
    next
}

FNR == 1 {
    print "point", "lab_energy", "row", "family", "branch", "legacy_l", \
        "state_index", "selector", "legacy_dispatch", "candidate_dispatch", \
        "legacy_title", "candidate_title", "legacy_previous", \
        "candidate_previous", "legacy_epx", "candidate_pre_reset", \
        "legacy_input", "candidate_input", \
        "legacy_effective", "candidate_effective", "legacy_dither", \
        "candidate_dither", "legacy_real", "candidate_real", \
        "legacy_imag", "candidate_imag", "exact", "first_field"
    next
}

{
    point = int(($1 - 1) / 26) + 1
    row = (($1 - 1) % 26) + 1
    key = point SUBSEP row
    legacy_dispatch = ($26 == "NA" ? "F" : "T")
    legacy_title = ($27 == "NA" ? "BLANK" : $27)
    legacy_previous = ($28 == "NA" ? "BLANK" : $28)
    first_field = ""

    if ($2 != candidate_family[key]) first_field = "family"
    else if ($3 != candidate_branch[key]) first_field = "branch"
    else if ($4 != candidate_l[key]) first_field = "legacy_l"
    else if ($7 != candidate_state[key]) first_field = "state_index"
    else if ($8 != candidate_selector[key]) first_field = "selector"
    else if (legacy_dispatch != candidate_dispatch[key]) first_field = "dispatch"
    else if (legacy_dispatch == "T" && \
        legacy_title != candidate_dispatch_title[key]) first_field = "dispatch_title"
    else if (legacy_dispatch == "T" && \
        legacy_previous != candidate_previous_title[key]) first_field = "previous_title"
    else if (legacy_dispatch == "T" && \
        $22 != candidate_input[key]) first_field = "input_energy"
    else if (legacy_dispatch == "T" && \
        $29 != candidate_effective[key]) first_field = "effective_energy"
    else if (legacy_dispatch == "T" && \
        $30 != candidate_dither[key]) first_field = "dither"
    else if (legacy_dispatch == "T" && \
        $31 != candidate_real[key]) first_field = "hadronic_real"
    else if (legacy_dispatch == "T" && \
        $32 != candidate_imag[key]) first_field = "hadronic_imag"

    print point, candidate_energy[key], row, $2, $3, $4, $7, $8, \
        legacy_dispatch, candidate_dispatch[key], legacy_title, \
        candidate_dispatch_title[key], legacy_previous, \
        candidate_previous_title[key], $9, candidate_pre_reset[key], \
        $22, candidate_input[key], $29, \
        candidate_effective[key], $30, candidate_dither[key], $31, \
        candidate_real[key], $32, candidate_imag[key], \
        (first_field == "" ? "T" : "F"), \
        (first_field == "" ? "NA" : first_field)
}
