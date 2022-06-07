module dct_v32p_wrapper (iClk,
    iRst_n,
    iSDAT,
    iSVAL,
    iValid,
    oSDAT,
    oSVAL,
    vccd1,
    vccd2,
    vdda1,
    vdda2,
    vssa1,
    vssa2,
    vssd1,
    vssd2,
    iSize);
 input iClk;
 input iRst_n;
 input iSDAT;
 input iSVAL;
 input iValid;
 output oSDAT;
 output oSVAL;
 input vccd1;
 input vccd2;
 input vdda1;
 input vdda2;
 input vssa1;
 input vssa2;
 input vssd1;
 input vssd2;
 input [2:0] iSize;


 DCT_V32P_TOP mprj (.iClk(iClk),
    .iRst_n(iRst_n),
    .iSDAT(iSDAT),
    .iSVAL(iSVAL),
    .iValid(iValid),
    .oSDAT(oSDAT),
    .oSVAL(oSVAL),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .iSize({iSize[2],
    iSize[1],
    iSize[0]}));
endmodule
