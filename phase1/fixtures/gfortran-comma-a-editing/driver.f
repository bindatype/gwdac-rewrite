C     Exercises the A4 round trip on a record taken from arndt64/KN/
C     KNSOL.USR. Exit status 0 when the comma survives, 1 when it does
C     not. The -std= setting of THIS unit, the main program, governs the
C     process-global formatted-input semantics established through
C     _gfortran_set_options.
      PROGRAM DRIVER
      CHARACTER*80 R,O
      R='PRMS=(62,27) TAIL'
      CALL RT(R,O)
      IF(O(1:17).EQ.R(1:17)) THEN
        WRITE(6,*) 'PRESERVED ',O(1:17)
        CALL EXIT(0)
      ELSE
        WRITE(6,*) 'CORRUPT   ',O(1:17)
        CALL EXIT(1)
      ENDIF
      END
