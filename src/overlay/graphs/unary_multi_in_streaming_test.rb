
$unary_multi_in_test_graph = {}

##

num_msgs = $PARAMS[:num_tiles] ? $PARAMS[:num_tiles] : 8
msg_size = $PARAMS[:tile_size] ? $PARAMS[:tile_size] :(1024 * 2) + 16 + 16

num_input0_data_buf_msgs =  $PARAMS[:num_input0_data_buf_msgs] ?  $PARAMS[:num_input0_data_buf_msgs] : num_msgs;
input0_data_buf_msg_size =  $PARAMS[:input0_data_buf_tile_size] ?  $PARAMS[:input0_data_buf_tile_size] : msg_size;
input0_data_buf_size = num_input0_data_buf_msgs*input0_data_buf_msg_size

num_input1_data_buf_msgs =  $PARAMS[:num_input1_data_buf_msgs] ?  $PARAMS[:num_input1_data_buf_msgs] : num_msgs;
input1_data_buf_msg_size =  $PARAMS[:input1_data_buf_tile_size] ?  $PARAMS[:input1_data_buf_tile_size] : msg_size;
input1_data_buf_size = num_input1_data_buf_msgs*input1_data_buf_msg_size

num_input2_data_buf_msgs =  $PARAMS[:num_input2_data_buf_msgs] ?  $PARAMS[:num_input2_data_buf_msgs] : num_msgs;
input2_data_buf_msg_size =  $PARAMS[:input2_data_buf_tile_size] ?  $PARAMS[:input2_data_buf_tile_size] : msg_size;
input2_data_buf_size = num_input2_data_buf_msgs*input2_data_buf_msg_size

num_input3_data_buf_msgs =  $PARAMS[:num_input3_data_buf_msgs] ?  $PARAMS[:num_input3_data_buf_msgs] : num_msgs;
input3_data_buf_msg_size =  $PARAMS[:input3_data_buf_tile_size] ?  $PARAMS[:input3_data_buf_tile_size] : msg_size;
input3_data_buf_size = num_input3_data_buf_msgs*input3_data_buf_msg_size

num_output0_data_buf_msgs =  $PARAMS[:num_output0_data_buf_msgs] ?  $PARAMS[:num_output0_data_buf_msgs] : num_msgs;
output0_data_buf_msg_size =  $PARAMS[:output0_data_buf_tile_size] ?  $PARAMS[:output0_data_buf_tile_size] : msg_size;
output0_data_buf_size = num_output0_data_buf_msgs*output0_data_buf_msg_size

data_buffer_space_base = $PARAMS[:data_buffer_space_base] + $extra_tile_header_buffer_size
input0_data_base = $PARAMS[:input0_data_base] ? $PARAMS[:input0_data_base] : data_buffer_space_base;
input1_data_base = $PARAMS[:input1_data_base] ? $PARAMS[:input1_data_base] : input0_data_base + (128 * 1024);
input2_data_base = $PARAMS[:input1_data_base] ? $PARAMS[:input1_data_base] : input1_data_base + (128 * 1024);
input3_data_base = $PARAMS[:input1_data_base] ? $PARAMS[:input1_data_base] : input2_data_base + (128 * 1024);
test_data_offset = $PARAMS[:test_data_offset] ? $PARAMS[:test_data_offset] : (64 * 1024)
output0_data_base = $PARAMS[:output0_data_base] ? $PARAMS[:output0_data_base] : (data_buffer_space_base + (512 * 1024));

input0_data_stream_id = $PARAMS[:input0_data_stream_id] ? $PARAMS[:input0_data_stream_id] : $PARAMS[:chip] == "grayskull" ? 8 : 4
input1_data_stream_id = $PARAMS[:input1_data_stream_id] ? $PARAMS[:input1_data_stream_id] : $PARAMS[:chip] == "grayskull" ? 9 : 5
input2_data_stream_id = $PARAMS[:input2_data_stream_id] ? $PARAMS[:input2_data_stream_id] : 10
input3_data_stream_id = $PARAMS[:input3_data_stream_id] ? $PARAMS[:input3_data_stream_id] : 11
output0_stream_id = $PARAMS[:output0_stream_id] ? $PARAMS[:output0_stream_id] : 24

output0_num_microblocks = $PARAMS[:output0_num_microblocks] ? $PARAMS[:output0_num_microblocks] : num_output0_data_buf_msgs;
output0_double_buffered = false
output0_no_resend = true
##

num_phases = 1

msg_info_buf_size = num_msgs*16

chip_id = 0
x = 0
y = 0

input0_data_stream = :"chip_#{chip_id}__y_#{y}__x_#{x}__stream_id_#{input0_data_stream_id}"
input1_data_stream = :"chip_#{chip_id}__y_#{y}__x_#{x}__stream_id_#{input1_data_stream_id}"
input2_data_stream = :"chip_#{chip_id}__y_#{y}__x_#{x}__stream_id_#{input2_data_stream_id}"
input3_data_stream = :"chip_#{chip_id}__y_#{y}__x_#{x}__stream_id_#{input3_data_stream_id}"
output0_stream = :"chip_#{chip_id}__y_#{y}__x_#{x}__stream_id_#{output0_stream_id}"

start_seed_0 = 0xa0000000
start_seed_1 = 0xb0000000

for p in 1..num_phases

  phase = :"phase_#{p}"

  $unary_multi_in_test_graph[phase] = {}

  buf_addr = input0_data_base

  $unary_multi_in_test_graph[phase][input0_data_stream] = {
    :input_index => 0,
    :auto_run => true,
    :buf_addr => buf_addr,
    :buf_size => input0_data_buf_size,
    :msg_info_buf_addr => buf_addr + input0_data_buf_size,
    :dest => [],
    :source_endpoint => true,  
    :receiver_endpoint => $PARAMS[:chip] == "grayskull"? false : true ,
    :local_receiver => $PARAMS[:chip] == "grayskull"? true : false,
    :local_receiver_tile_clearing => $PARAMS[:chip] == "grayskull"? true : false,  
    :num_msgs => num_input0_data_buf_msgs,
    :msg_size => input0_data_buf_msg_size,
    :legacy_pack => true,
    :next_phase_src_change => true,
    :reg_update_vc => 1
  }

  buf_addr = input1_data_base

  $unary_multi_in_test_graph[phase][input1_data_stream] = {
    :input_index => 1,
    :auto_run => true,
    :buf_addr => buf_addr,
    :buf_size => input1_data_buf_size,
    :msg_info_buf_addr => buf_addr + input1_data_buf_size,
    :dest => [],
    :source_endpoint => true,  
    :receiver_endpoint => $PARAMS[:chip] == "grayskull"? false : true ,
    :local_receiver => $PARAMS[:chip] == "grayskull"? true : false,
    :local_receiver_tile_clearing => $PARAMS[:chip] == "grayskull"? true : false,  
    :num_msgs => num_input1_data_buf_msgs,
    :msg_size => input1_data_buf_msg_size,
    :legacy_pack => true,
    :next_phase_src_change => true,
    :reg_update_vc => 1
  }

  buf_addr = input2_data_base

  $unary_multi_in_test_graph[phase][input2_data_stream] = {
    :input_index => 2,
    :auto_run => true,
    :buf_addr => buf_addr,
    :buf_size => input2_data_buf_size,
    :msg_info_buf_addr => buf_addr + input2_data_buf_size,
    :dest => [],
    :source_endpoint => true,  
    :receiver_endpoint => $PARAMS[:chip] == "grayskull"? false : true ,
    :local_receiver => $PARAMS[:chip] == "grayskull"? true : false,
    :local_receiver_tile_clearing => $PARAMS[:chip] == "grayskull"? true : false,  
    :num_msgs => num_input2_data_buf_msgs,
    :msg_size => input2_data_buf_msg_size,
    :legacy_pack => true,
    :next_phase_src_change => true,
    :reg_update_vc => 1
  }

  buf_addr = input3_data_base

  $unary_multi_in_test_graph[phase][input3_data_stream] = {
    :input_index => 3,
    :auto_run => true,
    :buf_addr => buf_addr,
    :buf_size => input3_data_buf_size,
    :msg_info_buf_addr => buf_addr + input3_data_buf_size,
    :dest => [],
    :source_endpoint => true,  
    :receiver_endpoint => $PARAMS[:chip] == "grayskull"? false : true ,
    :local_receiver => $PARAMS[:chip] == "grayskull"? true : false,
    :local_receiver_tile_clearing => $PARAMS[:chip] == "grayskull"? true : false,   
    :num_msgs => num_input3_data_buf_msgs,
    :msg_size => input3_data_buf_msg_size,
    :next_phase_src_change => true,
    :legacy_pack => true,
    :reg_update_vc => 1
  }

end

num_phases = output0_double_buffered ? 2*output0_num_microblocks : output0_num_microblocks
num_msgs_per_phase = num_output0_data_buf_msgs / num_phases
buf_addr = output0_data_base
buf_size = num_msgs_per_phase * output0_data_buf_msg_size
num_microblocks_in_buf = output0_data_buf_size / buf_size

for p in 1..num_phases

  phase = :"phase_#{p}"

  if !$unary_multi_in_test_graph[phase]
    $unary_multi_in_test_graph[phase] = {}
  end

  resend = output0_no_resend ? false : (((p-1) % num_microblocks_in_buf) == 0 ? false : true)

  $unary_multi_in_test_graph[phase][output0_stream] = {
    :output_index => 0,
    :auto_run => true,
    :buf_addr => buf_addr,
    :buf_size => buf_size,
    :msg_info_buf_addr => buf_addr + output0_data_buf_size,
    :vc => 0,
    :dest => [],
    :num_msgs_in_block => output0_no_resend ? num_msgs_per_phase : num_msgs_per_phase * num_microblocks_in_buf,
    :num_msgs => num_msgs_per_phase,
    :msg_size => output0_data_buf_msg_size,
    :buf_full_size_bytes => num_microblocks_in_buf*buf_size,
    :source_endpoint => true,
    :receiver_endpoint => true,
    :outgoing_data_noc => 1,
#    :preload_data => (0..(output0_data_buf_size/msg_size)-1).map { |i| (start_seed_1 + (i << 16)) },
    :resend => resend,
    :dest_data_buf_no_flow_ctrl => false,
    :next_phase_src_change => true
  }

  buf_addr += buf_size
  if (buf_addr >= output0_data_base + output0_data_buf_size)
    buf_addr -= output0_data_buf_size
  end

end




