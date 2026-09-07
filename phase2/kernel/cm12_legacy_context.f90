module cm12_legacy_context
    use cm12_kernel, only: &
        cm12_dataset, cm12_invalid_argument, cm12_ok, load_cm12_dataset
    use cm12_non_cm12_seam, only: &
        cm12_background_grid_state, cm12_begin_background_grid, &
        cm12_finish_background_grid
    use cm12_prbas_dispatch, only: &
        cm12_initialize_prbas_process, cm12_invalidate_prbas_process, &
        cm12_load_prbas_solution_selector, cm12_prbas_dispatch_state
    use cm12_solution_kernel, only: &
        cm12_solution, cm12_solution_summary, load_cm12_solution
    implicit none
    private

    character(len=64), parameter :: canonical_solution_sha256 = &
        'dbcaae30bbf44aca6e5482fc2b10b81cb6e1033cf41061bc089d5f6a85576522'

    type(cm12_dataset), save, target :: dataset
    type(cm12_solution), save, target :: solution
    type(cm12_prbas_dispatch_state), save :: prbas_process_state
    character(len=4), save :: prbas_loaded_solution_selector = ''
    logical, save :: initialized = .false.
    logical, save :: prbas_process_initialized = .false.
    logical, save :: prbas_solution_observed = .false.
    integer, save :: prbas_solution_status = cm12_invalid_argument
    character(len=512), save :: prbas_solution_message = &
        'legacy solution load has not initialized typed PRBAS state'

    public :: legacy_cm12_objects
    public :: legacy_cm12_prbas_begin
    public :: legacy_cm12_prbas_commit
    public :: legacy_cm12_prbas_invalidate
    public :: legacy_cm12_prbas_solution_loaded
    public :: legacy_cm12_solution

contains

    subroutine legacy_cm12_objects(dataset_result, solution_result)
        type(cm12_dataset), pointer, intent(out) :: dataset_result
        type(cm12_solution), pointer, intent(out) :: solution_result

        call initialize_context()
        dataset_result => dataset
        solution_result => solution
    end subroutine legacy_cm12_objects

    subroutine legacy_cm12_solution(solution_result)
        type(cm12_solution), pointer, intent(out) :: solution_result

        call initialize_context()
        solution_result => solution
    end subroutine legacy_cm12_solution

    subroutine legacy_cm12_prbas_solution_loaded(solution_selector)
        character(len=*), intent(in) :: solution_selector

        type(cm12_prbas_dispatch_state) :: next_state

        if (.not. prbas_process_initialized) then
            call cm12_initialize_prbas_process(prbas_process_state)
            prbas_process_initialized = .true.
        end if
        call cm12_load_prbas_solution_selector( &
            prbas_process_state, solution_selector, next_state, &
            prbas_solution_status, prbas_solution_message)
        if (prbas_solution_status /= cm12_ok) then
            prbas_solution_observed = .false.
            return
        end if
        prbas_process_state = next_state
        prbas_loaded_solution_selector = solution_selector(1:4)
        prbas_solution_observed = .true.
    end subroutine legacy_cm12_prbas_solution_loaded

    subroutine legacy_cm12_prbas_invalidate()
        type(cm12_prbas_dispatch_state) :: next_state

        if (.not. prbas_process_initialized) then
            call cm12_initialize_prbas_process(prbas_process_state)
            prbas_process_initialized = .true.
        end if
        call cm12_invalidate_prbas_process(prbas_process_state, next_state)
        prbas_process_state = next_state
    end subroutine legacy_cm12_prbas_invalidate

    subroutine legacy_cm12_prbas_begin( &
        reaction, grid_state, status, message)
        integer, intent(in) :: reaction
        type(cm12_background_grid_state), intent(out) :: grid_state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=4) :: solution_identifier
        character(len=64) :: source_sha256
        character(len=72) :: solution_title
        character(len=1024) :: source_path
        integer :: explicit_records
        integer :: max_partial_wave

        grid_state = cm12_background_grid_state()
        call initialize_context()
        if (.not. prbas_solution_observed) then
            status = prbas_solution_status
            message = trim(prbas_solution_message)
            return
        end if
        call cm12_solution_summary( &
            solution, solution_identifier, solution_title, source_path, &
            source_sha256, explicit_records, max_partial_wave)
        if (prbas_loaded_solution_selector /= solution_title(57:60)) then
            status = cm12_invalid_argument
            message = &
                'legacy and immutable CM12 solution selectors do not match'
            return
        end if
        call cm12_begin_background_grid( &
            solution, reaction, prbas_process_state, grid_state, &
            status, message)
    end subroutine legacy_cm12_prbas_begin

    subroutine legacy_cm12_prbas_commit(grid_state, status, message)
        type(cm12_background_grid_state), intent(in) :: grid_state
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        type(cm12_prbas_dispatch_state) :: next_state

        call cm12_finish_background_grid( &
            grid_state, next_state, status, message)
        if (status /= cm12_ok) return
        prbas_process_state = next_state
    end subroutine legacy_cm12_prbas_commit

    subroutine initialize_context()
        character(len=1024) :: dataset_root
        character(len=1024) :: solution_path
        character(len=512) :: message
        character(len=64) :: solution_sha256
        character(len=4) :: solution_id
        integer :: status
        integer :: length

        if (initialized) return

        dataset_root = ''
        call get_environment_variable( &
            'CM12_KCM_ROOT', dataset_root, length=length, status=status)
        if (status /= 0 .or. length == 0) dataset_root = 'KCM'

        solution_path = ''
        call get_environment_variable( &
            'CM12_SOLUTION_FILE', solution_path, &
            length=length, status=status)
        if (status /= 0 .or. length == 0) then
            solution_path = '../sdat/prsol.dat'
        end if

        solution_sha256 = ''
        call get_environment_variable( &
            'CM12_SOLUTION_SHA256', solution_sha256, &
            length=length, status=status)
        if (status /= 0 .or. length == 0) then
            solution_sha256 = canonical_solution_sha256
        end if

        solution_id = ''
        call get_environment_variable( &
            'CM12_SOLUTION_ID', solution_id, length=length, status=status)
        if (status /= 0 .or. length == 0) solution_id = 'CM12'

        call load_cm12_dataset( &
            trim(dataset_root), dataset, status, message)
        if (status /= cm12_ok) then
            write(*, '(a)') 'CM12 dataset load failed: ' // trim(message)
            error stop 2
        end if
        call load_cm12_solution( &
            trim(solution_path), trim(solution_sha256), solution_id, &
            solution, status, message)
        if (status /= cm12_ok) then
            write(*, '(a)') 'CM12 solution load failed: ' // trim(message)
            error stop 3
        end if
        initialized = .true.
    end subroutine initialize_context

end module cm12_legacy_context

subroutine cm12prbassolutionloaded(solution_selector_word)
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_legacy_context, only: legacy_cm12_prbas_solution_loaded
    implicit none

    real(real32), intent(in) :: solution_selector_word

    character(len=4) :: solution_selector

    solution_selector = transfer(solution_selector_word, solution_selector)
    call legacy_cm12_prbas_solution_loaded(solution_selector)
end subroutine cm12prbassolutionloaded
