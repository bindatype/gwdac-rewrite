program cm12_prbas_rescaling_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_prbas_dispatch, only: cm12_apply_pnpwi_threshold_rescaling
    implicit none

    character(len=1024) :: fixture_path
    character(len=2048) :: header
    integer :: fixture_unit
    integer :: io_status
    integer :: orbital_l
    integer :: row_id
    real(real32) :: actual_imag
    real(real32) :: actual_real
    real(real32) :: expected_imag
    real(real32) :: expected_real
    real(real32) :: input_energy_mev
    real(real32) :: unscaled_imag
    real(real32) :: unscaled_real

    if (command_argument_count() /= 1) then
        write(*, '(a)') &
            'usage: cm12-prbas-rescaling-probe THRESHOLD_FIXTURE'
        stop 64
    end if
    call get_command_argument(1, fixture_path)
    open( &
        newunit=fixture_unit, file=trim(fixture_path), status='old', &
        action='read', iostat=io_status)
    if (io_status /= 0) stop 1
    read(fixture_unit, '(a)', iostat=io_status) header
    if (io_status /= 0) stop 2

    write(*, '(a)') &
        'row_id' // achar(9) // 'orbital_l' // achar(9) // &
        'input_energy_mev' // achar(9) // 'unscaled_real' // achar(9) // &
        'unscaled_imag' // achar(9) // 'expected_real' // achar(9) // &
        'expected_imag' // achar(9) // 'actual_real' // achar(9) // &
        'actual_imag' // achar(9) // 'real_exact' // achar(9) // 'imag_exact'
    do
        read(fixture_unit, *, iostat=io_status) &
            row_id, orbital_l, input_energy_mev, unscaled_real, &
            unscaled_imag, expected_real, expected_imag
        if (io_status < 0) exit
        if (io_status /= 0) stop 3
        actual_real = unscaled_real
        actual_imag = unscaled_imag
        call cm12_apply_pnpwi_threshold_rescaling( &
            input_energy_mev, orbital_l, actual_real, actual_imag)
        write(*, '(I0,A,I0,A,7(ES25.16E3,A),L1,A,L1)') &
            row_id, achar(9), orbital_l, achar(9), &
            input_energy_mev, achar(9), unscaled_real, achar(9), &
            unscaled_imag, achar(9), expected_real, achar(9), &
            expected_imag, achar(9), actual_real, achar(9), &
            actual_imag, achar(9), actual_real == expected_real, achar(9), &
            actual_imag == expected_imag
        if (actual_real /= expected_real .or. actual_imag /= expected_imag) &
            stop 4
    end do
    close(fixture_unit)
end program cm12_prbas_rescaling_probe
