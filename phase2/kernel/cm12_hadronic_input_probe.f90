program cm12_hadronic_input_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_ok
    use cm12_solution_kernel, only: &
        cm12_calculate_kinematics, cm12_kinematics, cm12_solution, &
        cm12_solution_multipole, load_cm12_solution
    implicit none

    integer, parameter :: family_count = 6
    integer, parameter :: branch_count = 2
    integer, parameter :: partial_wave_count = 6
    integer, parameter :: reaction = 2
    real(real32), parameter :: photon_lab_energy_mev = 1000.0_real32

    type(cm12_solution) :: solution
    type(cm12_kinematics) :: kinematics
    character(len=1024) :: solution_path
    character(len=64) :: solution_sha256
    character(len=512) :: message
    real(real32) :: pion_real(4, 8)
    real(real32) :: pion_imag(4, 8)
    real(real32) :: parameters(25)
    integer :: pion_title(18)
    integer :: family
    integer :: branch
    integer :: orbital_l
    integer :: legacy_l
    integer :: rotation_form
    integer :: base_form
    integer :: state_index
    integer :: form_selector
    integer :: status

    interface
        subroutine pnsm05(energy, reaction_number, real_part, imag_part, title)
            import real32
            real(real32), intent(in) :: energy
            integer, intent(in) :: reaction_number
            real(real32), intent(out) :: real_part(4, 8)
            real(real32), intent(out) :: imag_part(4, 8)
            integer, intent(out) :: title(18)
        end subroutine pnsm05
    end interface

    if (command_argument_count() /= 2) then
        write(*, '(a)') &
            'usage: cm12-hadronic-input-probe SOLUTION SHA256'
        stop 64
    end if
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)

    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1
    call cm12_calculate_kinematics( &
        reaction, photon_lab_energy_mev, kinematics, status, message)
    if (status /= cm12_ok) stop 2

    ! This is the exact direct call made by the WIP candidate seam.
    call pnsm05( &
        kinematics%final_meson_energy_mev, 0, &
        pion_real, pion_imag, pion_title)

    write(*, '(a)') &
        'family' // achar(9) // 'branch' // achar(9) // 'legacy_l' // &
        achar(9) // 'rotation_form' // achar(9) // 'base_form' // &
        achar(9) // 'state_index' // achar(9) // 'form_selector' // &
        achar(9) // 'epx' // achar(9) // 'epxx' // achar(9) // &
        'ter' // achar(9) // 'tei' // achar(9) // 'qcm' // achar(9) // &
        'zkcm'
    do family = 1, family_count
        do branch = 1, branch_count
            do orbital_l = 0, partial_wave_count - 1
                call cm12_solution_multipole( &
                    solution, family, branch, orbital_l, form_selector, &
                    parameters, status, message)
                if (status /= cm12_ok) stop 3
                if (form_selector == 0) cycle
                if (form_selector > 100 .and. form_selector < 200) cycle
                if (family > 4) cycle

                legacy_l = orbital_l + 1
                rotation_form = form_selector / 10
                base_form = mod(form_selector, 10)
                state_index = branch
                if (family <= 2) state_index = state_index + 2
                write(*, '(6(i0,a),i0,6(a,es24.16e3))') &
                    family, achar(9), branch, achar(9), &
                    legacy_l, achar(9), rotation_form, achar(9), &
                    base_form, achar(9), state_index, achar(9), &
                    form_selector, &
                    achar(9), kinematics%final_meson_energy_mev, &
                    achar(9), kinematics%final_meson_energy_mev, &
                    achar(9), pion_real(state_index, legacy_l), &
                    achar(9), pion_imag(state_index, legacy_l), &
                    achar(9), kinematics%meson_cm_momentum_mev, &
                    achar(9), kinematics%photon_cm_momentum_mev
            end do
        end do
    end do
end program cm12_hadronic_input_probe
