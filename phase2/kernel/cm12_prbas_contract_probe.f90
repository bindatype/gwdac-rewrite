program cm12_prbas_contract_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_invalid_argument, cm12_ok
    use cm12_prbas_dispatch, only: &
        cm12_begin_prbas_dispatch, cm12_prbas_dispatch_state, &
        cm12_record_prbas_formula_title
    use cm12_request_kernel, only: &
        cm12_background_grid_state, cm12_prepare_legacy_background, &
        cm12_prepared_background, cm12_request
    use cm12_solution_kernel, only: cm12_solution, load_cm12_solution
    implicit none

    type(cm12_background_grid_state) :: grid_state
    type(cm12_prbas_dispatch_state) :: dispatch_state
    type(cm12_prbas_dispatch_state) :: next_dispatch_state
    type(cm12_prepared_background) :: background
    type(cm12_request) :: request
    type(cm12_solution) :: solution
    character(len=1024) :: solution_path
    character(len=512) :: message
    character(len=72) :: solution_title
    character(len=64) :: solution_sha256
    character(len=4) :: invalid_formula_title
    integer :: status

    if (command_argument_count() /= 2) then
        write(*, '(a)') &
            'usage: cm12-prbas-contract-probe SOLUTION SHA256'
        stop 64
    end if
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)

    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1

    write(*, '(a)') 'contract' // achar(9) // 'status' // achar(9) // 'message'

    solution_title = ''
    solution_title(57:60) = 'SP00'
    call cm12_begin_prbas_dispatch( &
        solution_title, dispatch_state, status, message)
    if (status /= cm12_ok) stop 2
    invalid_formula_title = 'SP00'
    invalid_formula_title(1:1) = achar(31)
    call cm12_record_prbas_formula_title( &
        dispatch_state, invalid_formula_title, next_dispatch_state, &
        status, message)
    call require_result( &
        'non_printable_title', status, message, cm12_invalid_argument, &
        'frozen hadronic formula returned a non-printable title')

    request = cm12_request( &
        reaction=2, photon_lab_energy_mev=200.0_real32, &
        angle_cm_deg=90.0_real32)
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message, grid_state=grid_state)
    call require_result('initialize_grid', status, message, cm12_ok, '')

    request%reaction = 1
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message, grid_state=grid_state)
    call require_result( &
        'reaction_mismatch', status, message, cm12_invalid_argument, &
        'background grid state provenance does not match request')

    request%reaction = 2
    request%photon_lab_energy_mev = 300.0_real32
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message, grid_state=grid_state)
    call require_result( &
        'original_reaction_reuse', status, message, cm12_ok, '')

contains

    subroutine require_result( &
        contract, actual_status, actual_message, expected_status, &
        expected_message)
        character(len=*), intent(in) :: contract
        integer, intent(in) :: actual_status
        character(len=*), intent(in) :: actual_message
        integer, intent(in) :: expected_status
        character(len=*), intent(in) :: expected_message

        character(len=512) :: displayed_message

        displayed_message = trim(actual_message)
        if (len_trim(displayed_message) == 0) displayed_message = '<empty>'
        write(*, '(a,a,i0,a,a)') &
            trim(contract), achar(9), actual_status, achar(9), &
            trim(displayed_message)
        if ( &
            actual_status /= expected_status .or. &
            trim(actual_message) /= expected_message) stop 7
    end subroutine require_result

end program cm12_prbas_contract_probe
