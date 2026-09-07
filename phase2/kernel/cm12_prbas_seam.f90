subroutine prbas
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: cm12_dataset, cm12_ok
    use cm12_prbas_dispatch, only: cm12_validate_prbas_ambient
    use cm12_solution_kernel, only: &
        cm12_calculate_kinematics, cm12_kinematics, cm12_solution
    use cm12_request_kernel, only: &
        cm12_background_grid_state, cm12_evaluate_request, &
        cm12_prepare_legacy_angle_background, &
        cm12_prepare_legacy_background, cm12_prepared_background, &
        cm12_request, cm12_request_result
    use cm12_legacy_context, only: &
        legacy_cm12_objects, legacy_cm12_prbas_begin, &
        legacy_cm12_prbas_commit, legacy_cm12_prbas_invalidate
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
    real(real32) :: gom1
    real(real32) :: gom2
    real(real32) :: goms
    real(real32) :: gpi2
    real(real32) :: gp1
    real(real32) :: gp2
    integer :: irct
    real(real32) :: bcoff
    integer :: iprk
    real(real32) :: pg(20, 4, 8)
    integer :: nfg(4, 8)

    common /prsc/ &
        mtrn, ir, mm, jj, ll, nn, ne, na, ie, ia, ii, nnbt, it, nprm, &
        title, dttl, mttl, ittl, emr, emi, ttli, e, zkcm, qcm, epi, &
        nf, pem, bas, hr, hi, hrx, hix, p0, ddp, ethr, yz, ermtx, &
        dum, a, obsx, err, tex, obs, dobs, xex, nbt, cis, ch, hdat, &
        ir0, thtx, ninc, nincmx, nnl, nmttl, nittl, der, dei, dpz, &
        obsprd
    common /gomega/ gom1, gom2, goms, gpi2, gp1, gp2, irct, bcoff
    common /prkc/ iprk
    common /pglob/ pg, nfg

    type(cm12_dataset), pointer :: dataset
    type(cm12_solution), pointer :: solution
    type(cm12_request) :: request
    type(cm12_prepared_background) :: background
    type(cm12_background_grid_state) :: grid_state
    type(cm12_request_result) :: result
    type(cm12_kinematics) :: validation_kinematics
    character(len=512) :: message
    integer :: energy_index
    integer :: angle_index
    integer :: result_index
    integer :: status
    integer :: k
    integer :: cm12_diagnostic
    integer :: diagnostic_length
    integer :: diagnostic_status
    character(len=8) :: diagnostic_value
    integer :: mode_length
    integer :: mode_status
    character(len=16) :: mode_value
    external :: prbas_legacy
    common /cm12diag/ cm12_diagnostic

    cm12_diagnostic = 0
    diagnostic_value = ''
    call get_environment_variable( &
        'CM12_FORCE_LEGACY_PRBAS', diagnostic_value, &
        length=diagnostic_length, status=diagnostic_status)
    if ( &
        diagnostic_status == 0 .and. diagnostic_length > 0 .and. &
        diagnostic_value(1:1) == '1') then
        cm12_diagnostic = 1
        call fallback_to_legacy
        return
    end if
    mode_value = ''
    call get_environment_variable( &
        'CM12_PRBAS_MODE', mode_value, &
        length=mode_length, status=mode_status)
    if ( &
        mode_status == 0 .and. mode_length > 0 .and. &
        trim(mode_value) == 'legacy') then
        call fallback_to_legacy
        return
    end if
    if (.not. retained_request_is_valid()) then
        call fallback_to_legacy
        return
    end if

    call legacy_cm12_objects(dataset, solution)
    call legacy_cm12_prbas_begin(ir, grid_state, status, message)
    if (status /= cm12_ok) then
        call fallback_to_legacy
        return
    end if
    result_index = 1
    do energy_index = 1, ne
        ie = energy_index
        request = cm12_request( &
            reaction=ir, photon_lab_energy_mev=e(energy_index), &
            angle_cm_deg=a(1))
        call cm12_prepare_legacy_background( &
            solution, request, background, status, message, &
            grid_state=grid_state)
        if (status /= cm12_ok) then
            call stop_after_typed_failure( &
                'background preparation', message)
        end if
        do angle_index = 1, na
            ia = angle_index
            request = cm12_request( &
                reaction=ir, photon_lab_energy_mev=e(energy_index), &
                angle_cm_deg=a(angle_index))
            if (angle_index > 1) then
                call cm12_prepare_legacy_angle_background( &
                    solution, request, background, status, message)
                if (status /= cm12_ok) then
                    call stop_after_typed_failure( &
                        'angle background preparation', message)
                end if
            end if
            call cm12_evaluate_request( &
                solution, dataset, request, background, result, &
                status, message)
            if (status /= cm12_ok) then
                call stop_after_typed_failure('request evaluation', message)
            end if

            ethr = result%kinematics%threshold_lab_energy_mev
            epi(energy_index) = result%kinematics%final_meson_energy_mev
            zkcm(energy_index) = &
                result%kinematics%photon_cm_momentum_mev
            qcm(energy_index) = &
                result%kinematics%meson_cm_momentum_mev
            do k = 1, 4
                hr(k, result_index) = &
                    real(result%amplitudes_mfm(k), kind=real32)
                hi(k, result_index) = aimag(result%amplitudes_mfm(k))
                hrx(k) = hr(k, result_index)
                hix(k) = hi(k, result_index)
            end do
            obs(result_index) = result%dsg_microbarn_per_sr
            obsprd = result%dsg_microbarn_per_sr
            result_index = result_index + 1
        end do
    end do
    call legacy_cm12_prbas_commit(grid_state, status, message)
    if (status /= cm12_ok) then
        call stop_after_typed_failure('process-state commit', message)
    end if
    ii = result_index

contains

    logical function retained_request_is_valid()
        integer :: energy
        integer :: angle
        integer :: validation_status
        character(len=512) :: validation_message

        retained_request_is_valid = .false.
        if (transfer(title(1), '    ') /= 'CM12') return
        if (ir0 /= 0 .or. ir < 1 .or. ir > 4) return
        if (nnbt /= 0) return
        if (ne < 1 .or. ne > 70 .or. na < 1 .or. na > 99) return
        if (ne * na > 70) return
        call cm12_validate_prbas_ambient( &
            it, nnl, iprk, bcoff, pem(25, 6, 2, 6), nfg, pg, &
            validation_status, validation_message)
        if (validation_status /= cm12_ok) return
        do energy = 1, ne
            if ( &
                .not. ieee_is_finite(e(energy)) .or. &
                e(energy) <= 0.0_real32) return
            call cm12_calculate_kinematics( &
                ir, e(energy), validation_kinematics, &
                validation_status, validation_message)
            if (validation_status /= cm12_ok) return
            if ( &
                e(energy) <= &
                validation_kinematics%threshold_lab_energy_mev) return
        end do
        do angle = 1, na
            if ( &
                .not. ieee_is_finite(a(angle)) .or. &
                a(angle) < 0.0_real32 .or. &
                a(angle) > 180.0_real32) return
        end do
        retained_request_is_valid = .true.
    end function retained_request_is_valid

    subroutine fallback_to_legacy()
        call legacy_cm12_prbas_invalidate
        call prbas_legacy
    end subroutine fallback_to_legacy

    subroutine stop_after_typed_failure(operation, failure_message)
        character(len=*), intent(in) :: operation
        character(len=*), intent(in) :: failure_message

        write(*, '(a)') &
            'Typed CM12 PRBAS ' // trim(operation) // &
            ' failed after dispatch began: ' // trim(failure_message)
        error stop 9
    end subroutine stop_after_typed_failure

end subroutine prbas
