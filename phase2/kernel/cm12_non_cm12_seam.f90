module cm12_non_cm12_seam
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: cm12_invalid_argument, cm12_ok
    use cm12_solution_kernel, only: &
        cm12_kinematics, cm12_solution, cm12_solution_multipole
    implicit none
    private

    integer, parameter :: family_count = 6
    integer, parameter :: branch_count = 2
    integer, parameter :: partial_wave_count = 6
    integer, parameter :: parameter_count = 25

    public :: cm12_prepare_non_cm12_multipoles

    interface
        subroutine pnsm05(energy, reaction, real_part, imag_part, title)
            import real32
            real(real32), intent(in) :: energy
            integer, intent(in) :: reaction
            real(real32), intent(out) :: real_part(4, 8)
            real(real32), intent(out) :: imag_part(4, 8)
            integer, intent(out) :: title(18)
        end subroutine pnsm05

        subroutine qjofx(values, argument, maximum_l)
            import real32
            real(real32), intent(out) :: values(*)
            real(real32), intent(in) :: argument
            integer, intent(in) :: maximum_l
        end subroutine qjofx
    end interface

contains

    subroutine cm12_prepare_non_cm12_multipoles( &
        solution, reaction, kinematics, opec_multipoles, multipoles, &
        status, message)
        type(cm12_solution), intent(in) :: solution
        integer, intent(in) :: reaction
        type(cm12_kinematics), intent(in) :: kinematics
        real(real32), intent(in) :: opec_multipoles( &
            family_count, branch_count, partial_wave_count)
        complex(real32), intent(out) :: multipoles( &
            family_count, branch_count, partial_wave_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        real(real32) :: pion_real(4, 8)
        real(real32) :: pion_imag(4, 8)
        real(real32) :: parameters(parameter_count)
        integer :: pion_title(18)
        integer :: family
        integer :: branch
        integer :: orbital_l
        integer :: form_selector

        multipoles = cmplx(0.0_real32, 0.0_real32, kind=real32)
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

        ! Frozen SM05 remains an explicit hidden-state boundary: PNSM05
        ! caches its last energy internally but receives all physics inputs.
        call pnsm05( &
            kinematics%final_meson_energy_mev, 0, &
            pion_real, pion_imag, pion_title)

        do family = 1, family_count
            do branch = 1, branch_count
                do orbital_l = 0, partial_wave_count - 1
                    call cm12_solution_multipole( &
                        solution, family, branch, orbital_l, &
                        form_selector, parameters, status, message)
                    if (status /= cm12_ok) return
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
                    call evaluate_legacy_form( &
                        form_selector, parameters, family, branch, &
                        orbital_l, kinematics, &
                        opec_multipoles(family, branch, orbital_l + 1), &
                        pion_real, pion_imag, &
                        multipoles(family, branch, orbital_l + 1))
                end do
            end do
        end do
        status = cm12_ok
        message = ''
    end subroutine cm12_prepare_non_cm12_multipoles

    subroutine evaluate_legacy_form( &
        form_selector, parameters, family, branch, orbital_l, kinematics, &
        opec_multipole, pion_real, pion_imag, adjusted_multipole)
        integer, intent(in) :: form_selector
        real(real32), intent(in) :: parameters(parameter_count)
        integer, intent(in) :: family
        integer, intent(in) :: branch
        integer, intent(in) :: orbital_l
        type(cm12_kinematics), intent(in) :: kinematics
        real(real32), intent(in) :: opec_multipole
        real(real32), intent(in) :: pion_real(4, 8)
        real(real32), intent(in) :: pion_imag(4, 8)
        complex(real32), intent(out) :: adjusted_multipole

        real(real32), parameter :: expansion_pion_mass = 135.04_real32
        real(real32), parameter :: charged_pion_mass = 139.65_real32
        real(real32), parameter :: proton_mass = 938.256_real32
        real(real32), parameter :: degrees_to_radians = 0.0174532_real32

        real(real32) :: q_values(10)
        real(real32) :: pion_lab_energy
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
        real(real32) :: hadronic_real
        real(real32) :: hadronic_imag
        integer :: base_form
        integer :: rotation_form
        integer :: pion_state
        integer :: legacy_l
        integer :: extra_power

        legacy_l = orbital_l + 1
        pion_state = branch
        if (family <= 2) pion_state = pion_state + 2
        hadronic_real = pion_real(pion_state, legacy_l)
        hadronic_imag = pion_imag(pion_state, legacy_l)

        base_form = mod(form_selector, 10)
        rotation_form = form_selector / 10
        pion_lab_energy = kinematics%final_meson_energy_mev
        expansion = pion_lab_energy / expansion_pion_mass
        if (base_form > 4) then
            expansion = pion_lab_energy / (800.0_real32 + pion_lab_energy)
        end if
        virtual_pion_momentum = proton_mass * sqrt( &
            pion_lab_energy * &
            (pion_lab_energy + 2.0_real32 * charged_pion_mass) / &
            ((charged_pion_mass + proton_mass) ** 2 + &
                2.0_real32 * proton_mass * pion_lab_energy))
        momentum_ratio = &
            virtual_pion_momentum / kinematics%photon_cm_momentum_mev

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

        polynomial_real = polynomial_real + opec_multipole
        real_part = &
            polynomial_real * (1.0_real32 - hadronic_imag) + &
            polynomial_rescattering * hadronic_real
        imag_part = &
            polynomial_real * hadronic_real + &
            polynomial_rescattering * hadronic_imag

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
