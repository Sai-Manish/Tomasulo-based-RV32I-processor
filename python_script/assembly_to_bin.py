from riscv_assembler.convert import AssemblyConverter
cnv = AssemblyConverter(output_type = "t") # gives txt file format
cnv.convert("test1.s")
