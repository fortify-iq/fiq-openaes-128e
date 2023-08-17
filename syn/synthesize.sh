# CONFIGURATION

## protection level: 8 or 13
PLEVEL=8
## enabling new linear algebra for plevel 8
NEW_LA_EN=1

# SYN LIBRARY
## Path to the Yosys library files. Change it to yours
LIBRARY_PATH="./stdcells.lib"


#SOURCE CODE FILES

## base rtl
COMPONENTS_SOURCES=" ../aes128enc/openAES_128e.v ../aes128enc/AES128_control.v ../aes128enc/AES128enc_Coding.v ../aes128enc/openAES_128e_Core.v ../aes128enc/AES_128e_reg_output.v ../aes128enc/AES_input.v ../aes128enc/AES_reg.v ../aes128enc/AES_reg_sharedext.v ../aes128enc/blocks_red.v ../aes128enc/grand_blocks_red.v"
## plevel dependend rtl
### plevel 8
LIB_8_SOURCES=" ../aes128enc/arithmetics_red_8.v"
### plevel 8 with new linear algebra
LIB_8_NEWLA_SOURCES=" ../aes128enc/arithmetics_red_8.v ../aes128enc/arithmetics_red_8_modified.v"
### plevel 13
LIB_13_SOURCES=" ../aes128enc/arithmetics_red_13.v"


# APPLYING THE CONFIGURATION
SOURCES=$COMPONENTS_SOURCES;
DEFINES="read -define CONFIG_FROM_TOOL "
## suffixes are need to name resulting netlist regarding the configuration
NEW_LA_SUFFIX=""

if [ $PLEVEL == 8 ]
then
  DEFINES+="read -define REDUNDANCY_8 "
  if [ $NEW_LA_EN == 1 ]
  then
    SOURCES+=$LIB_8_NEWLA_SOURCES;
    DEFINES+="read -define NEW_LA_EN "
    NEW_LA_SUFFIX="_new_la"
  else
    SOURCES+=$LIB_8_SOURCES;
  fi
else
  DEFINES+="read -define REDUNDANCY_13 "
  SOURCES+=$LIB_13_SOURCES;
fi


# CALL YOSYS, RUN SYNTHESIS
yosys -p  "$DEFINES"'; read_verilog '"$SOURCES"'; setattr -set keep_hierarchy 1; synth -top '"openAES_128e"'; dfflibmap -liberty '"$LIBRARY_PATH"'; abc -liberty '"$LIBRARY_PATH"'; opt_clean; stat -liberty '"$LIBRARY_PATH"'; setattr -set keep_hierarchy 0; flatten; select '"openAES_128e"'; write_verilog -noattr -selected open_aes_128enc_plevel'"$PLEVEL"''"$NEW_LA_SUFFIX"'.v;';

