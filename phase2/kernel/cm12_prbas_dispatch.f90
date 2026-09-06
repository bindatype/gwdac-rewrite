module cm12_prbas_dispatch
    use, intrinsic :: iso_fortran_env, only: real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: cm12_invalid_argument, cm12_ok
    implicit none
    private

    integer, parameter, public :: cm12_pntest_branch = 7

    type, public :: cm12_prbas_dispatch_state
        logical :: background_reset_pending = .true.
        character(len=4) :: current_title = ''
        character(len=4) :: previous_title = ''
        real(real32) :: next_dither_mev = 0.001_real32
    end type cm12_prbas_dispatch_state

    type, public :: cm12_prbas_dispatch_event
        logical :: dispatch = .false.
        integer :: family = 0
        integer :: branch = 0
        integer :: orbital_l = 0
        integer :: legacy_l = 0
        integer :: state_index = 0
        integer :: form_selector = 0
        integer :: dispatch_branch = 0
        character(len=4) :: dispatch_title = ''
        character(len=4) :: previous_title = ''
        real(real32) :: pre_reset_energy_mev = 0.0_real32
        real(real32) :: input_energy_mev = 0.0_real32
        real(real32) :: effective_energy_mev = 0.0_real32
        real(real32) :: dither_before_mev = 0.0_real32
    end type cm12_prbas_dispatch_event

    public :: cm12_begin_prbas_dispatch
    public :: cm12_initialize_prbas_process
    public :: cm12_load_prbas_solution_selector
    public :: cm12_next_prbas_dispatch
    public :: cm12_record_prbas_formula_title
    public :: cm12_validate_prbas_ambient

contains

    pure subroutine cm12_begin_prbas_dispatch( &
        solution_title, state, status, message)
        character(len=*), intent(in) :: solution_title
        type(cm12_prbas_dispatch_state), intent(out) :: state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        type(cm12_prbas_dispatch_state) :: initialized_state

        call cm12_initialize_prbas_process(initialized_state)
        if (len(solution_title) < 60) then
            state = initialized_state
            status = cm12_invalid_argument
            message = 'CM12 title does not contain the hadronic selector'
            return
        end if
        call cm12_load_prbas_solution_selector( &
            initialized_state, solution_title(57:60), state, status, message)
    end subroutine cm12_begin_prbas_dispatch

    pure subroutine cm12_initialize_prbas_process(state)
        type(cm12_prbas_dispatch_state), intent(out) :: state

        state = cm12_prbas_dispatch_state()
    end subroutine cm12_initialize_prbas_process

    pure subroutine cm12_load_prbas_solution_selector( &
        state, solution_selector, next_state, status, message)
        type(cm12_prbas_dispatch_state), intent(in) :: state
        character(len=*), intent(in) :: solution_selector
        type(cm12_prbas_dispatch_state), intent(out) :: next_state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        next_state = state
        if (len(solution_selector) < 4) then
            status = cm12_invalid_argument
            message = 'CM12 hadronic selector is incomplete'
            return
        end if
        if ( &
            solution_selector(1:4) /= 'M05 ' .and. &
            solution_selector(1:4) /= 'SP00') then
            status = cm12_invalid_argument
            message = 'unsupported CM12 hadronic dispatch title'
            return
        end if
        next_state%current_title = solution_selector(1:4)
        status = cm12_ok
        message = ''
    end subroutine cm12_load_prbas_solution_selector

    pure subroutine cm12_validate_prbas_ambient( &
        it, nnl, iprk, bcoff, kill, nfg, pg, status, message)
        integer, intent(in) :: it
        integer, intent(in) :: nnl
        integer, intent(in) :: iprk
        real(real32), intent(in) :: bcoff
        real(real32), intent(in) :: kill
        integer, intent(in) :: nfg(:, :)
        real(real32), intent(in) :: pg(:, :, :)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        if (it /= 1) then
            status = cm12_invalid_argument
            message = 'typed PRBAS requires retained IT=1'
            return
        end if
        if (nnl /= 6) then
            status = cm12_invalid_argument
            message = 'typed PRBAS requires retained NNL=6'
            return
        end if
        if (iprk /= 0) then
            status = cm12_invalid_argument
            message = 'typed PRBAS does not support IPRK scaling'
            return
        end if
        if (.not. ieee_is_finite(bcoff) .or. bcoff /= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'typed PRBAS requires retained BCOFF=0'
            return
        end if
        if (.not. ieee_is_finite(kill) .or. kill /= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'typed PRBAS requires retained KILL=0'
            return
        end if
        if (any(nfg /= 0)) then
            status = cm12_invalid_argument
            message = 'typed PRBAS does not support PNMOD overrides'
            return
        end if
        if ( &
            any(.not. ieee_is_finite(pg)) .or. &
            any(pg /= 0.0_real32)) then
            status = cm12_invalid_argument
            message = 'typed PRBAS does not support PGLOB parameters'
            return
        end if
        status = cm12_ok
        message = ''
    end subroutine cm12_validate_prbas_ambient

    pure subroutine cm12_next_prbas_dispatch( &
        state, family, branch, orbital_l, form_selector, input_energy_mev, &
        event, next_state, status, message)
        type(cm12_prbas_dispatch_state), intent(in) :: state
        integer, intent(in) :: family
        integer, intent(in) :: branch
        integer, intent(in) :: orbital_l
        integer, intent(in) :: form_selector
        real(real32), intent(in) :: input_energy_mev
        type(cm12_prbas_dispatch_event), intent(out) :: event
        type(cm12_prbas_dispatch_state), intent(out) :: next_state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        event = cm12_prbas_dispatch_event()
        next_state = state
        if ( &
            family < 1 .or. family > 6 .or. &
            branch < 1 .or. branch > 2 .or. &
            orbital_l < 0 .or. orbital_l > 5 .or. &
            form_selector <= 0 .or. &
            .not. ieee_is_finite(input_energy_mev) .or. &
            input_energy_mev <= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'invalid PRBAS dispatch input'
            return
        end if

        event%family = family
        event%branch = branch
        event%orbital_l = orbital_l
        event%legacy_l = orbital_l + 1
        event%state_index = branch
        if (family <= 2) event%state_index = event%state_index + 2
        event%form_selector = form_selector
        event%pre_reset_energy_mev = input_energy_mev

        if (state%background_reset_pending) then
            next_state%background_reset_pending = .false.
            status = cm12_ok
            message = ''
            return
        end if

        if ( &
            state%current_title /= 'M05 ' .and. &
            state%current_title /= 'SP00') then
            status = cm12_invalid_argument
            message = 'unsupported CM12 hadronic dispatch title'
            return
        end if

        event%dispatch = .true.
        event%dispatch_branch = cm12_pntest_branch
        event%dispatch_title = state%current_title
        event%previous_title = state%previous_title
        event%input_energy_mev = input_energy_mev
        event%effective_energy_mev = input_energy_mev
        event%dither_before_mev = state%next_dither_mev
        if (state%current_title /= state%previous_title) then
            event%effective_energy_mev = &
                input_energy_mev + state%next_dither_mev
            next_state%next_dither_mev = -state%next_dither_mev
            next_state%previous_title = state%current_title
        end if

        status = cm12_ok
        message = ''
    end subroutine cm12_next_prbas_dispatch

    pure subroutine cm12_record_prbas_formula_title( &
        state, formula_title, next_state, status, message)
        type(cm12_prbas_dispatch_state), intent(in) :: state
        character(len=4), intent(in) :: formula_title
        type(cm12_prbas_dispatch_state), intent(out) :: next_state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        integer :: character_index

        next_state = state
        if (len_trim(formula_title) == 0) then
            status = cm12_invalid_argument
            message = 'frozen hadronic formula returned an empty title'
            return
        end if
        do character_index = 1, len(formula_title)
            if ( &
                iachar(formula_title(character_index:character_index)) < 32 .or. &
                iachar(formula_title(character_index:character_index)) > 126) then
                status = cm12_invalid_argument
                message = &
                    'frozen hadronic formula returned a non-printable title'
                return
            end if
        end do
        next_state%current_title = formula_title
        status = cm12_ok
        message = ''
    end subroutine cm12_record_prbas_formula_title

end module cm12_prbas_dispatch
