module cm12_non_cm12_seam
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: cm12_invalid_argument, cm12_ok
    use cm12_prbas_dispatch, only: &
        cm12_apply_pnpwi_threshold_rescaling, cm12_begin_prbas_dispatch, &
        cm12_next_prbas_dispatch, &
        cm12_prbas_dispatch_event, cm12_prbas_dispatch_state, &
        cm12_record_prbas_formula_title
    use cm12_solution_kernel, only: &
        cm12_kinematics, cm12_solution, cm12_solution_multipole, &
        cm12_solution_summary
    implicit none
    private

    integer, parameter :: family_count = 6
    integer, parameter :: branch_count = 2
    integer, parameter :: partial_wave_count = 6
    integer, parameter :: parameter_count = 25
    character(len=4), parameter :: pntest_formula_title = 'SP00'

    integer, parameter, public :: cm12_max_hadronic_trace = &
        family_count * branch_count * partial_wave_count

    type, public :: cm12_prdlt_field_trace
        real(real32) :: z = 0.0_real32
        real(real32) :: qb = 0.0_real32
        real(real32) :: qk = 0.0_real32
        real(real32) :: zr = 0.0_real32
        real(real32) :: zb = 0.0_real32
        real(real32) :: brn = 0.0_real32
        real(real32) :: ter = 0.0_real32
        real(real32) :: tei = 0.0_real32
        real(real32) :: der = 0.0_real32
        real(real32) :: dei = 0.0_real32
    end type cm12_prdlt_field_trace

    type, public :: cm12_hadronic_trace
        type(cm12_prbas_dispatch_event) :: dispatch
        type(cm12_prdlt_field_trace) :: form
        character(len=4) :: formula_title = ''
        real(real32) :: hadronic_real = 0.0_real32
        real(real32) :: hadronic_imag = 0.0_real32
    end type cm12_hadronic_trace

    type, public :: cm12_background_grid_state
        private
        logical :: initialized = .false.
        integer :: reaction = 0
        character(len=64) :: solution_sha256 = ''
        type(cm12_prbas_dispatch_state) :: dispatch
    end type cm12_background_grid_state

    public :: cm12_begin_background_grid
    public :: cm12_finish_background_grid
    public :: cm12_prepare_non_cm12_multipoles

    interface
        subroutine pntest(energy, reaction, real_part, imag_part, title)
            import real32
            real(real32), intent(in) :: energy
            integer, intent(in) :: reaction
            real(real32), intent(out) :: real_part(4, 8)
            real(real32), intent(out) :: imag_part(4, 8)
            integer, intent(inout) :: title(13)
        end subroutine pntest

        subroutine qjofx(values, argument, maximum_l)
            import real32
            real(real32), intent(out) :: values(*)
            real(real32), intent(in) :: argument
            integer, intent(in) :: maximum_l
        end subroutine qjofx
    end interface

contains

    pure subroutine cm12_begin_background_grid( &
        solution, reaction, dispatch_state, grid_state, status, message)
        type(cm12_solution), intent(in) :: solution
        integer, intent(in) :: reaction
        type(cm12_prbas_dispatch_state), intent(in) :: dispatch_state
        type(cm12_background_grid_state), intent(out) :: grid_state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        integer :: explicit_records
        integer :: max_partial_wave
        character(len=4) :: solution_identifier
        character(len=64) :: source_sha256
        character(len=72) :: solution_title
        character(len=1024) :: source_path

        grid_state = cm12_background_grid_state()
        if (reaction < 1 .or. reaction > 4) then
            status = cm12_invalid_argument
            message = 'background grid requires pion reaction 1..4'
            return
        end if
        call cm12_solution_summary( &
            solution, solution_identifier, solution_title, source_path, &
            source_sha256, explicit_records, max_partial_wave)
        if (len_trim(source_sha256) == 0) then
            status = cm12_invalid_argument
            message = 'background grid requires a loaded solution'
            return
        end if
        if (.not. dispatch_state%typed_process_valid) then
            status = cm12_invalid_argument
            message = 'typed PRBAS process state is invalidated'
            return
        end if
        grid_state%initialized = .true.
        grid_state%reaction = reaction
        grid_state%solution_sha256 = source_sha256
        grid_state%dispatch = dispatch_state
        status = cm12_ok
        message = ''
    end subroutine cm12_begin_background_grid

    pure subroutine cm12_finish_background_grid( &
        grid_state, dispatch_state, status, message)
        type(cm12_background_grid_state), intent(in) :: grid_state
        type(cm12_prbas_dispatch_state), intent(out) :: dispatch_state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        dispatch_state = cm12_prbas_dispatch_state()
        if (.not. grid_state%initialized) then
            status = cm12_invalid_argument
            message = 'background grid did not complete'
            return
        end if
        dispatch_state = grid_state%dispatch
        status = cm12_ok
        message = ''
    end subroutine cm12_finish_background_grid

    subroutine cm12_prepare_non_cm12_multipoles( &
        solution, reaction, kinematics, born_multipoles, opec_multipoles, &
        multipoles, status, message, trace, trace_count, grid_state)
        type(cm12_solution), intent(in) :: solution
        integer, intent(in) :: reaction
        type(cm12_kinematics), intent(in) :: kinematics
        real(real32), intent(in) :: born_multipoles( &
            family_count, branch_count, partial_wave_count)
        real(real32), intent(in) :: opec_multipoles( &
            family_count, branch_count, partial_wave_count)
        complex(real32), intent(out) :: multipoles( &
            family_count, branch_count, partial_wave_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message
        type(cm12_hadronic_trace), intent(out), optional :: trace(:)
        integer, intent(out), optional :: trace_count
        type(cm12_background_grid_state), intent(inout), optional :: grid_state

        real(real32) :: pion_real(4, 8)
        real(real32) :: pion_imag(4, 8)
        real(real32) :: parameters_grid( &
            parameter_count, family_count, branch_count, partial_wave_count)
        real(real32) :: formula_energy
        real(real32) :: formula_born_multipole
        real(real32) :: hadronic_real
        real(real32) :: hadronic_imag
        integer :: pion_title(13)
        integer :: family
        integer :: branch
        integer :: orbital_l
        integer :: form_selector
        integer :: explicit_records
        integer :: max_partial_wave
        integer :: current_trace_count
        integer :: required_trace_count
        integer :: form_selector_grid( &
            family_count, branch_count, partial_wave_count)
        character(len=4) :: formula_title
        character(len=4) :: solution_identifier
        character(len=64) :: source_sha256
        character(len=72) :: solution_title
        character(len=1024) :: source_path
        type(cm12_prbas_dispatch_event) :: dispatch
        type(cm12_prbas_dispatch_state) :: dispatch_state
        type(cm12_prbas_dispatch_state) :: next_dispatch_state
        type(cm12_prdlt_field_trace) :: form_trace

        multipoles = cmplx(0.0_real32, 0.0_real32, kind=real32)
        pion_real = 0.0_real32
        pion_imag = 0.0_real32
        pion_title = 0
        current_trace_count = 0
        required_trace_count = 0
        form_selector_grid = 0
        parameters_grid = 0.0_real32
        if (present(trace)) trace = cm12_hadronic_trace()
        if (present(trace_count)) trace_count = 0
        if (reaction < 1 .or. reaction > 4) then
            status = cm12_invalid_argument
            message = 'non-CM12 preparation requires pion reaction 1..4'
            return
        end if
        if ( &
            .not. ieee_is_finite(kinematics%final_meson_energy_mev) .or. &
            kinematics%final_meson_energy_mev <= 0.0_real32 .or. &
            .not. ieee_is_finite(kinematics%photon_cm_momentum_mev) .or. &
            kinematics%photon_cm_momentum_mev <= 0.0_real32 .or. &
            .not. ieee_is_finite(kinematics%meson_cm_momentum_mev) .or. &
            kinematics%meson_cm_momentum_mev <= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'non-CM12 preparation requires physical kinematics'
            return
        end if

        call cm12_solution_summary( &
            solution, solution_identifier, solution_title, source_path, &
            source_sha256, explicit_records, max_partial_wave)
        if (present(grid_state)) then
            if (grid_state%initialized) then
                if ( &
                    grid_state%reaction /= reaction .or. &
                    grid_state%solution_sha256 /= source_sha256) then
                    status = cm12_invalid_argument
                    message = &
                        'background grid state provenance does not match request'
                    return
                end if
                dispatch_state = grid_state%dispatch
            else
                call cm12_begin_prbas_dispatch( &
                    solution_title, dispatch_state, status, message)
                if (status /= cm12_ok) return
            end if
        else
            call cm12_begin_prbas_dispatch( &
                solution_title, dispatch_state, status, message)
            if (status /= cm12_ok) return
        end if

        ! Resolve every selector and trace requirement before PNTTEST can
        ! mutate its retained internal cache.
        do family = 1, family_count
            do branch = 1, branch_count
                do orbital_l = 0, partial_wave_count - 1
                    call cm12_solution_multipole( &
                        solution, family, branch, orbital_l, &
                        form_selector_grid(family, branch, orbital_l + 1), &
                        parameters_grid( &
                            :, family, branch, orbital_l + 1), &
                        status, message)
                    if (status /= cm12_ok) return
                    form_selector = &
                        form_selector_grid(family, branch, orbital_l + 1)
                    if (form_selector == 0) cycle
                    if (form_selector > 100 .and. form_selector < 200) cycle
                    if ( &
                        form_selector /= 3 .and. &
                        form_selector /= 21 .and. &
                        form_selector /= 25) then
                        status = cm12_invalid_argument
                        message = 'unsupported retained non-CM12 form'
                        return
                    end if
                    required_trace_count = required_trace_count + 1
                end do
            end do
        end do
        if (present(trace)) then
            if (size(trace) < required_trace_count) then
                status = cm12_invalid_argument
                message = 'hadronic trace buffer is too small'
                return
            end if
        end if

        do family = 1, family_count
            do branch = 1, branch_count
                do orbital_l = 0, partial_wave_count - 1
                    form_selector = &
                        form_selector_grid(family, branch, orbital_l + 1)
                    if (form_selector == 0) cycle
                    if (form_selector > 100 .and. form_selector < 200) cycle
                    current_trace_count = current_trace_count + 1
                    call cm12_next_prbas_dispatch( &
                        dispatch_state, family, branch, orbital_l, &
                        form_selector, kinematics%final_meson_energy_mev, &
                        dispatch, next_dispatch_state, status, message)
                    if (status /= cm12_ok) return
                    dispatch_state = next_dispatch_state
                    formula_title = ''
                    hadronic_real = 0.0_real32
                    hadronic_imag = 0.0_real32
                    if (dispatch%dispatch) then
                        formula_energy = dispatch%effective_energy_mev
                        ! PNTEST retains an internal cache; that frozen formula
                        ! state is the remaining hidden boundary at this seam.
                        pion_title = 0
                        pion_title(1) = transfer( &
                            pntest_formula_title, pion_title(1))
                        call pntest( &
                            formula_energy, 0, pion_real, pion_imag, pion_title)
                        hadronic_real = pion_real( &
                            dispatch%state_index, dispatch%legacy_l)
                        hadronic_imag = pion_imag( &
                            dispatch%state_index, dispatch%legacy_l)
                        call cm12_apply_pnpwi_threshold_rescaling( &
                            dispatch%input_energy_mev, dispatch%orbital_l, &
                            hadronic_real, hadronic_imag)
                        formula_title = transfer(pion_title(1), formula_title)
                        call cm12_record_prbas_formula_title( &
                            dispatch_state, formula_title, next_dispatch_state, &
                            status, message)
                        if (status /= cm12_ok) return
                        dispatch_state = next_dispatch_state
                    end if
                    formula_born_multipole = &
                        born_multipoles(family, branch, orbital_l + 1)
                    if (.not. dispatch%dispatch) then
                        formula_born_multipole = 0.0_real32
                    end if
                    call evaluate_legacy_form( &
                        form_selector, &
                        parameters_grid(:, family, branch, orbital_l + 1), &
                        orbital_l, dispatch%pre_reset_energy_mev, &
                        dispatch%input_energy_mev, kinematics, &
                        formula_born_multipole, &
                        opec_multipoles(family, branch, orbital_l + 1), &
                        hadronic_real, hadronic_imag, &
                        multipoles(family, branch, orbital_l + 1), form_trace)
                    if (present(trace)) then
                        trace(current_trace_count)%dispatch = dispatch
                        trace(current_trace_count)%form = form_trace
                        trace(current_trace_count)%formula_title = formula_title
                        trace(current_trace_count)%hadronic_real = hadronic_real
                        trace(current_trace_count)%hadronic_imag = hadronic_imag
                    end if
                end do
            end do
        end do
        if (present(grid_state)) then
            grid_state%initialized = .true.
            grid_state%reaction = reaction
            grid_state%solution_sha256 = source_sha256
            grid_state%dispatch = dispatch_state
        end if
        if (present(trace_count)) trace_count = current_trace_count
        status = cm12_ok
        message = ''
    end subroutine cm12_prepare_non_cm12_multipoles

    subroutine evaluate_legacy_form( &
        form_selector, parameters, orbital_l, &
        pre_reset_pion_lab_energy, pion_lab_energy, kinematics, &
        born_multipole, opec_multipole, hadronic_real, hadronic_imag, &
        adjusted_multipole, field_trace)
        integer, intent(in) :: form_selector
        real(real32), intent(in) :: parameters(parameter_count)
        integer, intent(in) :: orbital_l
        real(real32), intent(in) :: pre_reset_pion_lab_energy
        real(real32), intent(in) :: pion_lab_energy
        type(cm12_kinematics), intent(in) :: kinematics
        real(real32), intent(in) :: born_multipole
        real(real32), intent(in) :: opec_multipole
        real(real32), intent(in) :: hadronic_real
        real(real32), intent(in) :: hadronic_imag
        complex(real32), intent(out) :: adjusted_multipole
        type(cm12_prdlt_field_trace), intent(out) :: field_trace

        real(real32), parameter :: expansion_pion_mass = 135.04_real32
        real(real32), parameter :: charged_pion_mass = 139.65_real32
        real(real32), parameter :: proton_mass = 938.256_real32
        real(real32), parameter :: degrees_to_radians = 0.0174532_real32

        real(real32) :: q_values(10)
        real(real32) :: virtual_pion_momentum
        real(real32) :: momentum_ratio
        real(real32) :: expansion
        real(real32) :: polynomial_real
        real(real32) :: polynomial_rescattering
        real(real32) :: argument
        real(real32) :: scale
        real(real32) :: real_part
        real(real32) :: imag_part
        real(real32) :: previous_imag
        real(real32) :: rotation
        real(real32) :: magnitude
        real(real32) :: phase
        real(real32) :: cosine
        real(real32) :: sine
        integer :: base_form
        integer :: rotation_form
        integer :: legacy_l
        integer :: extra_power

        field_trace = cm12_prdlt_field_trace()

        legacy_l = orbital_l + 1

        base_form = mod(form_selector, 10)
        rotation_form = form_selector / 10
        expansion = pre_reset_pion_lab_energy / expansion_pion_mass
        if (base_form > 4) then
            expansion = pre_reset_pion_lab_energy / &
                (800.0_real32 + pre_reset_pion_lab_energy)
        end if
        virtual_pion_momentum = proton_mass * sqrt( &
            pion_lab_energy * &
            (pion_lab_energy + 2.0_real32 * charged_pion_mass) / &
            ((charged_pion_mass + proton_mass) ** 2 + &
                2.0_real32 * proton_mass * pion_lab_energy))
        momentum_ratio = &
            virtual_pion_momentum / kinematics%photon_cm_momentum_mev
        field_trace%z = expansion
        field_trace%qb = virtual_pion_momentum
        field_trace%qk = momentum_ratio

        polynomial_rescattering = 0.0_real32
        if (virtual_pion_momentum > 0.0_real32) then
            polynomial_rescattering = expansion * ( &
                parameters(6) + expansion * ( &
                    parameters(7) + expansion * parameters(8)))
            polynomial_rescattering = &
                (polynomial_rescattering + parameters(5)) * &
                expansion_pion_mass / virtual_pion_momentum
            if (legacy_l > 1) then
                polynomial_rescattering = polynomial_rescattering * &
                    (1.0_real32 / momentum_ratio) ** (legacy_l - 1)
            end if
        end if

        if (base_form <= 2) then
            polynomial_real = expansion * ( &
                parameters(2) + expansion * ( &
                    parameters(3) + expansion * parameters(4)))
            polynomial_real = polynomial_real + parameters(1)
            if (legacy_l > 1) then
                polynomial_real = polynomial_real * &
                    momentum_ratio ** (legacy_l - 1)
            end if
        else
            argument = sqrt( &
                kinematics%meson_cm_momentum_mev ** 2 + &
                (2.0_real32 * expansion_pion_mass) ** 2) / &
                kinematics%meson_cm_momentum_mev
            call qjofx(q_values, argument, 8)
            polynomial_real = &
                parameters(1) * q_values(legacy_l) + &
                parameters(2) * q_values(legacy_l + 1)
            polynomial_real = argument * ( &
                polynomial_real + &
                parameters(3) * q_values(legacy_l + 2) + &
                parameters(4) * q_values(legacy_l + 3))
        end if

        extra_power = 0
        if (base_form == 2 .or. base_form == 3) extra_power = 2
        if (base_form == 5) extra_power = 4
        if (extra_power > 0) then
            scale = momentum_ratio ** extra_power
            polynomial_rescattering = polynomial_rescattering * scale
            polynomial_real = polynomial_real * scale
        end if

        field_trace%zr = polynomial_rescattering
        field_trace%zb = polynomial_real
        field_trace%brn = born_multipole
        field_trace%ter = hadronic_real
        field_trace%tei = hadronic_imag
        polynomial_real = polynomial_real + born_multipole
        real_part = &
            polynomial_real * (1.0_real32 - hadronic_imag) + &
            polynomial_rescattering * hadronic_real
        imag_part = &
            polynomial_real * hadronic_real + &
            polynomial_rescattering * hadronic_imag
        field_trace%der = real_part
        field_trace%dei = imag_part

        rotation = &
            hadronic_imag - hadronic_real ** 2 - hadronic_imag ** 2
        if (rotation > 0.0_real32) then
            if (rotation_form == 2 .or. rotation_form == 3) then
                if (rotation_form == 3) rotation = sqrt(rotation)
                real_part = real_part + rotation * ( &
                    parameters(9) + expansion * parameters(10))
                imag_part = imag_part + rotation * ( &
                    parameters(11) + expansion * parameters(12))
            else
                rotation = rotation * ( &
                    parameters(9) + expansion * parameters(10)) * &
                    degrees_to_radians
                if (rotation /= 0.0_real32) then
                    cosine = cos(rotation)
                    sine = sin(rotation)
                    previous_imag = imag_part
                    imag_part = &
                        previous_imag * cosine + real_part * sine
                    real_part = &
                        cosine * real_part - sine * previous_imag
                end if
            end if
        end if

        magnitude = sqrt(real_part ** 2 + imag_part ** 2)
        scale = 1.0_real32
        if (magnitude > 0.0_real32) then
            scale = 1.0_real32 + parameters(15) / magnitude
        end if
        real_part = scale * real_part
        imag_part = scale * imag_part
        phase = degrees_to_radians * parameters(16)
        if ( &
            hadronic_imag - hadronic_real ** 2 - hadronic_imag ** 2 < &
            0.0001_real32) then
            phase = 0.0_real32
        end if
        cosine = cos(phase)
        sine = sin(phase)
        previous_imag = imag_part
        imag_part = previous_imag * cosine + real_part * sine
        real_part = cosine * real_part - sine * previous_imag

        adjusted_multipole = cmplx( &
            real_part - opec_multipole, imag_part, kind=real32)
    end subroutine evaluate_legacy_form

end module cm12_non_cm12_seam
