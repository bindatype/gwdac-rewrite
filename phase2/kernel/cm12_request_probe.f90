program cm12_request_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: &
        cm12_dataset, cm12_invalid_argument, cm12_ok, load_cm12_dataset
    use cm12_solution_kernel, only: &
        cm12_domain_error, cm12_solution, load_cm12_solution
    use cm12_request_kernel, only: &
        cm12_evaluate_request, cm12_prepare_legacy_background, &
        cm12_prepared_background, cm12_request, cm12_request_result
    implicit none

    integer, parameter :: case_count = 4
    integer, parameter :: reactions(case_count) = [ 1, 2, 3, 4 ]
    real(real32), parameter :: energies(case_count) = [ &
        400.0_real32, 1000.0_real32, 500.0_real32, 800.0_real32 ]
    real(real32), parameter :: angles(case_count) = [ &
        30.0_real32, 90.0_real32, 120.0_real32, 150.0_real32 ]

    type(cm12_dataset) :: dataset
    type(cm12_solution) :: solution
    type(cm12_request) :: request
    type(cm12_prepared_background) :: background
    type(cm12_request_result) :: result
    type(cm12_request_result) :: first_result
    character(len=1024) :: solution_path
    character(len=1024) :: dataset_root
    character(len=64) :: solution_sha256
    character(len=512) :: message
    integer :: status
    integer :: case_index
    logical :: exact

    if (command_argument_count() /= 3) then
        write(*, '(a)') &
            'usage: cm12-request-probe SOLUTION_FILE SHA256 KCM_ROOT'
        stop 64
    end if
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)
    call get_command_argument(3, dataset_root)

    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1
    call load_cm12_dataset(trim(dataset_root), dataset, status, message)
    if (status /= cm12_ok) stop 2

    write(*, '(a)') &
        'section' // achar(9) // 'case' // achar(9) // &
        'status' // achar(9) // 'multipoles' // achar(9) // &
        'a1_real' // achar(9) // 'a1_imag' // achar(9) // 'dsg'
    do case_index = 1, case_count
        request = cm12_request( &
            reaction=reactions(case_index), &
            photon_lab_energy_mev=energies(case_index), &
            angle_cm_deg=angles(case_index))
        call cm12_prepare_legacy_background( &
            solution, request, background, status, message)
        if (status /= cm12_ok) stop 3
        call cm12_evaluate_request( &
            solution, dataset, request, background, result, &
            status, message)
        if (status /= cm12_ok) stop 4
        if (result%evaluated_multipoles /= 34) stop 5
        if (case_index == 2) first_result = result
        write(*, '(a,a,i0,a,i0,a,i0,a,3(es16.8,a))') &
            'request', achar(9), case_index, achar(9), status, achar(9), &
            result%evaluated_multipoles, achar(9), &
            real(result%amplitudes_mfm(1), kind=real32), achar(9), &
            aimag(result%amplitudes_mfm(1)), achar(9), &
            result%dsg_microbarn_per_sr, ''
    end do

    request = cm12_request( &
        reaction=1, photon_lab_energy_mev=400.0_real32, &
        angle_cm_deg=30.0_real32)
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message)
    if (status /= cm12_ok) stop 6
    call cm12_evaluate_request( &
        solution, dataset, request, background, result, status, message)
    if (status /= cm12_ok) stop 7
    request = cm12_request( &
        reaction=2, photon_lab_energy_mev=1000.0_real32, &
        angle_cm_deg=90.0_real32)
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message)
    if (status /= cm12_ok) stop 8
    call cm12_evaluate_request( &
        solution, dataset, request, background, result, status, message)
    if (status /= cm12_ok) stop 9
    exact = &
        result%evaluated_multipoles == first_result%evaluated_multipoles .and. &
        all(result%amplitudes_mfm == first_result%amplitudes_mfm) .and. &
        result%dsg_microbarn_per_sr == first_result%dsg_microbarn_per_sr
    write(*, '(a,a,a,a,i0,a,i0,a,a)') &
        'order', achar(9), 'A-B-A', achar(9), cm12_ok, achar(9), 34, &
        achar(9), merge('exact    ', 'different', exact)
    if (.not. exact) stop 10

    request%angle_cm_deg = -1.0_real32
    call cm12_evaluate_request( &
        solution, dataset, request, background, result, status, message)
    write(*, '(a,a,a,a,i0,a,i0,a,a)') &
        'rejection', achar(9), 'invalid-angle', achar(9), status, &
        achar(9), 0, achar(9), trim(message)
    if (status /= cm12_invalid_argument) stop 11

    request = cm12_request( &
        reaction=2, photon_lab_energy_mev=100.0_real32, &
        angle_cm_deg=90.0_real32)
    call cm12_evaluate_request( &
        solution, dataset, request, background, result, status, message)
    write(*, '(a,a,a,a,i0,a,i0,a,a)') &
        'rejection', achar(9), 'below-threshold', achar(9), status, &
        achar(9), result%evaluated_multipoles, achar(9), trim(message)
    if (status /= cm12_domain_error) stop 12
end program cm12_request_probe
