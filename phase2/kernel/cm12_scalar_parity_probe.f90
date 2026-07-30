program cm12_scalar_parity_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: &
        cm12_dataset, cm12_evaluate_multipole, cm12_ok, load_cm12_dataset
    implicit none

    integer, parameter :: case_count = 14
    character(len=3), parameter :: wave(case_count) = [ &
        character(len=3) :: &
        'S11', 'S31', 'P11', 'P31', 'P13', 'P33', 'D13', &
        'D33', 'D15', 'D35', 'F15', 'F17', 'F35', 'F37' ]
    integer, parameter :: family(case_count) = [ &
        3, 1, 4, 2, 3, 1, 3, 1, 3, 1, 3, 3, 1, 1 ]
    integer, parameter :: j_branch(case_count) = [ &
        2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 2, 1, 2 ]
    integer, parameter :: orbital_l(case_count) = [ &
        0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3 ]
    real(real32), parameter :: energies(3) = [ &
        1100.0_real32, 1500.0_real32, 1900.0_real32 ]

    type(cm12_dataset) :: dataset
    integer :: nfmp(6, 2, 6)
    common /solnform/ nfmp
    character(len=1024) :: root
    character(len=512) :: message
    integer :: status
    integer :: case_index
    integer :: energy_index
    integer :: parameter_index
    integer :: mjl
    real(real32) :: parameters(30)
    real(real32) :: legacy_real
    real(real32) :: legacy_imag
    real(real32) :: ys
    complex(real32) :: seam_value
    logical :: exact
    external :: ys

    if (command_argument_count() /= 1) then
        write(*, '(a)') 'usage: cm12-scalar-parity-probe KCM_ROOT'
        stop 64
    end if
    call get_command_argument(1, root)
    call load_cm12_dataset(trim(root), dataset, status, message)
    if (status /= cm12_ok) then
        write(*, '(a,i0,1x,a)') 'status=', status, trim(message)
        stop 1
    end if

    nfmp = 135
    do parameter_index = 1, 30
        parameters(parameter_index) = &
            0.0025_real32 * real(parameter_index, real32)
    end do

    write(*, '(a)') &
        'wave' // achar(9) // 'wcm_mev' // achar(9) // &
        'legacy_real' // achar(9) // 'legacy_imag' // achar(9) // &
        'seam_real' // achar(9) // 'seam_imag' // achar(9) // 'exact'

    do case_index = 1, case_count
        mjl = &
            100 * family(case_index) + 10 * j_branch(case_index) + &
            orbital_l(case_index)
        do energy_index = 1, size(energies)
            legacy_real = ys( &
                12.0_real32, energies(energy_index), mjl, parameters)
            legacy_imag = ys( &
                -12.0_real32, energies(energy_index), mjl, parameters)
            call cm12_evaluate_multipole( &
                dataset, 135, parameters, family(case_index), &
                j_branch(case_index), orbital_l(case_index), &
                energies(energy_index), 0.0_real32, seam_value, &
                status, message)
            if (status /= cm12_ok) then
                write(*, '(a,i0,1x,a)') 'status=', status, trim(message)
                stop 2
            end if
            exact = &
                legacy_real == real(seam_value, kind=real32) .and. &
                legacy_imag == aimag(seam_value)
            write(*, '(a,a,f0.1,a,4(es16.8,a),l1)') &
                wave(case_index), achar(9), energies(energy_index), &
                achar(9), legacy_real, achar(9), legacy_imag, achar(9), &
                real(seam_value, kind=real32), achar(9), &
                aimag(seam_value), achar(9), exact
            if (.not. exact) stop 3
        end do
    end do
end program cm12_scalar_parity_probe

subroutine prborn(energy, multipoles, form)
    use, intrinsic :: iso_fortran_env, only: real32
    implicit none

    real(real32), intent(in) :: energy
    real(real32), intent(out) :: multipoles(6, 2, 6)
    integer, intent(in) :: form

    if (energy < -huge(energy) .or. form < 0) stop 99
    multipoles = 0.0_real32
end subroutine prborn

integer function imjl(mjl, m, j, l)
    implicit none

    integer, intent(in) :: mjl
    integer, intent(out) :: m
    integer, intent(out) :: j
    integer, intent(out) :: l
    integer :: encoded
    integer :: parity

    encoded = mjl / 100
    imjl = 0
    if (mjl > 1000) imjl = mjl - 100 * encoded
    if (mjl < 1000) encoded = mjl
    m = encoded / 100
    j = (encoded - 100 * m) / 10
    l = encoded - 100 * m - 10 * j
    if (m < 1 .or. m > 9) imjl = -1
    if (j /= 1 .and. j /= 2) imjl = -1
    if (l < 0 .or. l > 6) imjl = -1
    if (l == 0 .and. j == 1) imjl = -1
    if (m > 6) return
    parity = m - 2 * (m / 2)
    if (l == 0 .and. parity == 0) imjl = -1
    if (l == 1 .and. j == 1 .and. parity == 1) imjl = -1
end function imjl
