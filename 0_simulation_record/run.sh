# SSPcase to generate cam_in and clm_in
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/SSP0919 --compset BSSP370cmip6 --res f09_g17 

./create_newcase --case $HOME/projects/cesm/scratch/SSP0919wan --compset BSSP370cmip6 --res f09_g17 

cd $HOME/projects/cesm/scratch/SSP0919/

./xmlchange RUN_TYPE=startup
./xmlchange RUN_STARTDATE=2015-11-12
./xmlchange GET_REFCASE=FALSE
./xmlchange STOP_N=1
./xmlchange STOP_OPTION=nyears
./xmlchange --append CLM_BLDNML_OPTS="-ignore_warnings"

./case.setup
./case.build

./preview_namelists
cd Buildconf
cd camconf
cat atm_in

cd clmconf
cat lnd_in


# spin-up
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
./preview_namelists
vim user_nl_cam
vim user_nl_lnd
./case.build
./case.submit

# formal run
cd ~/my_cesm_sandbox/cime/scripts
./create_newcase --case $HOME/projects/cesm/scratch/FormalRun10032 --compset FHIST --res f09_f09_mg17

cd $HOME/projects/cesm/scratch/FormalRun10032/

./xmlchange RUN_TYPE=branch
./xmlchange GET_REFCASE=FALSE
./xmlchange RUN_REFDATE=2016-11-12
./xmlchange RUN_REFCASE=TestRun0919
./xmlchange STOP_N=17,STOP_OPTION=ndays,RESUBMIT=0
./xmlchange ATM_NTASKS=36,CPL_NTASKS=36,GLC_NTASKS=36,ICE_NTASKS=36,LND_NTASKS=36,OCN_NTASKS=36,ROF_NTASKS=36,WAV_NTASKS=36


./xmlquery RUN_TYPE 
./xmlquery GET_REFCASE 
./xmlquery RUN_REFCASE 
./xmlquery RUN_REFDATE

./case.setup
./preview_namelists

vim user_nl_cam
vim user_nl_clm

./case.build

cp $HOME/projects/cesm/archive/case/rest/2016-11-12-00000/* $HOME/projects/cesm/scratch/FormalRun10032/run/

./case.submit