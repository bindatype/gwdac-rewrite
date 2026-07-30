program cm12_layer_parity_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: &
        cm12_dataset, cm12_evaluate_multipole, cm12_ok, load_cm12_dataset
    use cm12_solution_kernel, only: &
        cm12_background_constants, cm12_solution, &
        cm12_solution_background, cm12_solution_multipole, &
        load_cm12_solution
    use cm12_background_seam, only: &
        cm12_evaluate_background, cm12_evaluate_born_multipoles
    implicit none

    integer, parameter :: wave_count = 14
    character(len=3), parameter :: wave(wave_count) = [ &
        character(len=3) :: &
        'S11', 'S31', 'P11', 'P31', 'P13', 'P33', 'D13', &
        'D33', 'D15', 'D35', 'F15', 'F17', 'F35', 'F37' ]
    integer, parameter :: family(wave_count) = [ &
        3, 1, 4, 2, 3, 1, 3, 1, 3, 1, 3, 3, 1, 1 ]
    integer, parameter :: j_branch(wave_count) = [ &
        2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 2, 1, 2 ]
    integer, parameter :: orbital_l(wave_count) = [ &
        0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3 ]
    real(real32), parameter :: wcm_values(3) = [ &
        1100.0_real32, 1500.0_real32, 1900.0_real32 ]
    real(real32), parameter :: proton_mass = 938.256_real32

    type(cm12_dataset) :: dataset
    type(cm12_solution) :: solution
    type(cm12_background_constants) :: background
    integer :: nfmp(6, 2, 6)
    integer :: iprk
    common /solnform/ nfmp
    common /prkc/ iprk
    character(len=1024) :: solution_path
    character(len=1024) :: dataset_root
    character(len=64) :: solution_sha256
    character(len=512) :: message
    integer :: status
    integer :: wave_index
    integer :: energy_index
    integer :: form_selector
    integer :: all_family
    integer :: all_branch
    integer :: all_l
    integer :: mjl
    integer :: nonzero_born_cases
    integer :: nonzero_background_values
    real(real32) :: parameters(30)
    real(real32) :: born(6, 2, 6)
    real(real32) :: opec(6, 2, 6)
    real(real32) :: born_first(6, 2, 6)
    real(real32) :: opec_first(6, 2, 6)
    real(real32) :: born_repeat(6, 2, 6)
    real(real32) :: opec_repeat(6, 2, 6)
    real(real32) :: lab_energy
    real(real32) :: legacy_real
    real(real32) :: legacy_imag
    real(real32) :: born_multipole
    real(real32) :: ys
    complex(real32) :: seam_value
    complex(real32) :: amplitudes_first(4)
    complex(real32) :: amplitudes_repeat(4)
    complex(real32) :: amplitudes_other(4)
    logical :: exact
    external :: ys

    if (command_argument_count() /= 3) then
        write(*, '(a)') &
            'usage: cm12-layer-parity-probe SOLUTION_FILE SHA256 KCM_ROOT'
        stop 64
    end if
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)
    call get_command_argument(3, dataset_root)
    iprk = 0

    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1
    call load_cm12_dataset(trim(dataset_root), dataset, status, message)
    if (status /= cm12_ok) stop 1
    call cm12_solution_background(solution, background, status, message)
    if (status /= cm12_ok) stop 1

    do all_l = 0, 5
        do all_branch = 1, 2
            do all_family = 1, 6
                call cm12_solution_multipole( &
                    solution, all_family, all_branch, all_l, &
                    nfmp(all_family, all_branch, all_l + 1), &
                    parameters(1:25), status, message)
                if (status /= cm12_ok) stop 1
            end do
        end do
    end do

    call cm12_evaluate_background( &
        background, 1000.0_real32, 90.0_real32, 2, &
        born_first, opec_first, amplitudes_first, status, message)
    if (status /= cm12_ok) stop 1
    call cm12_evaluate_background( &
        background, 400.0_real32, 30.0_real32, 1, &
        born, opec, amplitudes_other, status, message)
    if (status /= cm12_ok) stop 1
    call cm12_evaluate_background( &
        background, 1000.0_real32, 90.0_real32, 2, &
        born_repeat, opec_repeat, amplitudes_repeat, status, message)
    if (status /= cm12_ok) stop 1
    exact = &
        all(born_first == born_repeat) .and. &
        all(opec_first == opec_repeat) .and. &
        all(amplitudes_first == amplitudes_repeat)
    if (.not. exact) stop 10
    nonzero_background_values = &
        count(born_first /= 0.0_real32) + &
        count(opec_first /= 0.0_real32) + &
        count(real(amplitudes_first, kind=real32) /= 0.0_real32)
    if (nonzero_background_values == 0) stop 11

    write(*, '(a)') &
        'section' // achar(9) // 'case' // achar(9) // &
        'value_1' // achar(9) // 'value_2' // achar(9) // 'exact'
    write(*, '(a,a,a,a,i0,a,i0,a,l1)') &
        'background', achar(9), 'A-B-A', achar(9), &
        count(born_first /= 0.0_real32), achar(9), &
        nonzero_background_values, achar(9), exact

    nonzero_born_cases = 0
    do energy_index = 1, size(wcm_values)
        lab_energy = &
            (wcm_values(energy_index) ** 2 - proton_mass ** 2) / &
            (2.0_real32 * proton_mass)
        call cm12_evaluate_born_multipoles( &
            background, lab_energy, born, opec, status, message)
        if (status /= cm12_ok) stop 1
        do wave_index = 1, wave_count
            parameters = 0.0_real32
            call cm12_solution_multipole( &
                solution, family(wave_index), j_branch(wave_index), &
                orbital_l(wave_index), form_selector, parameters(1:25), &
                status, message)
            if (status /= cm12_ok) stop 1
            born_multipole = born( &
                family(wave_index), j_branch(wave_index), &
                orbital_l(wave_index) + 1)
            if ( &
                form_selector / 10 == 13 .and. &
                born_multipole /= 0.0_real32) then
                nonzero_born_cases = nonzero_born_cases + 1
            end if
            mjl = &
                100 * family(wave_index) + &
                10 * j_branch(wave_index) + orbital_l(wave_index)
            legacy_real = ys( &
                12.0_real32, wcm_values(energy_index), mjl, parameters)
            legacy_imag = ys( &
                -12.0_real32, wcm_values(energy_index), mjl, parameters)
            call cm12_evaluate_multipole( &
                dataset, form_selector, parameters, family(wave_index), &
                j_branch(wave_index), orbital_l(wave_index), &
                wcm_values(energy_index), born_multipole, seam_value, &
                status, message)
            if (status /= cm12_ok) stop 1
            exact = &
                legacy_real == real(seam_value, kind=real32) .and. &
                legacy_imag == aimag(seam_value)
            write(*, '(a,a,a,a,es16.8,a,es16.8,a,l1)') &
                'multipole', achar(9), wave(wave_index), achar(9), &
                wcm_values(energy_index), achar(9), born_multipole, &
                achar(9), exact
            if (.not. exact) stop 12
        end do
    end do
    if (nonzero_born_cases == 0) stop 13
end program cm12_layer_parity_probe
