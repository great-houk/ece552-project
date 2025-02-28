module reduction_unit(input [15:0] rs, input [15:0] rt, output [15:0] rd);

wire [4:0] out_ae; 
wire [3:0] out_ae_raw;
wire ae_ovfl;
wire cla_ae_out;


wire [4:0] out_bf; 
wire [3:0] out_bf_raw;
wire bf_ovfl;
wire cla_bf_out;


wire [4:0] out_cg; 
wire [3:0] out_cg_raw;
wire cg_ovfl;
wire cla_cg_out;


wire [4:0] out_dh; 
wire [3:0] out_dh_raw;
wire dh_ovfl;
wire cla_dh_out;


wire [5:0] cla_out_aebf;
wire [5:0] cla_out_cgdh;


wire [4:0] carry;
wire [4:0] Sum;

addsub_4bit ae(.A(rs[15:12]), .B(rt[15:12]), .Sum(out_ae_raw), .Ovfl(ae_ovfl), .sub(1'b0));
addsub_4bit bf(.A(rs[11:8]), .B(rt[11:8]), .Sum(out_bf_raw), .Ovfl(bf_ovfl), .sub(1'b0));
addsub_4bit cg(.A(rs[7:4]), .B(rt[7:4]), .Sum(out_cg_raw), .Ovfl(cg_ovfl), .sub(1'b0));
addsub_4bit dh(.A(rs[3:0]), .B(rt[3:0]), .Sum(out_dh_raw), .Ovfl(dh_ovfl), .sub(1'b0));

assign out_ae = {ae_ovfl, out_ae_raw[3:0]};
assign out_bf = {bf_ovfl, out_bf_raw[3:0]};
assign out_cg = {cg_ovfl, out_cg_raw[3:0]};
assign out_dh = {dh_ovfl, out_dh_raw[3:0]};




///////////CLA implementation///////////
cla_4bit cla1(.a(out_ae[3:0]), .b(out_bf[3:0]), .cin(1'b0), .sum(cla_out_aebf[3:0]), .cout(cla_ae_out));
cla_4bit cla2(.a({3'b0, bf_ovfl1}), .b({3'b0, bf_ovf1}), .cin(cla_ae_out) .sum(cla_out_aebf[5:4]), .cout(cla_bf_out));

cla_4bit cla3(.a(out_cg[3:0]), .b(out_dh[3:0]), .cin(1'b0), .sum(cla_out_cgdh[3:0]), .cout(cla_cg_out));
cla_4bit cla4(.a({3'b0, cg_ovfl1}), .b({3'b0, dh_ovf1}), .cin(cla_cg_out) .sum(cla_out_cgdh[5:4]), .cout(cout_dh_temp));



FA iFA0(.A(cla_out_aebf[0]), .B(cla_out_cgdh[0]), .Cin(sub), .S(Sum[0]), .Cout(carry[0]));
FA iFA1(.A(cla_out_aebf[1]), .B(cla_out_cgdh[1]), .Cin(carry[0]), .S(Sum[1]), .Cout(carry[1]));
FA iFA2(.A(cla_out_aebf[2]), .B(cla_out_cgdh[2]), .Cin(carry[1]), .S(Sum[2]), .Cout(carry[2]));
FA iFA3(.A(cla_out_aebf[3]), .B(cla_out_cgdh[3]), .Cin(carry[2]), .S(Sum[3]), .Cout(carry[3]));
//FA iFA4(.A(cla_out_aebf[4]), .B(cla_out_cgdh[4]), .Cin(carry[4]), .S(Sum[4]), .Cout(carry[4]));		//Do we ignore the overflow or no? how big is the output of the clas supposed to be?

assign rd = (Sum[3]) ? ({12'b1, Sum[3:0]}):({12'b0, Sum[3:0]});



endmodule