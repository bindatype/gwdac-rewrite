module cm12_request_kernel
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: &
        cm12_dataset, cm12_dataset_is_loaded, cm12_evaluate_multipole, &
        cm12_invalid_argument, cm12_ok
    use cm12_solution_kernel, only: &
        cm12_background_constants, cm12_calculate_kinematics, &
        cm12_domain_error, cm12_evaluate_dsg, cm12_kinematics, cm12_solution, &
        cm12_solution_background, cm12_solution_is_loaded, &
        cm12_solution_multipole, cm12_accumulate_multipole
    use cm12_background_seam, only: cm12_evaluate_background
    use cm12_non_cm12_seam, only: cm12_prepare_non_cm12_multipoles
    implicit none
    private

    integer, parameter :: family_count = 6
    integer, parameter :: branch_count = 2
    integer, parameter :: partial_wave_count = 6
    integer, parameter :: amplitude_count = 4

    type, public :: cm12_request
        integer :: reaction = 0
        real(real32) :: photon_lab_energy_mev = 0.0_real32
        real(real32) :: angle_cm_deg = 0.0_real32
    end type cm12_request

    type, public :: cm12_prepared_background
        real(real32) :: born_multipoles( &
            family_count, branch_count, partial_wave_count) = 0.0_real32
        real(real32) :: opec_multipoles( &
            family_count, branch_count, partial_wave_count) = 0.0_real32
        complex(real32) :: non_cm12_multipoles( &
            family_count, branch_count, partial_wave_count) = &
            cmplx(0.0_real32, 0.0_real32, kind=real32)
        complex(real32) :: initial_amplitudes(amplitude_count) = &
            cmplx(0.0_real32, 0.0_real32, kind=real32)
    end type cm12_prepared_background

    type, public :: cm12_request_result
        type(cm12_kinematics) :: kinematics
        complex(real32) :: amplitudes_mfm(amplitude_count) = &
            cmplx(0.0_real32, 0.0_real32, kind=real32)
        real(real32) :: dsg_microbarn_per_sr = 0.0_real32
        integer :: evaluated_multipoles = 0
    end type cm12_request_result

    public :: cm12_prepare_legacy_background
    public :: cm12_evaluate_request

contains

    subroutine cm12_prepare_legacy_background( &
        solution, request, background, status, message)
        type(cm12_solution), intent(in) :: solution
        type(cm12_request), intent(in) :: request
        type(cm12_prepared_background), intent(out) :: background
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        type(cm12_background_constants) :: constants
        type(cm12_kinematics) :: kinematics

        background = cm12_prepared_background()
        call cm12_solution_background( &
            solution, constants, status, message)
        if (status /= cm12_ok) return

        ! This is the single remaining hidden-state boundary. The frozen
        ! formulas exchange explicit values here but still use /GOMEGA/
        ! internally; cm12_evaluate_request never crosses that boundary.
        call cm12_evaluate_background( &
            constants, request%photon_lab_energy_mev, &
            request%angle_cm_deg, request%reaction, &
            background%born_multipoles, background%opec_multipoles, &
            background%initial_amplitudes, status, message)
        if (status /= cm12_ok) return
        call cm12_calculate_kinematics( &
            request%reaction, request%photon_lab_energy_mev, &
            kinematics, status, message)
        if (status /= cm12_ok) return
        call cm12_prepare_non_cm12_multipoles( &
            solution, request%reaction, kinematics, &
            background%opec_multipoles, &
            background%non_cm12_multipoles, status, message)
    end subroutine cm12_prepare_legacy_background

    pure subroutine cm12_evaluate_request( &
        solution, dataset, request, background, result, status, message)
        type(cm12_solution), intent(in) :: solution
        type(cm12_dataset), intent(in) :: dataset
        type(cm12_request), intent(in) :: request
        type(cm12_prepared_background), intent(in) :: background
        type(cm12_request_result), intent(out) :: result
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        complex(real32) :: accumulated(amplitude_count)
        complex(real32) :: multipole
        complex(real32) :: adjusted_multipole
        real(real32) :: parameters(25)
        integer :: family
        integer :: branch
        integer :: orbital_l
        integer :: form_selector

        result = cm12_request_result()
        if (.not. cm12_solution_is_loaded(solution)) then
            status = cm12_invalid_argument
            message = 'CM12 request requires a loaded solution'
            return
        end if
        if (.not. cm12_dataset_is_loaded(dataset)) then
            status = cm12_invalid_argument
            message = 'CM12 request requires a loaded dataset'
            return
        end if
        if ( &
            .not. ieee_is_finite(request%angle_cm_deg) .or. &
            request%angle_cm_deg < 0.0_real32 .or. &
            request%angle_cm_deg > 180.0_real32) then
            status = cm12_invalid_argument
            message = 'center-of-mass angle must be in 0..180 degrees'
            return
        end if
        call cm12_calculate_kinematics( &
            request%reaction, request%photon_lab_energy_mev, &
            result%kinematics, status, message)
        if (status /= cm12_ok) return
        if ( &
            request%photon_lab_energy_mev <= &
            result%kinematics%threshold_lab_energy_mev) then
            status = cm12_domain_error
            message = 'CM12 request is at or below the reaction threshold'
            return
        end if
        if ( &
            any(.not. ieee_is_finite(background%born_multipoles)) .or. &
            any(.not. ieee_is_finite(background%opec_multipoles)) .or. &
            any(.not. ieee_is_finite( &
                real(background%initial_amplitudes, kind=real32))) .or. &
            any(.not. ieee_is_finite( &
                aimag(background%initial_amplitudes))) .or. &
            any(.not. ieee_is_finite( &
                real(background%non_cm12_multipoles, kind=real32))) .or. &
            any(.not. ieee_is_finite( &
                aimag(background%non_cm12_multipoles)))) then
            status = cm12_invalid_argument
            message = 'prepared CM12 background must be finite'
            return
        end if

        result%amplitudes_mfm = background%initial_amplitudes
        do family = 1, family_count
            if ( &
                request%reaction < 3 .and. family > 4 .or. &
                request%reaction > 2 .and. &
                    (family == 3 .or. family == 4)) cycle
            do branch = 1, branch_count
                do orbital_l = 0, partial_wave_count - 1
                    call cm12_solution_multipole( &
                        solution, family, branch, orbital_l, &
                        form_selector, parameters, status, message)
                    if (status /= cm12_ok) return
                    if (form_selector == 0) cycle

                    if ( &
                        form_selector > 100 .and. &
                        form_selector < 200) then
                        call cm12_evaluate_multipole( &
                            dataset, form_selector, parameters, &
                            family, branch, orbital_l, &
                            result%kinematics%w_cm_mev, &
                            background%born_multipoles( &
                                family, branch, orbital_l + 1), &
                            multipole, status, message)
                        if (status /= cm12_ok) return
                        adjusted_multipole = multipole - cmplx( &
                            background%opec_multipoles( &
                                family, branch, orbital_l + 1), &
                            0.0_real32, kind=real32)
                    else
                        adjusted_multipole = &
                            background%non_cm12_multipoles( &
                                family, branch, orbital_l + 1)
                    end if
                    call cm12_accumulate_multipole( &
                        solution, request%reaction, request%angle_cm_deg, &
                        family, branch, orbital_l, adjusted_multipole, &
                        result%amplitudes_mfm, accumulated, status, message)
                    if (status /= cm12_ok) return
                    result%amplitudes_mfm = accumulated
                    result%evaluated_multipoles = &
                        result%evaluated_multipoles + 1
                end do
            end do
        end do

        call cm12_evaluate_dsg( &
            result%kinematics%photon_lab_energy_mev, &
            result%kinematics%threshold_lab_energy_mev, &
            result%kinematics%photon_cm_momentum_mev, &
            result%kinematics%meson_cm_momentum_mev, &
            result%amplitudes_mfm, result%dsg_microbarn_per_sr, &
            status, message)
    end subroutine cm12_evaluate_request

end module cm12_request_kernel
