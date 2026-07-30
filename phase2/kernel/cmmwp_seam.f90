subroutine cmmwp
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: &
        cm12_dataset, cm12_evaluate_multipole, cm12_ok
    use cm12_solution_kernel, only: &
        cm12_background_constants, cm12_solution, &
        cm12_solution_background, cm12_solution_multipole
    use cm12_background_seam, only: cm12_evaluate_born_multipoles
    use cm12_legacy_context, only: legacy_cm12_objects
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

    type(cm12_dataset), pointer :: dataset
    type(cm12_solution), pointer :: solution
    type(cm12_background_constants) :: background
    complex(real32) :: multipole
    real(real32) :: parameters(25)
    real(real32) :: born(6, 2, 6)
    real(real32) :: opec(6, 2, 6)
    real(real32) :: born_multipole
    real(real32) :: photon_lab_energy_mev
    real(real32) :: w_cm_mev
    real(real32), parameter :: proton_mass = 938.256_real32
    integer :: decoded_m
    integer :: decoded_j
    integer :: decoded_l
    integer :: form_number
    integer :: imjl
    integer :: status
    character(len=512) :: message
    external :: imjl
    external :: prborn

    der = 0.0_real32
    dei = 0.0_real32

    ! Preserve the frozen adapter's accidental /PRSC/ II mutation. The pure
    ! scalar API has no such output or side effect.
    ii = imjl( &
        100 * mm + 10 * jj + ll - 1, decoded_m, decoded_j, decoded_l)
    if (ii < 0) then
        write(*, '(a,4i6)') &
            'invalid CM12 multipole index:', mm, jj, ll, ii
        error stop 3
    end if

    call legacy_cm12_objects(dataset, solution)
    call cm12_solution_multipole( &
        solution, mm, jj, ll - 1, form_number, parameters, &
        status, message)
    if (status /= cm12_ok) then
        write(*, '(a)') 'CM12 solution lookup failed: ' // trim(message)
        error stop 4
    end if
    w_cm_mev = sqrt( &
        proton_mass**2 + 2.0_real32 * e(ie) * proton_mass)

    born_multipole = 0.0_real32
    if (form_number / 10 == 13) then
        photon_lab_energy_mev = &
            (w_cm_mev**2 - proton_mass**2) / &
            (2.0_real32 * proton_mass)
        call cm12_solution_background( &
            solution, background, status, message)
        if (status /= cm12_ok) then
            write(*, '(a)') &
                'CM12 background lookup failed: ' // trim(message)
            error stop 5
        end if
        if ( &
            ieee_is_finite(photon_lab_energy_mev) .and. &
            photon_lab_energy_mev > 0.0_real32) then
            call cm12_evaluate_born_multipoles( &
                background, photon_lab_energy_mev, born, opec, &
                status, message)
            if (status /= cm12_ok) then
                write(*, '(a)') &
                    'CM12 Born evaluation failed: ' // trim(message)
                error stop 6
            end if
        else
            ! Preserve only the frozen malformed-grid behavior. The public
            ! background seam rejects this non-finite domain.
            call prborn(photon_lab_energy_mev, born, 5)
        end if
        born_multipole = born(mm, jj, ll)
    end if

    call cm12_evaluate_multipole( &
        dataset, form_number, parameters, mm, jj, ll - 1, w_cm_mev, &
        born_multipole, multipole, status, message)
    if (status /= cm12_ok) then
        write(*, '(a)') 'CM12 multipole evaluation failed: ' // trim(message)
        error stop 7
    end if

    der = real(multipole, kind=real32)
    dei = aimag(multipole)
end subroutine cmmwp
