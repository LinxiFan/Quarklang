open Semantic

let _ =
  (* from http://rosettacode.org/wiki/Command-line_arguments#OCaml *)
  let srcfile = ref "" and outfile = ref "" in
  let speclist = [
      ("-s", Arg.String(fun src -> 
              let srclen = String.length src in
              if Sys.file_exists src then
                let ext = Preprocessor.extension in (* enforce .qk extension *)
                let extlen = String.length ext in
                if srclen > extlen && 
                  String.sub src (srclen - extlen) extlen = ext then
                  srcfile := src
                else
                  failwith @@ "Quark source file must have extension " ^ ext
              else
                failwith @@ "Source file doesn't exist: " ^ src),
        ": quark source file");

      ("-o", Arg.String(fun out -> outfile := out), 
        ": output C++ file. If unspecified, the generated code will print to stdout");
  ] in
  let usage = "usage: quarkc -s source.qk [-o output.cpp]" in
  let _ = Arg.parse speclist
    (* handle anonymous args *)
    (fun arg -> failwith @@ "Unrecognized arg: " ^ arg)
    usage
  in
  let _ = if !srcfile = "" then
      failwith "Please specify a source file with option -s"
  in
  (* Preprocessor: handles import and elif *)
  let processed_code = Preprocessor.process !srcfile in
  (* Scanner: converts processed code to stream of tokens *)
    (* let lexbuf = Lexing.from_channel stdin in *)
  let lexbuf = Lexing.from_string processed_code in
  (* Parser: converts scanned tokens to AST *)
  let ast = Parser.top_level Scanner.token lexbuf in
  (* Semantic checker: verifies and converts AST to SAST  *)
  let env = { 
    var_table = StrMap.empty; 
    func_table = StrMap.empty;
    func_current = "";
    depth = 0;
    is_returned = true;
    in_loop = false;
  } in 
  let _, sast = Semantic.gen_sast env ast in
  (* Code generator: converts SAST to C++ code *)
  let code = Generator.gen_code sast in
  let code = Generator.header_code ^ code in
  (* Output *)
  if !outfile = "" then (* print to stdout *)
    print_endline code
  else
    output_string (open_out !outfile) code