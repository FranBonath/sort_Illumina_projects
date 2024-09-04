#example for sequencing setup table
df_lane_output <- data.frame("Sequencing.Platform"= c("NovaSeq X Plus","NovaSeq X Plus","NovaSeq 6000","NextSeq 2000","NextSeq 2000","NextSeq 2000"), "Flowcell"= c("1.5B-200","10B-300","SP-100 v1.5","P1-100","P1-300","P2-100"), "req_reads"= c(1500,1250,325,100,100,400))

sort_project <- function(data, df_lane_output, name_outfile="result_sort_projects", max_samples=1000, min_vol=10, used_fmol_ONT=100, min_tot_cycles=175, min_Ill_runs_possible=2, Ill_req_ul=40, Ill_req_nM=10, output_25B_lane=3000, min_25_perc=12.5){
  #left over ul after ONT amount has been taken
  data$left_ul_after_ONT <- as.numeric(as.character(data[,12]))-(used_fmol_ONT/as.numeric(data[,11]))
  
  #calculate the total number of cycles to fulfill the project
  data$tot_cycles <- unlist(lapply(lapply(strsplit(as.character(data[,17]), split="-"),as.numeric),sum, na.rm=TRUE))
  #calculate the percentage of 25B lane to be used
  data_merged <- merge(data, df_lane_output, by=c("Sequencing.Platform","Flowcell"))
  data_merged$perc_25B_lane = round(100/output_25B_lane*data_merged$req_reads, digit=2)
  # number of Illumina runs possible after ONT amount has been taken, taking into account the amount to be sequenced
  data_merged$Ill_runs_possible <- round((as.numeric(data_merged$Pool.conc..nM.)*data_merged$left_ul_after_ONT)/(Ill_req_nM*Ill_req_ul*(data_merged$perc_25B_lane/100)), digits = 2)
  
  filtered_list <- data_merged[
      data_merged$Ill_runs_possible > min_Ill_runs_possible 
      & data_merged$Samples < max_samples 
      & data_merged$tot_cycles>min_tot_cycles 
      & data_merged$perc_25B_lane>min_25_perc
      & data_merged$Pool.volume..uL.>min_vol,]
  
  list_excluded <- data_merged[
    data_merged$Ill_runs_possible < min_Ill_runs_possible 
    | data_merged$Samples > max_samples 
    | data_merged$tot_cycles<min_tot_cycles
    | data_merged$perc_25B_lane<min_25_perc
    | data_merged$Pool.volume..uL.<min_vol,]
 
   filtered_list_short <- data.frame(
      "Project.Name"=filtered_list$Project.Name, 
      "Application"=filtered_list$Application, 
      "Pool.conc.nM"=filtered_list$Pool.conc..nM.,
      "Pool.volume.uL"=filtered_list$Pool.volume..uL., 
      "tot_cycles"=filtered_list$tot_cycles,
      "Sequencing.Platform"=filtered_list$Sequencing.Platform,
      "Flowcell"=filtered_list$Flowcell,
      "perc_25B_lane"=filtered_list$perc_25B_lane,
      "Ill_runs_possible"=filtered_list$Ill_runs_possible,
      "library_type"=filtered_list$library_type_.ready.made_libraries.)
  
  # generate output files
   ## report
  outfile_report <-  file(paste(name_outfile, "_report.txt", sep=""), open = "wt")
  writeLines(paste(as.character(nrow(filtered_list)), " projects fulfil the criteria"),outfile_report)
  writeLines("--------------------------------------------------------------------------------------",outfile_report)
  writeLines("These were the criteria:",outfile_report)
  writeLines(paste("Maximum number of samples allowed in the Illumina pool -",max_samples),outfile_report)
  writeLines(paste("Minimal volume of the Illumina pool -",min_vol),outfile_report)
  writeLines(paste("fmol used for ONT run - ",used_fmol_ONT),outfile_report)
  writeLines(paste("Minimal required cycles to have been ordered by the user -",min_tot_cycles),outfile_report)
  writeLines(paste("Minimal number of Illumina seq runs possible after ONT run -",min_Ill_runs_possible),outfile_report)
  writeLines(paste("Required ul for an Illumina run (used as basis for standard Illumina input) -",Ill_req_ul),outfile_report)
  writeLines(paste("Required nM for an Illumina run (used as basis for standard Illumina input) -",Ill_req_nM),outfile_report)
  writeLines(paste("expected output of a 25B lane - ",output_25B_lane),outfile_report)
  writeLines(paste("Minimum %age of a 25B lane the user run has to have ordered -",min_25_perc),outfile_report)
  writeLines("--------------------------------------------------------------------------------------",outfile_report)
  close(outfile_report)
   ## table
  write.csv(filtered_list_short,paste(name_outfile,"_table.csv",sep=""), row.names= FALSE)

  # print report to screen
  read_outfile <- file(paste(name_outfile,"_report.txt",sep=""),open="r")
  lines_outfile <-readLines(read_outfile)
  for (i in 1:length(lines_outfile)){
    print(lines_outfile[i], quote=FALSE)
  }
  close(read_outfile)
  
  # print table to screen
  read_outtable <- read.csv(paste(name_outfile,"_table.csv",sep=""))
  print(read_outtable[1:9])
  
  return(c(filtered_list, list_excluded))
}