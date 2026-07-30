C Headless ABI boundary for the renderer-facing calls made by libxz.
C
C These routines intentionally preserve only call compatibility. Scientific
C code and libxz state handling remain unchanged; drawing, cursor input, and
C renderer control are disabled for the non-plotting executable. SAIDPS keeps
C the transaction log and exit messages but omits mail-back and PostScript
C conversion after reading the final response.

      SUBROUTINE SAIDPS
      CHARACTER A*79
      CALL DATEA(NM,ND,NY)
      OPEN(51,FILE='SAID.LOG',STATUS='UNKNOWN')
      REWIND 51
    1 READ(51,100,END=2) A
  100 FORMAT(A)
      IF(A.NE.'QQQQ') GO TO 1
    2 BACKSPACE 51
      WRITE(A,103) NM,ND,NY
  103 FORMAT(' SAID- ',A2,'/',A2,'/',A2)
      WRITE(51,102) A
  102 FORMAT(' ',A)
      A='QQQQ'
      WRITE(51,100) A
      WRITE(*,101)
  101 FORMAT(' Messages can be sent to: ',
     C/' mparis@gwu.edu or rworkman@gwu.edu',
     C/' Thanks for using SAID')
      WRITE(*,109)
  109 FORMAT(' The SAID files can be retrieved through MAIL'
     C,/' by entering "M". Enter "M" or RETURN(to skip)->',$)
      READ(5,100,END=99) A
   99 RETURN
      END

      SUBROUTINE CLEAR_PLOT
      RETURN
      END

      SUBROUTINE CLTRANS
      RETURN
      END

      SUBROUTINE CROSSHAIR_R(X,Y,CODE,XL,YL)
      REAL X,Y,XL,YL
      BYTE CODE
      X=XL
      Y=YL
      CODE=ICHAR('0')
      RETURN
      END

      SUBROUTINE FLUSH_PLOT
      RETURN
      END

      SUBROUTINE GPLOT_CONTROL(PROMPT_IN,*)
      CHARACTER*(*) PROMPT_IN
      RETURN
      END

      SUBROUTINE HARDCOPY_RANGE(XMINH,XMAXH,YMINH,YMAXH,
     C XMINHP,XMAXHP,YMINHP,YMAXHP,IORIENTH,*)
      REAL XMINH,XMAXH,YMINH,YMAXH
      REAL XMINHP,XMAXHP,YMINHP,YMAXHP
      INTEGER IORIENTH
      RETURN
      END

      SUBROUTINE MONITOR_RANGE(IMONITOR,IOUTM,
     C XMINH,XMAXH,YMINH,YMAXH,
     C XMINM,XMAXM,YMINM,YMAXM,IORIENTM,*)
      INTEGER IMONITOR,IOUTM,IORIENTM
      REAL XMINH,XMAXH,YMINH,YMAXH
      REAL XMINM,XMAXM,YMINM,YMAXM
      RETURN
      END

      SUBROUTINE PLOT_COLOR(ICODE,ICODE2)
      INTEGER ICODE,ICODE2
      RETURN
      END

      SUBROUTINE PLOT_DATA_LEVEL(ILEVEL)
      INTEGER ILEVEL
      RETURN
      END

      SUBROUTINE PLOT_R(X,Y,IPEN)
      REAL X,Y
      INTEGER IPEN
      RETURN
      END

      SUBROUTINE PSYM(X,Y,HEIGHT,STRING,ANGLE,LENGTH,*)
      REAL X,Y,HEIGHT,ANGLE
      BYTE STRING(1)
      INTEGER LENGTH
      RETURN
      END

      SUBROUTINE TRANSPARENT_MODE(ICLEAR)
      INTEGER ICLEAR
      RETURN
      END
