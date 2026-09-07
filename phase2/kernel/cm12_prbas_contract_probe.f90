program cm12_prbas_contract_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_invalid_argument, cm12_ok
    use cm12_prbas_dispatch, only: &
        cm12_begin_prbas_dispatch, cm12_load_prbas_solution_selector, &
        cm12_invalidate_prbas_process, &
        cm12_next_prbas_dispatch, cm12_prbas_dispatch_event, &
        cm12_prbas_dispatch_state, cm12_record_prbas_formula_title, &
        cm12_validate_prbas_ambient
    use cm12_request_kernel, only: &
        cm12_background_grid_state, cm12_prepare_legacy_background, &
        cm12_prepared_background, cm12_request
    use cm12_non_cm12_seam, only: cm12_begin_background_grid
    use cm12_solution_kernel, only: cm12_solution, load_cm12_solution
    implicit none

    type(cm12_background_grid_state) :: grid_state
    type(cm12_prbas_dispatch_state) :: dispatch_state
    type(cm12_prbas_dispatch_state) :: next_dispatch_state
    type(cm12_prbas_dispatch_event) :: dispatch_event
    type(cm12_prepared_background) :: background
    type(cm12_request) :: request
    type(cm12_solution) :: solution
    character(len=1024) :: solution_path
    character(len=512) :: message
    character(len=72) :: solution_title
    character(len=64) :: solution_sha256
    character(len=4) :: invalid_formula_title
    integer :: nfg(4, 8)
    real(real32) :: pg(20, 4, 8)
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

    nfg = 0
    pg = 0.0_real32
    call cm12_validate_prbas_ambient( &
        1, 6, 0, 0.0_real32, 0.0_real32, nfg, pg, status, message)
    call require_result('ambient_supported', status, message, cm12_ok, '')
    call cm12_validate_prbas_ambient( &
        100, 6, 0, 0.0_real32, 0.0_real32, nfg, pg, status, message)
    call require_result( &
        'ambient_it_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS requires retained IT=1')
    call cm12_validate_prbas_ambient( &
        1, 5, 0, 0.0_real32, 0.0_real32, nfg, pg, status, message)
    call require_result( &
        'ambient_nnl_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS requires retained NNL=6')
    call cm12_validate_prbas_ambient( &
        1, 6, 1, 0.0_real32, 0.0_real32, nfg, pg, status, message)
    call require_result( &
        'ambient_iprk_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS does not support IPRK scaling')
    call cm12_validate_prbas_ambient( &
        1, 6, 0, 1.0_real32, 0.0_real32, nfg, pg, status, message)
    call require_result( &
        'ambient_bcoff_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS requires retained BCOFF=0')
    call cm12_validate_prbas_ambient( &
        1, 6, 0, 0.0_real32, 1.0_real32, nfg, pg, status, message)
    call require_result( &
        'ambient_kill_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS requires retained KILL=0')
    nfg(1, 1) = 1
    call cm12_validate_prbas_ambient( &
        1, 6, 0, 0.0_real32, 0.0_real32, nfg, pg, status, message)
    call require_result( &
        'ambient_nfg_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS does not support PNMOD overrides')
    nfg = 0
    pg(1, 1, 1) = 1.0_real32
    call cm12_validate_prbas_ambient( &
        1, 6, 0, 0.0_real32, 0.0_real32, nfg, pg, status, message)
    call require_result( &
        'ambient_pg_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS does not support PGLOB parameters')

    solution_title = ''
    solution_title(57:60) = 'M05 '
    call cm12_begin_prbas_dispatch( &
        solution_title, dispatch_state, status, message)
    if (status /= cm12_ok) stop 8
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 1, 4, 25, 849.9572_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if (status /= cm12_ok .or. dispatch_event%dispatch) stop 9
    dispatch_state = next_dispatch_state
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 1, 5, 25, 849.9572_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if (status /= cm12_ok .or. .not. dispatch_event%dispatch) stop 10
    call cm12_record_prbas_formula_title( &
        next_dispatch_state, 'SP00', dispatch_state, status, message)
    if (status /= cm12_ok) stop 11
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 2, 1, 21, 849.9572_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if (status /= cm12_ok .or. .not. dispatch_event%dispatch) stop 12
    call cm12_record_prbas_formula_title( &
        next_dispatch_state, 'SP00', dispatch_state, status, message)
    if (status /= cm12_ok) stop 13
    if ( &
        dispatch_state%background_reset_pending .or. &
        dispatch_state%current_title /= 'SP00' .or. &
        dispatch_state%previous_title /= 'SP00' .or. &
        dispatch_state%next_dither_mev /= 0.001_real32) stop 14
    call require_result( &
        'process_state_survives_request', status, message, cm12_ok, '')
    call cm12_load_prbas_solution_selector( &
        dispatch_state, 'M05 ', next_dispatch_state, status, message)
    if (status /= cm12_ok) stop 15
    dispatch_state = next_dispatch_state
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 1, 4, 25, 849.9572_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if ( &
        status /= cm12_ok .or. .not. dispatch_event%dispatch .or. &
        dispatch_event%dispatch_title /= 'M05 ' .or. &
        dispatch_event%previous_title /= 'SP00' .or. &
        dispatch_event%effective_energy_mev /= &
            849.9572_real32 + 0.001_real32) stop 16
    call require_result( &
        'solution_reload_preserves_process', status, message, cm12_ok, '')

    call cm12_invalidate_prbas_process( &
        dispatch_state, next_dispatch_state)
    if (next_dispatch_state%typed_process_valid) stop 17
    status = cm12_ok
    message = ''
    call require_result( &
        'process_state_invalidated', status, message, cm12_ok, '')
    dispatch_state = next_dispatch_state
    call cm12_load_prbas_solution_selector( &
        dispatch_state, 'M05 ', next_dispatch_state, status, message)
    if (status /= cm12_ok .or. next_dispatch_state%typed_process_valid) stop 18
    call require_result( &
        'solution_reload_preserves_invalidation', &
        status, message, cm12_ok, '')
    dispatch_state = next_dispatch_state
    call cm12_begin_background_grid( &
        solution, 2, dispatch_state, grid_state, status, message)
    call require_result( &
        'invalidated_grid_rejected', status, message, cm12_invalid_argument, &
        'typed PRBAS process state is invalidated')

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

    solution_title = ''
    solution_title(57:60) = 'M05 '
    call cm12_begin_prbas_dispatch( &
        solution_title, dispatch_state, status, message)
    if (status /= cm12_ok) stop 19
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 1, 4, 25, 1.5_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if (status /= cm12_ok .or. dispatch_event%dispatch) stop 20
    dispatch_state = next_dispatch_state
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 1, 5, 25, 1.5_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if ( &
        status /= cm12_ok .or. .not. dispatch_event%dispatch .or. &
        dispatch_event%effective_energy_mev /= 2.0_real32 .or. &
        dispatch_event%dither_before_mev /= 0.001_real32 .or. &
        next_dispatch_state%next_dither_mev /= -0.001_real32) stop 21
    message = 'input=1.5000 dither=0.0010 effective=2.0000'
    call require_result( &
        'dispatch_below_clamp', status, message, cm12_ok, &
        'input=1.5000 dither=0.0010 effective=2.0000')

    call cm12_record_prbas_formula_title( &
        next_dispatch_state, 'M05 ', dispatch_state, status, message)
    if (status /= cm12_ok) stop 22
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 2, 1, 21, 2.0_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if ( &
        status /= cm12_ok .or. .not. dispatch_event%dispatch .or. &
        dispatch_event%effective_energy_mev /= 2.0_real32 .or. &
        dispatch_event%dither_before_mev /= -0.001_real32 .or. &
        next_dispatch_state%next_dither_mev /= -0.001_real32) stop 23
    message = 'input=2.0000 dither=none effective=2.0000'
    call require_result( &
        'dispatch_at_clamp', status, message, cm12_ok, &
        'input=2.0000 dither=none effective=2.0000')

    dispatch_state = next_dispatch_state
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 2, 2, 21, 2.5_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if ( &
        status /= cm12_ok .or. .not. dispatch_event%dispatch .or. &
        dispatch_event%effective_energy_mev /= 2.5_real32 .or. &
        next_dispatch_state%next_dither_mev /= -0.001_real32) stop 24
    message = 'input=2.5000 dither=none effective=2.5000'
    call require_result( &
        'dispatch_above_clamp', status, message, cm12_ok, &
        'input=2.5000 dither=none effective=2.5000')

    call cm12_load_prbas_solution_selector( &
        next_dispatch_state, 'SP00', dispatch_state, status, message)
    if (status /= cm12_ok) stop 25
    call cm12_next_prbas_dispatch( &
        dispatch_state, 1, 2, 3, 21, 1.9995_real32, dispatch_event, &
        next_dispatch_state, status, message)
    if ( &
        status /= cm12_ok .or. .not. dispatch_event%dispatch .or. &
        dispatch_event%effective_energy_mev /= 2.0_real32 .or. &
        dispatch_event%dither_before_mev /= -0.001_real32 .or. &
        next_dispatch_state%next_dither_mev /= 0.001_real32) stop 26
    message = 'input=1.9995 dither=-0.0010 effective=2.0000'
    call require_result( &
        'dispatch_dither_then_clamp', status, message, cm12_ok, &
        'input=1.9995 dither=-0.0010 effective=2.0000')

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
