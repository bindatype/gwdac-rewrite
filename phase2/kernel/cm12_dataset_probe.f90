program cm12_dataset_probe
    use, intrinsic :: iso_fortran_env, only: real32
    use cm12_kernel, only: &
        cm12_dataset, cm12_dataset_summary, cm12_ok, load_cm12_dataset
    implicit none

    type(cm12_dataset) :: dataset
    character(len=1024) :: root
    character(len=1024) :: loaded_root
    character(len=512) :: message
    integer :: status
    integer :: waves
    integer :: rows
    real(real32) :: first_energy
    real(real32) :: last_energy

    if (command_argument_count() /= 1) then
        write(*, '(a)') 'usage: cm12-dataset-probe KCM_ROOT'
        stop 64
    end if
    call get_command_argument(1, root)
    call load_cm12_dataset(trim(root), dataset, status, message)
    if (status /= cm12_ok) then
        write(*, '(a,i0,1x,a)') 'status=', status, trim(message)
        stop 1
    end if

    call cm12_dataset_summary( &
        dataset, loaded_root, waves, rows, first_energy, last_energy)
    write(*, '(a)') &
        'root' // achar(9) // 'waves' // achar(9) // 'rows' // &
        achar(9) // 'first_wcm_mev' // achar(9) // 'last_wcm_mev'
    write(*, '(a,a,i0,a,i0,a,f0.1,a,f0.1)') &
        trim(loaded_root), achar(9), waves, achar(9), rows, achar(9), &
        first_energy, achar(9), last_energy
end program cm12_dataset_probe
