C     Subprogram performing an A4 formatted round trip through an
C     internal file, the pattern legacy SAID uses for title records.
      SUBROUTINE RT(R,O)
      CHARACTER*80 R,O
      CHARACTER*4 CW(20)
      READ(R,100) (CW(I),I=1,20)
      WRITE(O,100) (CW(I),I=1,20)
  100 FORMAT(20A4)
      END
