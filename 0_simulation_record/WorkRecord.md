[case control system](http://esmci.github.io/cime/versions/cesm2.2/html/users_guide/index.html)

[CESM Tutorial](https://ncar.github.io/CESM-Tutorial/notebooks/modifications/xml/exercises/xml_runtype_exercise.html)



# 0809 运行流程

## 准备工作

```
ssh zhonghua@10.141.12.196
输入密码：Manchestermedal

export ZLIBDIR=/home/zhonghua/CESM/Libs/zlib-1.2.12
export HDF5DIR=/home/zhonghua/CESM/Libs/hdf5-1_12_2
export NETCDFCDIR=/home/zhonghua/CESM/Libs/netcdf-c-4.9.0
export NETCDFFDIR=/home/zhonghua/CESM/Libs/netcdf-fortran-4.6.0
export PNETCDFDIR=/home/zhonghua/CESM/Libs/pnetcdf-1.12.3
export MPICHDIR=/home/zhonghua/CESM/Libs/mpich-4.0.2
export CIMEROOT=/home/zhonghua/my_cesm_sandbox/cime
export INPUTROOT=/home/zhonghua/projects/cesm/inputdata

export LD_LIBRARY_PATH=$ZLIBDIR/lib:$HDF5DIR/lib:$NETCDFCDIR/lib:$NETCDFFDIR/lib:$MPICHDIR/lib:$PNETCDFDIR/lib:$LD_LIBRARY_PATH

export PATH=$HDF5DIR/bin:$NETCDFCDIR/bin:$NETCDFFDIR/bin:$MPICHDIR/bin:$PNETCDFDIR/bin:$PATH

export MPICC=mpicc
export MPICXX=mpicxx
export MPIFC=mpifort
```



## Spin-up

```
#spin-up阶段:运行1年
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/TestRun --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/TestRun/
./xmlchange RUN_TYPE=startup
./xmlchange RUN_STARTDATE=2013-11-12 #仅适用于startup和hybrid模式下
./xmlchange GET_REFCASE=FALSE
./xmlchange STOP_N=1
./xmlchange STOP_OPTION=nyears

./case.setup
./case.setup --reset
./case.build
./case.build --clean
./case.submit

cat CaseStatus #查看运行情况，包括xmlchange是否修改成功

#查看运行状态：
#运行过程文件在/run 中
cd $HOME/projects/cesm/scratch/TestRun/run
ls -al
#运行结束后的文件在archive中,当 case.st_archive运行后
cd /home/zhonghua/projects/cesm/archive/case/rest/2014-11-12-00000

cat CaseStatus
#结果
case.run success
st_archive starting
st_archive sucess
#如果出现case.submit error ERROR: No result from jobs [('case.run', None), ('case.st_archive', 'case.run or case.test')]没有关系，可以忽略



./xmlquery RUN_REFDATE
#结果：1979-01-01
./xmlquery RUN_REFCASE
#结果：f.e20.FHIST.f09_f09.cesm2_1.001_v2

#查看模拟结果
cd $HOME/projects/cesm/archive/case/rest/2014-11-12-0000
```



## 目标运行

[ref](https://blog.csdn.net/qq_38607066/article/details/109445839?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169229785616800226564763%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169229785616800226564763&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~baidu_landing_v2~default-1-109445839-null-null.142^v93^insert_down1&utm_term=GET_REFCASE&spm=1018.2226.3001.4187)

[starting-from-a-refcase](https://esmci.github.io/cime/versions/master/html/users_guide/running-a-case.html#starting-from-a-refcase)

[Setting up a branch or hybrid run](http://esmci.github.io/cime/versions/master/html/users_guide/cime-change-namelist.html#setting-up-a-branch-or-hybrid-run)



For a branch run, `env_run.xml` for EXAMPLE_CASEp should be identical to EXAMPLE_CASE, except for the $RUN_TYPE setting [ref](https://www2.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x1894.html)



要设置分支运行，请找到RUN_REFCASE和RUN_REFDATE的restart tar文件或restart目录，然后将这些文件放在RUNDIR目录中[ref](https://blog.csdn.net/z894730988/article/details/119427832?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169229365816800188531465%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169229365816800188531465&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-4-119427832-null-null.142^v93^insert_down1&utm_term=cesm%20branch&spm=1018.2226.3001.4187)

```
#目标阶段：运行1天
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/FormalRun --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/FormalRun/
#在env_run.xml中修改

./xmlchange RUN_TYPE=branch
./xmlchange GET_REFCASE=FALSE
./xmlchange RUN_REFDATE=2014-11-12
./xmlchange RUN_REFCASE=TestRun
./xmlchange STOP_N=1,STOP_OPTION=ndays,RESUBMIT=0

#branch中无需设置RUN_STARTDATE
#RUN_STARTDATE(YYY-MM-DD) 只适用于startup或者hybrid run
#./xmlchange RUN_STARTDATE=2014-11-12

#查看
./xmlquery RUN_TYPE 
./xmlquery GET_REFCASE 
./xmlquery RUN_REFCASE 
./xmlquery RUN_REFDATE

./case.setup

cp $HOME/projects/cesm/archive/case/rest/2014-11-12-00000/* $HOME/projects/cesm/scratch/FormalRun/run/

# 编辑user_nl_cam文件
vim user_nl_cam
nhtfrq=0,-3
mfilt=1,8
fincl2='T:I','RELHUM:I','SZA:I','SOAG_SRF:I','DMS_SRF:I','H2SO4_SRF:I','O3:I','H2O2_SRF:I','SO2_SRF:I','bc_a1_SRF:I','bc_a4_SRF:I','dst_a1_SRF:I','dst_a2_SRF:I','dst_a3_SRF:I','ncl_a1_SRF:I','ncl_a2_SRF:I','ncl_a3_SRF:I','pom_a1_SRF:I','pom_a4_SRF:I','so4_a1_SRF:I','so4_a2_SRF:I','so4_a3_SRF:I','soa_a1_SRF:I','soa_a2_SRF:I'

:wq


# 在运行前检查参数设置
#查看 运行类型，运行开始时间，结束选项，结束选项对应的数字，结束时间
./xmlquery RUN_TYPE,RUN_STARTDATE,STOP_OPTION,STOP_N,STOP_DATE
#查看 重启选项，重启数字，继续运行选项，重新提交是否继续运行
./xmlquery REST_OPTION,REST_N,CONTINUE_RUN,RESUBMIT,RESUBMIT_SETS_CONTINUE_RUN

./preview_namelists
./preview_run
# 发现CASE INFO 不符合
nodes: 4
  total tasks: 144
  tasks per node: 36
  thread count: 1
# 修改env_mach_pes.xml  
 
./xmlquery  ATM_NTASKS,CPL_NTASKS,GLC_NTASKS,ICE_NTASKS,LND_NTASKS,OCN_NTASKS,ROF_NTASKS,WAV_NTASKS

./xmlchange ATM_NTASKS=36,CPL_NTASKS=36,GLC_NTASKS=36,ICE_NTASKS=36,LND_NTASKS=36,OCN_NTASKS=36,ROF_NTASKS=36,WAV_NTASKS=36

./case.setup --reset

./case.build --clean
./case.build
./case.submit


# 出现error, 重来
rm -r FormalRun


#查看模拟结果
cd $HOME/projects/cesm/archive/case/rest/2014-11-13-0000
```

inputdata 位置：cd /home/zhonghua/projects/cesm/inputdata



# 延长FHIST时间

目标时间：13-27 November, 2016

```
#spin-up阶段:运行1年
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/SpinupRun --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/SpinupRun/
./xmlchange RUN_TYPE=startup
./xmlchange RUN_STARTDATE=2015-11-12
./xmlchange GET_REFCASE=FALSE
./xmlchange STOP_N=1
./xmlchange STOP_OPTION=nyears

./case.setup
./case.setup --reset
./case.build
./case.build --clean
./case.submit

cat CaseStatus #查看运行情况，包括xmlchange是否修改成功

#查看运行状态：
#运行过程文件在/run 中
cd $HOME/projects/cesm/scratch/SpinupRun/run
ls -al
#运行结束后的文件在archive中,当 case.st_archive运行后
cd /home/zhonghua/projects/cesm/archive/case/rest/2016-11-12-00000(跑完后确认)

#目标运行阶段
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/FormalRun2308 --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/FormalRun2308/
#在env_run.xml中修改

./xmlchange RUN_TYPE=branch
./xmlchange GET_REFCASE=FALSE
./xmlchange RUN_REFDATE=2016-11-12
./xmlchange RUN_REFCASE=TestRun
./xmlchange STOP_N=17,STOP_OPTION=ndays,RESUBMIT=0

./case.setup

cp $HOME/projects/cesm/archive/case/rest/2016-11-12-00000/* $HOME/projects/cesm/scratch/FormalRun2308/run/

# 编辑user_nl_cam文件
vim user_nl_cam
nhtfrq=0,-3
mfilt=1,8
fincl2='T:I','RELHUM:I','SZA:I','SOAG_SRF:I','DMS_SRF:I','H2SO4_SRF:I','O3:I','H2O2_SRF:I','SO2_SRF:I','bc_a1_SRF:I','bc_a4_SRF:I','dst_a1_SRF:I','dst_a2_SRF:I','dst_a3_SRF:I','ncl_a1_SRF:I','ncl_a2_SRF:I','ncl_a3_SRF:I','pom_a1_SRF:I','pom_a4_SRF:I','so4_a1_SRF:I','so4_a2_SRF:I','so4_a3_SRF:I','soa_a1_SRF:I','soa_a2_SRF:I'

:wq

#延长时间见下一节

./preview_namelists
./preview_run
# 发现CASE INFO 不符合
nodes: 4
  total tasks: 144
  tasks per node: 36
  thread count: 1

# 修改env_mach_pes.xml   
./xmlquery  ATM_NTASKS,CPL_NTASKS,GLC_NTASKS,ICE_NTASKS,LND_NTASKS,OCN_NTASKS,ROF_NTASKS,WAV_NTASKS
./xmlchange ATM_NTASKS=36,CPL_NTASKS=36,GLC_NTASKS=36,ICE_NTASKS=36,LND_NTASKS=36,OCN_NTASKS=36,ROF_NTASKS=36,WAV_NTASKS=36

./case.setup --reset

./case.build --clean
./case.build
./case.submit

```



## compset FHIST

**思路1：**

You can certainly run CAM and CAM-chem for more recent years.

We have some general information here:

[https://wiki.ucar.edu/display/camchem/Changing+Dates+of+a+Run [wiki.ucar.edu\]](https://urldefense.com/v3/__https://wiki.ucar.edu/display/camchem/Changing*Dates*of*a*Run__;KysrKw!!PDiH4ENfjr2_Jw!E0A9dpEc942NC10B0sjni7f3_KCW8TFhDT4WG6GrekcktWD-4AHKayj44ESHl1DmH5K7i4yup0U8O034oZZFCFVzZNwQQYap$)

And information about various emissions files are here:https://wiki.ucar.edu/display/camchem/Emission+Inventories

```
# Ensure emissions cover the dates specified. Default emissions can be determined by looking at the CaseDocs/atm_in file.
# default emissions can be found in CaseDocs/atm_in after a default build

cat CaseDocs/atm_in

#重复使用某些年的emissions,参考：change emissions input,https://wiki.ucar.edu/display/camchem/Change+emissions+input
#在user_nl_cam中添加：
#示例
&chem_inparm
 ext_frc_specifier      = '$species_name1 -> $path_to_vertically_gridded_emissions, $species_name2 -> $path_to_vertically_gridded_emissions'
 srf_emis_specifier     = '$species_name1 -> $path_to_surface_emissions, $species_name2 -> $path_to_to_surface_emissions'
 srf_emis_type          = 'SERIAL'
/
#修改chem_inparm可参考：https://bb.cgd.ucar.edu/cesm/threads/brcp45c5cn-extension-to-2300.8355/,以及参考：https://ncar.github.io/CAM/doc/build/html/users_guide/customizing-compsets.html,以及参考：https://bb.cgd.ucar.edu/cesm/threads/cam6-aerosol-emission-in-a-specific-year.5459/

vim user_nl_cam
ext_frc_specifier  = 'H2O -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/elev/H2OemissionCH4oxidationx2_3D_L70_1849-2015_CMIP6ensAvg_c180927.nc',
                     'SO2         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',                    
                     'num_a1      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
                     'num_a2      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
                     'so4_a1      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_num_so4_a1_anthro-ene_vertical_1750-2015_0.9x1.25_c20170616.nc',
                     'so4_a1      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
                     'so4_a2      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc'


srf_emis_specifier = 'DMS         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_DMS_bb_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'DMS         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_DMS_other_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'SO2         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_anthro-ag-ship-res_surface_1750-2015_0.9x1.25_c20170616.nc',
                     'SO2         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_anthro-ene_surface_1750-2015_0.9x1.25_c20170616.nc',
                     'SO2         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_bb_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'SOAG         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SOAGx1.5_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',
                     'SOAG         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SOAGx1.5_biogenic_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'SOAG         -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SOAGx1.5_bb_surface_1750-2015_0.9x1.25_c20170322.nc',                                    
                     'bc_a4       -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_bc_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',
                     'bc_a4       -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_bc_a4_bb_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'num_a1      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_so4_a1_anthro-ag-ship_surface_1750-2015_0.9x1.25_c20170616.nc',
                     'num_a1      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_so4_a1_bb_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'num_a2      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_so4_a2_anthro-res_surface_1750-2015_0.9x1.25_c20170616.nc',
                     'num_a4      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_bc_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',
                     'num_a4      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_bc_a4_bb_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'num_a4      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_pom_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',
                     'num_a4      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_pom_a4_bb_surface_1750-2015_0.9x1.25_c20170509.nc',
                     'so4_a1      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_num_so4_a1_anthro-ag-ship_surface_1750-2015_0.9x1.25_c20170616.nc',
                     'so4_a1      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_num_so4_a1_bb_surface_1750-2015_0.9x1.25_c20170322.nc',
                     'so4_a2      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_num_so4_a2_anthro-res_surface_1750-2015_0.9x1.25_c20170616.nc',
                     'pom_a4      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_pom_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',
                     'pom_a4      -> $HOME/projects/cesm/inputdata/atm/cam/chem/emis/emissions-cmip6_pom_a4_bb_surface_1750-2015_0.9x1.25_c20170322.nc',
                     


#并在CaseDocs/atm_in中修改
#修改后需要重新build case
#If you want to repeat emissions from one year over variable dynamics use:

&chem_inparm
 ext_frc_type           = 'CYCLICAL'
 ext_frc_cycle_yr       = 2015
 srf_emis_type          = 'CYCLICAL'
 srf_emis_cycle_yr      = 2015
/
 
&chem_surfvals_nl
 flbc_type              = 'CYCLICAL'
 flbc_cycle_yr          =  2015
/

#指定初始化文件
./xmlchange RUN_TYPE=branch
./xmlchange RUN_REFCASE=b.e21.BHIST.f19_g17.CMIP6-historical-2deg.001
./xmlchange RUN_REFDATE=2000-01-01




# 运行./preview_namelist, 并检查CaseDocs/atm_in文件，确保请求的更改已经进入CAM名称列表文件
./case.build
./case.submit

```



**思路2：**

You can also use the SSP emissions inventories for 2015 to present-day, as well as into the future.

[CAM compsets](https://ncar.github.io/CAM/doc/build/html/users_guide/atmospheric-configurations.html)

[Changing Dates of a Run](https://wiki.ucar.edu/display/camchem/Changing+Dates+of+a+Run)

[change emissions input](https://wiki.ucar.edu/display/camchem/Change+emissions+input)

[customizing CAM runs](https://ncar.github.io/CAM/doc/build/html/users_guide/customizing-compsets.html?highlight=output#modifying-namelist-settings-detailed-example-using-cmip5-emissions)

[教程2：extend FHIST time period](https://bb.cgd.ucar.edu/cesm/threads/how-can-i-extend-fhist-time-period.4619/)

- You can extend FHIST past 2014 by manually altering the namelist files to give it the forcings associated with a projection scenario e.g., SSP2-4.5 or SSP3-7.0. 
- The best way to do this is to set up a coupled case with the SSP scenario e.g., using the BSSP370 compset. Preview the namelist by running ./preview_namelists from the case directory. 
- Then go into ./CaseDocs from your case directory and look at atm_in and lnd_in and look at the forcing files that are needed. There will be many of them, especially from the atmosphere.
- Then you can set up your FHIST case and paste these namelist settings into user_nl_cam and user_nl_clm in your case directory for the FHIST run. 
- You may also need to give it an observation-based (see surface temperatures) SST file that extends up to when your run ends.



## 修改user_nl_cam

[Option1: Use the following script: echo](https://zhonghuazheng.com/Environmental-Data-Science-Book/modeling/earth-system-modeling/cesm2-quickstart.html)

```
# 修改user_nl_cam
# If using "Nudging" be sure to check that you have the appropriate meteorological files for nudging, and have 'nudge_end_year' set to an appropriate date in atm_in (user_nl_cam).
# nudge_end_year设置参考：https://bb.cgd.ucar.edu/cesm/threads/env_run-xml-variables-runtime-variables.8208/#post-48916

echo "&nudging_nl" >> user_nl_cam
    
echo " nudge_model            = .true." >> user_nl_cam
echo " model_times_per_day    = 48" >> user_nl_cam
    
echo " nudge_times_per_day    = 8" >> user_nl_cam
echo " nudge_timescale_opt    = 1" >> user_nl_cam
        
echo " nudge_beg_day          = 01 >> user_nl_cam
echo " nudge_beg_month        = 01” >> user_nl_cam
echo " nudge_beg_year         = 20”10 >> user_nl_cam
    
echo " nudge_end_day          = 31” >> user_nl_cam
echo " nudge_end_month        = 01” >> user_nl_cam
echo " nudge_end_year         = 2010” >> user_nl_cam
    
echo " nudge_path             = ~/CESM2.2/data/input/atm/cam/met/nudging/MERRA2_fv09_32L/'" >> user_nl_cam
    
echo " nudge_file_template    = '%y/MERRA2_fv09.cam2.i.%y-%m-%d-%s.nc'" >> user_nl_cam

echo " nudge_force_opt        = 0" >> user_nl_cam

echo " nudge_pscoef           = 0.00" >> user_nl_cam
echo " nudge_psprof           = 0" >> user_nl_cam
    
echo " nudge_qcoef            = 0.25" >> user_nl_cam
echo " nudge_qprof            = 1" >> user_nl_cam

echo " nudge_tcoef            = 0.25" >> user_nl_cam
echo " nudge_tprof            = 1" >> user_nl_cam
    
echo " nudge_ucoef            = 0.25" >> user_nl_cam
echo " nudge_uprof            = 1" >> user_nl_cam
    
echo " nudge_vcoef            = 0.25" >> user_nl_cam
echo " nudge_vprof            = 1" >> user_nl_cam
```



# 文件传输

```
# mac address 10.206.47.137

wget --no-check-certificate --user anonymous --password user@example.edu --spider ftp://ftp.cgd.ucar.edu/cesm/inputdata/
```



# 计算BC_DRE

- Physics modifications via the namelist in user_nl_cam

- modify namelists using the $CASEROOT/user_nl_cam file，[how to change a namelist variable?](https://www2.cesm.ucar.edu/events/tutorials/2011/practicals_hannay.pdf)

- [Modifying namelist settings in CAM run](https://ncar.github.io/CAM/doc/build/html/users_guide/building-and-running-cam.html#building-and-running-cam)

- 参照[!!以此为准Black carbon radiative forcing](https://ncar.github.io/CAM/doc/build/html/CAM6.0_users_guide/physics-modifications-via-the-namelist.html#example-black-carbon-radiative-forcing)section 8.5 修改namelist

  - 注意

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

we see from the default definitions of the `trop_mam4`[modes](https://ncar.github.io/CAM/doc/build/html/users_guide/physics-modifications-via-the-namelist.html#def-rad-clim) that black carbon is contained in `mam4_mode1` and `mam4_mode4`

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

  

# 0919 运行流程

## 准备工作

```
ssh zhonghua@10.141.12.196
输入密码：Manchestermedal

export ZLIBDIR=/home/zhonghua/CESM/Libs/zlib-1.2.12
export HDF5DIR=/home/zhonghua/CESM/Libs/hdf5-1_12_2
export NETCDFCDIR=/home/zhonghua/CESM/Libs/netcdf-c-4.9.0
export NETCDFFDIR=/home/zhonghua/CESM/Libs/netcdf-fortran-4.6.0
export PNETCDFDIR=/home/zhonghua/CESM/Libs/pnetcdf-1.12.3
export MPICHDIR=/home/zhonghua/CESM/Libs/mpich-4.0.2
export CIMEROOT=/home/zhonghua/my_cesm_sandbox/cime
export INPUTROOT=/home/zhonghua/projects/cesm/inputdata

export LD_LIBRARY_PATH=$ZLIBDIR/lib:$HDF5DIR/lib:$NETCDFCDIR/lib:$NETCDFFDIR/lib:$MPICHDIR/lib:$PNETCDFDIR/lib:$LD_LIBRARY_PATH

export PATH=$HDF5DIR/bin:$NETCDFCDIR/bin:$NETCDFFDIR/bin:$MPICHDIR/bin:$PNETCDFDIR/bin:$PATH

export MPICC=mpicc
export MPICXX=mpicxx
export MPIFC=mpifort
```



## SSP 驱动数据

- [CESM2.1.3 compset definition with supported grid](https://docs.cesm.ucar.edu/models/cesm2/config/2.1.3/compsets.html)
- 建立ssp case的目的只是为了查看cam_in和clm_in（获取驱动数据），而不需要跑SSP case.

```
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/SSP0919 --compset BSSP370cmip6 --res f09_g17 

./create_newcase --case $HOME/projects/cesm/scratch/SSP0919wan --compset BSSP370cmip6 --res f09_g17 

cd $HOME/projects/cesm/scratch/SSP0919/

./xmlchange RUN_TYPE=startup
./xmlchange RUN_STARTDATE=2015-11-12
./xmlchange GET_REFCASE=FALSE
./xmlchange STOP_N=1
./xmlchange STOP_OPTION=nyears

#
./xmlchange --append CLM_BLDNML_OPTS="-ignore_warnings"

./case.setup
./case.build
# case.build之后会生成atm.in 和lnd_in等文件
# 查看forcing setting
./preview_namelists
cd Buildconf
cd camconf
cat atm_in

cd clmconf
cat lnd_in


# 数据备份
scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/SSP0919/Buildconf/camconf/atm_in /Users/user/Desktop

scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/SSP0919/Buildconf/clmconf/lnd_in /Users/user/Desktop
```

### atm_in

```
# cat atm_in
&aerosol_nl
 aer_drydep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 aer_wetdep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 modal_accum_coarse_exch		= .true.
 seasalt_emis_scale		= 1.00D0
 sol_factb_interstitial		= 0.1D0
 sol_facti_cloud_borne		= 1.0D0
 sol_factic_interstitial		= 0.4D0
/
&aircraft_emit_nl
 aircraft_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas'
 aircraft_specifier		= 'ac_CO2 -> emissions-cmip6_CO2_anthro_ac_ssp370_201401-210112_fv_0.9x1.25_c20190207.txt'
 aircraft_type		= 'SERIAL'
/
&blj_nl
 do_beljaars		=  .true.
/
&cam_initfiles_nl
 bnd_topo		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/topo/fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_sgh30_24km_GRNL_c170103.nc'
 ncdata		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/inic/fv/cami-mam3_0000-01-01_0.9x1.25_L32_c141031.nc'
 use_topo_file		=  .true.
/
&check_energy_nl
 print_energy_errors		= .false.
/
&chem_inparm
 chem_use_chemtrop		= .true.
 clim_soilw_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc'
 depvel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/depvel_monthly.nc'
 depvel_lnd_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc'
 exo_coldens_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/phot/exo_coldens.nc'
 ext_frc_specifier		= 'H2O    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/elev/H2OemissionCH4oxidationx2_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'num_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'SO2    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc'
 ext_frc_type		= 'INTERP_MISSING_MONTHS'
 fstrat_list		= ' '
 rsf_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/RSF_GT200nm_v3.0_c080811.nc'
 season_wes_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/season_wes.nc'
 srf_emis_specifier		= 'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_DMS_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-SSP_DMS_other_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ag-ship-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ene_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp/emissions-cmip6-SOAGx1.5_biogenic_surface_mol_175001-210101_0.9x1.25_c20190329.nc'
 srf_emis_type		= 'INTERP_MISSING_MONTHS'
 tracer_cnst_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/tracer_cnst'
 tracer_cnst_file		= 'tracer_cnst_halons_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc'
 tracer_cnst_filelist		= ''
 tracer_cnst_specifier		= 'O3','OH','NO3','HO2'
 tracer_cnst_type		= 'INTERP_MISSING_MONTHS'
 xactive_prates		= .false.
 xs_long_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/temp_prs_GT200nm_JPL10_c140624.nc'
/
&chem_surfvals_nl
 flbc_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/lb/LBC_2014-2500_CMIP6_SSP370_0p5degLat_GlobAnnAvg_c190301.nc'
 flbc_list		= 'CO2','CH4','N2O','CFC11eq','CFC12'
 flbc_type		= 'SERIAL'
 scenario_ghg		= 'CHEM_LBC_FILE'
/
&cldfrc2m_nl
 cldfrc2m_do_subgrid_growth		= .true.
 cldfrc2m_rhmaxi		=   1.0D0
 cldfrc2m_rhmaxis		=   1.0D0
 cldfrc2m_rhmini		=   0.80D0
 cldfrc2m_rhminis		=   1.0D0
/
&cldfrc_nl
 cldfrc_dp1		=  0.10D0
 cldfrc_dp2		=  500.0D0
 cldfrc_freeze_dry		= .true.
 cldfrc_ice		= .true.
 cldfrc_icecrit		=  0.93D0
 cldfrc_iceopt		=  5
 cldfrc_premib		=  700.0D2
 cldfrc_premit		=  75000.0D0
 cldfrc_rhminh		=  0.800D0
 cldfrc_rhminl		=  0.950D0
 cldfrc_rhminl_adj_land		=  0.000D0
 cldfrc_sh1		=  0.04D0
 cldfrc_sh2		=  500.0D0
/
&clubb_his_nl
 clubb_history		=  .false.
 clubb_rad_history		=  .false.
/
&clubb_params_nl
 clubb_beta		=  2.4
 clubb_c11		=  0.7D0
 clubb_c11b		=  0.35D0
 clubb_c14		=  2.2D0
 clubb_c2rt		=  1.0
 clubb_c2rtthl		=  1.3
 clubb_c2thl		=  1.0
 clubb_c7		=  0.5
 clubb_c7b		=  0.5
 clubb_c8		=  4.2
 clubb_c_k10		=  0.5
 clubb_c_k10h		=  0.3
 clubb_do_liqsupersat		=  .false.
 clubb_gamma_coef		=  0.308
 clubb_l_lscale_plume_centered		=  .false.
 clubb_l_use_ice_latent		=  .false.
 clubb_lambda0_stability_coef		=  0.04
 clubb_mult_coef		=  1.0D0
 clubb_skw_denom_coef		=  0.0
/
&clubbpbl_diff_nl
 clubb_cloudtop_cooling		=  .false.
 clubb_expldiff		=  .true.
 clubb_rainevap_turb		=  .false.
 clubb_rnevap_effic		=  1.0D0
 clubb_stabcorrect		=  .false.
 clubb_timestep		=  300.0D0
/
&co2_cycle_nl
 co2_flag		= .true.
 co2_readflux_aircraft		=                   .true.
 co2_readflux_fuel		=                       .true.
 co2flux_fuel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas/emissions-cmip6_CO2_anthro_surface_ScenarioMIP_IAMC-AIM-ssp370_201401-210112_fv_0.9x1.25_c20190207.nc'
/
&conv_water_nl
 conv_water_frac_limit		=  0.01d0
 conv_water_in_rad		=  1
/
&dust_nl
 dust_emis_fact		= 0.70D0
 soil_erod_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/dst/dst_source2x2tunedcam6-2x2-04062017.nc'
/
&dyn_fv_inparm
 fv_del2coef		= 3.e+5
 fv_div24del2flag		=  4
 fv_fft_flt		= 1
 fv_filtcw		= 0
 fv_nspltvrm		= 2
/
&gw_drag_nl
 effgw_rdg_beta		= 1.0D0
 effgw_rdg_beta_max		= 1.0D0
 fcrit2		= 1.0
 gw_apply_tndmax		= .true.
 gw_dc		= 0.D0
 gw_dc_long		= 0.D0
 gw_limit_tau_without_eff		= .false.
 gw_lndscl_sgh		= .true.
 gw_oro_south_fac		= 1.d0
 gw_prndl		= 0.5D0
 n_rdg_beta		= 10
 pgwv		= 0
 pgwv_long		= 0
 rdg_beta_cd_llb		= 1.0D0
 tau_0_ubc		= .false.
 trpd_leewv_rdg_beta		= .false.
 use_gw_rdg_beta		= .true.
 use_gw_rdg_gamma		= .false.
/
&gw_rdg_nl
 gw_rdg_c_betamax_ds		=  0.0d0
 gw_rdg_c_betamax_sm		=  2.0d0
 gw_rdg_c_gammamax		=  2.0d0
 gw_rdg_do_adjust_tauoro		= .true.
 gw_rdg_do_backward_compat		= .false.
 gw_rdg_do_divstream		= .true.
 gw_rdg_do_smooth_regimes		= .false.
 gw_rdg_fr_c		= 1.0D0
 gw_rdg_frx0		=  2.0d0
 gw_rdg_frx1		=  3.0d0
 gw_rdg_orohmin		=  0.01d0
 gw_rdg_orom2min		=  0.1d0
 gw_rdg_orostratmin		=  0.002d0
 gw_rdg_orovmin		=  1.0d-3
/
&micro_mg_nl
 micro_do_sb_physics		= .false.
 micro_mg_adjust_cpt		= .false.
 micro_mg_berg_eff_factor		=   1.0D0
 micro_mg_dcs		=                                  500.D-6
 micro_mg_num_steps		=                                  1
 micro_mg_precip_frac_method		= 'in_cloud'
 micro_mg_sub_version		=                                  0
 micro_mg_version		=                                  2
/
&modal_aer_opt_nl
 water_refindex_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/water_refindex_rrtmg_c080910.nc'
/
&nucleate_ice_nl
 nucleate_ice_incloud		= .false.
 nucleate_ice_strat		= 1.0D0
 nucleate_ice_subgrid		= 1.2D0
 nucleate_ice_subgrid_strat		= 1.2D0
 nucleate_ice_use_troplev		= .true.
 use_preexisting_ice		= .true.
/
&phys_ctl_nl
 cam_chempkg		= 'trop_mam4'
 cam_physpkg		= 'cam6'
 cld_macmic_num_steps		=  3
 deep_scheme		= 'ZM'
 do_clubb_sgs		=  .true.
 eddy_scheme		= 'CLUBB_SGS'
 history_aero_optics		=           .false.
 history_aerosol		=               .false.
 history_amwg		=                  .true.
 history_budget		=                .false.
 history_chemistry		=             .true.
 history_chemspecies_srf		=       .true.
 history_clubb		=                 .true.
 history_dust		=                  .false.
 history_eddy		=                  .false.
 history_vdiag		=                 .false.
 history_waccm		=                 .false.
 history_waccmx		=                .false.
 macrop_scheme		= 'CLUBB_SGS'
 microp_scheme		= 'MG'
 radiation_scheme		= 'rrtmg'
 shallow_scheme		= 'CLUBB_SGS'
 srf_flux_avg		= 0
 use_gw_convect_dp		= .false.
 use_gw_convect_sh		= .false.
 use_gw_front		= .false.
 use_gw_front_igw		= .false.
 use_gw_oro		= .false.
 use_hetfrz_classnuc		= .true.
 use_subcol_microp		= .false.
 waccmx_opt		= 'off'
/
&prescribed_ozone_nl
 prescribed_ozone_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_ozone_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_ozone_name		= 'O3'
 prescribed_ozone_type		= 'SERIAL'
/
&prescribed_strataero_nl
 prescribed_strataero_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_strataero_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_strataero_type		= 'SERIAL'
 prescribed_strataero_use_chemtrop		=  .true.
/
&qneg_nl
 print_qneg_warn		= 'summary'
/
&rad_cnst_nl
 icecldoptics		= 'mitchell'
 iceopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/iceoptics_c080917.nc'
 liqcldoptics		= 'gammadist'
 liqopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/F_nwvl200_mu20_lam50_res64_t298_c080428.nc'
 mode_defs		= 'mam4_mode1:accum:=', 'A:num_a1:N:num_c1:num_mr:+',
         'A:so4_a1:N:so4_c1:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:pom_a1:N:pom_c1:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:soa_a1:N:soa_c1:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+', 'A:bc_a1:N:bc_c1:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc:+',
         'A:dst_a1:N:dst_c1:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a1:N:ncl_c1:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc',
         'mam4_mode2:aitken:=', 'A:num_a2:N:num_c2:num_mr:+',
         'A:so4_a2:N:so4_c2:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:soa_a2:N:soa_c2:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
         'A:ncl_a2:N:ncl_c2:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+', 'A:dst_a2:N:dst_c2:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc',
         'mam4_mode3:coarse:=', 'A:num_a3:N:num_c3:num_mr:+',
         'A:dst_a3:N:dst_c3:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a3:N:ncl_c3:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+',
         'A:so4_a3:N:so4_c3:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc', 'mam4_mode4:primary_carbon:=',
         'A:num_a4:N:num_c4:num_mr:+', 'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:bc_a4:N:bc_c4:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'
 rad_climate		= 'A:Q:H2O', 'N:O2:O2',
         'N:CO2:CO2', 'N:ozone:O3',
         'N:N2O:N2O', 'N:CH4:CH4',
         'N:CFC11:CFC11', 'N:CFC12:CFC12',
         'M:mam4_mode1:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode1_rrtmg_aeronetdust_sig1.6_dgnh.48_c140304.nc', 'M:mam4_mode2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode2_rrtmg_aitkendust_c141106.nc',
         'M:mam4_mode3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode3_rrtmg_aeronetdust_sig1.2_dgnl.40_c150219.nc', 'M:mam4_mode4:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode4_rrtmg_c130628.nc',
         'N:VOLC_MMR1:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode1_c170214.nc', 'N:VOLC_MMR2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode2_c170214.nc',
         'N:VOLC_MMR3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.2_mode3_c170214.nc'
/
&ref_pres_nl
 clim_modal_aero_top_press		=  1.D-4
 do_molec_press		=  0.1D0
 molec_diff_bot_press		=  50.D0
 trop_cloud_top_press		=       1.D2
/
&solar_data_opts
 solar_htng_spctrl_scl		= .true.
 solar_irrad_data_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/solar/SolarForcingCMIP6_18491230-22991231_c171031.nc'
/
&tms_nl
 do_tms		=  .false.
/
&tropopause_nl
 tropopause_climo_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/ub/clim_p_trop.nc'
/
&vert_diff_nl
 diff_cnsrv_mass_check		=  .false.
 do_iss		=  .true.
/
&wetdep_inparm
 gas_wetdep_list		= 'H2O2','H2SO4','SO2'
 gas_wetdep_method		= 'NEU'
/
&zmconv_nl
 zmconv_c0_lnd		=  0.0075D0
 zmconv_c0_ocn		=  0.0300D0
 zmconv_ke		=  5.0E-6
 zmconv_ke_lnd		=  1.0E-5
 zmconv_microp		=  .false.
 zmconv_momcd		=  0.7000D0
 zmconv_momcu		=  0.7000D0
 zmconv_num_cin		=  1
 zmconv_org		=  .false.
/
```



### Lnd_in

```
# cat lnd_in
&clm_inparm
 albice = 0.50,0.30
 atm_c13_filename = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/isotopes/atm_delta_C13_CMIP6_SSP3B_1850-2100_yearly_c181209.nc'
 atm_c14_filename = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/isotopes/atm_delta_C14_CMIP6_SSP3B_3x1_global_1850-2100_yearly_c181209.nc'
 co2_type = 'diagnostic'
 create_crop_landunit = .true.
 dtime = 1800
 fatmlndfrc = '/home/zhonghua/projects/cesm/inputdata/share/domains/domain.lnd.fv0.9x1.25_gx1v7.151020.nc'
 finidat = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/initdata_map/clmi.BHIST.2000-01-01.0.9x1.25_gx1v7_simyr2000_c181015.nc'
 fsnowaging = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/snicardata/snicar_drdt_bst_fit_60_c070416.nc'
 fsnowoptics = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/snicardata/snicar_optics_5bnd_c090915.nc'
 fsurdat = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/surfdata_map/release-clm5.0.18/surfdata_0.9x1.25_hist_78pfts_CMIP6_simyr1850_c190214.nc'
 glc_do_dynglacier = .true.
 glc_snow_persistence_max_days = 0
 h2osno_max = 10000.0
 hist_dov2xy(1) = .true.
 hist_dov2xy(2) = .false.
 hist_dov2xy(3) = .false.
 hist_dov2xy(4) = .true.
 hist_dov2xy(5) = .false.
 hist_fexcl1 = 'PCT_GLC_MEC', 'PCT_NAT_PFT', 'SOIL1C_vr', 'SOIL1N_vr', 'SOIL2C_vr', 'SOIL2N_vr', 'SOIL3C_vr', 'SOIL3N_vr',
         'SOILC_vr', 'SOILN_vr', 'CWDC_vr', 'LITR1C_vr', 'LITR2C_vr', 'LITR3C_vr', 'LITR1N_vr', 'LITR2N_vr',
         'LITR3N_vr', 'CWDN_vr', 'SMIN_NO3_vr', 'CONC_O2_UNSAT', 'CONC_O2_SAT', 'SMIN_NH4_vr', 'SMINN_vr', 'PCT_CFT',
         'C14_SOILC_vr'
 hist_fincl1 = 'EFLX_LH_TOT_ICE', 'FIRE_ICE', 'FLDS_ICE', 'FSH_ICE', 'FSNO_ICE', 'FSR_ICE',
         'QFLX_SUB_SNOW_ICE', 'QRUNOFF_ICE', 'QSNOFRZ_ICE', 'QSNOMELT_ICE', 'RAIN_ICE', 'SNOW_ICE',
         'SNOWICE_ICE', 'SNOWLIQ_ICE', 'SNOTXMASS_ICE', 'TG_ICE', 'TOPO_COL_ICE', 'TSA_ICE',
         'TSOI_ICE', 'LEAFC_TO_LITTER', 'FROOTC_TO_LITTER', 'LITR1C_TO_SOIL1C', 'LITR1N_TO_SOIL1N', 'LITR2C_TO_SOIL1C',
         'LITR2N_TO_SOIL1N', 'LITR3C_TO_SOIL2C', 'LITR3N_TO_SOIL2N', 'DWT_WOOD_PRODUCTC_GAIN_PATCH'
 hist_fincl2 = 'TLAI', 'TSA', 'TREFMNAV', 'TREFMXAV', 'BTRANMN', 'Vcmx25Z', 'FSH', 'VEGWP', 'FCTR', 'FCEV', 'FGEV',
         'FIRE', 'FSR', 'FIRA', 'FSA', 'GSSUNLN', 'GSSHALN', 'TSKIN', 'GPP', 'NPP', 'AGNPP', 'TOTVEGC',
         'NPP_NUPTAKE', 'AR', 'HR', 'HTOP', 'GRAINC_TO_FOOD', 'NFERTILIZATION'
 hist_fincl3 = 'FSR', 'H2OSNO', 'Q2M', 'SNOWDP', 'TSA', 'TREFMNAV', 'TREFMXAV', 'TG', 'QRUNOFF',
         'FSH', 'FIRE', 'FIRA', 'FGR', 'EFLX_LH_TOT', 'RH2M', 'TLAI', 'SOILWATER_10CM', 'TOTSOILLIQ',
         'TOTSOILICE', 'U10', 'TSOI_10CM', 'QIRRIG', 'URBAN_HEAT', 'WASTEHEAT', 'TSKIN', 'GPP', 'NPP',
         'AR', 'HR', 'DWT_CONV_CFLUX_PATCH', 'WOOD_HARVESTC', 'DWT_WOOD_PRODUCTC_GAIN_PATCH', 'SLASH_HARVESTC', 'COL_FIRE_CLOSS', 'DWT_SLASH_CFLUX', 'FROOTC:I',
         'HTOP', 'GRAINC_TO_FOOD'
 hist_fincl4 = 'PCT_GLC_MEC', 'QICE_FORC', 'TSRF_FORC', 'TOPO_FORC', 'PCT_NAT_PFT', 'PCT_LANDUNIT', 'FSNO_ICE', 'SOILC_vr',
         'SOILN_vr', 'CWDC_vr', 'LITR1C_vr', 'LITR2C_vr', 'LITR3C_vr', 'LITR1N_vr', 'LITR2N_vr', 'LITR3N_vr',
         'CWDN_vr', 'TOTLITC:I', 'TOT_WOODPRODC:I', 'TOTSOMC:I', 'TOTVEGC:I', 'PCT_CFT', 'CROPPROD1C:I', 'C14_SOILC_vr'
 hist_fincl5 = 'TOTSOMC:I', 'TOTSOMC_1m:I', 'TOTECOSYSC:I', 'TOTVEGC:I', 'WOODC:I', 'TOTLITC:I', 'LIVECROOTC:I',
         'DEADCROOTC:I', 'FROOTC:I'
 hist_mfilt(1) = 1
 hist_mfilt(2) = 1
 hist_mfilt(3) = 1
 hist_mfilt(4) = 1
 hist_mfilt(5) = 1
 hist_nhtfrq(1) = 0
 hist_nhtfrq(2) = 0
 hist_nhtfrq(3) = 0
 hist_nhtfrq(4) = -8760
 hist_nhtfrq(5) = -8760
 hist_type1d_pertape(1) = ' '
 hist_type1d_pertape(2) = ' '
 hist_type1d_pertape(3) = 'LAND'
 hist_type1d_pertape(4) = ' '
 hist_type1d_pertape(5) = 'LAND'
 int_snow_max = 2000.
 irrigate = .true.
 maxpatch_glcmec = 10
 maxpatch_pft = 79
 n_melt_glcmec = 10.0d00
 nlevsno = 12
 nsegspc = 35
 paramfile = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/paramdata/clm5_params.c171117.nc'
 run_zero_weight_urban = .false.
 soil_layerstruct = '20SL_8.5m'
 spinup_state = 0
 suplnitro = 'NONE'
 use_bedrock = .true.
 use_c13 = .true.
 use_c13_timeseries = .true.
 use_c14 = .true.
 use_c14_bombspike = .true.
 use_century_decomp = .true.
 use_cn = .true.
 use_crop = .true.
 use_dynroot = .false.
 use_fates = .false.
 use_fertilizer = .true.
 use_flexiblecn = .true.
 use_fun = .true.
 use_grainproduct = .true.
 use_hydrstress = .true.
 use_init_interp = .true.
 use_lai_streams = .false.
 use_lch4 = .true.
 use_luna = .true.
 use_nguardrail = .true.
 use_nitrif_denitrif = .true.
 use_soil_moisture_streams = .false.
 use_vertsoilc = .true.
/
&ndepdyn_nml
 model_year_align_ndep = 2015
 ndep_taxmode = 'cycle'
 ndep_varlist = 'NDEP_month'
 ndepmapalgo = 'bilinear'
 stream_fldfilename_ndep = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/ndepdata/fndep_clm_f09_g17.CMIP6-SSP3-7.0-WACCM_1849-2101_monthly_c191007.nc'
 stream_year_first_ndep = 2015
 stream_year_last_ndep = 2101
/
&popd_streams
 model_year_align_popdens = 2015
 popdensmapalgo = 'bilinear'
 stream_fldfilename_popdens = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/firedata/clmforc.Li_2018_SSP3_CMIP6_hdm_0.5x0.5_AVHRR_simyr1850-2100_c181205.nc'
 stream_year_first_popdens = 2015
 stream_year_last_popdens = 2100
/
&urbantv_streams
 model_year_align_urbantv = 2015
 stream_fldfilename_urbantv = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/urbandata/CLM50_tbuildmax_Oleson_2016_0.9x1.25_simyr1849-2106_c160923.nc'
 stream_year_first_urbantv = 2015
 stream_year_last_urbantv = 2106
 urbantvmapalgo = 'nn'
/
&light_streams
 lightngmapalgo = 'bilinear'
 stream_fldfilename_lightng = '/home/zhonghua/projects/cesm/inputdata/atm/datm7/NASA_LIS/clmforc.Li_2012_climo1995-2011.T62.lnfm_Total_c140423.nc'
 stream_year_first_lightng = 0001
 stream_year_last_lightng = 0001
/
&soil_moisture_streams
/
&lai_streams
/
&atm2lnd_inparm
 glcmec_downscale_longwave = .true.
 lapse_rate = 0.006
 lapse_rate_longwave = 0.032
 longwave_downscaling_limit = 0.5
 precip_repartition_glc_all_rain_t = 0.
 precip_repartition_glc_all_snow_t = -2.
 precip_repartition_nonglc_all_rain_t = 2.
 precip_repartition_nonglc_all_snow_t = 0.
 repartition_rain_snow = .true.
/
&lnd2atm_inparm
 melt_non_icesheet_ice_runoff = .true.
/
&clm_canopyhydrology_inparm
 interception_fraction = 1.0
 maximum_leaf_wetted_fraction = 0.05
 snowveg_flag = 'ON_RAD'
 use_clm5_fpi = .true.
/
&cnphenology
 initial_seed_at_planting = 3.d00
/
&clm_soilhydrology_inparm
/
&dynamic_subgrid
 do_harvest = .true.
 do_transient_crops = .true.
 do_transient_pfts = .true.
 flanduse_timeseries = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/surfdata_map/release-clm5.0.18/landuse.timeseries_0.9x1.25_SSP3-7.0_78pfts_CMIP6_simyr1850-2100_c190214.nc'
&cnvegcarbonstate
 initial_vegc = 100.d00
/
&finidat_consistency_checks
/
&dynpft_consistency_checks
/
&clm_initinterp_inparm
 init_interp_method = 'general'
/
&century_soilbgcdecompcascade
 initial_cstocks = 200.0d00, 200.0d00, 200.0d00
 initial_cstocks_depth = 1.50d00
/
&soilhydrology_inparm
 baseflow_scalar = 0.001d00
/
&luna
 jmaxb1 = 0.093563
/
&friction_velocity
 zetamaxstable = 0.5d00
/
&mineral_nitrogen_dynamics
/
&soilwater_movement_inparm
 dtmin = 60.
 expensive = 42
 flux_calculation = 1
 inexpensive = 1
 lower_boundary_condition = 2
 soilwater_movement_method = 1
 upper_boundary_condition = 1
 verysmall = 1.e-8
 xtolerlower = 1.e-2
 xtolerupper = 1.e-1
/
&rooting_profile_inparm
 rooting_profile_method_carbon = 1
 rooting_profile_method_water = 1
/
&soil_resis_inparm
 soil_resis_method = 1
/
&bgc_shared
 constrain_stress_deciduous_onset = .true.
 decomp_depth_efolding = 10.0
/
&canopyfluxes_inparm
 use_undercanopy_stability = .false.
/
&aerosol
 fresh_snw_rds_max = 204.526d00
/
&clmu_inparm
 building_temp_method = 1
 urban_hac = 'ON_WASTEHEAT'
 urban_traffic = .false.
/
&clm_soilstate_inparm
 organic_frac_squared = .false.
/
&clm_nitrogen
 carbon_resp_opt = 0
 cn_evergreen_phenology_opt = 1
 cn_partition_opt = 1
 cn_residual_opt = 1
 cnratio_floating = .true.
 downreg_opt = .false.
 lnc_opt = .true.
 mm_nuptake_opt = .true.
 nscalar_opt = .true.
 plant_ndemand_opt = 3
 reduce_dayl_factor = .false.
 substrate_term_opt = .true.
 temp_scalar_opt = .true.
 vcmax_opt = 3
/
&clm_snowhydrology_inparm
 lotmp_snowdensity_method = 'Slater2017'
 reset_snow = .false.
 reset_snow_glc = .false.
 reset_snow_glc_ela = 1.e9
 snow_overburden_compaction_method = 'Vionnet2012'
 upplim_destruct_metamorph = 175.d00
 wind_dependent_snow_density = .true.
/
&cnprecision_inparm
 cnegcrit = -6.d+1
 ncrit = 1.d-9
 nnegcrit = -6.d+0
/
&clm_glacier_behavior
 glacier_region_behavior = 'single_at_atm_topo','virtual','virtual','virtual'
 glacier_region_ice_runoff_behavior = 'melted','melted','remains_ice','remains_ice'
 glacier_region_melt_behavior = 'remains_in_place','replaced_by_ice','replaced_by_ice','replaced_by_ice'
 glacier_region_rain_to_snow_behavior = 'converted_to_snow','converted_to_snow','converted_to_snow','converted_to_snow'
/
&crop
 baset_latvary_intercept = 12.0d00
 baset_latvary_slope = 0.4d00
 baset_mapping = 'varytropicsbylat'
/
&irrigation_inparm
 irrig_depth = 0.6
 irrig_length = 14400
 irrig_min_lai = 0.0
 irrig_start_time = 21600
 irrig_target_smp = -3400.
 irrig_threshold_fraction = 1.0
 limit_irrigation_if_rof_enabled = .false.
/
&ch4par_in
 finundation_method = 'TWS_inversion'
 use_aereoxid_prog = .true.
/
&clm_humanindex_inparm
 calc_human_stress_indices = 'FAST'
/
&cnmresp_inparm
 br_root = 0.83d-06
/
&photosyns_inparm
 leafresp_method = 2
 light_inhibit = .true.
 modifyphoto_and_lmr_forcrop = .true.
 rootstem_acc = .false.
 stomatalcond_method = 'Medlyn2011'
/
&cnfire_inparm
 fire_method = 'li2016crufrc'
/
&cn_general
 dribble_crophrv_xsmrpool_2atm = .false.
/
&nitrif_inparm
/
&lifire_inparm
 boreal_peatfire_c = 0.09d-4
 bt_max = 0.98d00
 bt_min = 0.85d00
 cli_scale = 0.033d00
 cmb_cmplt_fact = 0.5d00, 0.28d00
 cropfire_a1 = 1.6d-4
 lfuel = 105.d00
 non_boreal_peatfire_c = 0.17d-3
 occur_hi_gdp_tree = 0.33d00
 pot_hmn_ign_counts_alpha = 0.008d00
 rh_hgh = 80.0d00
 rh_low = 20.0d00
 ufuel = 1050.d00
/
&ch4finundated
 stream_fldfilename_ch4finundated = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/paramdata/finundated_inversiondata_0.9x1.25_c170706.nc'
/
&clm_canopy_inparm
 leaf_mr_vcm = 0.015d00
/ 
```



### Error

Error1： grid alias f09_f09_

f09_f09_mg17 only for compsets that are not_POP [Parallel Ocean Program (POP)](https://www.cesm.ucar.edu/models/pop), 因此修改为用f09_g17

![grid_resolution](/Users/user/Desktop/progress_Yuan_Sun/Learning_Record/CESM_RunRecords/workstation/ErrorScreeshot/creat_newcase/grid_resolution.png)



Error2: ./case.setup failed因为CLM

![clm_build_namelist](/Users/user/Desktop/progress_Yuan_Sun/Learning_Record/CESM_RunRecords/workstation/ErrorScreeshot/creat_newcase/clm_build_namelist.png)

解决：./xmlchange --append CLM_BLDNML_OPTS="-ignore_warnings"



## Spin-up运行

实际修改并使用的代码如下：

```
#spin-up阶段:运行1年
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/TestRun0919 --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/TestRun0919/
./xmlquery RUN_STARTDATE
./xmlquery CLM_BLDNML_OPTS

./xmlchange RUN_TYPE=startup
./xmlchange RUN_STARTDATE=2015-11-12
./xmlchange GET_REFCASE=FALSE
./xmlchange STOP_N=1
./xmlchange STOP_OPTION=nyears
./xmlchange ATM_NTASKS=36,CPL_NTASKS=36,GLC_NTASKS=36,ICE_NTASKS=36,LND_NTASKS=36,OCN_NTASKS=36,ROF_NTASKS=36,WAV_NTASKS=36

./case.setup
# setup后先通过preview_namelist生成user_nl_*等文件
./preview_namelists
# 修改user_nl_*后再case.build
vim user_nl_cam
vim user_nl_lnd
./case.build
./case.submit

cat CaseStatus #查看运行情况，包括xmlchange是否修改成功

#查看运行状态：
#运行过程文件在/run 中
cd $HOME/projects/cesm/scratch/TestRun0919/run
ls -al
#运行结束后的文件在archive中,当 case.st_archive运行后
cd /home/zhonghua/projects/cesm/archive/case/rest/2016-11-12-00000



./xmlquery RUN_REFDATE
#结果：1979-01-01
./xmlquery RUN_REFCASE
#结果：f.e20.FHIST.f09_f09.cesm2_1.001_v2

#查看模拟结果
cd $HOME/projects/cesm/archive/case/rest/2014-11-12-0000

# 备份文件
scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/TestRun0919/user_nl_cam /Users/user/Desktop

scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/TestRun0919/user_nl_clm /Users/user/Desktop
```



### 修改user_nl_cam

- 将SSP中cam_in的设置粘贴进来

- 修改black carbon 部分

- [User's Guide to the Community Atmosphere Model CAM-5.0](https://www2.cesm.ucar.edu/models/cesm1.0/cam/docs/ug5_0/ug.html)

  

vim user_nl_cam

```
&aerosol_nl
 aer_drydep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 aer_wetdep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 modal_accum_coarse_exch		= .true.
 seasalt_emis_scale		= 1.00D0
 sol_factb_interstitial		= 0.1D0
 sol_facti_cloud_borne		= 1.0D0
 sol_factic_interstitial		= 0.4D0
/
&aircraft_emit_nl
 aircraft_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas'
 aircraft_specifier		= 'ac_CO2 -> emissions-cmip6_CO2_anthro_ac_ssp370_201401-210112_fv_0.9x1.25_c20190207.txt'
 aircraft_type		= 'SERIAL'
/
&blj_nl
 do_beljaars		=  .true.
/
&cam_initfiles_nl
 bnd_topo		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/topo/fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_sgh30_24km_GRNL_c170103.nc'
 ncdata		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/inic/fv/cami-mam3_0000-01-01_0.9x1.25_L32_c141031.nc'
 use_topo_file		=  .true.
/
&check_energy_nl
 print_energy_errors		= .false.
/
&chem_inparm
 chem_use_chemtrop		= .true.
 clim_soilw_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc'
 depvel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/depvel_monthly.nc'
 depvel_lnd_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc'
 exo_coldens_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/phot/exo_coldens.nc'
 ext_frc_specifier		= 'H2O    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/elev/H2OemissionCH4oxidationx2_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'num_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'SO2    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc'
 ext_frc_type		= 'INTERP_MISSING_MONTHS'
 fstrat_list		= ' '
 rsf_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/RSF_GT200nm_v3.0_c080811.nc'
 season_wes_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/season_wes.nc'
 srf_emis_specifier		= 'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_DMS_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-SSP_DMS_other_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ag-ship-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ene_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp/emissions-cmip6-SOAGx1.5_biogenic_surface_mol_175001-210101_0.9x1.25_c20190329.nc'
 srf_emis_type		= 'INTERP_MISSING_MONTHS'
 tracer_cnst_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/tracer_cnst'
 tracer_cnst_file		= 'tracer_cnst_halons_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc'
 tracer_cnst_filelist		= ''
 tracer_cnst_specifier		= 'O3','OH','NO3','HO2'
 tracer_cnst_type		= 'INTERP_MISSING_MONTHS'
 xactive_prates		= .false.
 xs_long_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/temp_prs_GT200nm_JPL10_c140624.nc'
/
&chem_surfvals_nl
 flbc_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/lb/LBC_2014-2500_CMIP6_SSP370_0p5degLat_GlobAnnAvg_c190301.nc'
 flbc_list		= 'CO2','CH4','N2O','CFC11eq','CFC12'
 flbc_type		= 'SERIAL'
 scenario_ghg		= 'CHEM_LBC_FILE'
/
&cldfrc2m_nl
 cldfrc2m_do_subgrid_growth		= .true.
 cldfrc2m_rhmaxi		=   1.0D0
 cldfrc2m_rhmaxis		=   1.0D0
 cldfrc2m_rhmini		=   0.80D0
 cldfrc2m_rhminis		=   1.0D0
/
&cldfrc_nl
 cldfrc_dp1		=  0.10D0
 cldfrc_dp2		=  500.0D0
 cldfrc_freeze_dry		= .true.
 cldfrc_ice		= .true.
 cldfrc_icecrit		=  0.93D0
 cldfrc_iceopt		=  5
 cldfrc_premib		=  700.0D2
 cldfrc_premit		=  75000.0D0
 cldfrc_rhminh		=  0.800D0
 cldfrc_rhminl		=  0.950D0
 cldfrc_rhminl_adj_land		=  0.000D0
 cldfrc_sh1		=  0.04D0
 cldfrc_sh2		=  500.0D0
/
&clubb_his_nl
 clubb_history		=  .false.
 clubb_rad_history		=  .false.
/
&clubb_params_nl
 clubb_beta		=  2.4
 clubb_c11		=  0.7D0
 clubb_c11b		=  0.35D0
 clubb_c14		=  2.2D0
 clubb_c2rt		=  1.0
 clubb_c2rtthl		=  1.3
 clubb_c2thl		=  1.0
 clubb_c7		=  0.5
 clubb_c7b		=  0.5
 clubb_c8		=  4.2
 clubb_c_k10		=  0.5
 clubb_c_k10h		=  0.3
 clubb_do_liqsupersat		=  .false.
 clubb_gamma_coef		=  0.308
 clubb_l_lscale_plume_centered		=  .false.
 clubb_l_use_ice_latent		=  .false.
 clubb_lambda0_stability_coef		=  0.04
 clubb_mult_coef		=  1.0D0
 clubb_skw_denom_coef		=  0.0
/
&clubbpbl_diff_nl
 clubb_cloudtop_cooling		=  .false.
 clubb_expldiff		=  .true.
 clubb_rainevap_turb		=  .false.
 clubb_rnevap_effic		=  1.0D0
 clubb_stabcorrect		=  .false.
 clubb_timestep		=  300.0D0
/
&co2_cycle_nl
 co2_readflux_aircraft		=                   .true.
 co2_readflux_fuel		=                       .true.
 co2flux_fuel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas/emissions-cmip6_CO2_anthro_ac_ScenarioMIP_IAMC-AIM-ssp370_201401-210112_fv_0.9x1.25_c20190207.nc'
/
&conv_water_nl
 conv_water_frac_limit		=  0.01d0
 conv_water_in_rad		=  1
/
&dust_nl
 dust_emis_fact		= 0.70D0
 soil_erod_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/dst/dst_source2x2tunedcam6-2x2-04062017.nc'
/
&dyn_fv_inparm
 fv_del2coef		= 3.e+5
 fv_div24del2flag		=  4
 fv_fft_flt		= 1
 fv_filtcw		= 0
 fv_nspltvrm		= 2
/
&gw_drag_nl
 effgw_rdg_beta		= 1.0D0
 effgw_rdg_beta_max		= 1.0D0
 fcrit2		= 1.0
 gw_apply_tndmax		= .true.
 gw_dc		= 0.D0
 gw_dc_long		= 0.D0
 gw_limit_tau_without_eff		= .false.
 gw_lndscl_sgh		= .true.
 gw_oro_south_fac		= 1.d0
 gw_prndl		= 0.5D0
 n_rdg_beta		= 10
 pgwv		= 0
 pgwv_long		= 0
 rdg_beta_cd_llb		= 1.0D0
 tau_0_ubc		= .false.
 trpd_leewv_rdg_beta		= .false.
 use_gw_rdg_beta		= .true.
 use_gw_rdg_gamma		= .false.
/
&gw_rdg_nl
 gw_rdg_c_betamax_ds		=  0.0d0
 gw_rdg_c_betamax_sm		=  2.0d0
 gw_rdg_c_gammamax		=  2.0d0
 gw_rdg_do_adjust_tauoro		= .true.
 gw_rdg_do_backward_compat		= .false.
 gw_rdg_do_divstream		= .true.
 gw_rdg_do_smooth_regimes		= .false.
 gw_rdg_fr_c		= 1.0D0
 gw_rdg_frx0		=  2.0d0
 gw_rdg_frx1		=  3.0d0
 gw_rdg_orohmin		=  0.01d0
 gw_rdg_orom2min		=  0.1d0
 gw_rdg_orostratmin		=  0.002d0
 gw_rdg_orovmin		=  1.0d-3
/
&micro_mg_nl
 micro_do_sb_physics		= .false.
 micro_mg_adjust_cpt		= .false.
 micro_mg_berg_eff_factor		=   1.0D0
 micro_mg_dcs		=                                  500.D-6
 micro_mg_num_steps		=                                  1
 micro_mg_precip_frac_method		= 'in_cloud'
 micro_mg_sub_version		=                                  0
 micro_mg_version		=                                  2
/
&modal_aer_opt_nl
 water_refindex_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/water_refindex_rrtmg_c080910.nc'
/
&nucleate_ice_nl
 nucleate_ice_incloud		= .false.
 nucleate_ice_strat		= 1.0D0
 nucleate_ice_subgrid		= 1.2D0
 nucleate_ice_subgrid_strat		= 1.2D0
 nucleate_ice_use_troplev		= .true.
 use_preexisting_ice		= .true.
/
&phys_ctl_nl
 cld_macmic_num_steps		=  3
 deep_scheme		= 'ZM'
 do_clubb_sgs		=  .true.
 eddy_scheme		= 'CLUBB_SGS'
 history_aero_optics		=           .false.
 history_aerosol		=               .false.
 history_amwg		=                  .true.
 history_budget		=                .false.
 history_chemistry		=             .true.
 history_chemspecies_srf		=       .true.
 history_clubb		=                 .true.
 history_dust		=                  .false.
 history_eddy		=                  .false.
 history_vdiag		=                 .false.
 history_waccm		=                 .false.
 history_waccmx		=                .false.
 macrop_scheme		= 'CLUBB_SGS'
 microp_scheme		= 'MG'
 radiation_scheme		= 'rrtmg'
 shallow_scheme		= 'CLUBB_SGS'
 srf_flux_avg		= 0
 use_gw_convect_dp		= .false.
 use_gw_convect_sh		= .false.
 use_gw_front		= .false.
 use_gw_front_igw		= .false.
 use_gw_oro		= .false.
 use_hetfrz_classnuc		= .true.
 use_subcol_microp		= .false.
 waccmx_opt		= 'off'
/
&prescribed_ozone_nl
 prescribed_ozone_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_ozone_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_ozone_name		= 'O3'
 prescribed_ozone_type		= 'SERIAL'
/
&prescribed_strataero_nl
 prescribed_strataero_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_strataero_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_strataero_type		= 'SERIAL'
 prescribed_strataero_use_chemtrop		=  .true.
/
&qneg_nl
 print_qneg_warn		= 'summary'
/
&rad_cnst_nl
 icecldoptics		= 'mitchell'
 iceopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/iceoptics_c080917.nc'
 liqcldoptics		= 'gammadist'
 liqopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/F_nwvl200_mu20_lam50_res64_t298_c080428.nc'
 mode_defs		= 
 
'mam4_mode1:accum:=', 
         'A:num_a1:N:num_c1:num_mr:+',        'A:so4_a1:N:so4_c1:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:pom_a1:N:pom_c1:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:soa_a1:N:soa_c1:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+', 'A:bc_a1:N:bc_c1:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc:+',
         'A:dst_a1:N:dst_c1:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a1:N:ncl_c1:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode2:aitken:=', 
         'A:num_a2:N:num_c2:num_mr:+',
         'A:so4_a2:N:so4_c2:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:soa_a2:N:soa_c2:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
         'A:ncl_a2:N:ncl_c2:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+', 'A:dst_a2:N:dst_c2:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc',
'mam4_mode3:coarse:=', 
         'A:num_a3:N:num_c3:num_mr:+',
         'A:dst_a3:N:dst_c3:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a3:N:ncl_c3:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+',
         'A:so4_a3:N:so4_c3:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc', 'mam4_mode4:primary_carbon:=',
         'A:num_a4:N:num_c4:num_mr:+', 
         'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:bc_a4:N:bc_c4:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'
'mam4_mode1_nobc:accum:=', 
         'A:num_a1:N:num_c1:num_mr:+',
         'A:so4_a1:N:so4_c1:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+',
         'A:pom_a1:N:pom_c1:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:soa_a1:N:soa_c1:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
         'A:dst_a1:N:dst_c1:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+',
         'A:ncl_a1:N:ncl_c1:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode4_nobc:primary_carbon:=',
         'A:num_a4:N:num_c4:num_mr:+',
         'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:bc_a4:N:bc_c4:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'        
rad_diag_1		= 
         'A:Q:H2O', 'N:O2:O2',
         'N:CO2:CO2', 'N:ozone:O3',
         'N:N2O:N2O', 'N:CH4:CH4',
         'N:CFC11:CFC11', 'N:CFC12:CFC12',
'M:mam4_mode1_nobc:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode1_rrtmg_aeronetdust_sig1.6_dgnh.48_c140304.nc',
'M:mam4_mode2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode2_rrtmg_aitkendust_c141106.nc',
'M:mam4_mode3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode3_rrtmg_aeronetdust_sig1.2_dgnl.40_c150219.nc',
'M:mam4_mode4_nobc:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode4_rrtmg_c130628.nc',   
'N:VOLC_MMR1:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode1_c170214.nc', 'N:VOLC_MMR2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode2_c170214.nc',
'N:VOLC_MMR3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.2_mode3_c170214.nc'
/
&ref_pres_nl
 clim_modal_aero_top_press		=  1.D-4
 do_molec_press		=  0.1D0
 molec_diff_bot_press		=  50.D0
 trop_cloud_top_press		=       1.D2
/
&solar_data_opts
 solar_htng_spctrl_scl		= .true.
 solar_irrad_data_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/solar/SolarForcingCMIP6_18491230-22991231_c171031.nc'
/
&spmd_fv_inparm
 npr_yz		= 48,6,6,48
/
&tms_nl
 do_tms		=  .false.
/
&tropopause_nl
 tropopause_climo_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/ub/clim_p_trop.nc'
/
&vert_diff_nl
 diff_cnsrv_mass_check		=  .false.
 do_iss		=  .true.
/
&wetdep_inparm
 gas_wetdep_list		= 'H2O2','H2SO4','SO2'
 gas_wetdep_method		= 'NEU'
/
&zmconv_nl
 zmconv_c0_lnd		=  0.0075D0
 zmconv_c0_ocn		=  0.0300D0
 zmconv_ke		=  5.0E-6
 zmconv_ke_lnd		=  1.0E-5
 zmconv_microp		=  .false.
 zmconv_momcd		=  0.7000D0
 zmconv_momcu		=  0.7000D0
 zmconv_num_cin		=  1
 zmconv_org		=  .false.
/

```

#### #20230923更新

- 'mam4_mode4_nobc:primary_carbon:=',
           'A:num_a4:N:num_c4:num_mr:+',
           'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
           'A:bc_a4:N:bc_c4:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'

  **删去'A:bc_a4:N:bc_c4:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'**

```
&aerosol_nl
 aer_drydep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 aer_wetdep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 modal_accum_coarse_exch		= .true.
 seasalt_emis_scale		= 1.00D0
 sol_factb_interstitial		= 0.1D0
 sol_facti_cloud_borne		= 1.0D0
 sol_factic_interstitial		= 0.4D0
/
&aircraft_emit_nl
 aircraft_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas'
 aircraft_specifier		= 'ac_CO2 -> emissions-cmip6_CO2_anthro_ac_ssp370_201401-210112_fv_0.9x1.25_c20190207.txt'
 aircraft_type		= 'SERIAL'
/
&blj_nl
 do_beljaars		=  .true.
/
&cam_initfiles_nl
 bnd_topo		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/topo/fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_sgh30_24km_GRNL_c170103.nc'
 ncdata		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/inic/fv/cami-mam3_0000-01-01_0.9x1.25_L32_c141031.nc'
 use_topo_file		=  .true.
/
&check_energy_nl
 print_energy_errors		= .false.
/
&chem_inparm
 chem_use_chemtrop		= .true.
 clim_soilw_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc'
 depvel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/depvel_monthly.nc'
 depvel_lnd_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc'
 exo_coldens_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/phot/exo_coldens.nc'
 ext_frc_specifier		= 'H2O    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/elev/H2OemissionCH4oxidationx2_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'num_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'SO2    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc'
 ext_frc_type		= 'INTERP_MISSING_MONTHS'
 fstrat_list		= ' '
 rsf_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/RSF_GT200nm_v3.0_c080811.nc'
 season_wes_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/season_wes.nc'
 srf_emis_specifier		= 'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_DMS_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-SSP_DMS_other_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ag-ship-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ene_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp/emissions-cmip6-SOAGx1.5_biogenic_surface_mol_175001-210101_0.9x1.25_c20190329.nc'
 srf_emis_type		= 'INTERP_MISSING_MONTHS'
 tracer_cnst_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/tracer_cnst'
 tracer_cnst_file		= 'tracer_cnst_halons_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc'
 tracer_cnst_filelist		= ''
 tracer_cnst_specifier		= 'O3','OH','NO3','HO2'
 tracer_cnst_type		= 'INTERP_MISSING_MONTHS'
 xactive_prates		= .false.
 xs_long_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/temp_prs_GT200nm_JPL10_c140624.nc'
/
&chem_surfvals_nl
 flbc_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/lb/LBC_2014-2500_CMIP6_SSP370_0p5degLat_GlobAnnAvg_c190301.nc'
 flbc_list		= 'CO2','CH4','N2O','CFC11eq','CFC12'
 flbc_type		= 'SERIAL'
 scenario_ghg		= 'CHEM_LBC_FILE'
/
&cldfrc2m_nl
 cldfrc2m_do_subgrid_growth		= .true.
 cldfrc2m_rhmaxi		=   1.0D0
 cldfrc2m_rhmaxis		=   1.0D0
 cldfrc2m_rhmini		=   0.80D0
 cldfrc2m_rhminis		=   1.0D0
/
&cldfrc_nl
 cldfrc_dp1		=  0.10D0
 cldfrc_dp2		=  500.0D0
 cldfrc_freeze_dry		= .true.
 cldfrc_ice		= .true.
 cldfrc_icecrit		=  0.93D0
 cldfrc_iceopt		=  5
 cldfrc_premib		=  700.0D2
 cldfrc_premit		=  75000.0D0
 cldfrc_rhminh		=  0.800D0
 cldfrc_rhminl		=  0.950D0
 cldfrc_rhminl_adj_land		=  0.000D0
 cldfrc_sh1		=  0.04D0
 cldfrc_sh2		=  500.0D0
/
&clubb_his_nl
 clubb_history		=  .false.
 clubb_rad_history		=  .false.
/
&clubb_params_nl
 clubb_beta		=  2.4
 clubb_c11		=  0.7D0
 clubb_c11b		=  0.35D0
 clubb_c14		=  2.2D0
 clubb_c2rt		=  1.0
 clubb_c2rtthl		=  1.3
 clubb_c2thl		=  1.0
 clubb_c7		=  0.5
 clubb_c7b		=  0.5
 clubb_c8		=  4.2
 clubb_c_k10		=  0.5
 clubb_c_k10h		=  0.3
 clubb_do_liqsupersat		=  .false.
 clubb_gamma_coef		=  0.308
 clubb_l_lscale_plume_centered		=  .false.
 clubb_l_use_ice_latent		=  .false.
 clubb_lambda0_stability_coef		=  0.04
 clubb_mult_coef		=  1.0D0
 clubb_skw_denom_coef		=  0.0
/
&clubbpbl_diff_nl
 clubb_cloudtop_cooling		=  .false.
 clubb_expldiff		=  .true.
 clubb_rainevap_turb		=  .false.
 clubb_rnevap_effic		=  1.0D0
 clubb_stabcorrect		=  .false.
 clubb_timestep		=  300.0D0
/
&co2_cycle_nl
 co2_readflux_aircraft		=                   .true.
 co2_readflux_fuel		=                       .true.
 co2flux_fuel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas/emissions-cmip6_CO2_anthro_ac_ScenarioMIP_IAMC-AIM-ssp370_201401-210112_fv_0.9x1.25_c20190207.nc'
/
&conv_water_nl
 conv_water_frac_limit		=  0.01d0
 conv_water_in_rad		=  1
/
&dust_nl
 dust_emis_fact		= 0.70D0
 soil_erod_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/dst/dst_source2x2tunedcam6-2x2-04062017.nc'
/
&dyn_fv_inparm
 fv_del2coef		= 3.e+5
 fv_div24del2flag		=  4
 fv_fft_flt		= 1
 fv_filtcw		= 0
 fv_nspltvrm		= 2
/
&gw_drag_nl
 effgw_rdg_beta		= 1.0D0
 effgw_rdg_beta_max		= 1.0D0
 fcrit2		= 1.0
 gw_apply_tndmax		= .true.
 gw_dc		= 0.D0
 gw_dc_long		= 0.D0
 gw_limit_tau_without_eff		= .false.
 gw_lndscl_sgh		= .true.
 gw_oro_south_fac		= 1.d0
 gw_prndl		= 0.5D0
 n_rdg_beta		= 10
 pgwv		= 0
 pgwv_long		= 0
 rdg_beta_cd_llb		= 1.0D0
 tau_0_ubc		= .false.
 trpd_leewv_rdg_beta		= .false.
 use_gw_rdg_beta		= .true.
 use_gw_rdg_gamma		= .false.
/
&gw_rdg_nl
 gw_rdg_c_betamax_ds		=  0.0d0
 gw_rdg_c_betamax_sm		=  2.0d0
 gw_rdg_c_gammamax		=  2.0d0
 gw_rdg_do_adjust_tauoro		= .true.
 gw_rdg_do_backward_compat		= .false.
 gw_rdg_do_divstream		= .true.
 gw_rdg_do_smooth_regimes		= .false.
 gw_rdg_fr_c		= 1.0D0
 gw_rdg_frx0		=  2.0d0
 gw_rdg_frx1		=  3.0d0
 gw_rdg_orohmin		=  0.01d0
 gw_rdg_orom2min		=  0.1d0
 gw_rdg_orostratmin		=  0.002d0
 gw_rdg_orovmin		=  1.0d-3
/
&micro_mg_nl
 micro_do_sb_physics		= .false.
 micro_mg_adjust_cpt		= .false.
 micro_mg_berg_eff_factor		=   1.0D0
 micro_mg_dcs		=                                  500.D-6
 micro_mg_num_steps		=                                  1
 micro_mg_precip_frac_method		= 'in_cloud'
 micro_mg_sub_version		=                                  0
 micro_mg_version		=                                  2
/
&modal_aer_opt_nl
 water_refindex_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/water_refindex_rrtmg_c080910.nc'
/
&nucleate_ice_nl
 nucleate_ice_incloud		= .false.
 nucleate_ice_strat		= 1.0D0
 nucleate_ice_subgrid		= 1.2D0
 nucleate_ice_subgrid_strat		= 1.2D0
 nucleate_ice_use_troplev		= .true.
 use_preexisting_ice		= .true.
/
&phys_ctl_nl
 cld_macmic_num_steps		=  3
 deep_scheme		= 'ZM'
 do_clubb_sgs		=  .true.
 eddy_scheme		= 'CLUBB_SGS'
 history_aero_optics		=           .false.
 history_aerosol		=               .true.
 history_amwg		=                  .true.
 history_budget		=                .false.
 history_chemistry		=             .true.
 history_chemspecies_srf		=       .true.
 history_clubb		=                 .true.
 history_dust		=                  .false.
 history_eddy		=                  .false.
 history_vdiag		=                 .false.
 history_waccm		=                 .false.
 history_waccmx		=                .false.
 macrop_scheme		= 'CLUBB_SGS'
 microp_scheme		= 'MG'
 radiation_scheme		= 'rrtmg'
 shallow_scheme		= 'CLUBB_SGS'
 srf_flux_avg		= 0
 use_gw_convect_dp		= .false.
 use_gw_convect_sh		= .false.
 use_gw_front		= .false.
 use_gw_front_igw		= .false.
 use_gw_oro		= .false.
 use_hetfrz_classnuc		= .true.
 use_subcol_microp		= .false.
 waccmx_opt		= 'off'
/
&prescribed_ozone_nl
 prescribed_ozone_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_ozone_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_ozone_name		= 'O3'
 prescribed_ozone_type		= 'SERIAL'
/
&prescribed_strataero_nl
 prescribed_strataero_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_strataero_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_strataero_type		= 'SERIAL'
 prescribed_strataero_use_chemtrop		=  .true.
/
&qneg_nl
 print_qneg_warn		= 'summary'
/
&rad_cnst_nl
 icecldoptics		= 'mitchell'
 iceopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/iceoptics_c080917.nc'
 liqcldoptics		= 'gammadist'
 liqopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/F_nwvl200_mu20_lam50_res64_t298_c080428.nc'
 mode_defs		=

'mam4_mode1:accum:=',
         'A:num_a1:N:num_c1:num_mr:+',        'A:so4_a1:N:so4_c1:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:pom_a1:N:pom_c1:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:soa_a1:N:soa_c1:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+', 'A:bc_a1:N:bc_c1:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc:+',
         'A:dst_a1:N:dst_c1:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a1:N:ncl_c1:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode2:aitken:=',
         'A:num_a2:N:num_c2:num_mr:+',
         'A:so4_a2:N:so4_c2:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:soa_a2:N:soa_c2:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
         'A:ncl_a2:N:ncl_c2:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+', 'A:dst_a2:N:dst_c2:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc',
'mam4_mode3:coarse:=',
         'A:num_a3:N:num_c3:num_mr:+',
         'A:dst_a3:N:dst_c3:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a3:N:ncl_c3:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+',
         'A:so4_a3:N:so4_c3:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc', 'mam4_mode4:primary_carbon:=',
         'A:num_a4:N:num_c4:num_mr:+',
         'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:bc_a4:N:bc_c4:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'
'mam4_mode1_nobc:accum:=',
         'A:num_a1:N:num_c1:num_mr:+',
         'A:so4_a1:N:so4_c1:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+',
         'A:pom_a1:N:pom_c1:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:soa_a1:N:soa_c1:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
         'A:dst_a1:N:dst_c1:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+',
         'A:ncl_a1:N:ncl_c1:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode4_nobc:primary_carbon:=',
         'A:num_a4:N:num_c4:num_mr:+',
         'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         
rad_diag_1		=
         'A:Q:H2O', 'N:O2:O2',
         'N:CO2:CO2', 'N:ozone:O3',
         'N:N2O:N2O', 'N:CH4:CH4',
         'N:CFC11:CFC11', 'N:CFC12:CFC12',
'M:mam4_mode1_nobc:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode1_rrtmg_aeronetdust_sig1.6_dgnh.48_c140304.nc',
'M:mam4_mode2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode2_rrtmg_aitkendust_c141106.nc',
'M:mam4_mode3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode3_rrtmg_aeronetdust_sig1.2_dgnl.40_c150219.nc',
'M:mam4_mode4_nobc:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode4_rrtmg_c130628.nc',
'N:VOLC_MMR1:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode1_c170214.nc', 'N:VOLC_MMR2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode2_c170214.nc',
'N:VOLC_MMR3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.2_mode3_c170214.nc'
/
&ref_pres_nl
 clim_modal_aero_top_press		=  1.D-4
 do_molec_press		=  0.1D0
 molec_diff_bot_press		=  50.D0
 trop_cloud_top_press		=       1.D2
/
&solar_data_opts
 solar_htng_spctrl_scl		= .true.
 solar_irrad_data_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/solar/SolarForcingCMIP6_18491230-22991231_c171031.nc'
/
&tms_nl
 do_tms		=  .false.
/
&tropopause_nl
 tropopause_climo_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/ub/clim_p_trop.nc'
/
&vert_diff_nl
 diff_cnsrv_mass_check		=  .false.
 do_iss		=  .true.
/
&wetdep_inparm
 gas_wetdep_list		= 'H2O2','H2SO4','SO2'
 gas_wetdep_method		= 'NEU'
/
&zmconv_nl
 zmconv_c0_lnd		=  0.0075D0
 zmconv_c0_ocn		=  0.0300D0
 zmconv_ke		=  5.0E-6
 zmconv_ke_lnd		=  1.0E-5
 zmconv_microp		=  .false.
 zmconv_momcd		=  0.7000D0
 zmconv_momcu		=  0.7000D0
 zmconv_num_cin		=  1
 zmconv_org		=  .false.
/
```



### 修改user_nl_clm

- 将SSP中lnd_in的设置粘贴进来
- **最后**把整个SSP的lnd_in都删掉了，只保留一行surface data的指令；

vim user_nl_clm

```
&dynamic_subgrid
 flanduse_timeseries = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/surfdata_map/release-clm5.0.18/landuse.timeseries_0.9x1.25_SSP3-7.0_16pfts_Irrig_CMIP6_simyr1850-2100_c190214.nc'
/
```



### Error

Error1: 

Cam

ERROR: Command /home/zhonghua/my_cesm_sandbox/components/cam/bld/build-namelist -ntasks 144 -csmdata /home/zhonghua/projects/cesm/inputdata -infile /home/zhonghua/projects/cesm/scratch/TestRun0919/Buildconf/camconf/namelist -ignore_ic_date -use_case hist_cam6 -inputdata /home/zhonghua/projects/cesm/scratch/TestRun0919/Buildconf/cam.input_data_list -namelist " &atmexp /"  failed rc=255
out=
err=CAM Namelist ERROR: User may not specify the value of cam_physpkg.
This variable is set by build-namelist based on information from the configure cache file.

![cam_physpkg](/Users/user/Desktop/progress_Yuan_Sun/ProjectRecord/ExtraProjects/ZJUCaseRun/ErrorScreenShot/cam_physpkg.png)

```
在user_nl_cam中删去cam_physpkg		= 'cam6'
```



相似的ERROR: Command /home/zhonghua/my_cesm_sandbox/components/cam/bld/build-namelist -ntasks 144 -csmdata /home/zhonghua/projects/cesm/inputdata -infile /home/zhonghua/projects/cesm/scratch/TestRun0919/Buildconf/camconf/namelist -ignore_ic_date -use_case hist_cam6 -inputdata /home/zhonghua/projects/cesm/scratch/TestRun0919/Buildconf/cam.input_data_list -namelist " &atmexp /"  failed rc=255
out=
err=CAM Namelist ERROR: User may not specify the value of use_simple_phys.
This variable is set by build-namelist based on information
from the configure cache file.

```
删去 use_simple_phys		= .false.
```



此外，还删去了cam_chempkg		= 'trop_mam4'



**Error2:**

Error: spmd_readnl: ERROR: incorrect yz domain decomposition

application called MPI_Abort(MPI_COMM_WORLD, 1001) - process 12

[incorrecy yz domain decomposition](https://bb.cgd.ucar.edu/cesm/threads/incorrect-yz-domain-decomposition.2235/)

解决：把spmd相关的设置给删掉了



**Error3:** 

![tracer](/Users/user/Desktop/progress_Yuan_Sun/ProjectRecord/ExtraProjects/ZJUCaseRun/ErrorScreenShot/tracer.png)

[co2 cycle and tracer index](https://bb.cgd.ucar.edu/cesm/threads/co2-cycle-and-tracer-index.4424/#post-49197)

```
./xmlquery CAM_CPPDEFS
# CAM_CPPDEFS:     -DPLON=288 -DPLAT=192 -DPLEV=32 -DPCNST=33 -DPCOLS=16 -DPSUBCOLS=1 -DN_RAD_CNST=30 -DPTRM=1 -DPTRN=1 -DPTRK=1 -DSPMD -DMODAL_AERO -DMODAL_AERO_4MODE  -DCLUBB_SGS -DCLUBB_CAM -DNO_LAPACK_ISNAN -DCLUBB_REAL_TYPE=dp -DHAVE_VPRINTF -DHAVE_TIMES -DHAVE_GETTIMEOFDAY -DHAVE_COMM_F2C -DHAVE_NANOTIME -DBIT64 -DHAVE_SLASHPROC

# https://docs.cesm.ucar.edu/models/cesm2/settings/2.1.3/cam_input.html
# CAM_CPPDEFS: CAM cpp definitions (setup automatically - DO NOT EDIT)
# A string of user specified CPP defines appended to Makefile defaults. E.g. -cppdefs '-DVAR1 -DVAR2'. Note that a string containing whitespace will need to be quoted.

cnst: constituents
rad_cnst: constituents that are either radiatively active, or in any single diagnostic list for the radiation
```

解决：把co2_flag =.true. 这一行删掉了



**Error4:**

直接把SSP中的Lnd_in 复制到user_nl_clm，会有很多报错，因为历史情景下用是地表观测数据，ssp情景下用的是过程模拟

[clm5的官方文件](https://escomp.github.io/ctsm-docs/versions/release-clm5.0/html/users_guide/running-special-cases/Spinning-up-the-biogeochemistry-BGC-spinup.html?highlight=bgc)

[CLM4.5 **in** CESM1.2.0 **User's Guide Documentation**](https://www2.cesm.ucar.edu/models/cesm1.2/clm/models/lnd/clm/doc/UsersGuide/x1230.html)

![clm](/Users/user/Desktop/progress_Yuan_Sun/ProjectRecord/ExtraProjects/ZJUCaseRun/ErrorScreenShot/clm.png)

![clm2](/Users/user/Desktop/progress_Yuan_Sun/ProjectRecord/ExtraProjects/ZJUCaseRun/ErrorScreenShot/clm2.png)



**Error5:**

[natural pft](https://bb.cgd.ucar.edu/cesm/threads/how-to-obtain-the-indices-of-natural-pfts-of-each-grid-of-surface-data.6153/)

[Plant functional types index](https://escomp.github.io/ctsm-docs/versions/master/html/tech_note/Ecosystem/CLM50_Tech_Note_Ecosystem.html#table-plant-functional-types)

从序号15-18 增加了crop类，导致natpft的数量增加

![natpft](/Users/user/Desktop/progress_Yuan_Sun/ProjectRecord/ExtraProjects/ZJUCaseRun/ErrorScreenShot/natpft.png)

解决：更换 land surface data

```
# 区别clm不同路径下的土地利用文件
landuse.timeseries_0.9x1.25_SSP3-7.0_16pfts_Irrig_CMIP6_simyr1850-2100_c190214.nc
landuse.timeseries_0.9x1.25_rcp4.5_simyr1850-2100_c141219.nc
```



**Error6**: scp 将ssh上的文件下载到本地时 “/Users/user/Desktop/: No such file or directory”

[scp使用绝对目录出现no such file/directory](https://blog.csdn.net/m0_46530201/article/details/130947896)

解决：应该在本地端输入scp 命令



## 验证运行

- 对于spin-up后的结果，不宜直接拿来用作分析，而应该进行valide

- 通过试跑一个一年的simulation，输出月均数据，和已有文献的结论进行比较，看看是否一致或相近。
- 如果相差过远，则需要考虑更换排放数据

```
./xmlchange RUN_TYPE=branch
./xmlchange GET_REFCASE=FALSE
./xmlchange RUN_REFDATE=2016-11-12
./xmlchange RUN_REFCASE=TestRun0919
./xmlchange STOP_N=1,STOP_OPTION=nyears,RESUBMIT=0
./xmlchange ATM_NTASKS=36,CPL_NTASKS=36,GLC_NTASKS=36,ICE_NTASKS=36,LND_NTASKS=36,OCN_NTASKS=36,ROF_NTASKS=36,WAV_NTASKS=36

nhtfrq=0
mfilt=1

#在本地输入以下命令，将ssh中的文件下载至本地：
scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/FormalRun0923/run/FormalRun0923.cam.h0.2017-10.nc /Users/user/Desktop
```



## 目标运行

目标时间：13-27 November, 2016

[CAM_Model_Output](https://ncar.github.io/CAM/doc/build/html/CAM6.0_users_guide/model-output.html)

```
#目标阶段：2016-11-13到2016-11-27
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/FormalRun10032 --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/FormalRun10032/
#在env_run.xml中修改

./xmlchange RUN_TYPE=branch
./xmlchange GET_REFCASE=FALSE
./xmlchange RUN_REFDATE=2016-11-12
./xmlchange RUN_REFCASE=TestRun0919
./xmlchange STOP_N=17,STOP_OPTION=ndays,RESUBMIT=0
./xmlchange ATM_NTASKS=36,CPL_NTASKS=36,GLC_NTASKS=36,ICE_NTASKS=36,LND_NTASKS=36,OCN_NTASKS=36,ROF_NTASKS=36,WAV_NTASKS=36

#查看
./xmlquery RUN_TYPE 
./xmlquery GET_REFCASE 
./xmlquery RUN_REFCASE 
./xmlquery RUN_REFDATE

./case.setup
./preview_namelists

# 编辑user_nl_cam文件
# history_aerosol   = .true.
vim user_nl_cam

# 在最后加：
nhtfrq=0,-1
mfilt=1,24
fincl2='H2O','H2SO4','RELHUM','T','bc_a1','bc_a4','dst_a1','dst_a2','dst_a3','ncl_a1','ncl_a2','ncl_a3','num_a1','num_a2','num_a3','num_a4','pom_a1','pom_a4','so4_a1','so4_a2','so4_a3','soa_a1','soa_a2','PSL','bc_num','bcc_num','bcuc_num','AODVIS','AODABS','AODBC','AODABSBC','FSNT','FSNT_d1','FSNTC','FSNTC_d1','FLNT','FLNT_d1','FLNTC','FLNTC_d1'

# 保存为local_time的数据
avgflag_pertape = 'L'

:wq

# 编辑 user_nl_clm 文件
vim user_nl_clm

./case.build

cp $HOME/projects/cesm/archive/case/rest/2016-11-12-00000/* $HOME/projects/cesm/scratch/FormalRun10032/run/

./case.submit

# 跑完的文件不都在$HOME/projects/cesm/scratch/FormalRun1003/里
# ./xmlquery RUNDIR
# 结果：/home/zhonghua/projects/cesm/scratch/FormalRun1003/run
# ./xmlquery CASE
# 结果：case的名称
# ./xmlquery CASEROOT
# 结果：/home/zhonghua/projects/cesm/scratch/FormalRun1003
# ./xmlquery DOUT_S
# 结果：DOUT_S: TRUE
# ./xmlquery DOUT_S_ROOT
# 结果：DOUT_S_ROOT: /home/zhonghua/projects/cesm/archive/case
# 不同模块下的文件分开保存

#在本地输入以下命令，将ssh中的文件下载至本地：
scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/archive/case/atm/hist/FormalRun10032.cam.h1.*.nc /Users/user/Desktop/FormalRun10032

# 观察生成的nc文件时，用天的平均数据而不是某小时的数据（有的地方是白天有的地方是黑夜），默认模式时间是Universal Time Coordinated / Universal Coordinated Time(utc),如果要保存为当地时间，则在user_nl_cam文件中增加一行”avgflag_pertape = 'L'“

# 备份文件
scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/FormalRun10032/user_nl_cam /Users/user/Desktop

scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/FormalRun10032/user_nl_clm /Users/user/Desktop

```



### 修改user_nl_cam

cat $HOME/projects/cesm/scratch/TestRun0919/user_nl_cam > $HOME/projects/cesm/scratch/FormalRun0923/user_nl_cam

```
&aerosol_nl
 aer_drydep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 aer_wetdep_list		= 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'num_a1', 'num_a2', 'num_a3',
         'num_a4', 'pom_a1', 'pom_a4', 'so4_a1', 'so4_a2', 'so4_a3', 'soa_a1', 'soa_a2'
 modal_accum_coarse_exch		= .true.
 seasalt_emis_scale		= 1.00D0
 sol_factb_interstitial		= 0.1D0
 sol_facti_cloud_borne		= 1.0D0
 sol_factic_interstitial		= 0.4D0
/
&aircraft_emit_nl
 aircraft_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas'
 aircraft_specifier		= 'ac_CO2 -> emissions-cmip6_CO2_anthro_ac_ssp370_201401-210112_fv_0.9x1.25_c20190207.txt'
 aircraft_type		= 'SERIAL'
/
&blj_nl
 do_beljaars		=  .true.
/
&cam_initfiles_nl
 bnd_topo		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/topo/fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_sgh30_24km_GRNL_c170103.nc'
 ncdata		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/inic/fv/cami-mam3_0000-01-01_0.9x1.25_L32_c141031.nc'
 use_topo_file		=  .true.
/
&check_energy_nl
 print_energy_errors		= .false.
/
&chem_inparm
 chem_use_chemtrop		= .true.
 clim_soilw_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc'
 depvel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/depvel_monthly.nc'
 depvel_lnd_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc'
 exo_coldens_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/phot/exo_coldens.nc'
 ext_frc_specifier		= 'H2O    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/elev/H2OemissionCH4oxidationx2_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'num_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'SO2    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ene_vertical_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',
         'so4_a2 -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc'
 ext_frc_type		= 'INTERP_MISSING_MONTHS'
 fstrat_list		= ' '
 rsf_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/RSF_GT200nm_v3.0_c080811.nc'
 season_wes_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/dvel/season_wes.nc'
 srf_emis_specifier		= 'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'bc_a4    -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_DMS_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'DMS      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-SSP_DMS_other_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_bc_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'num_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_num_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'pom_a4   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_pom_a4_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ag-ship-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_anthro-ene_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SO2      -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SO2_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_anthro-ag-ship_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a1   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a1_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'so4_a2   -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_so4_a2_anthro-res_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_anthro_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp370/emissions-cmip6-ScenarioMIP_IAMC-AIM-ssp370-1-1_SOAGx1.5_bb_surface_mol_175001-210101_0.9x1.25_c20190222.nc',
         'SOAG     -> /home/zhonghua/projects/cesm/inputdata/atm/cam/chem/emis/emissions_ssp/emissions-cmip6-SOAGx1.5_biogenic_surface_mol_175001-210101_0.9x1.25_c20190329.nc'
 srf_emis_type		= 'INTERP_MISSING_MONTHS'
 tracer_cnst_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/tracer_cnst'
 tracer_cnst_file		= 'tracer_cnst_halons_3D_L70_1849-2101_CMIP6ensAvg_SSP3-7.0_c190403.nc'
 tracer_cnst_filelist		= ''
 tracer_cnst_specifier		= 'O3','OH','NO3','HO2'
 tracer_cnst_type		= 'INTERP_MISSING_MONTHS'
 xactive_prates		= .false.
 xs_long_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/phot/temp_prs_GT200nm_JPL10_c140624.nc'
/
&chem_surfvals_nl
 flbc_file		= '/home/zhonghua/projects/cesm/inputdata/atm/waccm/lb/LBC_2014-2500_CMIP6_SSP370_0p5degLat_GlobAnnAvg_c190301.nc'
 flbc_list		= 'CO2','CH4','N2O','CFC11eq','CFC12'
 flbc_type		= 'SERIAL'
 scenario_ghg		= 'CHEM_LBC_FILE'
/
&cldfrc2m_nl
 cldfrc2m_do_subgrid_growth		= .true.
 cldfrc2m_rhmaxi		=   1.0D0
 cldfrc2m_rhmaxis		=   1.0D0
 cldfrc2m_rhmini		=   0.80D0
 cldfrc2m_rhminis		=   1.0D0
/
&cldfrc_nl
 cldfrc_dp1		=  0.10D0
 cldfrc_dp2		=  500.0D0
 cldfrc_freeze_dry		= .true.
 cldfrc_ice		= .true.
 cldfrc_icecrit		=  0.93D0
 cldfrc_iceopt		=  5
 cldfrc_premib		=  700.0D2
 cldfrc_premit		=  75000.0D0
 cldfrc_rhminh		=  0.800D0
 cldfrc_rhminl		=  0.950D0
 cldfrc_rhminl_adj_land		=  0.000D0
 cldfrc_sh1		=  0.04D0
 cldfrc_sh2		=  500.0D0
/
&clubb_his_nl
 clubb_history		=  .false.
 clubb_rad_history		=  .false.
/
&clubb_params_nl
 clubb_beta		=  2.4
 clubb_c11		=  0.7D0
 clubb_c11b		=  0.35D0
 clubb_c14		=  2.2D0
 clubb_c2rt		=  1.0
 clubb_c2rtthl		=  1.3
 clubb_c2thl		=  1.0
 clubb_c7		=  0.5
 clubb_c7b		=  0.5
 clubb_c8		=  4.2
 clubb_c_k10		=  0.5
 clubb_c_k10h		=  0.3
 clubb_do_liqsupersat		=  .false.
 clubb_gamma_coef		=  0.308
 clubb_l_lscale_plume_centered		=  .false.
 clubb_l_use_ice_latent		=  .false.
 clubb_lambda0_stability_coef		=  0.04
 clubb_mult_coef		=  1.0D0
 clubb_skw_denom_coef		=  0.0
/
&clubbpbl_diff_nl
 clubb_cloudtop_cooling		=  .false.
 clubb_expldiff		=  .true.
 clubb_rainevap_turb		=  .false.
 clubb_rnevap_effic		=  1.0D0
 clubb_stabcorrect		=  .false.
 clubb_timestep		=  300.0D0
/
&co2_cycle_nl
 co2_readflux_aircraft		=                   .true.
 co2_readflux_fuel		=                       .true.
 co2flux_fuel_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ggas/emissions-cmip6_CO2_anthro_ac_ScenarioMIP_IAMC-AIM-ssp370_201401-210112_fv_0.9x1.25_c20190207.nc'
/
&conv_water_nl
 conv_water_frac_limit		=  0.01d0
 conv_water_in_rad		=  1
/
&dust_nl
 dust_emis_fact		= 0.70D0
 soil_erod_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/dst/dst_source2x2tunedcam6-2x2-04062017.nc'
/
&dyn_fv_inparm
 fv_del2coef		= 3.e+5
 fv_div24del2flag		=  4
 fv_fft_flt		= 1
 fv_filtcw		= 0
 fv_nspltvrm		= 2
/
&gw_drag_nl
 effgw_rdg_beta		= 1.0D0
 effgw_rdg_beta_max		= 1.0D0
 fcrit2		= 1.0
 gw_apply_tndmax		= .true.
 gw_dc		= 0.D0
 gw_dc_long		= 0.D0
 gw_limit_tau_without_eff		= .false.
 gw_lndscl_sgh		= .true.
 gw_oro_south_fac		= 1.d0
 gw_prndl		= 0.5D0
 n_rdg_beta		= 10
 pgwv		= 0
 pgwv_long		= 0
 rdg_beta_cd_llb		= 1.0D0
 tau_0_ubc		= .false.
 trpd_leewv_rdg_beta		= .false.
 use_gw_rdg_beta		= .true.
 use_gw_rdg_gamma		= .false.
/
&gw_rdg_nl
 gw_rdg_c_betamax_ds		=  0.0d0
 gw_rdg_c_betamax_sm		=  2.0d0
 gw_rdg_c_gammamax		=  2.0d0
 gw_rdg_do_adjust_tauoro		= .true.
 gw_rdg_do_backward_compat		= .false.
 gw_rdg_do_divstream		= .true.
 gw_rdg_do_smooth_regimes		= .false.
 gw_rdg_fr_c		= 1.0D0
 gw_rdg_frx0		=  2.0d0
 gw_rdg_frx1		=  3.0d0
 gw_rdg_orohmin		=  0.01d0
 gw_rdg_orom2min		=  0.1d0
 gw_rdg_orostratmin		=  0.002d0
 gw_rdg_orovmin		=  1.0d-3
/
&micro_mg_nl
 micro_do_sb_physics		= .false.
 micro_mg_adjust_cpt		= .false.
 micro_mg_berg_eff_factor		=   1.0D0
 micro_mg_dcs		=                                  500.D-6
 micro_mg_num_steps		=                                  1
 micro_mg_precip_frac_method		= 'in_cloud'
 micro_mg_sub_version		=                                  0
 micro_mg_version		=                                  2
/
&modal_aer_opt_nl
 water_refindex_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/water_refindex_rrtmg_c080910.nc'
/
&nucleate_ice_nl
 nucleate_ice_incloud		= .false.
 nucleate_ice_strat		= 1.0D0
 nucleate_ice_subgrid		= 1.2D0
 nucleate_ice_subgrid_strat		= 1.2D0
 nucleate_ice_use_troplev		= .true.
 use_preexisting_ice		= .true.
/
&phys_ctl_nl
 cld_macmic_num_steps		=  3
 deep_scheme		= 'ZM'
 do_clubb_sgs		=  .true.
 eddy_scheme		= 'CLUBB_SGS'
 history_aero_optics		=           .false.
 history_aerosol		=               .true.
 history_amwg		=                  .true.
 history_budget		=                .false.
 history_chemistry		=             .true.
 history_chemspecies_srf		=       .true.
 history_clubb		=                 .true.
 history_dust		=                  .false.
 history_eddy		=                  .false.
 history_vdiag		=                 .false.
 history_waccm		=                 .false.
 history_waccmx		=                .false.
 macrop_scheme		= 'CLUBB_SGS'
 microp_scheme		= 'MG'
 radiation_scheme		= 'rrtmg'
 shallow_scheme		= 'CLUBB_SGS'
 srf_flux_avg		= 0
 use_gw_convect_dp		= .false.
 use_gw_convect_sh		= .false.
 use_gw_front		= .false.
 use_gw_front_igw		= .false.
 use_gw_oro		= .false.
 use_hetfrz_classnuc		= .true.
 use_subcol_microp		= .false.
 waccmx_opt		= 'off'
/
&prescribed_ozone_nl
 prescribed_ozone_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_ozone_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_ozone_name		= 'O3'
 prescribed_ozone_type		= 'SERIAL'
/
&prescribed_strataero_nl
 prescribed_strataero_datapath		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/ozone_strataero'
 prescribed_strataero_file		= 'ozone_strataero_WACCM_L70_zm5day_18500101-21010201_CMIP6histEnsAvg_SSP370_c190403.nc'
 prescribed_strataero_type		= 'SERIAL'
 prescribed_strataero_use_chemtrop		=  .true.
/
&qneg_nl
 print_qneg_warn		= 'summary'
/
&rad_cnst_nl
 icecldoptics		= 'mitchell'
 iceopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/iceoptics_c080917.nc'
 liqcldoptics		= 'gammadist'
 liqopticsfile		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/F_nwvl200_mu20_lam50_res64_t298_c080428.nc'
 mode_defs		=

'mam4_mode1:accum:=',
         'A:num_a1:N:num_c1:num_mr:+',        'A:so4_a1:N:so4_c1:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:pom_a1:N:pom_c1:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:soa_a1:N:soa_c1:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+', 'A:bc_a1:N:bc_c1:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc:+',
         'A:dst_a1:N:dst_c1:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a1:N:ncl_c1:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode2:aitken:=',
         'A:num_a2:N:num_c2:num_mr:+',
         'A:so4_a2:N:so4_c2:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+', 'A:soa_a2:N:soa_c2:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
         'A:ncl_a2:N:ncl_c2:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+', 'A:dst_a2:N:dst_c2:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc',
'mam4_mode3:coarse:=',
         'A:num_a3:N:num_c3:num_mr:+',
         'A:dst_a3:N:dst_c3:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+', 'A:ncl_a3:N:ncl_c3:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc:+',
         'A:so4_a3:N:so4_c3:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc', 'mam4_mode4:primary_carbon:=',
         'A:num_a4:N:num_c4:num_mr:+',
         'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:bc_a4:N:bc_c4:black-c:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/bcpho_rrtmg_c100508.nc'
'mam4_mode1_nobc:accum:=',
         'A:num_a1:N:num_c1:num_mr:+',
         'A:so4_a1:N:so4_c1:sulfate:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/sulfate_rrtmg_c080918.nc:+',
         'A:pom_a1:N:pom_c1:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
         'A:soa_a1:N:soa_c1:s-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocphi_rrtmg_c100508.nc:+',
         'A:dst_a1:N:dst_c1:dust:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/dust_aeronet_rrtmg_c141106.nc:+',
         'A:ncl_a1:N:ncl_c1:seasalt:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ssam_rrtmg_c100508.nc',
'mam4_mode4_nobc:primary_carbon:=',
         'A:num_a4:N:num_c4:num_mr:+',
         'A:pom_a4:N:pom_c4:p-organic:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/ocpho_rrtmg_c130709.nc:+',
rad_diag_1		=
         'A:Q:H2O', 'N:O2:O2',
         'N:CO2:CO2', 'N:ozone:O3',
         'N:N2O:N2O', 'N:CH4:CH4',
         'N:CFC11:CFC11', 'N:CFC12:CFC12',
'M:mam4_mode1_nobc:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode1_rrtmg_aeronetdust_sig1.6_dgnh.48_c140304.nc',
'M:mam4_mode2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode2_rrtmg_aitkendust_c141106.nc',
'M:mam4_mode3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode3_rrtmg_aeronetdust_sig1.2_dgnl.40_c150219.nc',
'M:mam4_mode4_nobc:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/mam4_mode4_rrtmg_c130628.nc',
'N:VOLC_MMR1:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode1_c170214.nc', 'N:VOLC_MMR2:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.6_mode2_c170214.nc',
'N:VOLC_MMR3:/home/zhonghua/projects/cesm/inputdata/atm/cam/physprops/volc_camRRTMG_byradius_sigma1.2_mode3_c170214.nc'
/
&ref_pres_nl
 clim_modal_aero_top_press		=  1.D-4
 do_molec_press		=  0.1D0
 molec_diff_bot_press		=  50.D0
 trop_cloud_top_press		=       1.D2
/
&solar_data_opts
 solar_htng_spctrl_scl		= .true.
 solar_irrad_data_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/solar/SolarForcingCMIP6_18491230-22991231_c171031.nc'
/
&tms_nl
 do_tms		=  .false.
/
&tropopause_nl
 tropopause_climo_file		= '/home/zhonghua/projects/cesm/inputdata/atm/cam/chem/trop_mozart/ub/clim_p_trop.nc'
/
&vert_diff_nl
 diff_cnsrv_mass_check		=  .false.
 do_iss		=  .true.
/
&wetdep_inparm
 gas_wetdep_list		= 'H2O2','H2SO4','SO2'
 gas_wetdep_method		= 'NEU'
/
&zmconv_nl
 zmconv_c0_lnd		=  0.0075D0
 zmconv_c0_ocn		=  0.0300D0
 zmconv_ke		=  5.0E-6
 zmconv_ke_lnd		=  1.0E-5
 zmconv_microp		=  .false.
 zmconv_momcd		=  0.7000D0
 zmconv_momcu		=  0.7000D0
 zmconv_num_cin		=  1
 zmconv_org		=  .false.
/
nhtfrq=0,-1
mfilt=1,24
fincl2= 'H2O','H2SO4','RELHUM','T','bc_a1','bc_a4','dst_a1','dst_a2','dst_a3','ncl_a1','ncl_a2','ncl_a3','num_a1','num_a2','num_a3','num_a4','pom_a1','pom_a4','so4_a1','so4_a2','so4_a3','soa_a1','soa_a2','PSL','bc_num','bcc_num','bcuc_num','AODVIS','AODABS','AODBC','AODABSBC','FSNT','FSNT_d1','FSNTC','FSNTC_d1','FLNT','FLNT_d1','FLNTC','FLNTC_d1'
avgflag_pertape = 'L'
```



### 修改 user_nl_clm

```
&dynamic_subgrid
 flanduse_timeseries = '/home/zhonghua/projects/cesm/inputdata/lnd/clm2/surfdata_map/release-clm5.0.18/landuse.timeseries_0.9x1.25_SSP3-7.0_16pfts_Irrig_CMIP6_simyr1850-2100_c190214.nc'
/
```



### Error

Error1: flbc_inti: time out of bounds for dataset

![CompsetTimeSpan](/Users/user/Desktop/progress_Yuan_Sun/Learning_Record/CESM_RunRecords/workstation/ErrorScreeshot/case.submit/CompsetTimeSpan.png)

解决：设置namelist 重新指定文件路径，详见user_nl_cam和user_nl_clm



Error2: (seq_infodata_Init) : : rpointer file read returns an error condition

![BranchRun](/Users/user/Desktop/progress_Yuan_Sun/Learning_Record/CESM_RunRecords/workstation/ErrorScreeshot/case.submit/BranchRun.png)

解决：将spin-up后得到的整个文件夹都拷贝到FormalRun中作为refercase



Error3：只输出了一个h1.nc文件

nhtfrg=-24， mfilt=1 ，表示是每24小时输出，每个生成文件保存1次输出结果，所以是2016-11-12的平均值；

解决：改为 nhtfrg=-1， mfilt=24， 每小时跑一次，一个nc文件保存24小时也就是1天的结果;



Error4：

误用中文标点，导致无法识别

![user_nl](/Users/user/Desktop/progress_Yuan_Sun/Learning_Record/CESM_RunRecords/workstation/ErrorScreeshot/case.submit/user_nl.png)



Error5:

设置fincl2 的目的是单独输出一个文件，只设置额外指定的变量

```
# 设置为fincl2
nhtfrq=0,-1
mfilt=1,24
fincl2='H2O','H2SO4','RELHUM','T','bc_a1','bc_a4','dst_a1','dst_a2','dst_a3','ncl_a1','ncl_a2','ncl_a3','num_a1','num_a2','num_a3','num_a4','pom_a1','pom_a4','so4_a1','so4_a2','so4_a3','soa_a1','soa_a2','PSL','bc_num','bcc_num','bcuc_num','AODVIS','AODABS','AODBC','AODABSBC','FSNT','FSNT_d1','FSNTC','FSNTC_d1','FLNT','FLNT_d1','FLNTC','FLNTC_d1'

# 设置为fincl1的话，会得到一个超级大的文件，包含了默认的变量和额外指定的变量
nhtfrq= -1
mfilt= 24
fincl1='H2O','H2SO4','RELHUM','T','bc_a1','bc_a4','dst_a1','dst_a2','dst_a3','ncl_a1','ncl_a2','ncl_a3','num_a1','num_a2','num_a3','num_a4','pom_a1','pom_a4','so4_a1','so4_a2','so4_a3','soa_a1','soa_a2','PSL','bc_num','bcc_num','bcuc_num','AODVIS','AODABS','AODBC','AODABSBC','FSNT','FSNT_d1','FSNTC','FSNTC_d1','FLNT','FLNT_d1','FLNTC','FLNTC_d1'
```



## 输出设置测试before目标运行

```
#目标阶段：2016-11-13到2016-11-27
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/FormalRun09292 --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/FormalRun09292/
#在env_run.xml中修改

./xmlchange RUN_TYPE=branch
./xmlchange GET_REFCASE=FALSE
./xmlchange RUN_REFDATE=2016-11-12
./xmlchange RUN_REFCASE=TestRun0919
./xmlchange STOP_N=1,STOP_OPTION=ndays,RESUBMIT=0
./xmlchange ATM_NTASKS=36,CPL_NTASKS=36,GLC_NTASKS=36,ICE_NTASKS=36,LND_NTASKS=36,OCN_NTASKS=36,ROF_NTASKS=36,WAV_NTASKS=36

#查看
./xmlquery RUN_TYPE 
./xmlquery GET_REFCASE 
./xmlquery RUN_REFCASE 
./xmlquery RUN_REFDATE

./case.setup
./preview_namelists

# 编辑user_nl_cam文件
# history_aerosol   = .true.
vim user_nl_cam

# 在最后加：
nhtfrq=0,-1
mfilt=1,24
fincl2='H2O','H2SO4','RELHUM','T','bc_a1','bc_a4','dst_a1','dst_a2','dst_a3','ncl_a1','ncl_a2','ncl_a3','num_a1','num_a2','num_a3','num_a4','pom_a1','pom_a4','so4_a1','so4_a2','so4_a3','soa_a1','soa_a2','PSL','bc_num','bcc_num','bcuc_num','AODVIS','AODABS','AODBC','AODABSBC','FSNT','FSNT_d1','FSNTC','FSNTC_d1','FLNT','FLNT_d1','FLNTC','FLNTC_d1'


:wq

# 编辑 user_nl_clm 文件
vim user_nl_clm

./case.build
cp $HOME/projects/cesm/archive/case/rest/2016-11-12-00000/* $HOME/projects/cesm/scratch/FormalRun09292/run/

./case.submit

#在本地输入以下命令，将ssh中的文件下载至本地：
scp zhonghua@10.141.12.196:/home/zhonghua/projects/cesm/scratch/FormalRun09292/run/FormalRun09292.cam.h1.2016-11-12-03600.nc /Users/user/Desktop
```



## 0925 运行流程 on HPC Pool (test)

### Spin-up

```
#spin-up阶段:运行1年
cd $HOME/CESM/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/scratch/yuanCESM/Projects/CESM2/scratch/TestRun0925 --compset FHIST --res f09_f09_mg17 --res f45_f45_mg37 --run-unsupported --mach csf3 --walltime 00:20:00

cd ~/scratch/yuanCESM/Projects/CESM2/scratch/TestRun0925
./xmlquery RUN_STARTDATE
./xmlquery CLM_BLDNML_OPTS

./xmlchange RUN_TYPE=startup
./xmlchange RUN_STARTDATE=2015-11-12
./xmlchange GET_REFCASE=FALSE
./xmlchange STOP_N=1
./xmlchange STOP_OPTION=nyears
./xmlchange ATM_NTASKS=320,CPL_NTASKS=320,GLC_NTASKS=320,ICE_NTASKS=320,LND_NTASKS=320,OCN_NTASKS=320,ROF_NTASKS=320,WAV_NTASKS=320

./case.setup
# setup后先通过preview_namelist生成user_nl_*等文件
./preview_namelists
# 修改user_nl_*后再case.build
vim user_nl_cam
vim user_nl_lnd
./case.build

touch myjobscript0925.sh
vim myjobscript0925.sh

#!/bin/bash --login
#$ -cwd
#$ -P hpc-zz-aerosol
#$ -pe hpc.pe 320
./case.submit

:wq

chmod -x myjobscript0925.sh
qsub myjobscript0925.sh

./case.submit

cat CaseStatus #查看运行情况，包括xmlchange是否修改成功

#查看运行状态：
#运行过程文件在/run 中
cd $HOME/projects/cesm/scratch/TestRun/run
ls -al
#运行结束后的文件在archive中,当 case.st_archive运行后
cd /home/zhonghua/projects/cesm/archive/case/rest/2016-11-12-00000



./xmlquery RUN_REFDATE
#结果：1979-01-01
./xmlquery RUN_REFCASE
#结果：f.e20.FHIST.f09_f09.cesm2_1.001_v2

#查看模拟结果
cd $HOME/projects/cesm/archive/case/rest/2014-11-12-0000
```





wall time 设置， resubmit 设置；
