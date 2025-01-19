# 计算BC_DRE

## modifiy namelist

- Physics modifications via the namelist in user_nl_cam

- modify namelists using the $CASEROOT/user_nl_cam file，[how to change a namelist variable?](https://www2.cesm.ucar.edu/events/tutorials/2011/practicals_hannay.pdf)

- [Modifying namelist settings in CAM run](https://ncar.github.io/CAM/doc/build/html/users_guide/building-and-running-cam.html#building-and-running-cam)

- 参照[!!以此为准Black carbon radiative forcing](https://ncar.github.io/CAM/doc/build/html/CAM6.0_users_guide/physics-modifications-via-the-namelist.html#example-black-carbon-radiative-forcing) section 8.5 修改namelist

  ```
  # 网站中列出的其中：
  'mam4_mode4_nobc:primary_carbon:=',
    'A:num_a4:N:num_c4:num_mr:+',
    'A:pom_a4:N:pom_c4:p-organic:/fs/cgd/csm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
    'A:bc_a4:N:bc_c4:black-c:/fs/cgd/csm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'
  
  # 应该把最后一条'A:bc_a4:N:bc_c4:black-c:/fs/cgd/csm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'删掉
  # 修正如下：
  'mam4_mode4_nobc:primary_carbon:=',
    'A:num_a4:N:num_c4:num_mr:+',
    'A:pom_a4:N:pom_c4:p-organic:/fs/cgd/csm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+'
    
  ```
  
  

[default rad_climate for cam6 physics](https://ncar.github.io/CAM/doc/build/html/users_guide/physics-modifications-via-the-namelist.html#def-rad-clim)

we see from the default definitions of the `trop_mam4`[mode](https://ncar.github.io/CAM/doc/build/html/users_guide/physics-modifications-via-the-namelist.html#def-rad-clim) that black carbon is contained in `mam4_mode1` and `mam4_mode4`

- mode_defs 默认调用辐射模块时，会计算所有气溶胶产生的辐射通量值（FSNT, FLNT等）。为了计算BC_DRE，在跑模型是会二次调用辐射模块，并在第二次调用中把bc移除掉，对应的输出变量为FSNT_d1，FLNT_d1 等。 将默认变量和*_d1的插值作为BC造成的辐射通量变化

- 不对default直接进行改变，而是另外增加'mam4_mode1_nobc:accum:='和'mam4_mode4:primary_carbon:='

- 删掉了'mam4_mode4:primary_carbon:='中的'A:bc_a4:N:bc_c4:black-c:$INPUTROOT/atm/cam/physprops/bcpho_rrtmg_c100508.nc'

- radiation 有short-wave radiation (solar radiation) 和long-wave radiation (land surface radiation) 两部分组成，其中black carbon 主要和short-wave radiation有关

  

```
mode_defs =
'mam4_mode1:accum:=',
  'A:num_a1:N:num_c1:num_mr:+',
  'A:so4_a1:N:so4_c1:sulfate:$INPUTROOT/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+',
  'A:pom_a1:N:pom_c1:p-organic:$INPUTROOT/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
  'A:soa_a1:N:soa_c1:s-organic:$INPUTROOT/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
  'A:bc_a1:N:bc_c1:black-c:$INPUTROOT/atm/cam/physprops/bcpho_rrtmg_c100508.nc:+',
  'A:dst_a1:N:dst_c1:dust:$INPUTROOT/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+',
  'A:ncl_a1:N:ncl_c1:seasalt:$INPUTROOT/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode2:aitken:=',
  'A:num_a2:N:num_c2:num_mr:+',
  'A:so4_a2:N:so4_c2:sulfate:$INPUTROOT/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+',
  'A:soa_a2:N:soa_c2:s-organic:$INPUTROOT/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
  'A:ncl_a2:N:ncl_c2:seasalt:$INPUTROOT/atm/cam/physprops/ssam_rrtmg_c100508.nc:+',
  'A:dst_a2:N:dst_c2:dust:$INPUTROOT/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc',
'mam4_mode3:coarse:=',
  'A:num_a3:N:num_c3:num_mr:+',
  'A:dst_a3:N:dst_c3:dust:$INPUTROOT/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+',
  'A:ncl_a3:N:ncl_c3:seasalt:$INPUTROOT/atm/cam/physprops/ssam_rrtmg_c100508.nc:+',
  'A:so4_a3:N:so4_c3:sulfate:$INPUTROOT/atm/cam/physprops/sulfate_rrtmg_c080918.nc',
'mam4_mode4:primary_carbon:=',
  'A:num_a4:N:num_c4:num_mr:+',
  'A:pom_a4:N:pom_c4:p-organic:$INPUTROOT/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
  'A:bc_a4:N:bc_c4:black-c:$INPUTROOT/atm/cam/physprops/bcpho_rrtmg_c100508.nc',

# define 'mam4_mode1_nobc'和'mam4_mode4_nobc'
'mam4_mode1_nobc:accum:=',
  'A:num_a1:N:num_c1:num_mr:+',
  'A:so4_a1:N:so4_c1:sulfate:$INPUTROOT/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+',
  'A:pom_a1:N:pom_c1:p-organic:$INPUTROOT/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
  'A:soa_a1:N:soa_c1:s-organic:$INPUTROOT/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
  'A:dst_a1:N:dst_c1:dust:$INPUTROOT/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+',
  'A:ncl_a1:N:ncl_c1:seasalt:$INPUTROOT/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode4_nobc:primary_carbon:=',
  'A:num_a4:N:num_c4:num_mr:+',
  'A:pom_a4:N:pom_c4:p-organic:$INPUTROOT/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
  

# add the radiation diagnostics
rad_diag_1 =
 'A:Q:H2O', 'N:O2:O2', 'N:CO2:CO2', 'N:ozone:O3',
 'N:N2O:N2O', 'N:CH4:CH4', 'N:CFC11:CFC11', 'N:CFC12:CFC12',
 'M:mam4_mode1_nobc:$INPUTROOT/atm/cam/physprops/mam4_mode1_rrtmg_aeronetdust_sig1.6_dgnh.48_c140304.nc',
 'M:mam4_mode2:$INPUTROOT/atm/cam/physprops/mam4_mode2_rrtmg_aitkendust_c141106.nc',
 'M:mam4_mode3:$INPUTROOT/atm/cam/physprops/mam4_mode3_rrtmg_aeronetdust_sig1.2_dgnl.40_c150219.nc',
 'M:mam4_mode4_nobc:$INPUTROOT/atm/cam/physprops/mam4_mode4_rrtmg_c130628.nc',
 'N:VOLC_MMR1:$INPUTROOT/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode1_c170214.nc',
 'N:VOLC_MMR2:$INPUTROOT/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode2_c170214.nc',
 'N:VOLC_MMR3:$INPUTROOT/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.2_mode3_c170214.nc'
```

## output field

```
 # add the radiation variables with “_d1” to write out the rad_diag_1 results
 fincl1         = 'FSNT','FSNT_d1','FSNTC_d1','FLNT','FLNT_d1','FLNTC_d1'
 fincl2         = 'FLNT', 'FLNR','FLNS', 'FSNT','FSNR', 'FSNS'
 
 # FSNT is the all-sky TOA shortwave net radiation flux. 
 # FSNT_d1 is the all-sky TOA shortwave net radiation flux without BC. 
 # FSNT - FSNT_d1 = all-sky BC shortwave radiative effect. 
 # FSNTC is the clear-sky TOA shortwave radiative flux.
 # FSNTC_d1 is the clear-sky TOA shortwave radiative flux. clear-sky 没有云
 # FSNTC-FSNTC_d1 is the clear-sky BC shortwave radiative effect.
 # 'FL' means longwave flux (i.e. terrestrial)
 # 'FS' means shortwave flux (i.e. solar)
 # 'U' = up
 # 'D' = down
 # 'N' = net
 # 'T' = top of atmosphere
 # 'S' = surface
```

- var1=ds['FSNT']-ds['FSNT_d1']是BC造成的短波辐射在TOA（Top of atmosphere）的变化。

- var3 = ds['FLNT']-ds['FLNT']是BC造成的长波辐射的TOA的变化

- BC_DRE = var1 - var3 (辐射变化向下为正，向上为负)

- 有时候想计算所有气溶胶的DRE，或者只是OC_DRE，则需要多次调用该辐射模块，相应生成 FSNT_d2，FSNT_d3等变量

- 硫酸盐的气溶胶=so4_a1+so4_a2+so4_a3进行计算，可以不用H2SO4这个变量；