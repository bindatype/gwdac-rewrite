program cm12_pure_kernel_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_ok
    use cm12_solution_kernel, only: &
        cm12_accumulate_multipole, cm12_domain_error, cm12_evaluate_dsg, &
        cm12_solution, load_cm12_solution
    implicit none

    integer, parameter :: case_count = 6
    integer, parameter :: reactions(case_count) = [ 1, 2, 3, 4, 2, 3 ]
    integer, parameter :: families(case_count) = [ 1, 2, 3, 4, 5, 6 ]
    integer, parameter :: branches(case_count) = [ 2, 1, 2, 1, 2, 1 ]
    integer, parameter :: orbital_l(case_count) = [ 0, 1, 2, 3, 4, 5 ]
    real(real32), parameter :: angles(case_count) = [ &
        0.0_real32, 37.0_real32, 90.0_real32, 180.0_real32, &
        123.4_real32, 10.0_real32 ]

    integer :: mtrn
    integer :: ir
    integer :: mm
    integer :: jj
    integer :: ll
    integer :: nn
    integer :: ne
    integer :: na
    integer :: ie
    integer :: ia
    integer :: ii
    integer :: nnbt
    integer :: it
    integer :: nprm
    real(real32) :: title(18)
    real(real32) :: dttl(18)
    integer :: mttl(8)
    integer :: ittl(40)
    real(real32) :: emr(70, 6, 2, 6)
    real(real32) :: emi(70, 6, 2, 6)
    real(real32) :: ttli(18)
    real(real32) :: e(70)
    real(real32) :: zkcm(70)
    real(real32) :: qcm(70)
    real(real32) :: epi(70)
    integer :: nf(6, 2, 6)
    real(real32) :: pem(25, 6, 2, 6)
    real(real32) :: bas(4, 10)
    real(real32) :: hr(4, 70)
    real(real32) :: hi(4, 70)
    real(real32) :: hrx(4)
    real(real32) :: hix(4)
    real(real32) :: p0(99)
    real(real32) :: ddp(99)
    real(real32) :: ethr
    real(real32) :: yz(99)
    real(real32) :: ermtx(7000)
    real(real32) :: dum(100)
    real(real32) :: a(100)
    real(real32) :: obsx(200)
    real(real32) :: err(200)
    real(real32) :: tex(200)
    real(real32) :: obs(99)
    real(real32) :: dobs(99)
    real(real32) :: xex(600)
    integer :: nbt(99)
    real(real32) :: cis(6, 2)
    real(real32) :: ch(4, 4, 6)
    real(real32) :: hdat(3)
    integer :: ir0
    real(real32) :: thtx(200)
    integer :: ninc
    integer :: nincmx
    integer :: nnl
    integer :: nmttl
    integer :: nittl
    real(real32) :: der
    real(real32) :: dei
    real(real32) :: dpz(99)
    real(real32) :: obsprd

    common /prsc/ &
        mtrn, ir, mm, jj, ll, nn, ne, na, ie, ia, ii, nnbt, it, nprm, &
        title, dttl, mttl, ittl, emr, emi, ttli, e, zkcm, qcm, epi, &
        nf, pem, bas, hr, hi, hrx, hix, p0, ddp, ethr, yz, ermtx, &
        dum, a, obsx, err, tex, obs, dobs, xex, nbt, cis, ch, hdat, &
        ir0, thtx, ninc, nincmx, nnl, nmttl, nittl, der, dei, dpz, &
        obsprd

    type(cm12_solution) :: solution
    character(len=1024) :: solution_path
    character(len=64) :: solution_sha256
    character(len=512) :: message
    complex(real32) :: initial_amplitudes(4)
    complex(real32) :: pure_amplitudes(4)
    complex(real32) :: legacy_amplitudes(4)
    complex(real32) :: multipole
    complex(real32) :: dsg_amplitudes(4)
    real(real32) :: dsg
    integer :: status
    integer :: case_index
    integer :: k
    logical :: exact
    external :: prda

    if (command_argument_count() /= 2) then
        write(*, '(a)') &
            'usage: cm12-pure-kernel-probe SOLUTION_FILE SHA256'
        stop 64
    end if
    call get_command_argument(1, solution_path)
    call get_command_argument(2, solution_sha256)
    call load_cm12_solution( &
        trim(solution_path), trim(solution_sha256), 'CM12', solution, &
        status, message)
    if (status /= cm12_ok) stop 1

    call clear_legacy_state()
    ia = 1
    ii = 1
    write(*, '(a)') &
        'section' // achar(9) // 'case' // achar(9) // 'exact'
    do case_index = 1, case_count
        ir = reactions(case_index)
        mm = families(case_index)
        jj = branches(case_index)
        ll = orbital_l(case_index) + 1
        a(ia) = angles(case_index)
        der = 0.75_real32 * real(case_index, real32)
        dei = -0.125_real32 * real(case_index, real32)
        multipole = cmplx(der, dei, kind=real32)
        do k = 1, 4
            initial_amplitudes(k) = cmplx( &
                0.1_real32 * real(case_index * k, real32), &
                -0.05_real32 * real(case_index + k, real32), kind=real32)
            hr(k, ii) = real(initial_amplitudes(k), kind=real32)
            hi(k, ii) = aimag(initial_amplitudes(k))
        end do

        call prda
        do k = 1, 4
            legacy_amplitudes(k) = cmplx(hrx(k), hix(k), kind=real32)
        end do
        call cm12_accumulate_multipole( &
            solution, ir, a(ia), mm, jj, ll - 1, multipole, &
            initial_amplitudes, pure_amplitudes, status, message)
        if (status /= cm12_ok) stop 2
        exact = all(legacy_amplitudes == pure_amplitudes)
        write(*, '(a,a,i0,a,l1)') &
            'prda', achar(9), case_index, achar(9), exact
        if (.not. exact) stop 3
    end do

    dsg_amplitudes = cmplx(0.0_real32, 0.0_real32, kind=real32)
    dsg_amplitudes(1) = cmplx(3.0_real32, 4.0_real32, kind=real32)
    call cm12_evaluate_dsg( &
        1000.0_real32, 145.0_real32, 4.0_real32, 2.0_real32, &
        dsg_amplitudes, dsg, status, message)
    exact = status == cm12_ok .and. dsg == 0.0625_real32
    write(*, '(a,a,a,a,l1)') &
        'dsg', achar(9), 'formula', achar(9), exact
    if (.not. exact) stop 4

    call cm12_evaluate_dsg( &
        100.0_real32, 145.0_real32, 4.0_real32, 0.0_real32, &
        dsg_amplitudes, dsg, status, message)
    exact = status == cm12_domain_error .and. dsg == 0.0_real32
    write(*, '(a,a,a,a,l1)') &
        'dsg', achar(9), 'threshold-rejection', achar(9), exact
    if (.not. exact) stop 5

    call cm12_evaluate_dsg( &
        1000.0_real32, 145.0_real32, 0.0_real32, 2.0_real32, &
        dsg_amplitudes, dsg, status, message)
    exact = status == cm12_domain_error
    write(*, '(a,a,a,a,l1)') &
        'dsg', achar(9), 'invalid-domain', achar(9), exact
    if (.not. exact) stop 6

contains

    subroutine clear_legacy_state()
        real(real32) :: orbital
        real(real32) :: sqrt_two
        integer :: l

        mtrn = 0
        ir = 0
        mm = 0
        jj = 0
        ll = 0
        nn = 0
        ne = 0
        na = 0
        ie = 0
        ia = 0
        ii = 0
        nnbt = 0
        it = 0
        nprm = 0
        title = 0.0_real32
        dttl = 0.0_real32
        mttl = 0
        ittl = 0
        emr = 0.0_real32
        emi = 0.0_real32
        ttli = 0.0_real32
        e = 0.0_real32
        zkcm = 0.0_real32
        qcm = 0.0_real32
        epi = 0.0_real32
        nf = 0
        pem = 0.0_real32
        bas = 0.0_real32
        hr = 0.0_real32
        hi = 0.0_real32
        hrx = 0.0_real32
        hix = 0.0_real32
        p0 = 0.0_real32
        ddp = 0.0_real32
        ethr = 0.0_real32
        yz = 0.0_real32
        ermtx = 0.0_real32
        dum = 0.0_real32
        a = 0.0_real32
        obsx = 0.0_real32
        err = 0.0_real32
        tex = 0.0_real32
        obs = 0.0_real32
        dobs = 0.0_real32
        xex = 0.0_real32
        nbt = 0
        cis = 0.0_real32
        ch = 0.0_real32
        hdat = 0.0_real32
        ir0 = 0
        thtx = 0.0_real32
        ninc = 0
        nincmx = 0
        nnl = 0
        nmttl = 0
        nittl = 0
        der = 0.0_real32
        dei = 0.0_real32
        dpz = 0.0_real32
        obsprd = 0.0_real32

        sqrt_two = sqrt(2.0_real32)
        cis(1, :) = [ 1.0_real32, 2.0_real32 / 3.0_real32 ]
        cis(2, :) = [ sqrt_two, -sqrt_two / 3.0_real32 ]
        cis(3, :) = [ sqrt_two, sqrt_two / 3.0_real32 ]
        cis(4, :) = [ -1.0_real32, 2.0_real32 / 3.0_real32 ]
        do l = 1, 6
            orbital = real(l - 1, real32)
            ch(1, :, l) = [ &
                -1.0_real32, -1.0_real32, 1.0_real32, -1.0_real32 ]
            ch(2, :, l) = [ &
                orbital, -orbital - 2.0_real32, &
                orbital + 2.0_real32, orbital ]
            ch(3, :, l) = [ &
                1.0_real32, 1.0_real32, 1.0_real32, -1.0_real32 ]
            ch(4, :, l) = [ &
                -orbital, orbital + 2.0_real32, &
                orbital + 2.0_real32, orbital ]
        end do
    end subroutine clear_legacy_state

end program cm12_pure_kernel_probe
