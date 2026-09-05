BEGIN {
    OFS = "\t"
    print "call_id", "energy_index", "row_id", "family", "branch", \
        "orbital_l", "legacy_l", "state_index", "form_selector", \
        "dispatch", "dispatch_branch", "formula_title", \
        "dispatch_title", "previous_title", "pre_reset_energy", \
        "input_energy", "effective_energy", "dither_before", "z", \
        "qb", "qk", "zr", "zb", "born", "ter", "tei", "der", \
        "dei", "hadronic_real", "hadronic_imag"
}

index($0, "CM12TYPED ROW ") {
    start = index($0, "CM12TYPED ROW ")
    count = split(substr($0, start), field)
    if (count != 32) {
        print "unexpected CM12TYPED ROW field count: " count > "/dev/stderr"
        exit 2
    }
    for (i = 3; i <= count; i++) {
        printf "%s%s", field[i], (i == count ? ORS : OFS)
    }
}
