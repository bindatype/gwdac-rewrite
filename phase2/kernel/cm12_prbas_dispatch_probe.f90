program cm12_prbas_dispatch_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_ok
    use cm12_non_cm12_seam, only: &
        cm12_hadronic_trace, cm12_max_hadronic_trace
    use cm12_request_kernel, only: &
        cm12_prepare_legacy_background, cm12_prepared_background, cm12_request
    use cm12_solution_kernel, only: cm12_solution, load_cm12_solution
    implicit none

    integer, parameter :: applicable_trace_count = 18
    integer, parameter :: reaction = 2
    real(real32), parameter :: photon_lab_energy_mev = 1000.0_real32
    real(real32), parameter :: angle_cm_deg = 90.0_real32

    type(cm12_solution) :: solution
    type(cm12_request) :: request
    type(cm12_prepared_background) :: background
    type(cm12_hadronic_trace) :: trace(cm12_max_hadronic_trace)
    character(len=1024) :: solution_path
    character(len=1024) :: legacy_trace_path
    character(len=1024) :: line
    character(len=512) :: message
    character(len=128) :: expected_title
    character(len=128) :: expected_previous_title
    character(len=64) :: solution_sha256
    real(real32) :: expected_real
    real(real32) :: expected_imag
    real(real32) :: expected_input_energy
    real(real32) :: expected_effective_energy
    real(real32) :: expected_dither
    integer :: unit
    integer :: ios
    integer :: status
    integer :: trace_count
    integer :: row_id
    integer :: applicable_row
    integer :: expected_family
    integer :: expected_branch
    integer :: expected_legacy_l
    integer :: expected_state_index
    integer :: expected_form_selector
    integer :: expected_dispatch_branch

    if (command_argument_count() /= 3) then
        write(*, '(a)') &
            'usage: cm12-prbas-dispatch-probe SOLUTION SHA256 LEGACY_TRACE'
        stop 64
    end if
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)
    call get_command_argument(3, legacy_trace_path)

    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1
    request = cm12_request( &
        reaction=reaction, &
        photon_lab_energy_mev=photon_lab_energy_mev, &
        angle_cm_deg=angle_cm_deg)
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message, trace, trace_count)
    if (status /= cm12_ok) stop 2
    if (trace_count < applicable_trace_count) stop 3

    open( &
        newunit=unit, file=trim(legacy_trace_path), status='old', &
        action='read', iostat=ios)
    if (ios /= 0) stop 4
    read(unit, '(a)', iostat=ios) line
    if (ios /= 0) stop 5

    write(*, '(a)') &
        'row_id' // achar(9) // 'family' // achar(9) // 'branch' // &
        achar(9) // 'legacy_l' // achar(9) // 'state_index' // &
        achar(9) // 'selector' // achar(9) // 'dispatch' // &
        achar(9) // 'effective_energy' // achar(9) // 'hadronic_real' // &
        achar(9) // 'hadronic_imag' // achar(9) // 'exact'
    applicable_row = 0
    do
        read(unit, '(a)', iostat=ios) line
        if (ios < 0) exit
        if (ios > 0) stop 5
        call read_integer_field(line, 1, row_id)
        call read_integer_field(line, 2, expected_family)
        if (expected_family > 4) cycle
        applicable_row = applicable_row + 1
        if (applicable_row > applicable_trace_count) then
            call fail(row_id, 'applicable-count')
        end if
        call read_integer_field(line, 3, expected_branch)
        call read_integer_field(line, 4, expected_legacy_l)
        call read_integer_field(line, 7, expected_state_index)
        call read_integer_field(line, 8, expected_form_selector)
        call read_real_field(line, 22, expected_input_energy)

        if (trace(applicable_row)%dispatch%family /= expected_family) &
            call fail(row_id, 'family')
        if (trace(applicable_row)%dispatch%branch /= expected_branch) &
            call fail(row_id, 'branch')
        if (trace(applicable_row)%dispatch%legacy_l /= expected_legacy_l) &
            call fail(row_id, 'legacy_l')
        if (trace(applicable_row)%dispatch%state_index /= expected_state_index) &
            call fail(row_id, 'state_index')
        if ( &
            trace(applicable_row)%dispatch%form_selector /= &
            expected_form_selector) call fail(row_id, 'form_selector')
        if ( &
            trace(applicable_row)%dispatch%input_energy_mev /= &
            expected_input_energy) call fail(row_id, 'input_energy')

        if (row_id == 1) then
            if (trace(applicable_row)%dispatch%dispatch) &
                call fail(row_id, 'unexpected_dispatch')
            if ( &
                trace(applicable_row)%hadronic_real /= 0.0_real32 .or. &
                trace(applicable_row)%hadronic_imag /= 0.0_real32) &
                call fail(row_id, 'reset_result')
        else
            call read_integer_field(line, 26, expected_dispatch_branch)
            expected_title = trim(tab_field(line, 27))
            expected_previous_title = trim(tab_field(line, 28))
            call read_real_field(line, 29, expected_effective_energy)
            call read_real_field(line, 30, expected_dither)
            call read_real_field(line, 31, expected_real)
            call read_real_field(line, 32, expected_imag)
            if (.not. trace(applicable_row)%dispatch%dispatch) &
                call fail(row_id, 'missing_dispatch')
            if ( &
                trace(applicable_row)%dispatch%dispatch_branch /= &
                expected_dispatch_branch) call fail(row_id, 'dispatch_branch')
            if ( &
                trim(trace(applicable_row)%dispatch%dispatch_title) /= &
                trim(expected_title)) call fail(row_id, 'dispatch_title')
            if (expected_previous_title == 'BLANK') expected_previous_title = ''
            if ( &
                trim(trace(applicable_row)%dispatch%previous_title) /= &
                trim(expected_previous_title)) call fail(row_id, 'previous_title')
            if ( &
                trace(applicable_row)%dispatch%effective_energy_mev /= &
                expected_effective_energy) call fail(row_id, 'effective_energy')
            if ( &
                trace(applicable_row)%dispatch%dither_before_mev /= &
                expected_dither) call fail(row_id, 'dither_before')
            if (trace(applicable_row)%formula_title /= 'SP00') &
                call fail(row_id, 'formula_title')
            if (trace(applicable_row)%hadronic_real /= expected_real) &
                call fail(row_id, 'hadronic_real')
            if (trace(applicable_row)%hadronic_imag /= expected_imag) &
                call fail(row_id, 'hadronic_imag')
        end if

        write(*, '(6(i0,a),l1,a,3(es24.16e3,a),a)') &
            row_id, achar(9), expected_family, achar(9), expected_branch, &
            achar(9), expected_legacy_l, achar(9), expected_state_index, &
            achar(9), expected_form_selector, achar(9), &
            trace(applicable_row)%dispatch%dispatch, achar(9), &
            trace(applicable_row)%dispatch%effective_energy_mev, achar(9), &
            trace(applicable_row)%hadronic_real, achar(9), &
            trace(applicable_row)%hadronic_imag, achar(9), 'T'
    end do
    close(unit)
    if (applicable_row /= applicable_trace_count) &
        call fail(0, 'applicable-count')

contains

    function tab_field(text, field_number) result(field)
        character(len=*), intent(in) :: text
        integer, intent(in) :: field_number
        character(len=128) :: field
        integer :: current_field
        integer :: field_start
        integer :: relative_end

        field = ''
        current_field = 1
        field_start = 1
        do while (current_field < field_number)
            relative_end = index(text(field_start:), achar(9))
            if (relative_end == 0) return
            field_start = field_start + relative_end
            current_field = current_field + 1
        end do
        relative_end = index(text(field_start:), achar(9))
        if (relative_end == 0) then
            field = text(field_start:)
        else
            field = text(field_start:field_start + relative_end - 2)
        end if
    end function tab_field

    subroutine read_integer_field(text, field_number, value)
        character(len=*), intent(in) :: text
        integer, intent(in) :: field_number
        integer, intent(out) :: value
        character(len=128) :: field
        integer :: read_status

        field = tab_field(text, field_number)
        read(field, *, iostat=read_status) value
        if (read_status /= 0) stop 65
    end subroutine read_integer_field

    subroutine read_real_field(text, field_number, value)
        character(len=*), intent(in) :: text
        integer, intent(in) :: field_number
        real(real32), intent(out) :: value
        character(len=128) :: field
        integer :: read_status

        field = tab_field(text, field_number)
        read(field, *, iostat=read_status) value
        if (read_status /= 0) stop 66
    end subroutine read_real_field

    subroutine fail(failing_row, field_name)
        integer, intent(in) :: failing_row
        character(len=*), intent(in) :: field_name

        write(*, '(a,i0,a,a)') &
            'first_divergence_row=', failing_row, ' field=', trim(field_name)
        stop 6
    end subroutine fail

end program cm12_prbas_dispatch_probe
