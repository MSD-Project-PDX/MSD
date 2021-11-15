module mem_con;

	int ip1, ip2, ip3;		//file pointers for input files
	longint unsigned q_ip_time[$];	//input queue for request time
	int q_ip_oper[$];		//input queue for operation
	logic [32:0] q_ip_addr[$];	//input queue for address
	longint unsigned str;		//string to store the contents of the file

	logic [34:0] q_mc[$:15], local_var;	//q_mc -> [34:33] operation; [32:0] address
	longint unsigned sim_time, last, remove[$];
	//Simulation time, last (to complete the last transfer), remove (queue to store the request time)
	// Max value = 18446744073709551615
	int s, a, count;
	int debug_en;

	initial $value$plusargs("debug_en=%d", debug_en);
	always begin
		#1 sim_time++;
	end

	initial begin
		ip1 = $fopen("ip_time.txt", "r");
		ip2 = $fopen("ip_oper.txt", "r");
		ip3 = $fopen("ip_addr.txt", "r");
		while(!$feof(ip1))begin
			$fscanf(ip1, "%d", str);
			q_ip_time.push_back(str);
			$fscanf(ip2, "%d", str);
			q_ip_oper.push_back(str);
			$fscanf(ip3, "%h", str);
			q_ip_addr.push_back(str);
		end
		q_ip_time.pop_back();
		q_ip_oper.pop_back();
		q_ip_addr.pop_back();

		$fclose(ip1);
		$fclose(ip2);
		$fclose(ip3);
	end

	task add_to_mc_q;
		local_var = {q_ip_oper.pop_front(), q_ip_addr.pop_front()};
		if(debug_en)
			$display(">>> Adding new element to the queue.. %h ... at sim_time = %0d --> q_mc.size = %0d\n", local_var, sim_time, q_mc.size()+1);
		q_mc.push_back(local_var);
		remove.push_back(sim_time);
		q_ip_time.pop_front();
		last = sim_time;
	endtask

	task display_q;
		$write("MEMORY_CONTROLLER Q: ");
		for(int i=0; i<q_mc.size(); i++)begin
			$write("%h ", q_mc[i]);
		end
		$write("\n\n");
	endtask
	always @ (sim_time) begin
		if(q_ip_time.size() != 0)begin

			s = q_ip_time.size();
			count = 1;
			a = 0;
			repeat ((s >= 4)?3:s-1) begin
				if(q_ip_time[a] == q_ip_time[a+1])begin
					count++;
					a++;
				end else break;
			end

			if((q_ip_time[0] == sim_time || q_ip_time[0] < sim_time) && q_mc.size()<16 && q_mc.size()>0)begin
				repeat((q_mc.size()+count<=16)? count :((q_mc.size()+count-1<=16) ? count-1: ((q_mc.size()+count-2<=16) ? count-2 : count-3 )))
					add_to_mc_q;
			end else if (q_mc.size() == 0) begin
				sim_time = q_ip_time[0];
				repeat(count)
					add_to_mc_q;
			end
		end else begin
			//simulation end after 101 cycles
			if(sim_time == last + 101) begin
				$display("Simulation ends here.");
				$display("Simulation Time = %0d", sim_time);
				$finish;
			end
		end
	end

	always @ (sim_time) begin
		if(remove.size() >0) begin
			repeat(4)
			if(remove[0]+100 == sim_time)begin
				if(debug_en == 1)
					$display("<<< Remove %h from the queue at time %0d", q_mc[0], sim_time);
				q_mc.pop_front();
				remove.pop_front();
				if(debug_en)
					display_q;
			end
		end
	end
endmodule
