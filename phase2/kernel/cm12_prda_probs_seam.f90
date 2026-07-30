subroutine cm12solutionform(family, j_branch, legacy_l, form_selector)
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: cm12_ok
    use cm12_solution_kernel, only: &
        cm12_solution, cm12_solution_multipole
    use cm12_legacy_context, only: legacy_cm12_solution
    implicit none

    integer, intent(in) :: family
    integer, intent(in) :: j_branch
    integer, intent(in) :: legacy_l
    integer, intent(out) :: form_selector

    type(cm12_solution), pointer :: solution
    real(real32) :: parameters(25)
    integer :: status
    character(len=256) :: message

    call legacy_cm12_solution(solution)
    call cm12_solution_multipole( &
        solution, family, j_branch, legacy_l - 1, form_selector, &
        parameters, status, message)
    if (status /= cm12_ok) form_selector = 0
end subroutine cm12solutionform

subroutine cm12solutionkill(kill)
    use, intrinsic :: iso_fortran_env, only: real32
    implicit none

    real(real32), intent(out) :: kill

    kill = 0.0_real32
end subroutine cm12solutionkill

subroutine prda
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: cm12_ok
    use cm12_solution_kernel, only: &
        cm12_accumulate_multipole, cm12_solution
    use cm12_legacy_context, only: legacy_cm12_solution
    implicit none

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

    type(cm12_solution), pointer :: solution
    complex(real32) :: initial_amplitudes(4)
    complex(real32) :: amplitudes(4)
    complex(real32) :: multipole
    real(real32) :: angle_cm_deg
    integer :: status
    integer :: k
    character(len=256) :: message
    external :: prda_legacy

    call legacy_cm12_solution(solution)
    if ( &
        .not. ieee_is_finite(der) .or. &
        .not. ieee_is_finite(dei)) then
        call prda_legacy
        return
    end if
    do k = 1, 4
        initial_amplitudes(k) = cmplx( &
            hr(k, ii), hi(k, ii), kind=real32)
    end do
    multipole = cmplx(der, dei, kind=real32)
    angle_cm_deg = a(ia)
    if (abs(angle_cm_deg) < 0.01_real32) angle_cm_deg = 0.0_real32
    if (abs(angle_cm_deg - 180.0_real32) < 0.01_real32) then
        angle_cm_deg = 180.0_real32
    end if
    call cm12_accumulate_multipole( &
        solution, ir, angle_cm_deg, mm, jj, ll - 1, multipole, &
        initial_amplitudes, amplitudes, status, message)
    if (status /= cm12_ok) then
        write(*, '(a)') 'CM12 PRDA evaluation failed: ' // trim(message)
        error stop 8
    end if
    do k = 1, 4
        hrx(k) = real(amplitudes(k), kind=real32)
        hix(k) = aimag(amplitudes(k))
    end do
end subroutine prda

subroutine probs
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: cm12_ok
    use cm12_solution_kernel, only: cm12_evaluate_dsg
    implicit none

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

    complex(real32) :: amplitudes(4)
    integer :: status
    integer :: k
    character(len=256) :: message
    external :: probs_legacy

    if ( &
        it /= 1 .or. .not. ieee_is_finite(e(ie)) .or. &
        .not. ieee_is_finite(zkcm(ie)) .or. &
        .not. ieee_is_finite(qcm(ie)) .or. &
        e(ie) <= ethr .or. &
        any(.not. ieee_is_finite(hrx)) .or. &
        any(.not. ieee_is_finite(hix))) then
        call probs_legacy
        return
    end if

    do k = 1, 4
        amplitudes(k) = cmplx(hrx(k), hix(k), kind=real32)
    end do
    call cm12_evaluate_dsg( &
        e(ie), ethr, zkcm(ie), qcm(ie), amplitudes, obsprd, &
        status, message)
    if (status /= cm12_ok) then
        write(*, '(a)') 'CM12 DSG evaluation failed: ' // trim(message)
        error stop 9
    end if
end subroutine probs
