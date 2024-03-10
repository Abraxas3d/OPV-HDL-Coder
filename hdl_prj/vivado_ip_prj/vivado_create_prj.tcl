create_project vivado_prj {} -part xc7z045ffg900-2 -force
set_property target_language VHDL [current_project]
set defaultRepoPath {./ipcore}
set_property ip_repo_paths $defaultRepoPath [current_fileset]
update_ip_catalog
set ipList [glob -nocomplain -directory $defaultRepoPath *.zip]
foreach ipCore $ipList {
  set folderList [glob -nocomplain -directory $defaultRepoPath -type d *]
  if {[lsearch -exact $folderList [file rootname $ipCore]] == -1} {
    catch {update_ip_catalog -add_ip $ipCore -repo_path $defaultRepoPath}
  }
}
update_ip_catalog
set project {adrv9009}
set carrier {zc706}
set ref_design {rxtx}
set fpga_board {ZC706}
set preprocess {off}
set postprocess {off}
set HDLVerifierAXI {off}
source vivado_custom_block_design.tcl
# Use global synthesis for this project
set_property synth_checkpoint_mode None [get_files system.bd]
save_bd_design
# Set project objective
set_property strategy Flow_PerfOptimized_High [get_runs synth_1]
set_property strategy Performance_Explore [get_runs impl_1]

close_project
exit
