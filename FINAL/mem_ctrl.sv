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
  longint unsigned q_ip_time_next [$:3];
  int q_ip_oper_next [$:3];
  bit [32:0] q_ip_addr_next [$:3];

  bit first_ip=1, last_ip=0;
  int size_ip_q;
  int size_ip_q_copy;
  longint sim_time = -1;
  bit q_mc_full;
  bit q_pending_full;

  int f_end;
  int first_ip_in_q_serviced;
  longint last_req_time;

  int TRC	= 2*76;
  int TRAS	= 2*52;
  int TRRD_L	= 2*6;
  int TRRD_S	= 2*4;
  int TRP	= 2*24;
  //int TRFC	= 2*350ns;
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
  //int REFI	= 2*7.8𝛍s;




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
  int debug_en;

  initial begin
	$value$plusargs("ip_file=%s", ip_file);
	$value$plusargs("debug_en=%d", debug_en);
  end



  initial begin
	ip = $fopen(ip_file, "r");
	op = $fopen("output_file.txt", "w");

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

  task automatic output_computation(int t, int bank_g, int bank, int r, int c, int operation);
	if(t == 48)begin
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#48
		if(operation[0] == 0)
			$fwrite(op,"%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		else if(operation == 1)
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 56) begin
		#8
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#48
		if(operation[0] == 0)
			$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		else if(operation == 1)
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 60)begin
		#12
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#48
		if(operation[0] == 0)
			$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
		else if(operation == 1)
			$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 120)begin
		#24
		$fwrite(op, "%0d \tPRE \t%0h \t%0h\n", sim_time, bank_g, bank);
		#48
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#48
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 136)begin
		#40
		$fwrite(op, "%0d \tPRE \t%0h \t%0h\n", sim_time, bank_g, bank);
		#48
		$fwrite(op, "%0d \tACT \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, r);
		#48
		$fwrite(op, "%0d \tWR \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 24)begin
		#24
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end else if(t == 16)begin
		#16
		$fwrite(op, "%0d \tRD \t%0h \t%0h \t%0h\n", sim_time, bank_g, bank, c);
	end
  endtask

  int extra_delay = 0;
  int delay;

  task calc_time(int bg, int b, int bg_b, int row, int col, int oper, int first, output int t);

	extra_delay = 0;

	if(first == 0) begin
		arr = {bg, b, row, col, oper};
		t = TRCD;
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

 
 
  bit add_flag;
  //MC Queue implemenation (Pending Q ---> MC Q)
  always@(sim_time)begin
     
     repeat(16)begin
	if(q_mc.size() < 16) begin
          if(q_pending_time.size()>0)begin
	    add_flag = 1;
	    q_mc.push_back(q_pending_time.pop_front());
	    q_mc_oper.push_back(q_pending_oper.pop_front());
	    q_mc_addr.push_back(q_pending_addr.pop_front());
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

  always@(sim_time) begin
	for(int i=0; i<q_mc.size(); i++)begin
	    if( db_arr[{q_mc_addr[i][7:6],q_mc_addr[i][9:8]}][0] == 0 || db_arr[{q_mc_addr[i][7:6],q_mc_addr[i][9:8]}][0] == -1)begin		//Checking for VALID not set
	        calc_valid_time(q_mc_oper[i], q_mc_addr[i], i);
		break;
	    end
	end
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

  initial begin 
        //$monitor("DB_ARR = %p",db_arr);
  end

  always @(sim_time) begin
	if(sim_time == last_req_time + 10000) begin
          $display("last_req_time = %d  LAST = %0d",last_req_time, sim_time);
          $finish; 
        end
  end

//  //ADAPTIVE SCHEDULING
//  int bgb; 
//  int k;
//  int q_adaptive_bgb[$:15];
//  int q_adaptive_row[$:15];
//  int q_starvation[$:15];
//  int flag;
//  int row_val_1, row_val_2, row_val_3;
//
//  longint unsigned time_temp;
//  int oper_temp;
//  bit [33:0] addr_temp;
//
//
//  task swap_j_to_i1 (int i, int j);
//	time_temp = q_pending_time[j];
//	oper_temp = q_pending_oper[j];
//	addr_temp = q_pending_addr[j];
//
//	q_pending_time.delete(j);
//	q_pending_oper.delete(j);
//	q_pending_addr.delete(j);
//
//	q_pending_time.insert(i+1,time_temp);
//	q_pending_oper.insert(i+1,oper_temp);
//	q_pending_addr.insert(i+1,addr_temp);
//  endtask
//
//  task automatic set_starvation(int k);
//	int temp;
//	temp = 
//	q_starvation
//  endtask
//
//  always@(sim_time)begin
//        for(int i=0; i<q_pending_addr.size(); i++)begin
//        	q_adaptive_bgb.push_back(q_pending_addr[i][9:6]);
//        	q_adaptive_row.push_back(q_pending_addr[i][32:18]);
//        end
//
//	for(int i=0; i<q_adaptive_bgb.size(); i++)begin
//		for(int j=0; j<q_adaptive_bgb.size(); j++)begin
//		    if(i!=j)begin
//			if(q_adaptive_bgb[i] == q_adaptive_bgb[j])begin
//			    if(flag == 0)begin
//				row_val_1 = q_adaptive_row[i];
//				row_val_2 = q_adaptive_row[j];
//				k = j;
//				flag = 1;
//				//continue; 
//			    end else begin
//				row_val_3 = q_adaptive_row[j];
//				if(row_val_1 == row_val_3 && row_val_1 != row_val_2) begin
//				  swap_j_to_i1(i,j);
//				  set_starvation(k);
//				  break;
//				end
//			    end
//			end
//		    end
//		end
//	end
//  end 


endmodule
