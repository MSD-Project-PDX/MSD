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

	//while(!$feof(ip)) begin
	while(f_end==0) begin
		$fscanf(ip, "%d %d %h", t, inst, addr);
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
		first_ip=0;
		f_end = $feof(ip);
		if(f_end == 1)begin
			q_ip_time_next.delete(q_ip_time_next.size()-1);
			q_ip_oper_next.delete(q_ip_oper_next.size()-1);
			q_ip_addr_next.delete(q_ip_addr_next.size()-1);
		end
	end
	//last set of inputs
        size_ip_q = q_ip_time_next.size();
	wait(!q_pending_full);
	last_ip = 1;
  end


  int db_arr[16][5]; //R C valid_time

  function int calc_time(int BG, int B, int BG_B, int R, int oper);
	if(db_arr[BG_B][0] == 1)begin
		if(db_arr[BG_B][2] == R)
			return(100); //RD
		else
			return(100); //PRE + ACT + RD
	end else begin
		return (100); 	//ACT + RD
	end
  endfunction



  /*task automatic calc_valid_time(int local_oper, bit [32:0] local_addr, int q_ref);

     int flag = 0;
     bit [1:0] BG, B;
     bit [3:0] BG_B; 				
     BG = local_addr[7:6];
     B  = local_addr[9:8];
     BG_B = {BG,B};				//BG_B = '{local_addr[7:6],local_addr[9:8]}; 	

     //$display("BEFORE FLAG @%0d BG=%0d, B=%0d",sim_time, BG, B);

     if(db_arr[BG_B][0] == 1)begin
	//$display("BEFORE WAIT @%0d BG=%0d, B=%0d",sim_time, BG, B);
	wait(db_arr[BG_B][0]==0);
	//$display("AFTER WAIT @%0d BG=%0d, B=%0d",sim_time, BG, B);
	flag = 1;
     end else begin
	flag = 1;
     end
    
     //$display("AFTER FLAG @%0d BG=%0d, B=%0d",sim_time, BG, B);

     if(flag == 1)begin
	db_arr[BG_B][1] = calc_time(BG, B, BG_B, db_arr[BG_B][1], local_oper) ;
	db_arr[BG_B][0] = 1 ;			//VALID = 1
	db_arr[BG_B][2] = local_addr[32:18];	//ROW number
	db_arr[BG_B][3] = local_addr[17:10];	//COL number
	db_arr[BG_B][4] = q_ref;	//Q position
     end
  endtask*/


  task automatic calc_valid_time(int local_oper, bit [32:0] local_addr, int q_ref);

     int flag = 1;
     bit [1:0] BG, B;
     bit [3:0] BG_B; 				
     BG = local_addr[7:6];
     B  = local_addr[9:8];
     BG_B = {BG,B};				//BG_B = '{local_addr[7:6],local_addr[9:8]}; 	

     //$display("BEFORE FLAG @%0d BG=%0d, B=%0d",sim_time, BG, B);

     //if(db_arr[BG_B][0] == 1)begin
     //   //$display("BEFORE WAIT @%0d BG=%0d, B=%0d",sim_time, BG, B);
     //   wait(db_arr[BG_B][0]==0);
     //   //$display("AFTER WAIT @%0d BG=%0d, B=%0d",sim_time, BG, B);
     //   flag = 1;
     //end else begin
     //   flag = 1;
     //end
   

     //if (db_arr[BG_B][0]==0) flag=1; 
     //$display("AFTER FLAG @%0d BG=%0d, B=%0d",sim_time, BG, B);

     if(flag == 1)begin
	db_arr[BG_B][1] = calc_time(BG, B, BG_B, db_arr[BG_B][1], local_oper) ;
	db_arr[BG_B][0] = 1 ;			//VALID = 1
	db_arr[BG_B][2] = local_addr[32:18];	//ROW number
	db_arr[BG_B][3] = local_addr[17:10];	//COL number
	db_arr[BG_B][4] = q_ref;	//Q position
     end
  endtask


  //task add_to_mc_q(int i); 
  //      //longint unsigned temp_time;
  //      repeat(i) begin
  //      	q_mc.push_back(q_ip_time_next.pop_front());
  //      	$display("debug5: reached here");
  //      	//calc_valid_time(q_ip_oper_next.pop_front(), q_ip_addr_next.pop_front());
  //      	q_remove.push_back(sim_time);
  //      end
  //      if (debug_en)
  //      	$display(">>>>>>>>Adding to queue...");
  //      display_q;
  //endtask


  task add_to_pending_q(int i); 
        //longint unsigned temp_time;
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
 
  
  int q_reference;

  //MC Queue implemenation (Pending Q ---> MC Q)
  always@(sim_time)begin
	if(q_mc.size() < 16) begin
          if(q_pending_time.size()>0)begin
	    q_mc.push_back(q_pending_time.pop_front());
	    q_mc_oper.push_back(q_pending_oper.pop_front());
	    q_mc_addr.push_back(q_pending_addr.pop_front());
	    //q_reference = q_mc.size() - 1;
	    //fork
	    //	calc_valid_time(q_pending_oper.pop_front(), q_pending_addr.pop_front(), q_reference);
	    //join_none
	    //q_remove.push_back()
	    if (debug_en)
	    	$display(">>>>>>>>Adding to MC queue...");
	    display_q;
	  end
	end
  end 

  always@(sim_time) begin
	for(int i=0; i<q_mc.size(); i++)begin
	    if( db_arr[{q_mc_addr[i][7:6],q_mc_addr[i][9:8]}][0] == 0)begin		//Checking for VALID set
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
	    	db_arr[i][0] = 0;
	    end

	    if(db_arr[i][4] > a && db_arr[i][4] >0)
		db_arr[i][4] = db_arr[i][4]-1;
	  end
	end
  endtask

  //REMOVE FROM MC Q
  always@(sim_time) begin
	for(int i=0; i<16; i++)begin
	    if(db_arr[i][1] == 1) begin
		q_mc.delete(db_arr[i][4]);
		$display("REMOVE FROM MC QUEUE @%0d %p",sim_time,q_mc);
		update_db(db_arr[i][4]);
	    end
	    if(db_arr[i][1] > 0 ) db_arr[i][1]--;
	end
  end

  initial begin 
        $monitor("DB_ARR = %p",db_arr);
  end


  initial begin
	#500 $finish; 
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
