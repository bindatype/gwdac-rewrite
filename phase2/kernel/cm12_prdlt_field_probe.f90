program cm12_prdlt_field_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_ok
    use cm12_non_cm12_seam, only: &
        cm12_hadronic_trace, cm12_max_hadronic_trace
    use cm12_request_kernel, only: &
        cm12_prepare_legacy_background, cm12_prepared_background, cm12_request
    use cm12_solution_kernel, only: cm12_solution, load_cm12_solution
    implicit none

    type(cm12_solution) :: solution
    type(cm12_request) :: request
    type(cm12_prepared_background) :: background
    type(cm12_hadronic_trace) :: trace(cm12_max_hadronic_trace)
    character(len=1024) :: solution_path
    character(len=64) :: solution_sha256
    character(len=512) :: message
    integer :: status
    integer :: trace_count
    integer :: row

    if (command_argument_count() /= 2) stop 64
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)
    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1

    request = cm12_request( &
        reaction=2, photon_lab_energy_mev=1000.0_real32, &
        angle_cm_deg=90.0_real32)
    call cm12_prepare_legacy_background( &
        solution, request, background, status, message, trace, trace_count)
    if (status /= cm12_ok) stop 2

    do row = 1, trace_count
        if ( &
            trace(row)%dispatch%family == 1 .and. &
            trace(row)%dispatch%branch == 1 .and. &
            trace(row)%dispatch%legacy_l == 5 .and. &
            trace(row)%dispatch%form_selector == 25) then
            write(*, '(10(es24.16e3,:,a))') &
                trace(row)%form%z, achar(9), &
                trace(row)%form%qb, achar(9), &
                trace(row)%form%qk, achar(9), &
                trace(row)%form%zr, achar(9), &
                trace(row)%form%zb, achar(9), &
                trace(row)%form%brn, achar(9), &
                trace(row)%form%ter, achar(9), &
                trace(row)%form%tei, achar(9), &
                trace(row)%form%der, achar(9), &
                trace(row)%form%dei
            stop
        end if
    end do
    stop 3
end program cm12_prdlt_field_probe
