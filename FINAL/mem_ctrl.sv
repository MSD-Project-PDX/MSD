module mem_ctrl;
  int ip;
  longint t, inst, addr;
  logic [34:0] q_mc[$:15];
  longint unsigned q_remove[$:15];
  longint q_ip_time_next [$:3];
  int q_ip_inst_next [$:3];
  int q_ip_addr_next [$:3];

  bit first_ip=1, last_ip=0;
  int size_ip_q;
  longint unsigned sim_time;
  bit q_full;

  int removed;

  always #1 sim_time++;

  always @ (sim_time) begin
    if(q_mc.size() == 16) q_full = 1;
    else q_full = 0;
  end

  string ip_file;
  int debug_en;

  initial begin
	$value$plusargs("ip_file=%s", ip_file);
	$value$plusargs("debug_en=%d", debug_en);
  end

  initial begin
	ip = $fopen(ip_file, "r");

	while(!$feof(ip)) begin
		$fscanf(ip, "%d %d %h", t, inst, addr);
		if(t==q_ip_time_next[0] || first_ip==1)begin
			q_ip_time_next.push_back(t);
			q_ip_inst_next.push_back(inst);
			q_ip_addr_next.push_back(addr);
		end else begin
                    size_ip_q = q_ip_time_next.size();
                    fork
		    for(int i=0; i<size_ip_q; i++) begin
			//$display("disp --> %d %d %h", q_ip_time_next.pop_front(), q_ip_inst_next.pop_front(), q_ip_addr_next.pop_front());
			wait(!q_full);
			//$display("disp --> %d %d %h", q_ip_time_next[i], q_ip_inst_next[i], q_ip_addr_next[i]);
		    end
		    join
		    //$display("\n\n\n");
                    wait(q_ip_time_next.size()==0);
		    q_ip_time_next.delete();
		    q_ip_inst_next.delete();
		    q_ip_addr_next.delete();
		    q_ip_time_next.push_back(t);
		    q_ip_inst_next.push_back(inst);
		    q_ip_addr_next.push_back(addr);
		end
		first_ip=0;
	end
	//last set of inputs
        size_ip_q = q_ip_time_next.size();
	fork
	for(int i=0; i<size_ip_q; i++) begin
		//$display("disp --> %d %d %h", q_ip_time_next.pop_front(), q_ip_inst_next.pop_front(), q_ip_addr_next.pop_front());
		wait(!q_full);
		//$display("disp --> %d %d %h", q_ip_time_next[i], q_ip_inst_next[i], q_ip_addr_next[i]);
	end
	join
	//$display("\n\n\n");
	last_ip = 1;
  end

  task add_to_mc_q(int i); 
	repeat(i) begin
		q_mc.push_back(q_ip_time_next.pop_front());
		q_remove.push_back(sim_time);
	end
	if (debug_en)
		$display(">>>>>>>>Adding to queue...");
	display_q;
  endtask

  task display_q;
     if(debug_en) begin
	$display("MC QUEUE @%0d SIZE=%0d q_mc = %p\n\n", sim_time, q_mc.size(), q_mc);
     end
  endtask

  always @(sim_time) begin
	if( (last_ip==0 && q_ip_time_next.size()>0) || (last_ip==1 && q_ip_time_next.size()>0) )begin
	    if(q_ip_time_next[0] <= sim_time && q_mc.size()<16 && q_mc.size()>0)begin
		if(q_mc.size() + q_ip_time_next.size() <= 16)begin
			//add q_ip_time_next all to q_mc
			size_ip_q = q_ip_time_next.size();
			add_to_mc_q(size_ip_q);
		end else begin
			size_ip_q = 16 - q_mc.size() ;
			add_to_mc_q(size_ip_q);
		end
	    end else if(q_mc.size() == 0) begin
		sim_time = q_ip_time_next[0];
		size_ip_q = q_ip_time_next.size();
		add_to_mc_q(size_ip_q);
	    end
	end else if (last_ip == 1 && q_ip_time_next.size() ==0) begin
		//finish tge simulation after 100 clock cycles
        	//if(sim_time == last + 101) begin
        	if(sim_time == 64'd1000000000000000 + 101) begin
                	$display("Simulation ends here.");
                        $display("Simulation Time = %0d", sim_time);
                        $finish;
                end
	end
  end

  always @ (sim_time) begin
          if(q_remove.size() >0) begin
		  removed = 0;
                  repeat(4)
                  if(q_remove[0]+100 == sim_time)begin
			  removed = 1;
                          //if(debug_en == 1)
                          //        $display("<<< Remove %h from the queue at time %0d", q_mc[0], sim_time);
                          q_mc.pop_front();
                          q_remove.pop_front();
                          //if(debug_en)
                          //        display_q;
                  end
		  if(debug_en)
		    if(removed) begin
			$display("<<<<<<<<Removing from the queue..");
			display_q;
		    end
          end
  end


endmodule