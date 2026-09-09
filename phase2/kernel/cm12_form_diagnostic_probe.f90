program cm12_form_diagnostic_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: &
        cm12_dataset, cm12_evaluate_multipole, cm12_ok, load_cm12_dataset
    use cm12_solution_kernel, only: &
        cm12_accumulate_multipole, cm12_evaluate_dsg, cm12_solution, &
        cm12_solution_multipole, load_cm12_solution
    use cm12_request_kernel, only: &
        cm12_evaluate_request, cm12_prepare_legacy_background, &
        cm12_prepared_background, cm12_request, cm12_request_result
    implicit none

    integer, parameter :: family_count = 6
    integer, parameter :: branch_count = 2
    integer, parameter :: partial_wave_count = 6
    integer, parameter :: amplitude_count = 4
    integer, parameter :: reaction = 2
    real(real32), parameter :: photon_lab_energy_mev = 1000.0_real32
    real(real32), parameter :: angle_cm_deg = 90.0_real32

    type(cm12_dataset) :: dataset
    type(cm12_solution) :: solution
    type(cm12_request) :: request
    type(cm12_prepared_background) :: background
    type(cm12_request_result) :: current_result
    character(len=1024) :: solution_path
    character(len=1024) :: dataset_root
    character(len=1024) :: form_trace_path
    character(len=1024) :: summary_path
    character(len=64) :: solution_sha256
    character(len=32) :: oracle_dsg_display
    character(len=32) :: replayed_dsg_display
    character(len=32) :: candidate_dsg_display
    character(len=32) :: current_dsg_display
    character(len=512) :: message
    character(len=32) :: disposition
    character(len=32) :: classification
    character(len=1024) :: header
    integer :: selector(family_count, branch_count, partial_wave_count)
    real(real32) :: legacy_real( &
        family_count, branch_count, partial_wave_count)
    real(real32) :: legacy_imag( &
        family_count, branch_count, partial_wave_count)
    real(real32) :: legacy_delta_real( &
        amplitude_count, family_count, branch_count, partial_wave_count)
    real(real32) :: legacy_delta_imag( &
        amplitude_count, family_count, branch_count, partial_wave_count)
    logical :: legacy_seen(family_count, branch_count, partial_wave_count)
    complex(real32) :: full_amplitudes(amplitude_count)
    complex(real32) :: candidate_amplitudes(amplitude_count)
    complex(real32) :: next_amplitudes(amplitude_count)
    complex(real32) :: before_amplitudes(amplitude_count)
    complex(real32) :: scalar_multipole
    complex(real32) :: adjusted_multipole
    complex(real32) :: legacy_multipole
    complex(real32) :: legacy_final(amplitude_count)
    real(real32) :: parameters(25)
    real(real32) :: legacy_initial(amplitude_count)
    real(real32) :: legacy_final_real(amplitude_count)
    real(real32) :: legacy_final_imag(amplitude_count)
    real(real32) :: full_dsg
    real(real32) :: candidate_dsg
    real(real32) :: legacy_row_delta_real(amplitude_count)
    real(real32) :: legacy_row_delta_imag(amplitude_count)
    real(real32) :: replay_delta_real(amplitude_count)
    real(real32) :: replay_delta_imag(amplitude_count)
    real(real32) :: candidate_delta_real(amplitude_count)
    real(real32) :: candidate_delta_imag(amplitude_count)
    integer :: unit
    integer :: ios
    integer :: status
    integer :: family
    integer :: branch
    integer :: orbital_l
    integer :: form_selector
    integer :: k
    integer :: active_forms
    integer :: cm12_forms
    integer :: non_cm12_forms
    integer :: applicable_non_cm12_forms
    integer :: exact_cm12_multipoles
    integer :: exact_non_cm12_multipoles
    integer :: exact_replayed_deltas
    integer :: exact_candidate_deltas
    logical :: applicable
    logical :: multipole_exact
    logical :: delta_exact
    logical :: candidate_delta_exact
    logical :: initial_exact
    logical :: full_amplitudes_exact
    logical :: full_dsg_exact
    logical :: candidate_amplitudes_exact
    logical :: candidate_dsg_exact
    logical :: request_result_exact

    if (command_argument_count() /= 6) then
        write(*, '(a)') &
            'usage: cm12-form-diagnostic-probe SOLUTION SHA256 KCM_ROOT ' // &
            'FORM_TRACE SUMMARY ORACLE_DSG_DISPLAY'
        stop 64
    end if
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)
    call get_command_argument(3, dataset_root)
    call get_command_argument(4, form_trace_path)
    call get_command_argument(5, summary_path)
    call get_command_argument(6, oracle_dsg_display)

    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1
    call load_cm12_dataset(trim(dataset_root), dataset, status, message)
    if (status /= cm12_ok) stop 2
    request = cm12_request( &
        reaction=reaction, &
        photon_lab_energy_mev=photon_lab_energy_mev, &
        angle_cm_deg=angle_cm_deg)
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message)
    if (status /= cm12_ok) stop 3
    call cm12_evaluate_request( &
        solution, dataset, request, background, current_result, &
        status, message)
    if (status /= cm12_ok) stop 4

    selector = 0
    legacy_real = 0.0_real32
    legacy_imag = 0.0_real32
    legacy_delta_real = 0.0_real32
    legacy_delta_imag = 0.0_real32
    legacy_seen = .false.
    open( &
        newunit=unit, file=trim(form_trace_path), status='old', &
        action='read', iostat=ios)
    if (ios /= 0) stop 5
    read(unit, '(a)', iostat=ios) header
    if (ios /= 0) stop 6
    do
        read(unit, *, iostat=ios) &
            family, branch, orbital_l, form_selector, &
            legacy_real(family, branch, orbital_l + 1), &
            legacy_imag(family, branch, orbital_l + 1), &
            (legacy_delta_real(k, family, branch, orbital_l + 1), &
                legacy_delta_imag(k, family, branch, orbital_l + 1), &
                k=1, amplitude_count)
        if (ios < 0) exit
        if (ios > 0) stop 7
        selector(family, branch, orbital_l + 1) = form_selector
        legacy_seen(family, branch, orbital_l + 1) = .true.
    end do
    close(unit)

    open( &
        newunit=unit, file=trim(summary_path), status='old', &
        action='read', iostat=ios)
    if (ios /= 0) stop 8
    read(unit, '(a)', iostat=ios) header
    if (ios /= 0) stop 9
    read(unit, *, iostat=ios) &
        legacy_initial, &
        (legacy_final_real(k), legacy_final_imag(k), k=1, amplitude_count)
    close(unit)
    if (ios /= 0) stop 10
    legacy_final = cmplx( &
        legacy_final_real, legacy_final_imag, kind=real32)

    initial_exact = all( &
        background%initial_amplitudes == &
        cmplx(legacy_initial, 0.0_real32, kind=real32))
    full_amplitudes = background%initial_amplitudes
    candidate_amplitudes = background%initial_amplitudes
    active_forms = 0
    cm12_forms = 0
    non_cm12_forms = 0
    applicable_non_cm12_forms = 0
    exact_cm12_multipoles = 0
    exact_non_cm12_multipoles = 0
    exact_replayed_deltas = 0
    exact_candidate_deltas = 0

    write(*, '(a)') &
        'family' // achar(9) // 'branch' // achar(9) // 'orbital_l' // &
        achar(9) // 'selector' // achar(9) // 'classification' // &
        achar(9) // 'disposition' // achar(9) // 'legacy_real' // &
        achar(9) // 'legacy_imag' // achar(9) // 'kernel_real' // &
        achar(9) // 'kernel_imag' // achar(9) // 'multipole_exact' // &
        achar(9) // 'replay_delta_exact' // achar(9) // &
        'candidate_delta_exact'
    do family = 1, family_count
        do branch = 1, branch_count
            do orbital_l = 0, partial_wave_count - 1
                call cm12_solution_multipole( &
                    solution, family, branch, orbital_l, form_selector, &
                    parameters, status, message)
                if (status /= cm12_ok) stop 11
                if (form_selector == 0) cycle
                active_forms = active_forms + 1
                applicable = family <= 4
                if (form_selector > 100 .and. form_selector < 200) then
                    classification = 'cm12-1xx'
                    cm12_forms = cm12_forms + 1
                else
                    classification = 'non-1xx'
                    non_cm12_forms = non_cm12_forms + 1
                    if (applicable) then
                        applicable_non_cm12_forms = &
                            applicable_non_cm12_forms + 1
                    end if
                end if

                multipole_exact = .true.
                delta_exact = .true.
                candidate_delta_exact = .true.
                scalar_multipole = cmplx( &
                    0.0_real32, 0.0_real32, kind=real32)
                adjusted_multipole = scalar_multipole
                if (.not. applicable) then
                    disposition = 'channel-skip'
                else
                    if (.not. legacy_seen(family, branch, orbital_l + 1)) then
                        stop 12
                    end if
                    legacy_multipole = cmplx( &
                        legacy_real(family, branch, orbital_l + 1), &
                        legacy_imag(family, branch, orbital_l + 1), &
                        kind=real32)
                    before_amplitudes = full_amplitudes
                    call cm12_accumulate_multipole( &
                        solution, reaction, angle_cm_deg, family, branch, &
                        orbital_l, legacy_multipole, full_amplitudes, &
                        next_amplitudes, status, message)
                    if (status /= cm12_ok) stop 12
                    full_amplitudes = next_amplitudes
                    replay_delta_real = &
                        real(full_amplitudes - before_amplitudes, kind=real32)
                    replay_delta_imag = aimag( &
                        full_amplitudes - before_amplitudes)
                    legacy_row_delta_real = &
                        legacy_delta_real(:, family, branch, orbital_l + 1)
                    legacy_row_delta_imag = &
                        legacy_delta_imag(:, family, branch, orbital_l + 1)
                    delta_exact = &
                        all(replay_delta_real == legacy_row_delta_real) .and. &
                        all(replay_delta_imag == legacy_row_delta_imag)
                    if (delta_exact) then
                        exact_replayed_deltas = exact_replayed_deltas + 1
                    end if

                    if (classification == 'cm12-1xx') then
                        call cm12_evaluate_multipole( &
                            dataset, form_selector, parameters, &
                            family, branch, orbital_l, &
                            current_result%kinematics%w_cm_mev, &
                            background%production_born_multipoles( &
                                family, branch, orbital_l + 1), &
                            scalar_multipole, status, message)
                        if (status /= cm12_ok) stop 14
                        adjusted_multipole = scalar_multipole - cmplx( &
                            background%opec_multipoles( &
                                family, branch, orbital_l + 1), &
                            0.0_real32, kind=real32)
                        multipole_exact = &
                            adjusted_multipole == legacy_multipole
                        if (multipole_exact) then
                            exact_cm12_multipoles = &
                                exact_cm12_multipoles + 1
                        end if
                        disposition = 'kernel-applied'
                    else
                        adjusted_multipole = &
                            background%non_cm12_multipoles( &
                                family, branch, orbital_l + 1)
                        multipole_exact = &
                            adjusted_multipole == legacy_multipole
                        if (multipole_exact) then
                            exact_non_cm12_multipoles = &
                                exact_non_cm12_multipoles + 1
                        end if
                        disposition = 'prepared'
                    end if
                    if (.not. multipole_exact) then
                        write(*, '(a,3(i0,a),i0)') &
                            'first_divergence=', family, '/', branch, '/', &
                            orbital_l, '/multipole selector=', form_selector
                        stop 19
                    end if
                    before_amplitudes = candidate_amplitudes
                    call cm12_accumulate_multipole( &
                        solution, reaction, angle_cm_deg, family, branch, &
                        orbital_l, adjusted_multipole, candidate_amplitudes, &
                        next_amplitudes, status, message)
                    if (status /= cm12_ok) stop 15
                    candidate_amplitudes = next_amplitudes
                    candidate_delta_real = real( &
                        candidate_amplitudes - before_amplitudes, kind=real32)
                    candidate_delta_imag = aimag( &
                        candidate_amplitudes - before_amplitudes)
                    candidate_delta_exact = &
                        all(candidate_delta_real == legacy_row_delta_real) .and. &
                        all(candidate_delta_imag == legacy_row_delta_imag)
                    if (.not. candidate_delta_exact) then
                        write(*, '(a,3(i0,a),i0)') &
                            'first_divergence=', family, '/', branch, '/', &
                            orbital_l, '/contribution selector=', form_selector
                        stop 20
                    end if
                    exact_candidate_deltas = exact_candidate_deltas + 1
                end if

                write(*, &
                    '(3(i0,a),i0,a,a,a,a,a,4(es16.8,a),l1,a,l1,a,l1)') &
                    family, achar(9), branch, achar(9), orbital_l, achar(9), &
                    form_selector, achar(9), trim(classification), achar(9), &
                    trim(disposition), achar(9), &
                    legacy_real(family, branch, orbital_l + 1), achar(9), &
                    legacy_imag(family, branch, orbital_l + 1), achar(9), &
                    real(adjusted_multipole, kind=real32), achar(9), &
                    aimag(adjusted_multipole), achar(9), &
                    multipole_exact, achar(9), delta_exact, achar(9), &
                    candidate_delta_exact
            end do
        end do
    end do

    call cm12_evaluate_dsg( &
        current_result%kinematics%photon_lab_energy_mev, &
        current_result%kinematics%threshold_lab_energy_mev, &
        current_result%kinematics%photon_cm_momentum_mev, &
        current_result%kinematics%meson_cm_momentum_mev, &
        full_amplitudes, full_dsg, status, message)
    if (status /= cm12_ok) stop 17
    call cm12_evaluate_dsg( &
        current_result%kinematics%photon_lab_energy_mev, &
        current_result%kinematics%threshold_lab_energy_mev, &
        current_result%kinematics%photon_cm_momentum_mev, &
        current_result%kinematics%meson_cm_momentum_mev, &
        candidate_amplitudes, candidate_dsg, status, message)
    if (status /= cm12_ok) stop 18

    full_amplitudes_exact = all(full_amplitudes == legacy_final)
    candidate_amplitudes_exact = all(candidate_amplitudes == legacy_final)
    request_result_exact = &
        current_result%evaluated_multipoles == 40 .and. &
        all(current_result%amplitudes_mfm == legacy_final)
    write(replayed_dsg_display, '(e11.4)') full_dsg
    write(candidate_dsg_display, '(e11.4)') candidate_dsg
    write(current_dsg_display, '(e11.4)') &
        current_result%dsg_microbarn_per_sr
    full_dsg_exact = &
        trim(adjustl(replayed_dsg_display)) == &
        trim(adjustl(oracle_dsg_display))
    candidate_dsg_exact = &
        candidate_dsg == full_dsg .and. &
        current_result%dsg_microbarn_per_sr == full_dsg .and. &
        trim(adjustl(candidate_dsg_display)) == &
            trim(adjustl(oracle_dsg_display)) .and. &
        trim(adjustl(current_dsg_display)) == &
            trim(adjustl(oracle_dsg_display))
    write(*, '(a)') 'SUMMARY'
    write(*, '(a,i0)') 'active_forms=', active_forms
    write(*, '(a,i0)') 'cm12_forms=', cm12_forms
    write(*, '(a,i0)') 'non_cm12_forms=', non_cm12_forms
    write(*, '(a,i0)') &
        'applicable_non_cm12_forms=', applicable_non_cm12_forms
    write(*, '(a,i0)') &
        'exact_cm12_multipoles=', exact_cm12_multipoles
    write(*, '(a,i0)') &
        'exact_non_cm12_multipoles=', exact_non_cm12_multipoles
    write(*, '(a,i0)') &
        'exact_replayed_deltas=', exact_replayed_deltas
    write(*, '(a,i0)') &
        'exact_candidate_deltas=', exact_candidate_deltas
    write(*, '(a,l1)') 'initial_exact=', initial_exact
    write(*, '(a,l1)') 'full_amplitudes_exact=', full_amplitudes_exact
    write(*, '(a,l1)') 'full_dsg_exact=', full_dsg_exact
    write(*, '(a,l1)') &
        'candidate_amplitudes_exact=', candidate_amplitudes_exact
    write(*, '(a,l1)') 'candidate_dsg_exact=', candidate_dsg_exact
    write(*, '(a,l1)') 'request_result_exact=', request_result_exact
    write(*, '(a,8(es16.8,1x))') &
        'legacy_amplitudes=', &
        (real(legacy_final(family), kind=real32), &
            aimag(legacy_final(family)), family=1, amplitude_count)
    write(*, '(a,8(es16.8,1x))') &
        'replayed_all_amplitudes=', &
        (real(full_amplitudes(family), kind=real32), &
            aimag(full_amplitudes(family)), family=1, amplitude_count)
    write(*, '(a,8(es16.8,1x))') &
        'candidate_all_form_amplitudes=', &
        (real(candidate_amplitudes(family), kind=real32), &
            aimag(candidate_amplitudes(family)), &
            family=1, amplitude_count)
    write(*, '(a,8(es16.8,1x))') &
        'candidate_request_amplitudes=', &
        (real(current_result%amplitudes_mfm(family), kind=real32), &
            aimag(current_result%amplitudes_mfm(family)), &
            family=1, amplitude_count)
    write(*, '(a,a)') &
        'oracle_dsg_display=', trim(adjustl(oracle_dsg_display))
    write(*, '(a,es16.8)') 'replayed_all_dsg=', full_dsg
    write(*, '(a,a)') &
        'replayed_all_dsg_display=', trim(adjustl(replayed_dsg_display))
    write(*, '(a,es16.8)') 'candidate_all_form_dsg=', candidate_dsg
    write(*, '(a,a)') &
        'candidate_all_form_dsg_display=', &
        trim(adjustl(candidate_dsg_display))
    write(*, '(a,es16.8)') &
        'candidate_request_dsg=', &
        current_result%dsg_microbarn_per_sr
    write(*, '(a,a)') &
        'candidate_request_dsg_display=', &
        trim(adjustl(current_dsg_display))
    if ( &
        active_forms /= 60 .or. &
        cm12_forms /= 34 .or. &
        non_cm12_forms /= 26 .or. &
        applicable_non_cm12_forms /= 18 .or. &
        exact_cm12_multipoles /= 22 .or. &
        exact_non_cm12_multipoles /= 18 .or. &
        exact_replayed_deltas /= 40 .or. &
        exact_candidate_deltas /= 40 .or. &
        .not. initial_exact .or. &
        .not. full_amplitudes_exact .or. &
        .not. full_dsg_exact .or. &
        .not. candidate_amplitudes_exact .or. &
        .not. candidate_dsg_exact .or. &
        .not. request_result_exact) stop 21
end program cm12_form_diagnostic_probe
