module cm12_background_seam
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: cm12_invalid_argument, cm12_ok
    use cm12_solution_kernel, only: cm12_background_constants
    implicit none
    private

    real(real32) :: legacy_omega_vector
    real(real32) :: legacy_omega_tensor
    real(real32) :: legacy_omega_model
    real(real32) :: legacy_pion_coupling
    real(real32) :: legacy_rho_vector
    real(real32) :: legacy_rho_tensor
    integer :: legacy_reaction_control
    real(real32) :: legacy_cutoff_mev
    common /gomega/ &
        legacy_omega_vector, legacy_omega_tensor, legacy_omega_model, &
        legacy_pion_coupling, legacy_rho_vector, legacy_rho_tensor, &
        legacy_reaction_control, legacy_cutoff_mev

    public :: cm12_evaluate_born_multipoles
    public :: cm12_evaluate_background
    public :: cm12_evaluate_initial_amplitudes
    public :: cm12_evaluate_production_born_multipoles

    interface
        subroutine prborn(energy, multipoles, form)
            import real32
            real(real32), intent(in) :: energy
            real(real32), intent(out) :: multipoles(6, 2, 6)
            integer, intent(in) :: form
        end subroutine prborn

        subroutine propec(energy, multipoles)
            import real32
            real(real32), intent(in) :: energy
            real(real32), intent(out) :: multipoles(6, 2, 6)
        end subroutine propec

        subroutine hopec(energy, angle, reaction, amplitudes)
            import real32
            real(real32), intent(in) :: energy
            real(real32), intent(in) :: angle
            integer, intent(in) :: reaction
            real(real32), intent(out) :: amplitudes(4)
        end subroutine hopec
    end interface

contains

    subroutine cm12_evaluate_born_multipoles( &
        constants, photon_lab_energy_mev, born_multipoles, &
        opec_multipoles, status, message)
        type(cm12_background_constants), intent(in) :: constants
        real(real32), intent(in) :: photon_lab_energy_mev
        real(real32), intent(out) :: born_multipoles(6, 2, 6)
        real(real32), intent(out) :: opec_multipoles(6, 2, 6)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        born_multipoles = 0.0_real32
        opec_multipoles = 0.0_real32
        if ( &
            .not. ieee_is_finite(photon_lab_energy_mev) .or. &
            photon_lab_energy_mev <= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'Born laboratory energy must be finite and positive'
            return
        end if
        if (.not. valid_constants(constants)) then
            status = cm12_invalid_argument
            message = 'Born/background constants must be finite'
            return
        end if

        call set_legacy_constants(constants)
        call propec(photon_lab_energy_mev, opec_multipoles)
        call prborn(photon_lab_energy_mev, born_multipoles, 5)
        status = cm12_ok
        message = ''
    end subroutine cm12_evaluate_born_multipoles

    subroutine cm12_evaluate_production_born_multipoles( &
        constants, photon_lab_energy_mev, born_multipoles, status, message)
        type(cm12_background_constants), intent(in) :: constants
        real(real32), intent(in) :: photon_lab_energy_mev
        real(real32), intent(out) :: born_multipoles(6, 2, 6)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        born_multipoles = 0.0_real32
        if ( &
            .not. ieee_is_finite(photon_lab_energy_mev) .or. &
            photon_lab_energy_mev <= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'Production Born energy must be finite and positive'
            return
        end if
        if (.not. valid_constants(constants)) then
            status = cm12_invalid_argument
            message = 'Born/background constants must be finite'
            return
        end if

        call set_legacy_constants(constants)
        call prborn(photon_lab_energy_mev, born_multipoles, 5)
        status = cm12_ok
        message = ''
    end subroutine cm12_evaluate_production_born_multipoles

    subroutine cm12_evaluate_background( &
        constants, photon_lab_energy_mev, angle_cm_deg, reaction, &
        born_multipoles, opec_multipoles, initial_amplitudes, &
        status, message)
        type(cm12_background_constants), intent(in) :: constants
        real(real32), intent(in) :: photon_lab_energy_mev
        real(real32), intent(in) :: angle_cm_deg
        integer, intent(in) :: reaction
        real(real32), intent(out) :: born_multipoles(6, 2, 6)
        real(real32), intent(out) :: opec_multipoles(6, 2, 6)
        complex(real32), intent(out) :: initial_amplitudes(4)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        initial_amplitudes = cmplx(0.0_real32, 0.0_real32, kind=real32)
        if (reaction < 1 .or. reaction > 4) then
            born_multipoles = 0.0_real32
            opec_multipoles = 0.0_real32
            status = cm12_invalid_argument
            message = 'background pion reaction must be in 1..4'
            return
        end if
        if ( &
            .not. ieee_is_finite(angle_cm_deg) .or. &
            angle_cm_deg < 0.0_real32 .or. angle_cm_deg > 180.0_real32) then
            born_multipoles = 0.0_real32
            opec_multipoles = 0.0_real32
            status = cm12_invalid_argument
            message = 'background angle must be in 0..180 degrees'
            return
        end if

        call cm12_evaluate_born_multipoles( &
            constants, photon_lab_energy_mev, born_multipoles, &
            opec_multipoles, status, message)
        if (status /= cm12_ok) return
        call cm12_evaluate_initial_amplitudes( &
            constants, photon_lab_energy_mev, angle_cm_deg, reaction, &
            initial_amplitudes, status, message)
    end subroutine cm12_evaluate_background

    subroutine cm12_evaluate_initial_amplitudes( &
        constants, photon_lab_energy_mev, angle_cm_deg, reaction, &
        initial_amplitudes, status, message)
        type(cm12_background_constants), intent(in) :: constants
        real(real32), intent(in) :: photon_lab_energy_mev
        real(real32), intent(in) :: angle_cm_deg
        integer, intent(in) :: reaction
        complex(real32), intent(out) :: initial_amplitudes(4)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        real(real32) :: legacy_amplitudes(4)

        initial_amplitudes = cmplx(0.0_real32, 0.0_real32, kind=real32)
        if (reaction < 1 .or. reaction > 4) then
            status = cm12_invalid_argument
            message = 'background pion reaction must be in 1..4'
            return
        end if
        if ( &
            .not. ieee_is_finite(photon_lab_energy_mev) .or. &
            photon_lab_energy_mev <= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'background energy must be finite and positive'
            return
        end if
        if ( &
            .not. ieee_is_finite(angle_cm_deg) .or. &
            angle_cm_deg < 0.0_real32 .or. angle_cm_deg > 180.0_real32) then
            status = cm12_invalid_argument
            message = 'background angle must be in 0..180 degrees'
            return
        end if
        if (.not. valid_constants(constants)) then
            status = cm12_invalid_argument
            message = 'Born/background constants must be finite'
            return
        end if

        call set_legacy_constants(constants)
        call hopec( &
            photon_lab_energy_mev, angle_cm_deg, reaction, &
            legacy_amplitudes)
        initial_amplitudes = cmplx( &
            legacy_amplitudes, 0.0_real32, kind=real32)
        status = cm12_ok
        message = ''
    end subroutine cm12_evaluate_initial_amplitudes

    subroutine set_legacy_constants(constants)
        type(cm12_background_constants), intent(in) :: constants

        legacy_omega_vector = constants%omega_vector
        legacy_omega_tensor = constants%omega_tensor
        legacy_omega_model = constants%omega_model
        legacy_pion_coupling = constants%pion_coupling
        legacy_rho_vector = constants%rho_vector
        legacy_rho_tensor = constants%rho_tensor
        legacy_reaction_control = constants%reaction_control
        legacy_cutoff_mev = constants%cutoff_mev
    end subroutine set_legacy_constants

    logical function valid_constants(constants)
        type(cm12_background_constants), intent(in) :: constants

        valid_constants = &
            ieee_is_finite(constants%pion_coupling) .and. &
            ieee_is_finite(constants%omega_vector) .and. &
            ieee_is_finite(constants%omega_tensor) .and. &
            ieee_is_finite(constants%omega_model) .and. &
            ieee_is_finite(constants%rho_vector) .and. &
            ieee_is_finite(constants%rho_tensor) .and. &
            ieee_is_finite(constants%cutoff_mev)
    end function valid_constants

end module cm12_background_seam
