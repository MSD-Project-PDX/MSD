module mem_ctrl;
  int ip;
  int op;
  longint unsigned t;
  int inst;
  bit [32:0] addr;
  longint unsigned q_mc[$:15];
  int q_mc_oper[$:15];
  bit [32:0] q_mc_addr[$:15];
  longint unsigned q_pending_time[$:15];
  int q_pending_oper[$:15];
  bit [32:0] q_pending_addr[$:15];
  int q_starvation[$:15];
  longint unsigned q_ip_time_next [$:3];
  int q_ip_oper_next [$:3];
  bit [32:0] q_ip_addr_next [$:3];

  bit first_ip=1, last_ip=0;
  int size_ip_q;
  int size_ip_q_copy;
  longint sim_time = -1;
  //longint unsigned sim_time ;
  bit q_mc_full;
  bit q_pending_full;
  int command_active;
 

  bit refresh_en;
  bit refresh_active;
  int refresh_counter;
  longint unsigned store_prev_ref_time;
 
  bit adaptive_en;

  int f_end;
  int first_ip_in_q_serviced;
  longint unsigned last_req_time;

  int TRC	= 2*76;
  int TRAS	= 2*52;
  int TRRD_L	= 2*6;
  int TRRD_S	= 2*4;
  int TRP	= 2*24;
  int TRFC	= 2*560;//1120
  int CWL	= 2*20;
  int TCAS	= 2*24;
  int TRCD	= 2*24;
  int TWR	= 2*20;
  int TRTP	= 2*12;
  int TCCD_L	= 2*8;
  int TCCD_S	= 2*4;
  int TBURST	= 2*4;
  int TWTR_L	= 2*12;
  int TWTR_S	= 2*4;
  int REFI	= 2*12480;//24960




  always begin
	#1 sim_time++;
  end

  always @ (sim_time) begin
     fork
	if(q_mc.size() == 16) q_mc_full = 1;
	else q_mc_full = 0;

	if(q_pending_time.size() == 16) q_pending_full = 1;
	else q_pending_full = 0;
     join
  end

  string ip_file;
  string op_file;
  int debug_en;

  initial begin
	$value$plusargs("ip_file=%s", ip_file);
	$value$plusargs("op_file=%s", op_file);
	$value$plusargs("debug_en=%d", debug_en);
	$value$plusargs("refresh_en=%d", refresh_en);
	$value$plusargs("adaptive_en=%d", adaptive_en);

	$display("\n\n\n\tECE-485/585: MICROPROCESSOR SYSTEM DESIGN PROJECT\n\n");
	$display("\n\tFINAL PROJECT - GROUP 7\n");
	$display("\tDINESH KUMAR SIVA");
	$display("\tPRADEEP MANTHU REDDY");
	$display("\tNARENDRA SRINIVAS");
	$display("\tNAVEEN MANIVANNAN\n\n");

	$display("\tMEMORY CONTROLLER IMPLEMENTATION FOR A 4-CORE PROCESSOR TO DIMM");
	$display("\t\tProcessor: 3.2GHz, 4-core, single memory channel");
	$display("\t\tMemory   : 8GB PC4-25600 DIMM (with X8 devices) || Page Size = 2KB || No ECC");

	$display("\n\nDRAM COMMANDS and Scheduling details: output_file.txt");

	$display("\n\n\n");
  end



  initial begin
	ip = $fopen(ip_file, "r");
	op = $fopen(op_file, "w");

	while(f_end==0) begin
		if($fscanf(ip, "%d %d %h", t, inst, addr) == 3)begin
		if(t==q_ip_time_next[0] || first_ip==1)begin
			q_ip_time_next.push_back(t);
			q_ip_oper_next.push_back(inst);
			q_ip_addr_next.push_back(addr);
		end else begin
                    size_ip_q = q_ip_time_next.size();
		    wait(!q_pending_full);
                    wait(q_ip_time_next.size()==0);
		    q_ip_time_next.delete();
		    q_ip_oper_next.delete();
		    q_ip_addr_next.delete();
		    q_ip_time_next.push_back(t);
		    q_ip_oper_next.push_back(inst);
		    q_ip_addr_next.push_back(addr);
		end
		end
		first_ip=0;
		f_end = $feof(ip);
		if(f_end) break;
	end
	//last set of inputs
        size_ip_q = q_ip_time_next.size();
	last_ip = 1;
	last_req_time = q_ip_time_next[0];
  end

  int db_arr[16][6]; 
  int arr[5]; 
  // VALID
  // 0  Has not been accessed at all
  // 1  Currently in progress
  //-1  Has been accessed before, but currently not active (Open page)

  always@(sim_time) begin
    fork
      if(command_active > 0) command_active = command_active - 1 ;

      if(refresh_en)begin
	//if(sim_time % REFI == 0 && sim_time!=0) begin
	if(sim_time == REFI+store_prev_ref_time && sim_time!=0) begin
		refresh_active = 1;
		command_active += TRFC;
		refresh_counter = 0;
		store_prev_ref_time = sim_time + TRFC;
		$fwrite(op, "%0d \tREF\n", sim_time);
	end
	if(refresh_active) begin
		refresh_counter++;
		if(refresh_counter == TRFC) 
			refresh_active = 0;
	end
      end
    join
  end
 
 

  task automatic output_computation(int t, int bank_g, int bank, int r, int c, int operation);
	if(t == 48)begin
		wait(command_active == 0);
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		command_active = 2;
		#49
		if(operation[0] == 0) begin
			wait(command_active == 0);
			$fwrite(op,"%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
			command_active = 2;
		end else if(operation == 1)begin
			wait(command_active == 0);
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
			command_active = 2;
		end
	end else if(t == 56) begin
		#9
		wait(command_active == 0);
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		command_active = 2;
		#49
		wait(command_active == 0);
		if(operation[0] == 0)begin
			$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
			command_active = 2;
		end else if(operation == 1)begin
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
			command_active = 2;
		end
	end else if(t == 60)begin
		#13
		wait(command_active == 0);
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		command_active = 2;
		#49
		wait(command_active == 0);
		if(operation[0] == 0)begin
			$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
			command_active = 2;
		end else if(operation == 1)begin
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
			command_active = 2;
		end
	end else if(t == 120)begin
		#25
		wait(command_active == 0);
		$fwrite(op, "%0d \tPRE \t%0h \t%0h\n", sim_time, bank_g, bank);
		command_active = 2;
		#49
		wait(command_active == 0);
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		command_active = 2;
		#49
		wait(command_active == 0);
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		command_active = 2;
	end else if(t == 136)begin
		#41
		wait(command_active == 0);
		$fwrite(op, "%0d \tPRE \t%0h \t%0h\n", sim_time, bank_g, bank);
		command_active = 2;
		#49
		wait(command_active == 0);
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		command_active = 2;
		#49
		wait(command_active == 0);
		$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		command_active = 2;
	end else if(t == 24)begin
		#25
		wait(command_active == 0);
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		command_active = 2;
	end else if(t == 16)begin
		#17
		wait(command_active == 0);
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		command_active = 2;
	end
  endtask


/*
task automatic output_computation(int t, int bank_g, int bank, int r, int c, int operation);
	if(t == 48)begin
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#49
		if(operation[0] == 0)
			$fwrite(op,"%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		else if(operation == 1)
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 56) begin
		#9
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#49
		if(operation[0] == 0)
			$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		else if(operation == 1)
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 60)begin
		#13
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#49
		if(operation[0] == 0)
			$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		else if(operation == 1)
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 120)begin
		#25
		$fwrite(op, "%0d \tPRE \t%0h \t%0h\n", sim_time, bank_g, bank);
		#49
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#49
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 136)begin
		#41
		$fwrite(op, "%0d \tPRE \t%0h \t%0h\n", sim_time, bank_g, bank);
		#49
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#49
		$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 24)begin
		#25
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 16)begin
		#17
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end
  endtask
*/

  int extra_delay = 0;
  int delay;

  task calc_time(int bg, int b, int bg_b, int row, int col, int oper, int first, output int t);

	extra_delay = 0;

	if(first == 0) begin
		arr = {bg, b, row, col, oper};
		t = TRCD;
		delay = t;
		//delay = t;
	end else begin
		if(arr[0] != bg) extra_delay  = TRRD_S;
		else
		  if(arr[1] != b) extra_delay = TRRD_L;

		arr = {bg, b, row, col, oper};

		if(db_arr[bg_b][0] == 0)begin
			delay = extra_delay + TRCD;
		end else if (db_arr[bg_b][0] == -1)begin
		    if(db_arr[bg_b][2] != row)	begin 		//ROW number mismatch
			if(db_arr[bg_b][5] == oper && oper[0] == 0) // R --> R || IF --> IF || R --> IF || IF --> R
				delay = TRTP + TRP + TRCD;

			else if(db_arr[bg_b][5] == oper && oper[0] == 1) // W --> W
				delay = TWR + TRP + TRCD;

			else if(db_arr[bg_b][5] == 1 && oper[0] == 0) 	// W --> R || W --> IF
				delay = TWR + TRP + TRCD;

			else if(db_arr[bg_b][5][0] == 0 && oper[0] == 1) 	// R --> W || IF --> W
				delay = TRTP + TRP + TRCD;
		    end else if(db_arr[bg_b][2] == row && db_arr[bg_b][3] != col) begin // COL number mismatch
			if(db_arr[bg_b][5] == 1 && oper[0] == 0) 	// W --> R || W --> IF
				delay = TWTR_L;
			else
				delay = TCCD_L;
		    end else if(db_arr[bg_b][2] == row && db_arr[bg_b][3] == col) begin 
			if(db_arr[bg_b][5] == 1 && oper[0] == 0) 	// W --> R || W --> IF
				delay = TWTR_L;
			else
				delay = TCCD_L;
		    end
		end 
	end
	t = delay;
	//$display("delay_final fro the loop  = %0d", delay);	

	fork
		output_computation(t, bg, b, row, col, oper);
	join_none
  endtask

  task automatic calc_valid_time(int local_oper, bit [32:0] local_addr, int q_ref);

     bit [1:0] BG, B;
     bit [3:0] BG_B; 
     int calc_time_op;				
     BG = local_addr[7:6];
     B  = local_addr[9:8];
     BG_B = {BG,B};				//BG_B = '{local_addr[7:6],local_addr[9:8]}; 	
     if(debug_en)
       $display("Start scheduling @%0d for %h : BG=%0d B=%0d R=%0d C=%0d oper=%0d",sim_time,local_addr, BG, B, local_addr[32:18], local_addr[17:10], local_oper);
     calc_time(BG, B, BG_B, local_addr[32:18], local_addr[17:10], local_oper, first_ip_in_q_serviced, calc_time_op) ;
     db_arr[BG_B][1] = calc_time_op;		 
     db_arr[BG_B][0] = 1 ;			//VALID = 1
     db_arr[BG_B][2] = local_addr[32:18];	//ROW number
     db_arr[BG_B][3] = local_addr[17:10];	//COL number
     db_arr[BG_B][4] = q_ref;			//Q position
     db_arr[BG_B][5] = local_oper;		//operation 0-R; 1-W; 2-IF
     first_ip_in_q_serviced = 1;
  endtask


  task add_to_pending_q(int i);
	repeat(i) begin
		if(adaptive_en)begin
		  q_starvation.push_back(0);
		end
		q_pending_time.push_back(q_ip_time_next.pop_front());
		q_pending_oper.push_back(q_ip_oper_next.pop_front());
		q_pending_addr.push_back(q_ip_addr_next.pop_front());
	end
	if (debug_en)
		$display(">>>>>>>>Adding to pending queue...");
	display_pending_q;
  endtask



  task display_q;
     if(debug_en) begin
	$display("MC QUEUE @%0d SIZE=%0d q_mc = %p\n\n", sim_time, q_mc.size(), q_mc);
     end
  endtask

  task display_pending_q;
     if(debug_en) begin
	$display("PENDING QUEUE @%0d SIZE=%0d q_pending_time = %p\n\n", sim_time, q_pending_time.size(), q_pending_time);
     end
  endtask


  //Pending queue implementation
  always@(sim_time) begin
     if(q_ip_time_next.size()>0)begin
	if( ((last_ip==0 && q_ip_time_next.size()>0) || (last_ip==1 && q_ip_time_next.size()>0)) && (q_ip_time_next[0] >= sim_time) )begin
	    	if(q_ip_time_next[0] == sim_time && q_pending_time.size() < 16)begin
	    	    size_ip_q_copy = q_ip_time_next.size();
		    add_to_pending_q(size_ip_q_copy);
	    	end
	end
     end
  end 

 
 
  //MC Queue implemenation (Pending Q ---> MC Q)
  bit add_flag;
  always@(sim_time)begin
     
     repeat(16)begin
	if(q_mc.size() < 16) begin
          if(q_pending_time.size()>0)begin
	    add_flag = 1;
	    q_mc.push_back(q_pending_time.pop_front());
	    q_mc_oper.push_back(q_pending_oper.pop_front());
	    q_mc_addr.push_back(q_pending_addr.pop_front());
	    if(adaptive_en)begin
		  q_starvation.pop_front();
	    end
	  end
	end
     end
     if(add_flag)
       if (debug_en)begin
           $display(">>>>>>>>Adding to MC queue...");
	   display_q;
       end
     add_flag = 0;
  end 
 
  bit start_service_flag = 0;

  always@(sim_time) begin
    if(!(refresh_en && refresh_active))begin
       if(start_service_flag==0)begin
	  for(int i=0; i<q_mc.size(); i++)begin
	    if( db_arr[{q_mc_addr[i][7:6],q_mc_addr[i][9:8]}][0] == 0 || db_arr[{q_mc_addr[i][7:6],q_mc_addr[i][9:8]}][0] == -1)begin		//Checking for VALID not set
	        calc_valid_time(q_mc_oper[i], q_mc_addr[i], i);
		start_service_flag = 2;  //encoded value
		break;
	    end
	  end
       end
     end //refresh
     start_service_flag--;
  end

  task update_db(int a);
	for(int i=0; i<16; i++)begin
	  if(db_arr[i][0]==1)begin
	    if(db_arr[i][4] == a) begin
		db_arr[i][4] =-1;
	    	db_arr[i][0] = -1;
	    end

	    if(db_arr[i][4] > a && db_arr[i][4] >0)
		db_arr[i][4] = db_arr[i][4]-1;
	  end
	end
  endtask

  //REMOVE FROM MC Q
  always@(sim_time) begin
	for(int i=0; i<16; i++)begin
	    if(db_arr[i][0] == 1 && db_arr[i][1] == 0) begin
		q_mc.delete(db_arr[i][4]);
		q_mc_oper.delete(db_arr[i][4]);
		q_mc_addr.delete(db_arr[i][4]);
		if(debug_en)
		  $display("REMOVE FROM MC QUEUE @%0d %p",sim_time,q_mc);
		update_db(db_arr[i][4]);
	    end
	    if(db_arr[i][1] > 0 ) db_arr[i][1]--;
	end
  end

//  //ADVANCE SIMULATION TIME IF Q IS EMPTY
//  always@(sim_time)begin
//	if(q_pending_time.size()==0 && q_mc.size()==0) sim_time = q_ip_time_next[0];
//  end

  always @(sim_time) begin
	if(sim_time == t + 10000) begin
	  $fclose(ip);
	  $fclose(op);
          $finish; 
        end
  end

  //ADAPTIVE SCHEDULING
  int bgb; 
  int k;
  int q_adaptive_bgb[$:15];
  int q_adaptive_row[$:15];
  //int q_starvation[$:15];
  int flag;
  int row_val_1, row_val_2, row_val_3;

  longint unsigned time_temp;
  int oper_temp;
  bit [33:0] addr_temp;
  int star_temp;


  task swap_j_to_i1 (int i, int j);
	time_temp = q_pending_time[j];
	oper_temp = q_pending_oper[j];
	addr_temp = q_pending_addr[j];
	star_temp = q_starvation[j];

	q_pending_time.delete(j);
	q_pending_oper.delete(j);
	q_pending_addr.delete(j);
	q_starvation.delete(j);

	q_pending_time.insert(i+1,time_temp);
	q_pending_oper.insert(i+1,oper_temp);
	q_pending_addr.insert(i+1,addr_temp);
	q_starvation.insert(i+1,star_temp);
  endtask

  int starvation_value = 100;

  always@(sim_time)begin
     if(adaptive_en) begin
        for(int i=0; i<q_pending_addr.size(); i++)begin
        	//q_adaptive_bgb.push_back(q_pending_addr[i][9:6]);
        	//q_adaptive_row.push_back(q_pending_addr[i][32:18]);
        	q_adaptive_bgb[i] = q_pending_addr[i][9:6];
        	q_adaptive_row[i] = q_pending_addr[i][32:18];
        end

	for(int i=0; i<q_adaptive_bgb.size(); i++)begin
	  for(int j=0; j<q_adaptive_bgb.size(); j++)begin
	    if(i!=j)begin
	      if(q_adaptive_bgb[i] == q_adaptive_bgb[j])begin
	        if(flag == 0)begin
		  row_val_1 = q_adaptive_row[i];
		  row_val_2 = q_adaptive_row[j];
		  k = j;
		  flag = 1;
		  //continue; 
		end else begin
		  row_val_3 = q_adaptive_row[j];
		  if(row_val_1 == row_val_3 && row_val_1 != row_val_2) begin
		    swap_j_to_i1(i,j);
		    q_starvation[k] = 1; //1 to max starvation value
		    //set_starvation(k);
		    break;
		  end
		end
	      end
	    end
	  end
	end
     end
  end 

  //always@(sim_time) begin
  //      $display("PENDING QUEUE @%0d SIZE=%0d q_pending_addr = %p\n\n", sim_time, q_pending_addr.size(), q_pending_addr);
  //end

  always@(sim_time) begin
    for(int i=0; i<16; i++)begin
	if(q_starvation[i] != 0) q_starvation[i]++;

	if(q_starvation[i] == starvation_value) begin
	  swap_j_to_i1(0, i);
	end
    end
  end

  //always@(sim_time)begin
  //      $display("db_arr = %p",db_arr);
  //end

endmodule
