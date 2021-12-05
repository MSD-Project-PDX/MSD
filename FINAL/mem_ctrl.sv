module mem_ctrl;
  int ip;
  longint t, inst, addr;
  longint unsigned q_mc[$:15];
  longint unsigned q_mc_oper[$:15];
  longint unsigned q_mc_addr[$:15];
  longint unsigned q_pending_time[$:15];
  longint unsigned q_pending_oper[$:15];
  longint unsigned q_pending_addr[$:15];
  longint unsigned q_remove[$:15];
  longint q_ip_time_next [$:3];
  int q_ip_oper_next [$:3];
  int q_ip_addr_next [$:3];

  bit first_ip=1, last_ip=0;
  int size_ip_q;
  int size_ip_q_copy;
  //int size_q_pending;
  longint sim_time = -1;
  bit q_mc_full;
  bit q_pending_full;

  int removed;
  int f_end;
  int first_ip_in_q_serviced;

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


  //int flag_err;
  int otha_podu;

  initial begin
	ip = $fopen(ip_file, "r");

	//while(!$feof(ip)) begin
	while(f_end==0) begin
	//do begin
		if($fscanf(ip, "%d %d %h", t, inst, addr) == 3)begin
		if(t==q_ip_time_next[0] || first_ip==1)begin
			q_ip_time_next.push_back(t);
			q_ip_oper_next.push_back(inst);
			q_ip_addr_next.push_back(addr);
			//flag_err = 1;
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
	wait(!q_pending_full);
	last_ip = 1;
  end

  int db_arr[16][6]; 
  int arr[5]; 

	//db_arr[BG_B][1] = calc_time(BG, B, BG_B, local_addr[32:18], local_addr[17:10], local_oper) ; // BG 

  // VALID
  // 0  Has not been accessed at all
  // 1  Currently in progress
  //-1  Has been accessed before, but currently not active (Open page)

  int extra_delay = 0;
  int delay;

  function int calc_time(int bg, int b, int bg_b, int row, int col, int oper, int first);

	extra_delay = 0;

	if(first == 0) begin
		arr = {bg, b, row, col, oper};
		$display("delay = %0d", TRCD);
		return (TRCD);		//48
	end else begin
		if(arr[0] != bg) extra_delay  = 2*4;
		else
		  if(arr[1] != b) extra_delay = 2*6;

		arr = {bg, b, row, col, oper};

		if(db_arr[bg_b][0] == 0)begin
			delay = extra_delay + TRCD;
			$display("otha");
		end else if (db_arr[bg_b][0] == -1)begin
		    if(db_arr[bg_b][2] != row)	begin 		//ROW number mismatch
			if(db_arr[bg_b][5] == oper && oper[0] == 0) // R --> R || IF --> IF || R --> IF || IF --> R
				delay = extra_delay + TRTP + TRP + TRCD;

			else if(db_arr[bg_b][5] == oper && oper[0] == 1) // W --> W
				delay = extra_delay + TWR + TRP + TRCD;

			else if(db_arr[bg_b][5] == 1 && oper[0] == 0) 	// W --> R || W --> IF
				delay = extra_delay + TWR + TRP + TRCD;

			else if(db_arr[bg_b][5][0] == 0 && oper[0] == 1) 	// R --> W || IF --> W
				delay = extra_delay + TRTP + TRP + TRCD;
		    end else if(db_arr[bg_b][2] == row && db_arr[bg_b][3] != col) begin // COL number mismatch
			delay = extra_delay + TCCD_L;
		    end else if(db_arr[bg_b][2] == row && db_arr[bg_b][3] == col) begin 
			delay = extra_delay + TCCD_L;
		    end
		end 
		$display("extra_delay = %0d, delay = %0d", extra_delay, delay);
		return(delay);
	end
  endfunction
  //function int calc_time(int bg, int b, int bg_b, int row, int col, int oper, int first);
  //      return(100);
  //endfunction
	/*	//if(db_arr[bg_b][0] == 0)begin
		arr = {bg, b, row, col, oper};
		if(arr[4][0] == 0 && oper[0] == 0) // (R --> R || R --> IF || IF --> IF || IF --> R)
		  if(arr[0] != bg)begin
			if(db_arr[bg_b][0] == -1)
				return(TRP + TRTP + TRCD + TRRD_S + TCCD_S);
			else if(db_arr[bg_b][0] == 0)
				return(TRCD + TRRD_S + TCCD_S);			//48+8+8 = 64
		  end else if (arr[0] == bg && arr[1] != b)begin
			if(db_arr[bg_b][0] == -1)
				return(TRP + TRTP + TRCD + TRRD_L + TCCD_L);
			else if(db_arr[bg_b][0] == 0)
				return(TRCD + TRRD_L + TCCD_L);			//48+12+16 = 76
		  end else if (arr[0] == bg && arr[1] == b && arr[2] != row)begin
			if(db_arr[bg_b][0] == -1)
				return(TRTP + TRP + TRCD + TRRD_L + TCCD_L);
			else if(db_arr[bg_b][0] == 0)
				return(TRTP + TRP + TRCD + TRRD_L + TCCD_L); 	//24+48+48+12+16 = 148	//DEAD
		  end else if (arr[0] == bg && arr[1] == b && arr[2] == row && arr[3] != col)begin	//DEAD 
			if(db_arr[bg_b][0] == -1)
				return(TCCD_L);
			else if(db_arr[bg_b][0] == 0)
				return(TCCD_L); 				//16
		  end else if (arr[0] == bg && arr[1] == b && arr[2] == row && arr[3] == col)begin
			if(db_arr[bg_b][0] == -1)
				return(2);
			else if(db_arr[bg_b][0] == 0)
				return(2);					//2
		  end
		end 

		else if (arr[4] == 1 && oper == 1)begin 		// W --> W
		  if(arr[0] != bg)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TRCD + TRRD_S + TCCD_S);			//48+8+8 = 64
		  end else if (arr[0] == bg && arr[1] != b)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TRCD + TRRD_L + TCCD_L);			//48+12+16 = 76
		  end else if (arr[0] == bg && arr[1] == b && arr[2] != row)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TRTP + TRP + TRCD + TRRD_L + TCCD_L); 	//24+48+48+12+16 = 148
		  end else if (arr[0] == bg && arr[1] == b && arr[2] == row && arr[3] != col)begin 
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TCCD_L); 				//16
		  end else if (arr[0] == bg && arr[1] == b && arr[2] == row && arr[3] == col)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(2);					//2
		  end
		end

		else if (arr[4] == 1 && oper[0] == 0) begin		// W --> R/IF
		  if(arr[0] != bg)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TRCD + TRRD_S + TCCD_S + TWTR_S);			//48+8+8 = 64
		  end else if (arr[0] == bg && arr[1] != b)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TRCD + TRRD_L + TCCD_L + TWTR_L);			//48+12+16 = 76
		  end else if (arr[0] == bg && arr[1] == b && arr[2] != row)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TRTP + TRP + TRCD + TRRD_L + TCCD_L); 	//24+48+48+12+16 = 148
		  end else if (arr[0] == bg && arr[1] == b && arr[2] == row && arr[3] != col)begin 
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(TCCD_L); 				//16
		  end else if (arr[0] == bg && arr[1] == b && arr[2] == row && arr[3] == col)begin
			if(db_arr[bg_b][0] == -1)
				return();
			else if(db_arr[bg_b][0] == 0)
				return(2);					//2
		  end
		end*/


  task automatic calc_valid_time(int local_oper, bit [32:0] local_addr, int q_ref);

     bit [1:0] BG, B;
     bit [3:0] BG_B; 				
     BG = local_addr[7:6];
     B  = local_addr[9:8];
     BG_B = {BG,B};				//BG_B = '{local_addr[7:6],local_addr[9:8]}; 	
     $display("Start scheduling @%0d for %h : BG=%0d B=%0d R=%0d C=%0d oper=%0d",sim_time,local_addr, BG, B, local_addr[32:18], local_addr[17:10], local_oper);
     db_arr[BG_B][1] = calc_time(BG, B, BG_B, local_addr[32:18], local_addr[17:10], local_oper, first_ip_in_q_serviced) ; // BG 
     db_arr[BG_B][0] = 1 ;			//VALID = 1
     db_arr[BG_B][2] = local_addr[32:18];	//ROW number
     db_arr[BG_B][3] = local_addr[17:10];	//COL number
     db_arr[BG_B][4] = q_ref;			//Q position
     db_arr[BG_B][5] = local_oper;		//operation 0-R; 1-W; 2-IF
     first_ip_in_q_serviced = 1;
  endtask


  //task add_to_mc_q(int i); 
  //      //longint unsigned temp_time;
  //      repeat(i) begin
  //      	q_mc.push_back(q_ip_time_next.pop_front());
  //      	$display("debug5: reached here");
  //      	q_remove.push_back(sim_time);
  //      end
  //      if (debug_en)
  //      	$display(">>>>>>>>Adding to queue...");
  //      display_q;
  //endtask


  task add_to_pending_q(int i);
        //longint unsigned temp_time;
	$display("q_ip_time_next = %p", q_ip_time_next);
	$display("q_ip_addr_next = %p", q_ip_addr_next);
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

  int bgb; 

  //ADAPTIVE SCHEDULING
  //always@(sim_time)begin
  //      for(int i=0; i<q_pending_addr.size(); i++)begin
  //      	bgb = q_pending_addr[i][]
  //      	if(q_pending_addr[i][])
  //      end
  //end 

 
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
		$display("REMOVE FROM MC QUEUE @%0d %p",sim_time,q_mc);
		update_db(db_arr[i][4]);
	    end
	    if(db_arr[i][1] > 0 ) db_arr[i][1]--;
	end
  end

  initial begin 
        //$monitor("DB_ARR = %p",db_arr);
  end


  initial begin
	#50000 $finish; 
  end

  //always @(sim_time) begin
  //      if( (last_ip==0 && q_ip_time_next.size()>0) || (last_ip==1 && q_ip_time_next.size()>0) )begin
  //          if(q_ip_time_next[0] <= sim_time && q_mc.size()<16 && q_mc.size()>0)begin
  //      	if(q_mc.size() + q_ip_time_next.size() <= 16)begin
  //      		//add q_ip_time_next all to q_mc
  //      		size_ip_q = q_ip_time_next.size();
  //      		add_to_mc_q(size_ip_q);
  //      	end else begin
  //      		size_ip_q = 16 - q_mc.size() ;
  //      		add_to_mc_q(size_ip_q);
  //      	end
  //          end else if(q_mc.size() == 0) begin
  //      	sim_time = q_ip_time_next[0];
  //      	size_ip_q = q_ip_time_next.size();
  //      	add_to_mc_q(size_ip_q);
  //          end
  //      end else if (last_ip == 1 && q_ip_time_next.size() ==0) begin
  //      	//finish the simulation after 100 clock cycles
  //      	//if(sim_time == last + 101) begin
  //      	if(sim_time == 64'd1000000000000000 + 101) begin
  //              	$display("Simulation ends here.");
  //                      $display("Simulation Time = %0d", sim_time);
  //                      $finish;
  //              end
  //      end
  //end

  //always @ (sim_time) begin
  //        if(q_remove.size() >0) begin
  //      	  removed = 0;
  //                repeat(4)
  //                if(q_remove[0]+100 == sim_time)begin
  //      		  removed = 1;
  //                        //if(debug_en == 1)
  //                        //        $display("<<< Remove %h from the queue at time %0d", q_mc[0], sim_time);
  //                        q_mc.pop_front();
  //                        q_remove.pop_front();
  //                        //if(debug_en)
  //                        //        display_q;
  //                end
  //      	  if(debug_en)
  //      	    if(removed) begin
  //      		$display("<<<<<<<<Removing from the queue..");
  //      		display_q;
  //      	    end
  //        end
  //end


endmodule
