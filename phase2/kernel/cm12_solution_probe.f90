program cm12_solution_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_ok
    use cm12_solution_kernel, only: &
        cm12_background_constants, cm12_solution, &
        cm12_solution_background, cm12_solution_multipole, &
        cm12_solution_summary, load_cm12_solution
    implicit none

    type(cm12_solution) :: solution
    type(cm12_background_constants) :: background
    character(len=1024) :: path
    character(len=64) :: expected_sha256
    character(len=64) :: actual_sha256
    character(len=72) :: title
    character(len=1024) :: source_path
    character(len=512) :: message
    character(len=4) :: identifier
    integer :: status
    integer :: explicit_records
    integer :: max_partial_wave
    integer :: form_selector
    integer :: family
    integer :: branch
    integer :: orbital_l
    integer :: active_forms
    integer :: cm12_forms
    real(real32) :: parameters(25)

    if (command_argument_count() /= 3) then
        write(*, '(a)') &
            'usage: cm12-solution-probe SOLUTION_FILE SHA256 ID'
        stop 64
    end if
    call get_command_argument(1, path)
    call get_command_argument(2, expected_sha256)
    call get_command_argument(3, identifier)

    call load_cm12_solution( &
        trim(path), trim(expected_sha256), identifier, solution, &
        status, message)
    if (status /= cm12_ok) then
        write(*, '(a,i0)') 'status=', status
        write(*, '(a,a)') 'message=', trim(message)
        stop 1
    end if

    call cm12_solution_summary( &
        solution, identifier, title, source_path, actual_sha256, &
        explicit_records, max_partial_wave)
    call cm12_solution_background(solution, background, status, message)
    if (status /= cm12_ok) stop 1

    active_forms = 0
    cm12_forms = 0
    do orbital_l = 0, max_partial_wave - 1
        do branch = 1, 2
            do family = 1, 6
                call cm12_solution_multipole( &
                    solution, family, branch, orbital_l, form_selector, &
                    parameters, status, message)
                if (status /= cm12_ok) stop 1
                if (form_selector /= 0) active_forms = active_forms + 1
                if ( &
                    form_selector > 100 .and. form_selector < 200) then
                    cm12_forms = cm12_forms + 1
                end if
            end do
        end do
    end do

    write(*, '(a)') &
        'identifier' // achar(9) // 'title' // achar(9) // &
        'source_sha256' // achar(9) // 'explicit_records' // achar(9) // &
        'active_forms' // achar(9) // 'cm12_forms' // achar(9) // &
        'max_partial_wave' // achar(9) // 'pion_coupling' // achar(9) // &
        'omega_vector' // achar(9) // 'omega_tensor' // achar(9) // &
        'rho_vector' // achar(9) // 'rho_tensor' // achar(9) // &
        'cutoff_mev'
    write(*, '(a,a,a,a,a,a,i0,a,i0,a,i0,a,i0,a,6(f0.5,a))') &
        identifier, achar(9), trim(title), achar(9), actual_sha256, &
        achar(9), explicit_records, achar(9), active_forms, achar(9), &
        cm12_forms, achar(9), max_partial_wave, achar(9), &
        background%pion_coupling, achar(9), &
        background%omega_vector, achar(9), &
        background%omega_tensor, achar(9), &
        background%rho_vector, achar(9), &
        background%rho_tensor, achar(9), &
        background%cutoff_mev, achar(9)
end program cm12_solution_probe
